module zc_m_axi_wr_3_axi_itf#(
    parameter                               ADDR_WIDTH = 32                 ,
    parameter                               AXI_WR_DATA_WIDTH = 128
)(
    input                                   axi_clk                         ,
    input                                   user_reset_n                    ,

    input [ADDR_WIDTH - 1 : 0]              axi_aw_addr                     ,
    input [8:0]                             axi_aw_length                   ,
    input                                   axi_wr_req                      ,
    output                                  axi_aw_ready                    ,

    input [AXI_WR_DATA_WIDTH - 1 : 0]       axi_w_data                      ,
    input                                   axi_w_last                      ,
    input                                   axi_w_valid                     ,
    output                                  axi_w_ready                     ,

    output [3:0]                            m_axi_awid                      ,
    output [1:0]                            m_axi_awburst                   ,
    output                                  m_axi_awlock                    ,
    output [3:0]                            m_axi_awcache                   ,
    output [2:0]                            m_axi_awprot                    ,
    output [3:0]                            m_axi_awqos                     ,
    output                                  m_axi_awuser                    ,
    output reg[ADDR_WIDTH - 1 : 0]          m_axi_awaddr                    ,
    output reg[7:0]                         m_axi_awlen                     ,
    output [2:0]                            m_axi_awsize                    ,
    output reg                              m_axi_awvalid                   ,
    input                                   m_axi_awready                   ,

    output reg[AXI_WR_DATA_WIDTH - 1 : 0]   m_axi_wdata                     ,
    output [AXI_WR_DATA_WIDTH/8 - 1 : 0]    m_axi_wstrb                     ,
    output reg                              m_axi_wvalid                    ,
    output reg                              m_axi_wlast                     ,
    output                                  m_axi_wuser                     ,
    input                                   m_axi_wready                    ,

    input [3:0]                             m_axi_bid                       ,
    input [1:0]                             m_axi_bresp                     ,
    input                                   m_axi_buser                     ,
    input                                   m_axi_bvalid                    ,
    output                                  m_axi_bready
);

    localparam M_AXI_IDLE   = 3'b000;
    localparam M_AXI_PRE    = 3'b001;
    localparam M_AXI_WRITE  = 3'b011;
    localparam M_AXI_END    = 3'b010;

    reg [2:0] cur_state;
    reg [2:0] nex_state;

    (* dont_touch = "true" *) reg async_reset_n_d;
    (* dont_touch = "true" *) reg async_reset_n_2d;
    (* dont_touch = "true" *) reg async_reset_n;

    assign axi_aw_ready     = ( cur_state == M_AXI_PRE);
    assign axi_w_ready      = m_axi_wready;
    
    assign m_axi_bready     = 1'b1  ;

    assign m_axi_awid       = 4'b0  ;
    assign m_axi_awburst    = 2'b1  ;
    assign m_axi_awlock     = 1'b0  ;
    assign m_axi_awcache    = 4'b0  ;
    assign m_axi_awprot     = 3'b0  ;
    assign m_axi_awqos      = 4'b0  ;
    assign m_axi_awuser     = 1'b0  ;
    assign m_axi_wuser      = 1'b0  ;
    assign m_axi_wstrb      = {AXI_WR_DATA_WIDTH/8{1'b1}}; // don't support data mask.
    assign m_axi_awsize     =   AXI_WR_DATA_WIDTH == 512 ? 3'h6 :
                                AXI_WR_DATA_WIDTH == 256 ? 3'h5 :
                                AXI_WR_DATA_WIDTH == 128 ? 3'h4 :
                                AXI_WR_DATA_WIDTH == 64  ? 3'h3 :
                                AXI_WR_DATA_WIDTH == 32  ? 3'h2 : 3'h0 ;

    always@(posedge axi_clk)begin
        async_reset_n_d <= user_reset_n;
        async_reset_n_2d <= async_reset_n_d;
        async_reset_n <= async_reset_n_2d;
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            cur_state <= M_AXI_IDLE;
        else
            cur_state <= nex_state;
    end


    always@(*)begin
        if(!async_reset_n)
            nex_state <= M_AXI_IDLE;
        else begin
            case(cur_state)
                M_AXI_IDLE  : nex_state <= (axi_wr_req == 1) ? M_AXI_PRE : cur_state;
                M_AXI_PRE   : nex_state <= M_AXI_WRITE;
                M_AXI_WRITE : nex_state <= (m_axi_wvalid & m_axi_wready & m_axi_wlast) ? M_AXI_END : cur_state;
                M_AXI_END   : nex_state <= M_AXI_IDLE;
                default     : nex_state <= M_AXI_IDLE;
            endcase
        end 
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            m_axi_awvalid <= 1'b0;
        else if(m_axi_awvalid & m_axi_awready)
            m_axi_awvalid <= 1'b0;
        else if(axi_wr_req & axi_aw_ready)
            m_axi_awvalid <= 1'b1;
        else
            m_axi_awvalid <= m_axi_awvalid;
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)begin
            m_axi_awaddr <= 'd0;
            m_axi_awlen  <= 'd0;
        end else if(axi_wr_req & axi_aw_ready)begin
            m_axi_awaddr <= axi_aw_addr;
            m_axi_awlen  <= axi_aw_length[7:0];
        end else begin
            m_axi_awaddr <= m_axi_awaddr;
            m_axi_awlen  <= m_axi_awlen;
        end
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            m_axi_wvalid <= 1'b0;
        else if(m_axi_wready & m_axi_wvalid & m_axi_wlast)
            m_axi_wvalid <= 1'b0;
        else if(axi_w_valid & axi_w_ready)
            m_axi_wvalid <= 1'b1;
        else
            m_axi_wvalid <= m_axi_wvalid;
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            m_axi_wdata <= 'd0;
        else if(axi_w_valid & axi_w_ready)
            m_axi_wdata <= axi_w_data;
        else
            m_axi_wdata <= m_axi_wdata; 
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            m_axi_wlast <= 1'b0;
        else if(m_axi_wready & m_axi_wvalid & m_axi_wlast)
            m_axi_wlast <= 1'b0;
        else if(axi_w_valid & axi_w_ready & axi_w_last)
            m_axi_wlast <= 1'b1;
        else
            m_axi_wlast <= m_axi_wlast;
    end
endmodule