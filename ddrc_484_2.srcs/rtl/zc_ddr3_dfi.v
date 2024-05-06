//Enter passphrase for key "/home/ICer/.ssh/test" : zc20021119

module zc_ddr3_dfi#(
    parameter       DDR_MHZ               = 100   ,
    parameter       DFI_WRITE_LATENCY     = 4     ,
    parameter       DFI_READ_LATENCY      = 4     ,
    parameter       DDR_COL_WIDTH         = 10    ,
    parameter       DDR_ROW_WIDTH         = 14    ,
    parameter       DFI_DATA_WIDTH        = 32    ,
    parameter       DFI_DQM_WIDTH         = 4     ,
    parameter       DFI_BURST_LEN         = 4      //double rate , ddr_BL = 8 , dfi_BL = 4
)(
    input           sys_clk                 ,
    input           sys_rst_n               ,

    input [13:0]    addr_send_i             ,
    input [2:0]     bank_send_i             ,
    input [3:0]     cmd_send_i              ,
    input           cke_send_i              ,
    input           rst_n_send_i            ,

    input [127:0]   inport_wr_data_i        ,
    input [15:0]    inport_wr_data_mask_i   ,

    output          cmd_accept_o            ,
    output [127:0]  inport_rd_data_o        ,
    output          inport_rd_data_vld_o    ,

    output [13:0]   dfi_address_o           ,
    output [2:0]    dfi_bank_o              ,
    output          dfi_cas_n_o             ,
    output          dfi_cke_o               ,
    output          dfi_cs_n_o              ,
    output          dfi_odt_o               ,
    output          dfi_ras_n_o             ,
    output          dfi_reset_n_o           ,
    output          dfi_we_n_o              ,
    output          dfi_rddata_en_o         ,
    input  [31:0]   dfi_rddata_i            ,
    input           dfi_rddata_valid_i      ,
    input  [3:0]    dfi_rddata_dnv_i        ,
    output [31:0]   dfi_wrdata_o            ,
    output          dfi_wrdata_en_o         ,
    output [3:0]    dfi_wrdata_mask_o
);

    //cmd_send_i是当前状态的表征，当前zc_ddr3_core的FSM状态是什么，cmd_send_i就是对应的命令; nex_delay是当前状态的延时，当前状态是什么，nex_delay就表征着当前状态的延时，cur_delay是nex_delay打一拍的结果。

    localparam      tCK_ns   = 1000 / DDR_MHZ                   ;  // 10 ns
    localparam      tRCD     =  (15 + (tCK_ns - 1)) / tCK_ns    ;  //round up to an integer , 15ns -> 20ns = 2 cycles
    localparam      tRP      =  (15 + (tCK_ns - 1)) / tCK_ns    ;  //2 cycles
    localparam      tRFC     =  (300+ (tCK_ns - 1)) / tCK_ns    ;  //30 cycles
    localparam      tWTR     =  6                               ;  
                                                                    //todo:这里设置为6，根据MRS的配置，WR = 16,不过16的时钟周期应该是DDR3的时钟周期，特别说明WR手册里给的解释是write recovery for autoprecharge; 不管是WTR还是WR,都需要保证写进去的数据真正被写入了bank里，所以这里设置了tWTR。
                                                                    //todo Spec P169 : tWTR : for DDR-800, min = max(4nCK , 7.5ns) , there I put the value 6nCK. And till now I am not sure the relationship between the controller's clock domain and the SDRAM's clock domain.  


    localparam      NOP_cmd     =   4'b0111             ;
    localparam      ACT_cmd     =   4'b0011             ;
    localparam      PREC_cmd    =   4'b0010             ;
    localparam      REF_cmd     =   4'b0001             ;
    localparam      MRS_cmd     =   4'b0000             ;
    localparam      ZQCL_cmd    =   4'b0110             ;
    localparam      WRITE_cmd   =   4'b0100             ;
    localparam      READ_cmd    =   4'b0101             ;

    localparam      tPHY_WRLAT  =  DFI_WRITE_LATENCY - 1;
                                                            //todo : DFI Spec : P12 this parameter may be specified as a fixed value , or as a constant based on other fixed values in the system.顶层参数中DFI_WRITE_LATENCY和DFI_READ_LATENCY必须保持为4，否则报错，可能是和github的原作者设置的PHY有关。
    localparam      tRDDATA_EN  =  DFI_READ_LATENCY  - 1;   //todo

    localparam      RW_NONSEQ_CYCLES = DFI_WRITE_LATENCY + DFI_BURST_LEN + tWTR;
    localparam      RW_SEQ_CYCLES    = RW_NONSEQ_CYCLES - DFI_BURST_LEN + 1;

    reg [3:0]                   cmd_accept              ;
    reg [DDR_ROW_WIDTH - 1 : 0] addr_accept             ;
    reg [2:0]                   bank_accept             ;
    reg                         cke_accept              ;
    reg                         rst_n_accept            ;

    reg [8:0]                   cur_delay               ;
    reg [8:0]                   nex_delay               ;

    reg [3:0]                   last_vld_cmd            ;

    wire [127 : 0]              wr_data_w               ;
    wire [15 : 0]               wr_data_mask_w          ;
    wire                        wr_data_fifo_rd_en      ;

    wire                        rd_early_accepted_w     ;
    wire                        wr_early_accepted_w     ;

    assign      rd_early_accepted_w = (last_vld_cmd == READ_cmd && cmd_send_i == READ_cmd && cur_delay == RW_SEQ_CYCLES);
    assign      wr_early_accepted_w = (last_vld_cmd == WRITE_cmd && cmd_send_i == WRITE_cmd && cur_delay == RW_SEQ_CYCLES);

    assign      cmd_accept_o        = (cur_delay == 'd0 || rd_early_accepted_w || wr_early_accepted_w || cmd_send_i == NOP_cmd);


    assign      dfi_address_o       = addr_accept       ;
    assign      dfi_bank_o          = bank_accept       ;
    assign      {dfi_cs_n_o , dfi_ras_n_o , dfi_cas_n_o , dfi_we_n_o} = cmd_accept;
    assign      dfi_cke_o           = cke_accept        ;
    assign      dfi_reset_n_o       = rst_n_accept      ;
    assign      dfi_odt_o           = 1'b0              ;

    zc_sync_fifo#(
        .WIDTH      (   144     ),
        .DEPTH      (   128     )
    )wr_data_fifo_FWFT(
        .sys_clk    (   sys_clk                                        ),
        .sys_rst_n  (   sys_rst_n                                      ),
        .wr_en      (   cmd_send_i == WRITE_cmd && cmd_accept_o        ),
        .wr_data    (   {inport_wr_data_mask_i , inport_wr_data_i}     ),
        .wr_full    (                                                  ),
        .rd_en      (   wr_data_fifo_rd_en                             ),
        .rd_data    (   {wr_data_mask_w , wr_data_w}                   ),
        .rd_empty   (                                                  )
    );


//control dfi interface

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            cmd_accept      <= NOP_cmd  ;
            addr_accept     <= 'd0      ;
            bank_accept     <= 'd0      ;
        end
        else if(cmd_accept_o)begin
            cmd_accept     <= cmd_send_i;
            addr_accept    <= addr_send_i;
            bank_accept    <= bank_send_i;
        end
        else begin
            cmd_accept     <= NOP_cmd    ;
            addr_accept    <= 'd0        ;
            bank_accept    <= 'd0        ;            
        end
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            cke_accept      <= 0;
            rst_n_accept    <= 0;
        end else begin
            cke_accept      <= cke_send_i   ;
            rst_n_accept    <= rst_n_send_i ;
        end
    end

//delay control

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            last_vld_cmd <= NOP_cmd;
        else if(cmd_accept_o && cmd_send_i != NOP_cmd)
                                                            //todo : 这里条件与上cmd_accept_o的原因是 ： 若写完马上转读，且不与上cmd_accept_o, cmd_send_i是读，last_vld_cmd也是读，且cur_delay正好命中了最后一个back-to-back的读，则会错误的触发read_early_accept.
            last_vld_cmd <= cmd_send_i;
        else
            last_vld_cmd <= last_vld_cmd;
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            cur_delay <= 'd0;
        else
            cur_delay <= nex_delay;
    end

    always@(*)begin
        if(!sys_rst_n)
            nex_delay <= 'd0;
        else begin
            case(cur_delay)
                0:begin
                    case(cmd_send_i)
                        ACT_cmd   : nex_delay <= tRCD;
                        PREC_cmd  : nex_delay <= tRP;
                        REF_cmd   : nex_delay <= tRFC;
                        READ_cmd  : nex_delay <= RW_NONSEQ_CYCLES;
                        WRITE_cmd : nex_delay <= RW_NONSEQ_CYCLES;
                        default   : nex_delay <= 'd0;
                    endcase
                end
                default:begin
                    if(rd_early_accepted_w || wr_early_accepted_w)
                        nex_delay <= RW_NONSEQ_CYCLES;
                    else
                        nex_delay <= cur_delay - 1'b1;

                end
            endcase
        end
    end


//DFI Write Process
    localparam                      WR_SHIFT_WIDTH  =   tPHY_WRLAT + DFI_BURST_LEN  ;

    reg [WR_SHIFT_WIDTH - 1 : 0]    wr_en_shift       ;
    reg [DFI_DATA_WIDTH - 1 : 0]    dfi_wrdata_r      ;
    reg [DFI_DQM_WIDTH  - 1 : 0]    dfi_wrdata_mask_r ;
    reg [1 : 0]                     dfi_wr_idx_r      ;
    reg                             dfi_wrdata_en_r   ;

    wire                            wr_en_w           ;

    assign                          wr_en_w            = wr_en_shift[0]                   ;
    assign                          wr_data_fifo_rd_en = wr_en_w && (dfi_wr_idx_r == 'd3) ;

    assign                          dfi_wrdata_o       = dfi_wrdata_r                     ;
    assign                          dfi_wrdata_mask_o  = dfi_wrdata_mask_r                ;
    assign                          dfi_wrdata_en_o    = dfi_wrdata_en_r                  ;

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            wr_en_shift <= {(WR_SHIFT_WIDTH){1'b0}};
        else if(cmd_send_i == WRITE_cmd && cmd_accept_o) //the time when a write cmd just is sent.
            wr_en_shift <= {{(DFI_BURST_LEN){1'b1}} , wr_en_shift[tPHY_WRLAT:1]};
        else
            wr_en_shift <= {1'b0,wr_en_shift[WR_SHIFT_WIDTH - 1 : 1]};
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            dfi_wrdata_r        <= {DFI_DATA_WIDTH{1'b0}}   ;
            dfi_wrdata_mask_r   <= {DFI_DQM_WIDTH{1'b0}}    ;
            dfi_wr_idx_r        <= 2'b0                     ;
        end
        else if(wr_en_w)begin
            case(dfi_wr_idx_r)
                2'd0 :  begin dfi_wrdata_r <= wr_data_w[ 31: 0]; dfi_wrdata_mask_r <= wr_data_mask_w[ 3: 0]; end
                2'd1 :  begin dfi_wrdata_r <= wr_data_w[ 63:32]; dfi_wrdata_mask_r <= wr_data_mask_w[ 7: 4]; end
                2'd2 :  begin dfi_wrdata_r <= wr_data_w[ 95:64]; dfi_wrdata_mask_r <= wr_data_mask_w[11: 8]; end
                2'd3 :  begin dfi_wrdata_r <= wr_data_w[127:96]; dfi_wrdata_mask_r <= wr_data_mask_w[15:12]; end 
            endcase
            dfi_wr_idx_r <= dfi_wr_idx_r + 1'b1;
        end
        else begin
            dfi_wrdata_r        <= {DFI_DATA_WIDTH{1'b0}}   ;
            dfi_wrdata_mask_r   <= {DFI_DQM_WIDTH{1'b0}}    ;            
        end
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            dfi_wrdata_en_r <= 1'b0;
        else
            dfi_wrdata_en_r <= wr_en_w;
    end


//DFI Read Process
    localparam                      RD_SHIFT_WIDTH  =   tRDDATA_EN + DFI_BURST_LEN  ;

    reg [RD_SHIFT_WIDTH - 1 : 0]    rd_en_shift         ;
    reg                             dfi_rddata_en_r     ;
    reg [1 : 0]                     dfi_rd_idx_r        ;
    reg [127 : 0]                   rd_data_r           ;
    reg                             rd_data_valid_r     ;

    wire                            rd_en_w             ;

    assign                          rd_en_w             = rd_en_shift[0];

    assign                          dfi_rddata_en_o         = dfi_rddata_en_r   ;
    assign                          inport_rd_data_o        = rd_data_r         ;
    assign                          inport_rd_data_vld_o    = rd_data_valid_r   ;

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            rd_en_shift <= 'd0;
        else if(cmd_send_i == READ_cmd && cmd_accept_o)
            rd_en_shift <= {{(DFI_BURST_LEN){1'b1}} , rd_en_shift[tRDDATA_EN : 1]};
        else
            rd_en_shift <= {1'b0 , rd_en_shift[RD_SHIFT_WIDTH - 1 : 1]};
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            dfi_rddata_en_r <= 1'b0;
        else
            dfi_rddata_en_r <= rd_en_w;
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            dfi_rd_idx_r <= 2'b0;
        else if(dfi_rddata_valid_i)
            dfi_rd_idx_r <= dfi_rd_idx_r + 1'b1;
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            rd_data_r <= 'd0;
        else if(dfi_rddata_valid_i)
            rd_data_r <= {dfi_rddata_i , rd_data_r[127 : 32]};
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            rd_data_valid_r <= 1'b0;
        else if(dfi_rddata_valid_i && dfi_rd_idx_r == 2'd3)
            rd_data_valid_r <= 1'b1;
        else
            rd_data_valid_r <= 0;
    end

endmodule
