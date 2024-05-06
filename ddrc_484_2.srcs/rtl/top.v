module top(
    input               fpga_clk_50mhz          ,

    output              ddr3_ck_p               ,                   
    output              ddr3_ck_n               ,      
    output              ddr3_cke                ,          
    output              ddr3_reset_n            ,        
    output              ddr3_ras_n              ,             
    output              ddr3_cas_n              ,              
    output              ddr3_we_n               ,                  
    output              ddr3_cs_n               ,                
    output [2  : 0]     ddr3_ba                 ,                
    output [13 : 0]     ddr3_addr               ,                
    output              ddr3_odt                ,                   
    output [1  : 0]     ddr3_dm                 ,                     
    inout  [1  : 0]     ddr3_dqs_p              ,               
    inout  [1  : 0]     ddr3_dqs_n              ,               
    inout  [15 : 0]     ddr3_dq                 ,

	input               phy_rgmii_rx_clk        ,
	input               phy_rgmii_rx_ctl        ,
	input [3:0]         phy_rgmii_rx_data       ,

	output              phy_rgmii_tx_clk        ,
	output              phy_rgmii_tx_ctl        ,
	output [3:0]        phy_rgmii_tx_data       ,

	output              phy_reset
);

    reg    [10 : 0]     fpga_rst_n_cnt          ;

    wire                fpga_rst_n              ;
    wire                clkout_100m             ;
    wire                clkout_400m             ;
    wire                clkout_200m             ;
    wire                clkout_400m_shift_90    ;
    wire                sys_rst_n               ;

    wire [15  : 0]      outport_wr_o            ;       
    wire                outport_rd_o            ;           
    wire [31  : 0]      outport_addr_o          ;     
    wire [127 : 0]      outport_wr_data_o       ;     
    wire                inport_accept_o         ;      
    wire                inport_ack_o            ;     
    wire [127 : 0]      inport_rd_data_o        ;        
    wire                inport_rd_data_vld_o    ;

    wire                mc_init_done            ;


    wire  [3  : 0]      m_axi_awid              ;      
    wire  [31 : 0]      m_axi_awaddr            ;              
    wire  [7  : 0]      m_axi_awlen             ;            
    wire  [2  : 0]      m_axi_awsize            ;             
    wire  [1  : 0]      m_axi_awburst           ;             
    wire                m_axi_awlock            ;                 
    wire  [3  : 0]      m_axi_awcache           ;                                
    wire  [2  : 0]      m_axi_awprot            ;                             
    wire  [3  : 0]      m_axi_awqos             ;                          
    wire                m_axi_awuser            ;                             
    wire                m_axi_awvalid           ;                                 
    wire                m_axi_awready           ;                 
    /* (* mark_debug = "true" *) */ wire  [127: 0]      m_axi_wdata             ;               
    wire  [15 : 0]      m_axi_wstrb             ;  
    /* (* mark_debug = "true" *) */ wire                m_axi_wlast             ;
    wire                m_axi_wuser             ;
    /* (* mark_debug = "true" *)  */wire                m_axi_wvalid            ;
    wire                m_axi_wready            ;
    wire  [3  : 0]      m_axi_bid               ;
    wire  [1  : 0]      m_axi_bresp             ;
    wire                m_axi_buser             ;
    wire                m_axi_bvalid            ;
    wire                m_axi_bready            ;
    wire  [3  : 0]      m_axi_arid              ;
    wire  [31 : 0]      m_axi_araddr            ;
    wire  [7  : 0]      m_axi_arlen             ;
    wire  [2  : 0]      m_axi_arsize            ;
    wire  [1  : 0]      m_axi_arburst           ;
    wire                m_axi_arlock            ;
    wire  [3  : 0]      m_axi_arcache           ;
    wire  [2  : 0]      m_axi_arprot            ;
    wire  [3  : 0]      m_axi_arqos             ;
    wire                m_axi_aruser            ;
    wire                m_axi_arvalid           ;
    wire                m_axi_arready           ;
    wire  [3  : 0]      m_axi_rid               ;
    /*(* mark_debug = "true" *) */ wire  [127: 0]      m_axi_rdata             ;
    wire  [1  : 0]      m_axi_rresp             ;
    /*(* mark_debug = "true" *) */ wire                m_axi_rlast             ;
    wire                m_axi_ruser             ;
    wire                m_axi_rvalid            ;
    wire                m_axi_rready            ;

    wire                aw_fifo_full            ;
    wire                ar_fifo_full            ; 

    wire                user_wr_en              ;
    wire [15:0]         user_wr_data            ;
    wire                user_rd_en              ;

    wire                user_rd_busy            ;
    (* mark_debug = "true" *) wire                user_rd_valid           ;
    (* mark_debug = "true" *) wire [7:0]          user_rd_data            ;
    (* mark_debug = "true" *) wire                user_rd_last            ;

	parameter   LOCAL_MAC_ADDR  = {8'h48,8'h2c,8'ha0,8'hdf,8'h00,8'hff}   ;
	parameter   TARGET_MAC_ADDR = {8'hbc,8'hec,8'ha0,8'h18,8'h2f,8'hdd}   ;
	parameter   LOCAL_IP_ADDR   = {8'd169,8'd254,8'd157,8'd100}           ;
	parameter   TARGET_IP_ADDR  = {8'd169,8'd254,8'd157,8'd112}           ;
	parameter   LOCAL_PORT      = 16'd1234                                ;
	parameter   TARGET_PORT     = 16'd1234                                ;

    wire        clkout_25m_eth          ;
    wire        clkout_50m_eth          ;
    wire        clkout_125m_eth         ;
    wire        clkout_200m_eth         ;
    wire        reset               ;

    assign      phy_reset = ~reset  ;

    wire        phy_rx_clk          ;

	wire			gmii_rx_vld     ;
	wire			gmii_rx_error   ;
	wire	[7:0]	gmii_rx_data    ;
	wire			gmii_tx_vld     ;
	wire	[7:0]	gmii_tx_data    ;

	wire        app_rx_data_vld     ;
	wire        app_rx_data_last    ;
	wire  [7:0] app_rx_data         ;
	wire [15:0] app_rx_length       ;


    (* dont_touch = "true" *) (* mark_debug = "true" *) wire app_tx_data_vld          ;
    (* dont_touch = "true" *) (* mark_debug = "true" *) wire app_tx_data_last         ;
    (* dont_touch = "true" *) (* mark_debug = "true" *) wire [7:0] app_tx_data        ;
    (* dont_touch = "true" *)                           wire [15:0] app_tx_length     ;
    (* dont_touch = "true" *) (* mark_debug = "true" *) wire app_tx_ready             ;

    assign              fpga_rst_n = (fpga_rst_n_cnt >= 160);

    always@(posedge fpga_clk_50mhz)begin
        if(fpga_rst_n_cnt  <= 170)
            fpga_rst_n_cnt <= fpga_rst_n_cnt + 1'b1;
        else
            fpga_rst_n_cnt <= fpga_rst_n_cnt;
    end

    zc_ddr_clk_gen u_zc_ddr_clk_gen(
        .outer_clkin_50m        ( fpga_clk_50mhz        ),
        .outer_rst_n            ( fpga_rst_n            ),
        .clkout_100m            ( clkout_100m           ),
        .clkout_400m            ( clkout_400m           ),
        .clkout_200m            ( clkout_200m           ),
        .clkout_400m_shift_90   ( clkout_400m_shift_90  ),
        .sys_rst_n              ( sys_rst_n             )
    );

    eth_clock_and_reset u_clock_and_reset(
        .clk_in_50m    ( fpga_clk_50mhz ),
        .clk_out_25m   ( clkout_25m_eth     ),
        .clk_out_50m   ( clkout_50m_eth     ),
        .clk_out_125m  ( clkout_125m_eth    ),
        .clk_out_200m  ( clkout_200m_eth    ),
        .reset         ( reset          )
    );

    user_rw_req_generate#(
    .USER_WR_DATA_WIDTH ( 16 )
    )u_user_rw_req_generate(
        .wr_clk        ( fpga_clk_50mhz                 ),
        .rd_clk        ( fpga_clk_50mhz                 ),
        .clk_100m      ( clkout_100m                    ),
        .reset         ( ~sys_rst_n                     ),
        .user_wr_en    ( user_wr_en                     ),
        .user_wr_data  ( user_wr_data                   ),
        .user_rd_req   ( user_rd_en                     )
    );      

    zc_m_axi_0_top#(
        .ADDR_WIDTH         ( 32                 ),
        .USER_WR_DATA_WIDTH ( 16                 ),
        .AXI_WR_DATA_WIDTH  ( 128                ),

        .USER_RD_DATA_WIDTH ( 8                  ),
        .AXI_RD_DATA_WIDTH  ( 128                )
    )u_zc_m_axi_0_top(
        .user_clk           ( fpga_clk_50mhz     ),
        .axi_clk            ( fpga_clk_50mhz     ),
        .user_reset_n       ( sys_rst_n          ),
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

    ddr_to_eth_send u_ddr_to_eth_send(
        .clk               ( fpga_clk_50mhz    ),
        .reset             ( ~sys_rst_n        ),
        .user_rd_valid     ( user_rd_valid     ),
        .user_rd_last      ( user_rd_last      ),
        .user_rd_data      ( user_rd_data      ),
        .app_tx_data_vld   ( app_tx_data_vld   ),
        .app_tx_data_last  ( app_tx_data_last  ),
        .app_tx_data       ( app_tx_data       ),
        .app_tx_length     ( app_tx_length     ),
        .app_tx_ready      ( app_tx_ready      )//
    );

    rgmii_interface u_rgmii_interface(
        .reset               ( reset                ),

        .delay_ref_200m_clk  ( clkout_200m_eth      ),

        .phy_rgmii_rx_clk    ( phy_rgmii_rx_clk     ),
        .phy_rgmii_rx_ctl    ( phy_rgmii_rx_ctl     ),
        .phy_rgmii_rx_data   ( phy_rgmii_rx_data    ),

        .gmii_rx_clk         ( phy_rx_clk           ),
        .gmii_rx_vld         ( gmii_rx_vld          ),
        .gmii_rx_error       ( gmii_rx_error        ),
        .gmii_rx_data        ( gmii_rx_data         ),


        .phy_rgmii_tx_clk    ( phy_rgmii_tx_clk     ),
        .phy_rgmii_tx_ctl    ( phy_rgmii_tx_ctl     ),
        .phy_rgmii_tx_data   ( phy_rgmii_tx_data    ),

        .gmii_tx_clk         ( clkout_125m_eth      ),
        .gmii_tx_vld         ( gmii_tx_vld          ),
        .gmii_tx_data        ( gmii_tx_data         )
    );

    udp_protocol_stack#(
        .LOCAL_MAC_ADDR    ( LOCAL_MAC_ADDR         ),
        .TARGET_MAC_ADDR   ( TARGET_MAC_ADDR        ),
        .LOCAL_IP_ADDR     ( LOCAL_IP_ADDR          ),
        .TARGET_IP_ADDR    ( TARGET_IP_ADDR         ),
        .LOCAL_PORT        ( LOCAL_PORT             ),
        .TARGET_PORT       ( TARGET_PORT            )
    )u_udp_protocol_stack(
        .phy_tx_clk        ( clkout_125m_eth        ),
        .phy_rx_clk        ( phy_rx_clk             ),
        .reset             ( reset                  ),

        .gmii_rx_data_vld  ( gmii_rx_vld            ),
        .gmii_rx_data      ( gmii_rx_data           ),
        .gmii_tx_data_vld  ( gmii_tx_vld            ),
        .gmii_tx_data      ( gmii_tx_data           ),

        .app_rx_clk        ( fpga_clk_50mhz         ),
        .app_rx_data_vld   ( app_rx_data_vld        ),
        .app_rx_data_last  ( app_rx_data_last       ),
        .app_rx_data       ( app_rx_data            ),
        .app_rx_length     ( app_rx_length          ),

        .app_tx_clk        ( fpga_clk_50mhz         ),
        .app_tx_data_vld   ( app_tx_data_vld        ),
        .app_tx_data_last  ( app_tx_data_last       ),
        .app_tx_data       ( app_tx_data            ),
        .app_tx_length     ( app_tx_length          ),
        .app_tx_ready      ( app_tx_ready           )
    );

    zc_ddr3_axi_slave_itf#(
        .AXI_ID_WIDTH     (     4           ),
        .AXI_DATA_WIDTH   (     128         ),  
        .AXI_ADDR_WIDTH   (     32          ),
        .AXI_AWUSER_WIDTH (     1           ),
        .AXI_ARUSER_WIDTH (     1           ),
        .AXI_WUSER_WIDTH  (     1           ),
        .AXI_RUSER_WIDTH  (     1           ),
        .AXI_BUSER_WIDTH  (     1           )
    )u_zc_ddr3_axi_slave_itf(
        .s_axi_aclk             (   fpga_clk_50mhz      ),
        .s_axi_areset_n         (   sys_rst_n           ),  
        .s_axi_awid             (   m_axi_awid          ),
        .s_axi_awaddr           (   m_axi_awaddr        ), 
        .s_axi_awlen            (   m_axi_awlen         ), 
        .s_axi_awsize           (   m_axi_awsize        ), 
        .s_axi_awburst          (   m_axi_awburst       ), 
        .s_axi_awlock           (   m_axi_awlock        ),
        .s_axi_awcache          (   m_axi_awcache       ),
        .s_axi_awprot           (   m_axi_awprot        ),
        .s_axi_awqos            (   m_axi_awqos         ),
        .s_axi_awuser           (   m_axi_awuser        ),
        .s_axi_awvalid          (   m_axi_awvalid       ),
        .s_axi_awready          (   m_axi_awready       ),
        .s_axi_wdata            (   m_axi_wdata         ),
        .s_axi_wstrb            (   m_axi_wstrb         ),
        .s_axi_wlast            (   m_axi_wlast         ),
        .s_axi_wuser            (   m_axi_wuser         ),
        .s_axi_wvalid           (   m_axi_wvalid        ),
        .s_axi_wready           (   m_axi_wready        ),
        .s_axi_bid              (   m_axi_bid           ),
        .s_axi_bresp            (   m_axi_bresp         ),
        .s_axi_buser            (   m_axi_buser         ),
        .s_axi_bvalid           (   m_axi_bvalid        ),
        .s_axi_bready           (   m_axi_bready        ),
        .s_axi_arid             (   m_axi_arid          ),
        .s_axi_araddr           (   m_axi_araddr        ),
        .s_axi_arlen            (   m_axi_arlen         ),
        .s_axi_arsize           (   m_axi_arsize        ),
        .s_axi_arburst          (   m_axi_arburst       ),
        .s_axi_arlock           (   m_axi_arlock        ),
        .s_axi_arcache          (   m_axi_arcache       ),
        .s_axi_arprot           (   m_axi_arprot        ),
        .s_axi_arqos            (   m_axi_arqos         ),
        .s_axi_aruser           (   m_axi_aruser        ),
        .s_axi_arvalid          (   m_axi_arvalid       ),
        .s_axi_arready          (   m_axi_arready       ),
        .s_axi_rid              (   m_axi_rid           ),
        .s_axi_rdata            (   m_axi_rdata         ),
        .s_axi_rresp            (   m_axi_rresp         ),
        .s_axi_rlast            (   m_axi_rlast         ),
        .s_axi_ruser            (   m_axi_ruser         ),
        .s_axi_rvalid           (   m_axi_rvalid        ),
        .s_axi_rready           (   m_axi_rready        ),
        .ddrc_clk               (   clkout_100m         ),
        .inport_wr_o            (   outport_wr_o        ),
        .inport_rd_o            (   outport_rd_o        ),
        .inport_addr_o          (   outport_addr_o      ),
        .inport_wr_data_o       (   outport_wr_data_o   ),
        .inport_accept_i        (   inport_accept_o     ),
        .inport_ack_i           (   inport_ack_o        ),
        .inport_rd_data_i       (   inport_rd_data_o    ),
        .inport_rd_data_vld_i   (   inport_rd_data_vld_o),
        .aw_fifo_full           (   aw_fifo_full        ),
        .ar_fifo_full           (   ar_fifo_full        )
    );  

    zc_ddr_mig u_zc_ddr_mig(
        .clkin_100m             ( clkout_100m           ),
        .clkin_400m             ( clkout_400m           ),
        .clkin_200m             ( clkout_200m           ),
        .clkin_400m_shift_90    ( clkout_400m_shift_90  ),
        .sys_rst_n              ( sys_rst_n             ),
        .inport_wr_i            ( outport_wr_o          ),
        .inport_rd_i            ( outport_rd_o          ),
        .inport_addr_i          ( outport_addr_o        ),
        .inport_wr_data_i       ( outport_wr_data_o     ),
        .inport_accept_o        ( inport_accept_o       ),
        .inport_ack_o           ( inport_ack_o          ),
        .inport_rd_data_o       ( inport_rd_data_o      ),
        .inport_rd_data_vld_o   ( inport_rd_data_vld_o  ),
        .mc_init_done           ( mc_init_done          ),
        .ddr3_ck_p              ( ddr3_ck_p             ),
        .ddr3_ck_n              ( ddr3_ck_n             ),
        .ddr3_cke               ( ddr3_cke              ),
        .ddr3_reset_n           ( ddr3_reset_n          ),
        .ddr3_ras_n             ( ddr3_ras_n            ),
        .ddr3_cas_n             ( ddr3_cas_n            ),
        .ddr3_we_n              ( ddr3_we_n             ),
        .ddr3_cs_n              ( ddr3_cs_n             ),
        .ddr3_ba                ( ddr3_ba               ),
        .ddr3_addr              ( ddr3_addr             ),
        .ddr3_odt               ( ddr3_odt              ),
        .ddr3_dm                ( ddr3_dm               ),
        .ddr3_dqs_p             ( ddr3_dqs_p            ),
        .ddr3_dqs_n             ( ddr3_dqs_n            ),
        .ddr3_dq                ( ddr3_dq               )
    );              
endmodule