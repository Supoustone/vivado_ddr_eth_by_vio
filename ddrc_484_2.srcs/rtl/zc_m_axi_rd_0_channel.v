module zc_m_axi_rd_0_channel#(
    parameter                               ADDR_WIDTH              = 32        ,
    parameter                               USER_RD_DATA_WIDTH      = 16        ,
    parameter                               AXI_RD_DATA_WIDTH       = 128
)(
    input                                   user_clk                            ,
    input                                   axi_clk                             ,
    input                                   user_reset_n                        ,
    input                                   mc_init_done                        ,

    input                                   user_rd_en                          ,
    input [ADDR_WIDTH - 1 : 0]              user_rd_base_addr                   ,
    input [ADDR_WIDTH - 1 : 0]              user_rd_end_addr                    ,
    output                                  user_rd_busy                        ,

    output                                  user_rd_valid                       ,
    output [USER_RD_DATA_WIDTH - 1 : 0]     user_rd_data                        ,
    output                                  user_rd_last                        ,

    output [3:0]                            m_axi_arid                          ,
    output [1:0]                            m_axi_arburst                       ,
    output                                  m_axi_arlock                        ,
    output [3:0]                            m_axi_arcache                       ,
    output [2:0]                            m_axi_arprot                        ,
    output [3:0]                            m_axi_arqos                         ,
    output                                  m_axi_aruser                        ,

    output [ADDR_WIDTH - 1 : 0]             m_axi_araddr                        ,
    output [7:0]                            m_axi_arlen                         ,
    output [2:0]                            m_axi_arsize                        ,
    output                                  m_axi_arvalid                       ,
    input                                   m_axi_arready                       ,

    input [3:0]                             m_axi_rid                           ,
    input                                   m_axi_ruser                         ,
    input [AXI_RD_DATA_WIDTH - 1 : 0]       m_axi_rdata                         ,
    input                                   m_axi_rvalid                        ,
    input                                   m_axi_rlast                         ,
    input [1:0]                             m_axi_rresp                         ,
    output                                  m_axi_rready
);

    wire [8:0]                              buffer_burst_length                 ;
    wire [ADDR_WIDTH - 1 : 0]               buffer_rd_addr                      ;
    wire                                    read_req_en                         ;
    wire                                    user_rd_ready                       ;

    wire                                    axi_ar_ready                        ;
    wire [ADDR_WIDTH - 1 : 0]               axi_ar_addr                         ;
    wire [8:0]                              axi_ar_length                       ;
    wire                                    axi_rd_req                          ;
    wire                                    axi_r_valid                         ;
    wire [AXI_RD_DATA_WIDTH - 1 : 0]        axi_r_data                          ;
    wire                                    axi_r_last                          ;


    zc_m_axi_rd_1_user_itf#(
        .ADDR_WIDTH             (   ADDR_WIDTH                  ),
        .USER_RD_DATA_WIDTH     (   USER_RD_DATA_WIDTH          ),
        .AXI_RD_DATA_WIDTH      (   AXI_RD_DATA_WIDTH           )
    )u_zc_m_axi_rd_1_user_itf(
        .user_clk               ( user_clk                      ),
        .user_reset_n           ( user_reset_n                  ),
        .mc_init_done           ( mc_init_done                  ),
        .user_rd_en             ( user_rd_en                    ),
        .user_rd_busy           ( user_rd_busy                  ),
        .user_rd_base_addr      ( user_rd_base_addr             ),
        .user_rd_end_addr       ( user_rd_end_addr              ),
        .buffer_burst_length    ( buffer_burst_length           ),
        .buffer_rd_addr         ( buffer_rd_addr                ),
        .read_req_en            ( read_req_en                   ),
        .user_rd_ready          ( user_rd_ready                 )
    );

    zc_m_axi_rd_2_buffer#(
        .ADDR_WIDTH             ( ADDR_WIDTH                    ),
        .USER_RD_DATA_WIDTH     ( USER_RD_DATA_WIDTH            ),
        .AXI_RD_DATA_WIDTH      ( AXI_RD_DATA_WIDTH             )
    )u_zc_m_axi_rd_2_buffer(
        .user_clk               ( user_clk                      ),
        .user_reset_n           ( user_reset_n                  ),
        .axi_clk                ( axi_clk                       ),
        .buffer_burst_length    ( buffer_burst_length           ),
        .buffer_rd_addr         ( buffer_rd_addr                ),
        .read_req_en            ( read_req_en                   ),
        .user_rd_ready          ( user_rd_ready                 ),
        .axi_ar_ready           ( axi_ar_ready                  ),
        .axi_ar_addr            ( axi_ar_addr                   ),
        .axi_ar_length          ( axi_ar_length                 ),
        .axi_rd_req             ( axi_rd_req                    ),
        .axi_r_valid            ( axi_r_valid                   ),
        .axi_r_data             ( axi_r_data                    ),
        .axi_r_last             ( axi_r_last                    ),
        .user_rd_valid          ( user_rd_valid                 ),
        .user_rd_data           ( user_rd_data                  ),
        .user_rd_last           ( user_rd_last                  )
    );

    zc_m_axi_rd_3_axi_itf#(
        .ADDR_WIDTH             ( ADDR_WIDTH                    ),
        .AXI_RD_DATA_WIDTH      ( AXI_RD_DATA_WIDTH             ),
        .USER_RD_DATA_WIDTH     ( USER_RD_DATA_WIDTH            )
    )u_zc_m_axi_rd_3_axi_itf(
        .axi_clk                ( axi_clk                       ),
        .user_reset_n           ( user_reset_n                  ),
        .axi_ar_ready           ( axi_ar_ready                  ),
        .axi_ar_addr            ( axi_ar_addr                   ),
        .axi_ar_length          ( axi_ar_length                 ),
        .axi_rd_req             ( axi_rd_req                    ),
        .axi_r_valid            ( axi_r_valid                   ),
        .axi_r_data             ( axi_r_data                    ),
        .axi_r_last             ( axi_r_last                    ),
        .m_axi_arid             ( m_axi_arid                    ),
        .m_axi_arburst          ( m_axi_arburst                 ),
        .m_axi_arlock           ( m_axi_arlock                  ),
        .m_axi_arcache          ( m_axi_arcache                 ),
        .m_axi_arprot           ( m_axi_arprot                  ),
        .m_axi_arqos            ( m_axi_arqos                   ),
        .m_axi_aruser           ( m_axi_aruser                  ),
        .m_axi_araddr           ( m_axi_araddr                  ),
        .m_axi_arlen            ( m_axi_arlen                   ),
        .m_axi_arsize           ( m_axi_arsize                  ),
        .m_axi_arvalid          ( m_axi_arvalid                 ),
        .m_axi_arready          ( m_axi_arready                 ),
        .m_axi_rid              ( m_axi_rid                     ),
        .m_axi_ruser            ( m_axi_ruser                   ),
        .m_axi_rdata            ( m_axi_rdata                   ),
        .m_axi_rvalid           ( m_axi_rvalid                  ),
        .m_axi_rlast            ( m_axi_rlast                   ),
        .m_axi_rresp            ( m_axi_rresp                   ),
        .m_axi_rready           ( m_axi_rready                  )
    );
endmodule