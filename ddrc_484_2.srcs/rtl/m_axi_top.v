module m_axi_top#(
    parameter                               ADDR_WIDTH          = 32        ,
    parameter                               USER_WR_DATA_WIDTH  = 16        ,
    parameter                               AXI_WR_DATA_WIDTH   = 128       ,

    parameter                               USER_RD_DATA_WIDTH  = 16        ,
    parameter                               AXI_RD_DATA_WIDTH   = 128       
)(

    input                                   user_clk                        ,
    input                                   axi_clk                         ,
    input                                   user_reset_n                    ,

    (* mark_debug = "true" *) input                                   mc_init_done                    ,

    output                                  user_rd_busy                    ,

    output                                  user_rd_valid                   , 
    output [USER_RD_DATA_WIDTH - 1 : 0]     user_rd_data                    , 
    output                                  user_rd_last                    , 

    output [3:0]                            m_axi_awid                      ,
    output [1:0]                            m_axi_awburst                   ,
    output                                  m_axi_awlock                    ,
    output [3:0]                            m_axi_awcache                   ,
    output [2:0]                            m_axi_awprot                    ,
    output [3:0]                            m_axi_awqos                     ,
    output                                  m_axi_awuser                    ,
    /*(* mark_debug = "true" *) */output [ADDR_WIDTH - 1 : 0]             m_axi_awaddr                    ,
    output [7:0]                            m_axi_awlen                     ,
    output [2:0]                            m_axi_awsize                    ,
    output                                  m_axi_awvalid                   ,
    input                                   m_axi_awready                   ,

    /*(* mark_debug = "true" *) */output [AXI_WR_DATA_WIDTH - 1 : 0]      m_axi_wdata                     ,
    output [AXI_WR_DATA_WIDTH/8 - 1 : 0]    m_axi_wstrb                     ,
    output                                  m_axi_wvalid                    ,
    (* mark_debug = "true" *) output                                  m_axi_wlast                     ,
    output                                  m_axi_wuser                     ,
    input                                   m_axi_wready                    ,

    input [3:0]                             m_axi_bid                       ,
    input [1:0]                             m_axi_bresp                     ,
    input                                   m_axi_buser                     ,
    input                                   m_axi_bvalid                    ,
    output                                  m_axi_bready                    ,

    output [3:0]                            m_axi_arid                      ,
    output [1:0]                            m_axi_arburst                   ,
    output                                  m_axi_arlock                    ,
    output [3:0]                            m_axi_arcache                   ,
    output [2:0]                            m_axi_arprot                    ,
    output [3:0]                            m_axi_arqos                     ,
    output                                  m_axi_aruser                    ,

    /*(* mark_debug = "true" *) */output [ADDR_WIDTH - 1 : 0]             m_axi_araddr                    ,
    output [7:0]                            m_axi_arlen                     ,
    output [2:0]                            m_axi_arsize                    ,
    output                                  m_axi_arvalid                   ,
    input                                   m_axi_arready                   ,

    input [3:0]                             m_axi_rid                       ,
    input                                   m_axi_ruser                     ,
    (* mark_debug = "true" *) input [AXI_RD_DATA_WIDTH - 1 : 0]       m_axi_rdata                     ,
    (* mark_debug = "true" *) input                                   m_axi_rvalid                    ,
    (* mark_debug = "true" *) input                                   m_axi_rlast                     ,
    input [1:0]                             m_axi_rresp                     ,
    output                                  m_axi_rready
);

    wire                                   user_wr_en                      ;
    wire [USER_WR_DATA_WIDTH - 1 : 0]      user_wr_data                    ;

    wire                                   user_rd_en                      ; 

    zc_m_axi_0_traffic_generator#(
        .ADDR_WIDTH         ( ADDR_WIDTH         ),
        .USER_WR_DATA_WIDTH ( USER_WR_DATA_WIDTH )
    )u_zc_m_axi_0_traffic_generator(
        .user_clk      ( user_clk      ),
        .user_reset_n  ( user_reset_n  ),
        .mc_init_done  ( mc_init_done  ),
        .user_wr_data  ( user_wr_data  ),
        .user_wr_en    ( user_wr_en    ),
        .user_rd_req   ( user_rd_en    )
    );

    zc_m_axi_0_top#(
        .ADDR_WIDTH         ( ADDR_WIDTH         ),
        .USER_WR_DATA_WIDTH ( USER_WR_DATA_WIDTH ),
        .AXI_WR_DATA_WIDTH  ( AXI_WR_DATA_WIDTH  ),

        .USER_RD_DATA_WIDTH ( USER_RD_DATA_WIDTH ),
        .AXI_RD_DATA_WIDTH  ( AXI_RD_DATA_WIDTH  )
    )u_zc_m_axi_0_top(
        .user_clk           ( user_clk           ),
        .axi_clk            ( axi_clk            ),
        .user_reset_n       ( user_reset_n       ),
        .mc_init_done       ( mc_init_done       ),
        .user_wr_en         ( user_wr_en         ),
        .user_wr_data       ( user_wr_data       ),
        .user_wr_base_addr  ( {5'b0 , 3'd2 , 14'h10 , 10'h0}   ),
        .user_wr_end_addr   ( {5'b0 , 3'd2 , 14'h20 , 10'h0}   ),
        .user_rd_en         ( user_rd_en         ),
        .user_rd_base_addr  (  {5'b0 , 3'd2 , 14'h10 , 10'h0}  ),
        .user_rd_end_addr   (  {5'b0 , 3'd2 , 14'h20 , 10'h0}  ),
        .user_rd_busy       ( user_rd_busy       ),
        .user_rd_valid      ( user_rd_valid      ),
        .user_rd_data       ( user_rd_data       ),
        .user_rd_last       ( user_rd_last       ),
        .m_axi_awid         ( m_axi_awid         ),
        .m_axi_awburst      ( m_axi_awburst      ),
        .m_axi_awlock       ( m_axi_awlock       ),
        .m_axi_awcache      ( m_axi_awcache      ),
        .m_axi_awprot       ( m_axi_awprot       ),
        .m_axi_awqos        ( m_axi_awqos        ),
        .m_axi_awuser       ( m_axi_awuser       ),
        .m_axi_awaddr       ( m_axi_awaddr       ),
        .m_axi_awlen        ( m_axi_awlen        ),
        .m_axi_awsize       ( m_axi_awsize       ),
        .m_axi_awvalid      ( m_axi_awvalid      ),
        .m_axi_awready      ( m_axi_awready      ),
        .m_axi_wdata        ( m_axi_wdata        ),
        .m_axi_wstrb        ( m_axi_wstrb        ),
        .m_axi_wvalid       ( m_axi_wvalid       ),
        .m_axi_wlast        ( m_axi_wlast        ),
        .m_axi_wuser        ( m_axi_wuser        ),
        .m_axi_wready       ( m_axi_wready       ),
        .m_axi_bid          ( m_axi_bid          ),
        .m_axi_bresp        ( m_axi_bresp        ),
        .m_axi_buser        ( m_axi_buser        ),
        .m_axi_bvalid       ( m_axi_bvalid       ),
        .m_axi_bready       ( m_axi_bready       ),
        .m_axi_arid         ( m_axi_arid         ),
        .m_axi_arburst      ( m_axi_arburst      ),
        .m_axi_arlock       ( m_axi_arlock       ),
        .m_axi_arcache      ( m_axi_arcache      ),
        .m_axi_arprot       ( m_axi_arprot       ),
        .m_axi_arqos        ( m_axi_arqos        ),
        .m_axi_aruser       ( m_axi_aruser       ),
        .m_axi_araddr       ( m_axi_araddr       ),
        .m_axi_arlen        ( m_axi_arlen        ),
        .m_axi_arsize       ( m_axi_arsize       ),
        .m_axi_arvalid      ( m_axi_arvalid      ),
        .m_axi_arready      ( m_axi_arready      ),
        .m_axi_rid          ( m_axi_rid          ),
        .m_axi_ruser        ( m_axi_ruser        ),
        .m_axi_rdata        ( m_axi_rdata        ),
        .m_axi_rvalid       ( m_axi_rvalid       ),
        .m_axi_rlast        ( m_axi_rlast        ),
        .m_axi_rresp        ( m_axi_rresp        ),
        .m_axi_rready       ( m_axi_rready       )
    );

endmodule