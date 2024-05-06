module zc_m_axi_wr_0_channel#(
    ADDR_WIDTH                          =   32                      ,
    USER_WR_DATA_WIDTH                  =   16                      ,
    AXI_WR_DATA_WIDTH                   =   128                     
)(
    input                                   user_clk                ,
    input                                   axi_clk                 ,
    input                                   user_reset_n            ,

    input                                   mc_init_done            ,

    input                                   user_wr_en              ,
    input [USER_WR_DATA_WIDTH - 1 : 0]      user_wr_data            ,
    input [ADDR_WIDTH - 1 : 0]              user_wr_base_addr       ,
    input [ADDR_WIDTH - 1 : 0]              user_wr_end_addr        ,

    output [3:0]                            m_axi_awid              ,
    output [1:0]                            m_axi_awburst           ,
    output                                  m_axi_awlock            ,
    output [3:0]                            m_axi_awcache           ,
    output [2:0]                            m_axi_awprot            ,
    output [3:0]                            m_axi_awqos             ,
    output                                  m_axi_awuser            ,
    output [ADDR_WIDTH - 1 : 0]             m_axi_awaddr            ,
    output [7:0]                            m_axi_awlen             ,
    output [2:0]                            m_axi_awsize            ,
    output                                  m_axi_awvalid           ,
    input                                   m_axi_awready           ,

    output [AXI_WR_DATA_WIDTH - 1 : 0]      m_axi_wdata             ,
    output [AXI_WR_DATA_WIDTH/8 - 1 : 0]    m_axi_wstrb             ,
    output                                  m_axi_wvalid            ,
    output                                  m_axi_wlast             ,
    output                                  m_axi_wuser             ,
    input                                   m_axi_wready            ,

    input [3:0]                             m_axi_bid               ,
    input [1:0]                             m_axi_bresp             ,
    input                                   m_axi_buser             ,
    input                                   m_axi_bvalid            ,
    output                                  m_axi_bready
);

    wire [AXI_WR_DATA_WIDTH - 1 : 0]        buffer_wr_data          ;
    wire                                    buffer_wr_data_valid    ;
    wire                                    buffer_wr_data_last     ;
    wire [8:0]                              buffer_burst_length     ;
    wire [ADDR_WIDTH - 1 : 0]               buffer_wr_addr          ;
    wire                                    axi_awready             ;
    wire [ADDR_WIDTH - 1 : 0]               axi_awaddr              ;
    wire [8:0]                              axi_awlength            ;
    wire                                    axi_wr_req              ;
    wire                                    axi_wready              ;
    wire [AXI_WR_DATA_WIDTH - 1 : 0]        axi_wdata               ;
    wire                                    axi_wlast               ;
    wire                                    axi_wvalid              ;       

    zc_m_axi_wr_1_user_itf#(
        .ADDR_WIDTH             (   ADDR_WIDTH          ),
        .USER_WR_DATA_WIDTH     (   USER_WR_DATA_WIDTH  ),
        .AXI_WR_DATA_WIDTH      (   AXI_WR_DATA_WIDTH   )
    )u_zc_m_axi_wr_1_user_itf(
        .user_clk               ( user_clk              ),
        .user_reset_n           ( user_reset_n          ),
        .mc_init_done           ( mc_init_done          ),
        .user_wr_en             ( user_wr_en            ),
        .user_wr_data           ( user_wr_data          ),
        .user_wr_base_addr      ( user_wr_base_addr     ),
        .user_wr_end_addr       ( user_wr_end_addr      ),
        .buffer_wr_data         ( buffer_wr_data        ),
        .buffer_wr_data_valid   ( buffer_wr_data_valid  ),
        .buffer_wr_data_last    ( buffer_wr_data_last   ),
        .buffer_burst_length    ( buffer_burst_length   ),
        .buffer_wr_addr         ( buffer_wr_addr        )
    );

    zc_m_axi_wr_2_buffer#(
        .ADDR_WIDTH             ( ADDR_WIDTH            ),
        .AXI_WR_DATA_WIDTH      ( AXI_WR_DATA_WIDTH     )
    )u_zc_m_axi_wr_2_buffer(
        .user_clk               ( user_clk              ),
        .user_reset_n           ( user_reset_n          ),
        .buffer_wr_data         ( buffer_wr_data        ),
        .buffer_wr_data_valid   ( buffer_wr_data_valid  ),
        .buffer_wr_data_last    ( buffer_wr_data_last   ),
        .buffer_burst_length    ( buffer_burst_length   ),
        .buffer_wr_addr         ( buffer_wr_addr        ),
        .axi_clk                ( axi_clk               ),
        .axi_awready            ( axi_awready           ),
        .axi_awaddr             ( axi_awaddr            ),
        .axi_awlength           ( axi_awlength          ),
        .axi_wr_req             ( axi_wr_req            ),
        .axi_wready             ( axi_wready            ),
        .axi_wdata              ( axi_wdata             ),
        .axi_wlast              ( axi_wlast             ),
        .axi_wvalid             ( axi_wvalid            )
    );

    zc_m_axi_wr_3_axi_itf#(
        .ADDR_WIDTH             ( ADDR_WIDTH            ),
        .AXI_WR_DATA_WIDTH      ( AXI_WR_DATA_WIDTH     )
    )u_zc_m_axi_wr_3_axi_itf(
        .axi_clk                ( axi_clk               ),
        .user_reset_n           ( user_reset_n          ),
        .axi_aw_addr            ( axi_awaddr            ),
        .axi_aw_length          ( axi_awlength          ),
        .axi_wr_req             ( axi_wr_req            ),
        .axi_aw_ready           ( axi_awready           ),
        .axi_w_data             ( axi_wdata             ),
        .axi_w_last             ( axi_wlast             ),
        .axi_w_valid            ( axi_wvalid            ),
        .axi_w_ready            ( axi_wready            ),
        .m_axi_awid             ( m_axi_awid            ),
        .m_axi_awburst          ( m_axi_awburst         ),
        .m_axi_awlock           ( m_axi_awlock          ),
        .m_axi_awcache          ( m_axi_awcache         ),
        .m_axi_awprot           ( m_axi_awprot          ),
        .m_axi_awqos            ( m_axi_awqos           ),
        .m_axi_awuser           ( m_axi_awuser          ),
        .m_axi_awaddr           ( m_axi_awaddr          ),
        .m_axi_awlen            ( m_axi_awlen           ),
        .m_axi_awsize           ( m_axi_awsize          ),
        .m_axi_awvalid          ( m_axi_awvalid         ),
        .m_axi_awready          ( m_axi_awready         ),
        .m_axi_wdata            ( m_axi_wdata           ),
        .m_axi_wstrb            ( m_axi_wstrb           ),
        .m_axi_wvalid           ( m_axi_wvalid          ),
        .m_axi_wlast            ( m_axi_wlast           ),
        .m_axi_wuser            ( m_axi_wuser           ),
        .m_axi_wready           ( m_axi_wready          ),
        .m_axi_bid              ( m_axi_bid             ),
        .m_axi_bresp            ( m_axi_bresp           ),
        .m_axi_buser            ( m_axi_buser           ),
        .m_axi_bvalid           ( m_axi_bvalid          ),
        .m_axi_bready           ( m_axi_bready          )
    );

endmodule