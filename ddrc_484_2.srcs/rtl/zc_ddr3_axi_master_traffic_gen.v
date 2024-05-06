
module zc_ddr3_axi_master_traffic_gen#(
   parameter                                BASE_ADDR           = {5'b0 , 3'b101 , 14'd2002 , 10'h20}   ,
   parameter integer                        AXI_BURST_LEN       = 16                                    ,
   parameter integer                        AXI_ID_WIDTH        = 4                                     ,
   parameter integer                        AXI_ADDR_WIDTH      = 32                                    ,
   parameter integer                        AXI_DATA_WIDTH      = 128                                   , //only support 128 bits
   parameter integer                        AXI_AWUSER_WIDTH    = 1                                     ,
   parameter integer                        AXI_ARUSER_WIDTH    = 1                                     ,
   parameter integer                        AXI_WUSER_WIDTH     = 1                                     ,
   parameter integer                        AXI_RUSER_WIDTH     = 1                                     , 
   parameter integer                        AXI_BUSER_WIDTH     = 1  
)(
    input                                   m_axi_aclk              ,
    input                                   m_axi_areset_n          ,

    output [AXI_ID_WIDTH - 1 : 0]           m_axi_awid              ,
    output reg[AXI_ADDR_WIDTH - 1 : 0]      m_axi_awaddr            ,
    output reg[7:0]                         m_axi_awlen             ,
    output [2:0]                            m_axi_awsize            ,
    output [1:0]                            m_axi_awburst           ,
    output                                  m_axi_awlock            ,
    output [3:0]                            m_axi_awcache           ,
    output [2:0]                            m_axi_awprot            ,
    output [3:0]                            m_axi_awqos             ,
    output [AXI_AWUSER_WIDTH - 1 : 0]       m_axi_awuser            ,
    output reg                              m_axi_awvalid           ,
    input                                   m_axi_awready           ,

    output reg [AXI_DATA_WIDTH - 1 : 0]     m_axi_wdata             ,
    output reg[AXI_DATA_WIDTH/8 - 1 : 0]    m_axi_wstrb             ,
    output reg                              m_axi_wlast             ,
    output [AXI_WUSER_WIDTH - 1 : 0]        m_axi_wuser             ,
    output  reg                             m_axi_wvalid            ,
    input                                   m_axi_wready            ,

    input [AXI_ID_WIDTH - 1 : 0]            m_axi_bid               ,
    input [1:0]                             m_axi_bresp             ,
    input [AXI_BUSER_WIDTH - 1 : 0]         m_axi_buser             ,
    input                                   m_axi_bvalid            ,
    output reg                              m_axi_bready            ,

    output [AXI_ID_WIDTH - 1 : 0]           m_axi_arid              ,
    output reg [AXI_ADDR_WIDTH - 1 : 0]     m_axi_araddr            ,
    output reg [7:0]                        m_axi_arlen             ,
    output [2:0]                            m_axi_arsize            ,
    output [1:0]                            m_axi_arburst           ,
    output                                  m_axi_arlock            ,
    output [3:0]                            m_axi_arcache           ,
    output [2:0]                            m_axi_arprot            ,
    output [3:0]                            m_axi_arqos             ,
    output [AXI_ARUSER_WIDTH - 1 : 0]       m_axi_aruser            ,
    output reg                              m_axi_arvalid           ,
    input                                   m_axi_arready           ,

    input [AXI_ID_WIDTH - 1 : 0]            m_axi_rid               ,
    input [AXI_DATA_WIDTH - 1 : 0]          m_axi_rdata             ,
    input [1:0]                             m_axi_rresp             ,
    input                                   m_axi_rlast             ,
    input [AXI_RUSER_WIDTH - 1 : 0]         m_axi_ruser             ,
    input                                   m_axi_rvalid            ,
    output reg                              m_axi_rready            ,

    input                                   mc_init_done            //没有这个也行，因为是异步fifo
);

    localparam M_AXI_IDLE    =       3'b000             ;
    localparam M_AXI_WAIT1   =       3'b001             ;
    localparam M_AXI_WRITE   =       3'b011             ;
    localparam M_AXI_WAIT2   =       3'b010             ;
    localparam M_AXI_READ    =       3'b110             ;
    localparam M_AXI_OVER    =       3'b100             ;

    (* dont_touch = "true" *)   reg  rst_n_d            ;    //beat some bests to keep the CDC process stable in the asynchronous clock domain
    (* dont_touch = "true" *)   reg  rst_n_2d           ;
    (* dont_touch = "true" *)   reg  rst_n              ;

    reg [2:0]                   cur_state               ;
    reg [2:0]                   nex_state               ;
    reg [11:0]                  state_cnt               ;
    reg  [3:0]                  axi_trans_times         ;

    reg [8:0]                   axi_write_cnt           ;

    wire                        w_aw_active             ;
    wire                        w_w_active              ;
    wire                        w_b_active              ;
    wire                        w_ar_active             ;
    wire                        w_r_active              ;

    wire rd_fifo_wr_full                                ;
    wire rd_fifo_rd_empty                               ;
    wire rd_fifo_rden                                   ;
    wire [AXI_DATA_WIDTH - 1 : 0] rd_fifo_rddata        ;

    assign w_aw_active = m_axi_awvalid & m_axi_awready  ;
    assign w_w_active  = m_axi_wvalid  & m_axi_wready   ;
    assign w_b_active  = m_axi_bvalid  & m_axi_bready   ;
    assign w_ar_active = m_axi_arvalid & m_axi_arready  ;
    assign w_r_active  = m_axi_rvalid  & m_axi_rready   ;

    assign rd_fifo_rden     = 1'b0                      ;

    assign m_axi_awid       = 'd0                       ;
    assign m_axi_awsize     = 3'b100                    ; //16 Bytes, 128 bits
    assign m_axi_awburst    = 'b1                       ; //INCR
    assign m_axi_awlock     = 'd0                       ;
    assign m_axi_awcache    = 'd0                       ;
    assign m_axi_awprot     = 'd0                       ;
    assign m_axi_awqos      = 'd0                       ;
    assign m_axi_awuser     = 'd0                       ;

    assign m_axi_wuser      = 'd0                       ;

    assign m_axi_arid      = 'd0                        ;
    assign m_axi_arsize    = 3'b100                     ; //16 Bytes, 128 bits
    assign m_axi_arburst   = 'b1                        ; //INCR
    assign m_axi_arlock    = 'd0                        ;
    assign m_axi_arcache   = 'd0                        ;
    assign m_axi_arprot    = 'd0                        ;
    assign m_axi_arqos     = 'd0                        ;
    assign m_axi_aruser    = 'd0                        ;

    always@(posedge m_axi_aclk)begin
        rst_n_d     <= m_axi_areset_n   ;
        rst_n_2d    <= rst_n_d          ;
        rst_n       <= rst_n_2d         ;
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            axi_trans_times <= 'd0;
        else if(axi_trans_times > 3)
            axi_trans_times <= axi_trans_times;
        else if(cur_state == M_AXI_OVER & state_cnt == 'd0)
            axi_trans_times <= axi_trans_times + 1'b1;
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            state_cnt <= 'd0;
        else if(nex_state != cur_state)
            state_cnt <= 'd0;
        else
            state_cnt <= state_cnt + 1'b1;
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            cur_state <= M_AXI_IDLE;
        else
            cur_state <= nex_state;
    end

    always@(*)begin
        if(!rst_n)
            nex_state <= M_AXI_IDLE;
        else case(cur_state)
            M_AXI_IDLE  :   nex_state <= (mc_init_done == 1 & axi_trans_times <= 3) ? M_AXI_WAIT1   : cur_state ;
            M_AXI_WAIT1 :   nex_state <= (state_cnt == 'd20)                        ? M_AXI_WRITE   : cur_state ;
            M_AXI_WRITE :   nex_state <= (w_b_active == 1)                          ? M_AXI_WAIT2   : cur_state ;
            M_AXI_WAIT2 :   nex_state <= (state_cnt == 'd50)                        ? M_AXI_READ    : cur_state ;
            M_AXI_READ  :   nex_state <= (w_r_active & m_axi_rlast)                 ? M_AXI_OVER    : cur_state ;
            M_AXI_OVER  :   nex_state <= M_AXI_IDLE;
            default     :   nex_state <= M_AXI_IDLE;   
        endcase
    end

//write transaction

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)begin
            m_axi_awaddr <= 'd0;
            m_axi_awlen  <= 'd0;             
        end else if(cur_state == M_AXI_WRITE & state_cnt == 'd0 & axi_trans_times == 0)begin
            m_axi_awaddr <= BASE_ADDR;
            m_axi_awlen  <= AXI_BURST_LEN - 1;
        end else if(cur_state == M_AXI_WRITE & state_cnt == 'd0)begin
            m_axi_awaddr <= m_axi_awaddr + {5'b0 , 3'b001 , 14'b0 , 10'b0};
            m_axi_awlen  <= AXI_BURST_LEN - 1;
        end else begin
            m_axi_awaddr <= m_axi_awaddr;
            m_axi_awlen  <= m_axi_awlen; 
        end
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)begin
            m_axi_wdata <= 'd0;
            m_axi_wstrb <= 'd0;
        end else if(cur_state == M_AXI_WRITE & state_cnt == 'd0 & axi_trans_times == 0)begin
            m_axi_wdata <= 128'hffff_0000_1111_2222_3333_4444_5555_6666;
            m_axi_wstrb <= 16'hffff;
        end else if(cur_state == M_AXI_WRITE & state_cnt == 'd0)begin
            m_axi_wdata <= m_axi_wdata;
            m_axi_wstrb <= 16'hffff;
        end else if(w_w_active)begin
            m_axi_wdata <= m_axi_wdata + 'h1111;
            m_axi_wstrb <= 16'hffff;
        end else begin
            m_axi_wdata <= m_axi_wdata;
            m_axi_wstrb <= m_axi_wstrb;
        end
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            m_axi_awvalid <= 1'b0;
        else if(w_aw_active)
            m_axi_awvalid <= 1'b0;
        else if(cur_state == M_AXI_WRITE & state_cnt == 'd0)
            m_axi_awvalid <= 1'b1;
        else
            m_axi_awvalid <= m_axi_awvalid;
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            axi_write_cnt <= 'd0;
        else if(w_w_active & m_axi_wlast)
            axi_write_cnt <= 'd0;
        else if(w_w_active)
            axi_write_cnt <= axi_write_cnt + 1'b1;
        else
            axi_write_cnt <= axi_write_cnt;
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            m_axi_wvalid <= 1'b0;
        else if(w_w_active & m_axi_wlast)
            m_axi_wvalid <= 1'b0;
        else if(w_aw_active)
            m_axi_wvalid <= 1'b1;
        else
            m_axi_wvalid <= m_axi_wvalid; 
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            m_axi_wlast <= 1'b0;
        else if(w_w_active & m_axi_wlast)
            m_axi_wlast <= 1'b0;
        else if(axi_write_cnt == AXI_BURST_LEN - 2 & w_w_active)
            m_axi_wlast <= 1'b1;
        else
            m_axi_wlast <= m_axi_wlast;
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            m_axi_bready <= 1'b0;
        else if(w_b_active)
            m_axi_bready <= 1'b0;
        else if(w_w_active & m_axi_wlast)
            m_axi_bready <= 1'b1;
        else
            m_axi_bready <= m_axi_bready;
    end

//read transaction

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)begin
            m_axi_araddr <= 'd0;
            m_axi_arlen  <= 'd0;
        end else if(cur_state == M_AXI_READ & state_cnt == 'd0 & axi_trans_times == 0)begin
            m_axi_araddr <= BASE_ADDR;
            m_axi_arlen  <= AXI_BURST_LEN - 1;
        end else if(cur_state == M_AXI_READ & state_cnt == 'd0)begin
            m_axi_araddr <= m_axi_araddr + {5'b0 , 3'b001 , 14'b0 , 10'b0};
            m_axi_arlen  <= AXI_BURST_LEN - 1; 
        end else begin
            m_axi_araddr <= m_axi_araddr;
            m_axi_arlen  <= m_axi_arlen;
        end
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            m_axi_arvalid <= 1'b0;
        else if(w_ar_active)
            m_axi_arvalid <= 1'b0;
        else if(cur_state == M_AXI_READ & state_cnt == 'd0)
            m_axi_arvalid <= 1'b1;
        else
            m_axi_arvalid <= m_axi_arvalid;
    end

    always@(posedge m_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            m_axi_rready <= 1'b0;
        else if(w_r_active & m_axi_rlast)
            m_axi_rready <= 1'b0;
        else if(w_ar_active)
            m_axi_rready <= 1'b1;
        else
            m_axi_rready <= m_axi_rready; 
    end

    zc_sync_fifo#(
        .WIDTH      ( AXI_DATA_WIDTH    ),
        .DEPTH      ( 512               )
    )u_m_axi_rd_fifo(
        .sys_clk    ( m_axi_aclk        ),
        .sys_rst_n  ( rst_n             ),
        .wr_en      ( m_axi_rvalid      ),
        .wr_data    ( m_axi_rdata       ),
        .wr_full    ( rd_fifo_wr_full   ),
        .rd_en      ( rd_fifo_rden      ),
        .rd_data    ( rd_fifo_rddata    ),
        .rd_empty   ( rd_fifo_rd_empty  )
    );
endmodule