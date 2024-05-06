//Enter passphrase for key "/home/ICer/.ssh/test" : zc20021119

//attention !!! : DFI Spec : P12 this parameter may be specified as a fixed value , or as a constant based on other fixed values in the system.顶层参数中DFI_WRITE_LATENCY和DFI_READ_LATENCY必须保持为4，否则报错，可能是和github的原作者设置的PHY有关。

module zc_ddr3_core#(
    parameter   DDR_MHZ             = 100           ,
    parameter   DFI_WRITE_LATENCY   = 4             ,
    parameter   DFI_READ_LATENCY    = 4             ,
    parameter   DDR_COL_WIDTH       = 10            ,
    parameter   DDR_ROW_WIDTH       = 14            ,
    parameter   DDR_BRC_MODE        = "BRC"      
)(

    input                       sys_clk             ,
    input                       sys_rst_n           ,
    input                       phy_init_done       ,
    output reg                  mc_init_done        ,

    input [15:0]                inport_wr_i         ,
    input                       inport_rd_i         ,
    input [31:0]                inport_addr_i       ,
    input [127:0]               inport_wr_data_i    ,

    output                      inport_accept_o     ,
    output                      inport_ack_o        ,
    output [127:0]              inport_rd_data_o    ,
    output                      inport_rd_data_vld_o,

    output [13:0]               dfi_address_o       ,
    output [2:0]                dfi_bank_o          ,
    output                      dfi_cas_n_o         ,
    output                      dfi_cke_o           ,
    output                      dfi_cs_n_o          ,
    output                      dfi_odt_o           ,
    output                      dfi_ras_n_o         ,
    output                      dfi_reset_n_o       ,
    output                      dfi_we_n_o          ,

    output [31:0]               dfi_wrdata_o        ,
    output                      dfi_wrdata_en_o     ,
    output [3:0]                dfi_wrdata_mask_o   ,

    output                      dfi_rddata_en_o     ,
    input [31:0]                dfi_rddata_i        ,
    input                       dfi_rddata_valid_i  ,
    input [3:0]                 dfi_rddata_dnv_i           
);

    localparam      tCK_ns              = 1000 / DDR_MHZ                    ; // 10 ns
    localparam      tXPR                =  30                               ; // 300ns
                                                                                //P170 : exit reset from CKE HIGH to a valid command : for DDR3-800 Min is max(5nCK , tRFC(min) + 10ns) for 2Gb , tRFC(min) = 160ns  ,there I put it 300ns(30 tCK_ns)
    localparam     tMRD                 = 6                                 ;   //min is 4 nCK
    localparam     tMOD                 = 15                                ;   //min = max(12 nCK , 15ns) ,there I put it 15 nCK(150ns)
    localparam     tZQinit              = 520                               ;   //min = max(512 nCK , 640ns) ,there I put it 520 nCK
    localparam     tRP                  = 3                                 ;   //min = 15ns , there I put it 30ns

    `ifdef XILINX_SIMULATOR
    localparam      DDR_INIT_DELAY      = 70000 / tCK_ns + tXPR + 3 * tMRD + tMOD + tZQinit + tRP   ;   // in simulator , the init begin time is 70us
    localparam      INIT_TIME_CKE_LOW   = DDR_INIT_DELAY - 19000/tCK_ns                             ;
    localparam      INIT_TIME_RST_HIGH  = DDR_INIT_DELAY - 20000/tCK_ns                             ;
    localparam      INIT_TIME_CKE_HIGH  = DDR_INIT_DELAY - 70000/tCK_ns                             ;
    `elsif VCS_SIMULATOR
    localparam      DDR_INIT_DELAY      = 70000 / tCK_ns + tXPR + 3 * tMRD + tMOD + tZQinit + tRP   ;   // in simulator , the init begin time is 70us
    localparam      INIT_TIME_CKE_LOW   = DDR_INIT_DELAY - 19000/tCK_ns                             ;
    localparam      INIT_TIME_RST_HIGH  = DDR_INIT_DELAY - 20000/tCK_ns                             ;
    localparam      INIT_TIME_CKE_HIGH  = DDR_INIT_DELAY - 70000/tCK_ns                             ;    
    `else
    localparam      DDR_INIT_DELAY      = 700000 / tCK_ns + tXPR + 3 * tMRD + tMOD + tZQinit + tRP  ;   // in real case , the init begin time is 700us
    localparam      INIT_TIME_CKE_LOW   = DDR_INIT_DELAY - 190000/tCK_ns                            ;
    localparam      INIT_TIME_RST_HIGH  = DDR_INIT_DELAY - 200000/tCK_ns                            ;
    localparam      INIT_TIME_CKE_HIGH  = DDR_INIT_DELAY - 700000/tCK_ns                            ;     
    `endif

    localparam      INIT_TIME_MR2_SET   = INIT_TIME_CKE_HIGH - tXPR                                 ;
    localparam      INIT_TIME_MR3_SET   = INIT_TIME_CKE_HIGH - tXPR - tMRD                          ;
    localparam      INIT_TIME_MR1_SET   = INIT_TIME_CKE_HIGH - tXPR - 2 * tMRD                      ;
    localparam      INIT_TIME_MR0_SET   = INIT_TIME_CKE_HIGH - tXPR - 3 * tMRD                      ;
    localparam      INIT_TIME_ZQCL      = INIT_TIME_CKE_HIGH - tXPR - 3 * tMRD - tMOD               ;
    localparam      INIT_TIME_PREC      = INIT_TIME_CKE_HIGH - tXPR - 3 * tMRD - tMOD - tZQinit     ;

    `ifdef XILINX_SIMULATOR
    localparam      DDR_REFI            = 100                                                       ; // in simulator , refresh per 1us(1000ns)
    `elsif VCS_SIMULATOR
    localparam      DDR_REFI            = 200                                                       ; // in simulator , refresh per 1us(1000ns)    
    `else
    localparam      DDR_REFI            = (64000 * DDR_MHZ) / 8192 - 31                             ; // in real case , refresh per 7.5us
    `endif

    localparam      NOP_cmd     =   4'b0111     ;    // CS#, RAS#, CAS#, WE#
    localparam      ACT_cmd     =   4'b0011     ; 
    localparam      PREC_cmd    =   4'b0010     ;
    localparam      REF_cmd     =   4'b0001     ;
    localparam      MRS_cmd     =   4'b0000     ;
    localparam      ZQCL_cmd    =   4'b0110     ;
    localparam      READ_cmd    =   4'b0101     ;
    localparam      WRITE_cmd   =   4'b0100     ;

    //Mode Register Set : BA2-BA0 A15-A0
    localparam      MR0_PPD     = 1'b0          ;   //slow exit(DLL off)
    localparam      MR0_WR      = 3'b000        ;   //WR = 16
    localparam      MR0_DLL     = 1'b1          ;   //DLL Reset : yes
    localparam      MR0_TM      = 1'b0          ;   //normal
    localparam      MR0_CL      = 4'b0100       ;   // DLL off mode : must be 6
    localparam      MR0_RBT     = 1'b0          ;   //Read Burst Type : Nibble Sequential
    localparam      MR0_BL      = 2'b00         ;   //BL = 8 , fixed
    localparam      MR0_A13     = 1'b0          ;   //Reserved 

    localparam      MR0_ADDR    = {MR0_A13, MR0_PPD, MR0_WR, MR0_DLL, MR0_TM, MR0_CL[3:1], MR0_RBT, MR0_CL[0], MR0_BL};
    localparam      MR0_BA      = 3'b000;

    localparam      MR1_DLL     = 1'b1          ;   //DLL disable
    localparam      MR1_DIC     = 2'b00         ;   //Output Driver Impedance Control : RZQ / 6 (RZQ = 240 Om)
    localparam      MR1_Rtt_Nom = 3'b000        ;   //Rtt_Nom disabled
    localparam      MR1_AL      = 2'b00         ;   //AL disabled
    localparam      MR1_Level   = 1'b0          ;   //Write leveling enable
    localparam      MR1_TDQS    = 1'b0          ;   //TDQS disable
    localparam      MR1_Qoff    = 1'b0          ;   //Output buffer enable(DQs, DQSs, DQS#s)
    localparam      MR1_A13     = 1'b0          ;   //Reserved
    
    localparam      MR1_ADDR    =
                         {MR1_A13, MR1_Qoff, MR1_TDQS, 1'b0, MR1_Rtt_Nom[1], 1'b0, MR1_Level, MR1_Rtt_Nom[1], MR1_DIC[1], MR1_AL, MR1_Rtt_Nom[0], MR1_DIC[0], MR1_DLL};
    localparam      MR1_BA      = 3'b001        ;

    localparam      MR2_PASR    = 3'b000        ;   //Partial Array Self-Refresh(Optional) : Full Array
    localparam      MR2_CWL     = 3'b001        ;   // DLL off mode : CWL must be 6
    localparam      MR2_ASR     = 1'b0          ;   // Auto Self-Refresh(ASR) : Manual SR Reference(SRT)
    localparam      MR2_SRT     = 1'b0          ;   // Self-Refresh Temperature(SRT) Range : Normal operating temperature range
    localparam      MR2_Rtt_WR  = 2'b00         ;   // Dynamic ODT off(Write does not affect Rtt value)
    localparam      MR2_A11_13  = 3'b000        ;

    localparam      MR2_ADDR    = {MR2_A11_13, MR2_Rtt_WR, 1'b0, MR2_SRT, MR2_ASR, MR2_CWL, MR2_PASR};
    localparam      MR2_BA      = 3'b010        ;

    localparam      MR3_MPR_Loc = 2'b00         ;   // MPR location : Predefined pattern
    localparam      MR3_MPR     = 1'b0          ;   // MPR : Normal operation
    localparam      MR3_A3_13   = 11'b0         ;

    localparam      MR3_ADDR    = {MR3_A3_13, MR3_MPR, MR3_MPR_Loc};
    localparam      MR3_BA      = 3'b011        ; 

    localparam      STATE_INIT  = 'd0           ;
    localparam      STATE_IDLE  = 'd1           ;
    localparam      STATE_ACT   = 'd2           ;
    localparam      STATE_PREC  = 'd3           ;
    localparam      STATE_REF   = 'd4           ;
    localparam      STATE_READ  = 'd5           ;
    localparam      STATE_WRITE = 'd6           ;

    reg [DDR_ROW_WIDTH - 1 : 0]     cur_actived_row[7 : 0]  ;
    reg [7 : 0]                     cur_actived_bank        ;

    reg [5 : 0]                     cur_state               ;
    reg [5 : 0]                     nex_state               ;
    reg [5 : 0]                     target_cur_state        ;
    reg [5 : 0]                     target_nex_state        ;

    reg [$clog2(DDR_INIT_DELAY) :0] refresh_cnt             ;
    reg                             refresh_req             ;

    reg [3 : 0]                     cmd_send                ;
    reg [DDR_ROW_WIDTH - 1 : 0]     addr_send               ;
    reg                             cke_send                ;
    reg [2 : 0]                     ba_send                 ;
    reg                             rst_n_send              ;

    wire [DDR_COL_WIDTH - 1 : 0]    col_addr_w              ;
    wire [DDR_ROW_WIDTH - 1 : 0]    row_addr_w              ;
    wire [2 : 0]                    bank_addr_w             ;

    wire                            rw_req_w                ;

    wire                            cmd_accept_w            ;

    assign  rw_req_w        = ((inport_wr_i != 0) || inport_rd_i)  ;
    
 //     assign  inport_ack_o    = ((cur_state == STATE_WRITE) && cmd_accept_w) || ( inport_rd_data_vld_o ) ; 
                                //todo :如果使用注释这里的，表明读任务在收到读数据之后才会拉高inport_ack_o,则表明这里的读不是back-to-back的读任务，如果使用下面的，则代表使用的是back-to-back的读任务
    assign  inport_ack_o    = ((cur_state == STATE_WRITE) || (cur_state == STATE_READ)) && cmd_accept_w;
    assign  inport_accept_o = ((cur_state == STATE_WRITE) || (cur_state == STATE_READ)) && cmd_accept_w;

    generate
        if(DDR_BRC_MODE == "BRC")begin // BA RA CA 
            assign col_addr_w  = inport_addr_i [DDR_COL_WIDTH - 1 : 0];
            assign row_addr_w  = inport_addr_i [DDR_ROW_WIDTH + DDR_COL_WIDTH - 1 : DDR_COL_WIDTH];
            assign bank_addr_w = inport_addr_i [3 + DDR_ROW_WIDTH + DDR_COL_WIDTH - 1 : DDR_ROW_WIDTH + DDR_COL_WIDTH];
        end
        else if(DDR_BRC_MODE == "RBC")begin //RA BA CA
            assign col_addr_w  = inport_addr_i [DDR_COL_WIDTH - 1 : 0];
            assign bank_addr_w = inport_addr_i [3 + DDR_COL_WIDTH - 1 : DDR_COL_WIDTH];
            assign row_addr_w  = inport_addr_i [DDR_ROW_WIDTH + 3 + DDR_COL_WIDTH - 1 : 3 + DDR_COL_WIDTH];
        end
    endgenerate

//main FSM  
    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            cur_state           <= STATE_INIT       ;
            target_cur_state    <= STATE_IDLE       ;
        end
        else if(cmd_accept_w)begin
            cur_state           <= nex_state        ;
            target_cur_state    <= target_nex_state ;
        end
    end

    always@(*)begin
        if(!sys_rst_n)begin
            nex_state           <= STATE_INIT   ;
            target_nex_state    <= STATE_IDLE   ;
        end
        else case(cur_state)
            STATE_INIT: nex_state <= (refresh_req == 1 ) ? STATE_IDLE : cur_state;
            STATE_IDLE: begin
                if(refresh_req == 1)begin
                    if(cur_actived_bank != 0)begin
                        nex_state        <= STATE_PREC  ;
                        target_nex_state <= STATE_REF   ;
                    end else
                            nex_state <= STATE_REF;
                end
                else if(rw_req_w == 1)begin
                  //PFH : directly R/W
                    if(cur_actived_bank[bank_addr_w] && (cur_actived_row[bank_addr_w]) == row_addr_w)
                        nex_state           <= (inport_rd_i == 1) ? STATE_READ : STATE_WRITE;
                   //PM : first PREC , then ACT , then R/W
                    else if(cur_actived_bank[bank_addr_w])begin
                        nex_state           <= STATE_PREC;
                        target_nex_state    <= (inport_rd_i) ? STATE_READ : STATE_WRITE;
                    end
                   //PH : first ACT , then R/W
                    else begin
                        nex_state           <= STATE_ACT;
                         target_nex_state   <= (inport_rd_i) ? STATE_READ : STATE_WRITE;                       
                    end
                    end
                else 
                    nex_state <= cur_state;
                end
            STATE_PREC: begin
                if(target_cur_state == STATE_REF)
                    nex_state <= STATE_REF;
                else
                    nex_state <= STATE_ACT;
                end 
            STATE_ACT   : nex_state <= target_cur_state     ;
            STATE_REF   : nex_state <= STATE_IDLE           ;
            STATE_READ  : nex_state <= STATE_IDLE           ;
            STATE_WRITE : nex_state <= STATE_IDLE           ;
            default     : begin
                          nex_state         <= cur_state        ;
                          target_nex_state  <= target_cur_state ;
                end
        endcase
    end

//BANK state
    integer i;
    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            cur_actived_bank <= 'd0;
            for(i = 0 ; i < 8 ; i = i + 1)
                cur_actived_row[i] <= 'd0;      
        end
        else begin
            case(cur_state)
                STATE_ACT : begin
                    cur_actived_bank[bank_addr_w] <= 1'b1;
                    cur_actived_row[bank_addr_w] <= row_addr_w;    
                end
                STATE_PREC : begin
                    if(target_cur_state == STATE_REF)
                        cur_actived_bank <= 'd0;
                    else
                        cur_actived_bank[bank_addr_w] <= 1'b0;    
                end
                default: ;
            endcase
        end
    end

//Refresh Counter
    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            refresh_cnt <= DDR_INIT_DELAY;
        else if(phy_init_done == 0)
            refresh_cnt <= DDR_INIT_DELAY;
        else if(refresh_cnt == 'd0)
            refresh_cnt <= DDR_REFI;
        else
            refresh_cnt <= refresh_cnt - 1'b1;
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            mc_init_done <= 0;
        else if(refresh_cnt == 'd0)
            mc_init_done <= 1;
        else
            mc_init_done <= mc_init_done;
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            refresh_req <= 0;
        else if (refresh_cnt == 0)
            refresh_req <= 1;
        else if(cur_state == STATE_REF)
            refresh_req <= 0;
        else
            refresh_req <= refresh_req;
    end

//Command Send 
    always@(*)begin
        if(!sys_rst_n)begin
            cmd_send    <= NOP_cmd  ;
            addr_send   <= 'd0      ;
            ba_send     <= 'd0      ;
            cke_send    <= 'b0      ;
            rst_n_send  <= 'b0      ;           
        end
        else begin
            case(cur_state)
                STATE_INIT :begin
                    if(refresh_cnt == INIT_TIME_CKE_LOW)
                        cke_send <= 1'b0;
                    else if(refresh_cnt == INIT_TIME_RST_HIGH)
                        rst_n_send <= 1'b1;
                    else if(refresh_cnt == INIT_TIME_CKE_HIGH)
                        cke_send <= 1'b1;
                    else if(refresh_cnt == INIT_TIME_MR2_SET)begin
                        cmd_send    <= MRS_cmd  ;
                        addr_send   <= MR2_ADDR ;
                        ba_send     <= MR2_BA   ;
                    end
                    else if(refresh_cnt == INIT_TIME_MR3_SET)begin
                        cmd_send    <= MRS_cmd  ;
                        addr_send   <= MR3_ADDR ;
                        ba_send     <= MR3_BA   ;
                    end
                    else if(refresh_cnt == INIT_TIME_MR1_SET)begin
                        cmd_send    <= MRS_cmd  ;
                        addr_send   <= MR1_ADDR ;
                        ba_send     <= MR1_BA   ;
                    end
                    else if(refresh_cnt == INIT_TIME_MR0_SET)begin
                        cmd_send    <= MRS_cmd  ;
                        addr_send   <= MR0_ADDR ;
                        ba_send     <= MR0_BA   ;
                    end
                    else if(refresh_cnt == INIT_TIME_ZQCL)begin
                        cmd_send        <= ZQCL_cmd ;
                        addr_send[10]   <= 1; 
                    end
                    else if(refresh_cnt == INIT_TIME_PREC)begin
                        cmd_send        <= PREC_cmd ;
                        addr_send[10]   <= 1;
                    end
                    else begin
                        cmd_send        <= NOP_cmd  ;
                        addr_send       <= 'd0      ;
                        ba_send         <= 'd0      ;
                    end
                end
                STATE_IDLE:begin
                    cmd_send    <= NOP_cmd  ;
                    addr_send   <= 'd0      ;
                    ba_send     <= 'd0      ;                   
                end
                STATE_ACT:begin
                    cmd_send    <= ACT_cmd    ;
                    addr_send   <= row_addr_w ;
                    ba_send     <= bank_addr_w;
                end
                STATE_REF:begin
                    cmd_send    <= REF_cmd  ;
                end
                STATE_PREC:begin
                    if(target_cur_state == STATE_REF)begin
                        cmd_send  <= PREC_cmd;
                        addr_send[10] <= 1;
                    end
                    else begin
                        cmd_send <= PREC_cmd;
                        addr_send[10] <= 0;
                        ba_send <= bank_addr_w;
                    end
                end
                STATE_READ:begin
                    cmd_send <= READ_cmd;
                    addr_send <= {1'b0,1'b1,1'b0,1'b0,col_addr_w[DDR_COL_WIDTH - 1 : 3] , 3'b0}; 
                                                                //A10 = 0 : disable auto precharge ; A12 = 1 : fixed BL = 8
                    ba_send <= bank_addr_w;
                end
                STATE_WRITE:begin
                    cmd_send <= WRITE_cmd;
                    addr_send <= {1'b0,1'b1,1'b0,1'b0,col_addr_w[DDR_COL_WIDTH - 1 : 3] , 3'b0};
                    ba_send <= bank_addr_w; 
                end
                default:
                    cmd_send <= NOP_cmd;

            endcase
        end
    end

    `ifdef XILINX_SIMULATOR

        reg [79:0]  dbg_state;

        always@(*)begin
            case(cur_state)
                STATE_INIT : dbg_state <= "INIT"    ;
                STATE_IDLE : dbg_state <= "IDLE"    ;
                STATE_PREC : dbg_state <= "PREC"    ;
                STATE_ACT  : dbg_state <= "ACT"     ;
                STATE_REF  : dbg_state <= "REF"     ;
                STATE_READ : dbg_state <= "READ"    ;
                STATE_WRITE: dbg_state <= "WRITE"   ;
                default    : dbg_state <= "NAN_STATE";    
            endcase    
        end
    `endif


    zc_ddr3_dfi#(
        .DDR_MHZ                (   DDR_MHZ             ),
        .DFI_WRITE_LATENCY      (   DFI_WRITE_LATENCY   ),
        .DFI_READ_LATENCY       (   DFI_READ_LATENCY    ),
        .DDR_COL_WIDTH          (   DDR_COL_WIDTH       ),
        .DDR_ROW_WIDTH          (   DDR_ROW_WIDTH       )
    )ddr_dfi_phy(
        .sys_clk                (   sys_clk             ),
        .sys_rst_n              (   sys_rst_n           ),

        .addr_send_i            (   addr_send           ),
        .bank_send_i            (   ba_send             ),
        .cmd_send_i             (   cmd_send            ),
        .cke_send_i             (   cke_send            ),
        .rst_n_send_i           (   rst_n_send          ),

        .inport_wr_data_i       (   inport_wr_data_i    ),
        .inport_wr_data_mask_i  (   ~inport_wr_i        ),

        .cmd_accept_o           (   cmd_accept_w        ),
        .inport_rd_data_o       (   inport_rd_data_o    ),
        .inport_rd_data_vld_o   (   inport_rd_data_vld_o),

        .dfi_address_o          (   dfi_address_o       ),
        .dfi_bank_o             (   dfi_bank_o          ),    
        .dfi_cas_n_o            (   dfi_cas_n_o         ),   
        .dfi_cke_o              (   dfi_cke_o           ),     
        .dfi_cs_n_o             (   dfi_cs_n_o          ),    
        .dfi_odt_o              (   dfi_odt_o           ),     
        .dfi_ras_n_o            (   dfi_ras_n_o         ),   
        .dfi_reset_n_o          (   dfi_reset_n_o       ), 
        .dfi_we_n_o             (   dfi_we_n_o          ),
        .dfi_rddata_en_o        (   dfi_rddata_en_o     ),    
        .dfi_rddata_i           (   dfi_rddata_i        ),       
        .dfi_rddata_valid_i     (   dfi_rddata_valid_i  ), 
        .dfi_rddata_dnv_i       (   dfi_rddata_dnv_i    ),   
        .dfi_wrdata_o           (   dfi_wrdata_o        ),       
        .dfi_wrdata_en_o        (   dfi_wrdata_en_o     ),    
        .dfi_wrdata_mask_o      (   dfi_wrdata_mask_o   )    
    );
endmodule