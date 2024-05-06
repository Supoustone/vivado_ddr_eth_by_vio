module zc_m_axi_rd_3_axi_itf#(
    parameter                               ADDR_WIDTH          = 32             ,
    parameter                               AXI_RD_DATA_WIDTH   = 128            ,
    parameter                               USER_RD_DATA_WIDTH  = 16
)(
    input                                   axi_clk                             ,
    input                                   user_reset_n                        ,

    output                                  axi_ar_ready                        ,
    input [ADDR_WIDTH - 1 : 0]              axi_ar_addr                         ,
    input [8:0]                             axi_ar_length                       ,
    input                                   axi_rd_req                          ,

    output reg                              axi_r_valid                         ,
    output reg[AXI_RD_DATA_WIDTH - 1 : 0]   axi_r_data                          ,
    output reg                              axi_r_last                          ,

    output [3:0]                            m_axi_arid                          ,
    output [1:0]                            m_axi_arburst                       ,
    output                                  m_axi_arlock                        ,
    output [3:0]                            m_axi_arcache                       ,
    output [2:0]                            m_axi_arprot                        ,
    output [3:0]                            m_axi_arqos                         ,
    output                                  m_axi_aruser                        ,

    output reg[ADDR_WIDTH - 1 : 0]          m_axi_araddr                        ,
    output reg[7:0]                         m_axi_arlen                         ,
    output [2:0]                            m_axi_arsize                        ,
    output reg                              m_axi_arvalid                       ,
    input                                   m_axi_arready                       ,

    input [3:0]                             m_axi_rid                           ,
    input                                   m_axi_ruser                         ,
    input [AXI_RD_DATA_WIDTH - 1 : 0]       m_axi_rdata                         ,
    input                                   m_axi_rvalid                        ,
    input                                   m_axi_rlast                         ,
    input [1:0]                             m_axi_rresp                         ,
    output                                  m_axi_rready
    );

    localparam                              AXI_RD_IDLE     = 2'b00             ;
    localparam                              AXI_RD_PRE      = 2'b01             ;
    localparam                              AXI_RD_READ     = 2'b11             ;
    localparam                              AXI_RD_END      = 2'b10             ;

    reg [1:0]                               cur_state                           ;
    reg [1:0]                               nex_state                           ;

    assign              m_axi_rready = 1'b1                                     ;
    assign              axi_ar_ready = (cur_state == AXI_RD_PRE)                ;

    assign              m_axi_arid      = 4'b0                                  ;
    assign              m_axi_arburst   = 2'b1                                  ;
    assign              m_axi_arlock    = 1'b0                                  ;
    assign              m_axi_arcache   = 4'b0                                  ;
    assign              m_axi_arprot    = 3'b0                                  ;
    assign              m_axi_arqos     = 4'b0                                  ;
    assign              m_axi_aruser    = 1'b0                                  ;
    assign              m_axi_arsize    =   AXI_RD_DATA_WIDTH == 512 ? 3'h6 :
                                            AXI_RD_DATA_WIDTH == 256 ? 3'h5 :
                                            AXI_RD_DATA_WIDTH == 128 ? 3'h4 :
                                            AXI_RD_DATA_WIDTH == 64  ? 3'h3 :
                                            AXI_RD_DATA_WIDTH == 32  ? 3'h2 : 3'h0  ;

    (* dont_touch = "true" *) reg async_reset_n_d       ;
    (* dont_touch = "true" *) reg async_reset_n_2d      ;
    (* dont_touch = "true" *) reg async_reset_n         ;

    always@(posedge axi_clk)begin
        async_reset_n_d     <= user_reset_n             ;
        async_reset_n_2d    <= async_reset_n_d          ;
        async_reset_n       <= async_reset_n_2d         ;
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            cur_state <= AXI_RD_IDLE;
        else
            cur_state <= nex_state;
    end

    always@(*)begin
        if(!async_reset_n)
            nex_state <= AXI_RD_IDLE;
        else begin
            case(cur_state)
                AXI_RD_IDLE : nex_state <= (axi_rd_req == 1) ? AXI_RD_PRE : cur_state;
                AXI_RD_PRE  : nex_state <= AXI_RD_READ;
                AXI_RD_READ : nex_state <= (m_axi_rready & m_axi_rvalid & m_axi_rlast) ? AXI_RD_END : cur_state;
                AXI_RD_END  : nex_state <= AXI_RD_IDLE;
                default     : nex_state <= AXI_RD_IDLE;                               
            endcase
        end
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            m_axi_arvalid <= 1'b0;
        else if(m_axi_arvalid & m_axi_arready)
            m_axi_arvalid <= 1'b0;
        else if(axi_rd_req & axi_ar_ready)
            m_axi_arvalid <= 1'b1;
        else
            m_axi_arvalid <= m_axi_arvalid;
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)begin
            m_axi_araddr <= 'd0;
            m_axi_arlen  <= 'd0;
        end else if(axi_rd_req & axi_ar_ready)begin
            m_axi_araddr <= axi_ar_addr;
            m_axi_arlen  <= axi_ar_length[7:0];
        end
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)begin
            axi_r_valid <= 1'b0;
            axi_r_data  <= 'd0;
            axi_r_last  <= 1'b0;
        end else begin
            axi_r_valid <= m_axi_rvalid;
            axi_r_data  <= m_axi_rdata;
            axi_r_last  <= m_axi_rlast;            
        end
    end   
endmodule