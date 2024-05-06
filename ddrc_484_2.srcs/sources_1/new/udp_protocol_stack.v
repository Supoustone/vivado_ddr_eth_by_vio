`timescale 1ns / 1ps

module udp_protocol_stack#(
    parameter       LOCAL_MAC_ADDR  = 48'hffffff_ffffff ,
    parameter       TARGET_MAC_ADDR = 48'hffffff_ffffff ,
    parameter       LOCAL_IP_ADDR   = 32'h0             ,
    parameter       TARGET_IP_ADDR  = 32'h0             ,
    parameter       LOCAL_PORT      = 16'h0             ,
    parameter       TARGET_PORT     = 16'h0
)(
    input           phy_tx_clk                  ,
    input           phy_rx_clk                  ,
    input           reset                       ,

//====================== gmii interface ============================

    input           gmii_rx_data_vld            ,
    input [7:0]     gmii_rx_data                ,
    output          gmii_tx_data_vld            ,
    output [7:0]    gmii_tx_data                ,

//====================== user receive ==============================

    input           app_rx_clk                  ,
    output          app_rx_data_vld             ,
    output          app_rx_data_last            ,
    output [7:0]    app_rx_data                 ,
    output [15:0]   app_rx_length               ,

//======================= user send ===============================

    input           app_tx_clk                  ,
    input           app_tx_data_vld             , 
    input           app_tx_data_last            ,
    input [7:0]     app_tx_data                 ,
    input [15:0]    app_tx_length               ,
    output          app_tx_ready
    );

    wire 		 app_tx_req        ;

	wire         mac_rx_data_vld   ;
	wire         mac_rx_data_last  ;
	wire   [7:0] mac_rx_data       ;
	wire  [15:0] mac_rx_frame_type ;
	wire         mac_tx_data_vld   ;
	wire         mac_tx_data_last  ;
	wire   [7:0] mac_tx_data       ;
	wire  [15:0] mac_tx_frame_type ;
	wire  [15:0] mac_tx_length     ;

	wire         ip_rx_data_vld    ;
	wire         ip_rx_data_last   ;
	wire   [7:0] ip_rx_data        ;
	wire         ip_tx_data_vld    ;
	wire         ip_tx_data_last   ;
	wire  [15:0] ip_tx_length      ;
	wire  [7:0 ] ip_tx_data        ;

	wire         udp_rx_data_vld   ;
	wire         udp_rx_data_last  ;
	wire   [7:0] udp_rx_data       ;
	wire  [15:0] udp_rx_length     ;
	wire         udp_tx_data_vld   ;
	wire         udp_tx_data_last  ;
	wire   [7:0] udp_tx_data       ;
	wire  [15:0] udp_tx_length     ;

	wire         icmp_rx_data_vld  ;
	wire         icmp_rx_data_last ;
	wire   [7:0] icmp_rx_data      ;
	wire  [15:0] icmp_rx_length    ;

	wire         arp_rx_data_vld   ;
	wire         arp_rx_data_last  ;
	wire   [7:0] arp_rx_data       ;


/*---------------------------------------------------*\
                复位信号处理
\*---------------------------------------------------*/
	reg  [19:0] phy_rx_reset_timer;
	reg         phy_rx_reset_d0;
	reg         phy_rx_reset_d1;
	reg         phy_rx_reset   ;

	always @(posedge phy_rx_clk or posedge reset) begin
        if (reset) 
            phy_rx_reset_timer <= 0;
        else if (phy_rx_reset_timer <= 20'h000ff) 
            phy_rx_reset_timer <= phy_rx_reset_timer + 1; 
        else 
            phy_rx_reset_timer <= phy_rx_reset_timer;
	end
	
	always @(posedge phy_rx_clk or posedge reset) begin
        if (reset) begin
            phy_rx_reset_d0 <= 1'b1;
            phy_rx_reset_d1 <= 1'b1;
            phy_rx_reset    <= 1'b1;
        end
        else begin
            phy_rx_reset_d0 <= phy_rx_reset_timer <= 20'h000ff;
            phy_rx_reset_d1 <= phy_rx_reset_d0;
            phy_rx_reset    <= phy_rx_reset_d1;
        end   
	end

//---------------------------------------------------------------------------
	reg  [19:0] phy_tx_reset_timer;
	reg         phy_tx_reset_d0;
	reg         phy_tx_reset_d1;
	reg         phy_tx_reset   ;

	always @(posedge phy_tx_clk or posedge reset) begin
        if (reset) 
            phy_tx_reset_timer <= 0;
        else if (phy_tx_reset_timer <= 20'h000ff) 
            phy_tx_reset_timer <= phy_tx_reset_timer + 1; 
        else 
            phy_tx_reset_timer <= phy_tx_reset_timer;
	end
	
	always @(posedge phy_tx_clk or posedge reset) begin
        if (reset) begin
            phy_tx_reset_d0 <= 1'b1;
            phy_tx_reset_d1 <= 1'b1;
            phy_tx_reset    <= 1'b1;
        end
        else begin
            phy_tx_reset_d0 <= phy_tx_reset_timer <= 20'h000ff;
            phy_tx_reset_d1 <= phy_tx_reset_d0;
            phy_tx_reset    <= phy_tx_reset_d1;
        end   
	end

//---------------------------------------------------------------------------
	reg  [19:0] app_tx_reset_timer;
	reg         app_tx_reset_d0;
	reg         app_tx_reset_d1;
	reg         app_tx_reset   ;

	always @(posedge app_tx_clk or posedge reset) begin
        if (reset) 
            app_tx_reset_timer <= 0;
        else if (app_tx_reset_timer <= 20'h000ff) 
            app_tx_reset_timer <= app_tx_reset_timer + 1; 
        else 
            app_tx_reset_timer <= app_tx_reset_timer;
	end
	
	always @(posedge app_tx_clk or posedge reset) begin
        if (reset) begin
            app_tx_reset_d0 <= 1'b1;
            app_tx_reset_d1 <= 1'b1;
            app_tx_reset    <= 1'b1;
        end
        else begin
            app_tx_reset_d0 <= app_tx_reset_timer <= 20'h000ff;
            app_tx_reset_d1 <= app_tx_reset_d0;
            app_tx_reset    <= app_tx_reset_d1;
        end   
	end

//---------------------------------------------------------------------------
	reg  [19:0] app_rx_reset_timer;
	reg         app_rx_reset_d0;
	reg         app_rx_reset_d1;
	reg         app_rx_reset   ;

	always @(posedge app_rx_clk or posedge reset) begin
        if (reset) 
            app_rx_reset_timer <= 0;
        else if (app_rx_reset_timer <= 20'h000ff) 
            app_rx_reset_timer <= app_rx_reset_timer + 1; 
        else 
            app_rx_reset_timer <= app_rx_reset_timer;
	end
	
	always @(posedge app_rx_clk or posedge reset) begin
        if (reset) begin
            app_rx_reset_d0 <= 1'b1;
            app_rx_reset_d1 <= 1'b1;
            app_rx_reset    <= 1'b1;
        end
        else begin
            app_rx_reset_d0 <= app_rx_reset_timer <= 20'h000ff;
            app_rx_reset_d1 <= app_rx_reset_d0;
            app_rx_reset    <= app_rx_reset_d1;
        end   
	end

    mac_layer#(
        .LOCAL_MAC_ADDR     ( LOCAL_MAC_ADDR ),
        .TARGET_MAC_ADDR    ( TARGET_MAC_ADDR ),
        .CRC_CHECK_EN       ( 1 )
    )u_mac_layer(
        .app_tx_clk         ( app_tx_clk         ),
        .app_rx_clk         ( app_rx_clk         ),
        .phy_tx_clk         ( phy_tx_clk         ),
        .phy_rx_clk         ( phy_rx_clk         ),

        .app_tx_reset       ( app_tx_reset       ),
        .app_rx_reset       ( app_rx_reset       ),
        .phy_tx_reset       ( phy_tx_reset       ),
        .phy_rx_reset       ( phy_rx_reset       ),

        .gmii_rx_data_vld   ( gmii_rx_data_vld   ),
        .gmii_rx_data       ( gmii_rx_data       ),
        .gmii_tx_data_vld   ( gmii_tx_data_vld   ),
        .gmii_tx_data       ( gmii_tx_data       ),

        .mac_rx_data_vld    ( mac_rx_data_vld    ),
        .mac_rx_data_last   ( mac_rx_data_last   ),
        .mac_rx_data        ( mac_rx_data        ),
        .mac_rx_frame_type  ( mac_rx_frame_type  ),

        .mac_tx_data_vld    ( ip_tx_data_vld     ),
        .mac_tx_data_last   ( ip_tx_data_last    ),
        .mac_tx_data        ( ip_tx_data         ),
        .mac_tx_frame_type  ( 16'h0800           ),
        .mac_tx_length      ( ip_tx_length       )  
    );

    mac_to_arp_ip u_mac_to_arp_ip(
        .clk                ( app_rx_clk         ),
        .reset              ( app_rx_reset       ),

        .mac_rx_data_vld    ( mac_rx_data_vld    ),
        .mac_rx_data_last   ( mac_rx_data_last   ),
        .mac_rx_data        ( mac_rx_data        ),
        .mac_rx_frame_type  ( mac_rx_frame_type  ),

        .ip_rx_data_vld     ( ip_rx_data_vld     ),
        .ip_rx_data_last    ( ip_rx_data_last    ),
        .ip_rx_data         ( ip_rx_data         ),

        .arp_rx_data_vld    ( arp_rx_data_vld    ),
        .arp_rx_data_last   ( arp_rx_data_last   ),
        .arp_rx_data        ( arp_rx_data        )
    );

    ip_layer#(
        .LOCAL_IP_ADDR      ( LOCAL_IP_ADDR      ),
        .TARGET_IP_ADDR     ( TARGET_IP_ADDR     )
    )u_ip_layer(
        .app_tx_clk         ( app_tx_clk         ),
        .app_rx_clk         ( app_rx_clk         ),

        .app_rx_reset       ( app_rx_reset       ),
        .app_tx_reset       ( app_tx_reset       ),

        .ip_rx_data_vld     ( ip_rx_data_vld     ),
        .ip_rx_data_last    ( ip_rx_data_last    ),
        .ip_rx_data         ( ip_rx_data         ),
        .ip_tx_data_vld     ( ip_tx_data_vld     ),
        .ip_tx_data_last    ( ip_tx_data_last    ),
        .ip_tx_length       ( ip_tx_length       ),
        .ip_tx_data         ( ip_tx_data         ),

        .udp_rx_data_vld    ( udp_rx_data_vld    ),
        .udp_rx_data_last   ( udp_rx_data_last   ),
        .udp_rx_data        ( udp_rx_data        ),
        .udp_rx_length      ( udp_rx_length      ),
        .udp_tx_data_vld    ( udp_tx_data_vld    ),
        .udp_tx_data_last   ( udp_tx_data_last   ),
        .udp_tx_data        ( udp_tx_data        ),
        .udp_tx_length      ( udp_tx_length      ),

        .icmp_rx_data_vld   ( icmp_rx_data_vld   ),
        .icmp_rx_data_last  ( icmp_rx_data_last  ),
        .icmp_rx_data       ( icmp_rx_data       ),
        .icmp_rx_length     ( icmp_rx_length     )
    );

    udp_layer#(
        .LOCAL_PORT        ( LOCAL_PORT         ),
        .TARGET_PORT       ( TARGET_PORT        )
    )u_udp_layer(
        .app_tx_clk        ( app_tx_clk        ),
        .app_rx_clk        ( app_rx_clk        ),

        .app_tx_reset      ( app_tx_reset      ),
        .app_rx_reset      ( app_rx_reset      ),

        .udp_rx_data_vld   ( udp_rx_data_vld   ),
        .udp_rx_data_last  ( udp_rx_data_last  ),
        .udp_rx_data       ( udp_rx_data       ),
        .udp_rx_length     ( udp_rx_length     ),
        .udp_tx_data_vld   ( udp_tx_data_vld   ),
        .udp_tx_data_last  ( udp_tx_data_last  ),
        .udp_tx_data       ( udp_tx_data       ),
        .udp_tx_length     ( udp_tx_length     ),

        .app_rx_data_vld   ( app_rx_data_vld   ),
        .app_rx_data_last  ( app_rx_data_last  ),
        .app_rx_data       ( app_rx_data       ),
        .app_rx_length     ( app_rx_length     ),
        .app_tx_data_vld   ( app_tx_data_vld   ),
        .app_tx_data_last  ( app_tx_data_last  ),
        .app_tx_data       ( app_tx_data       ),
        .app_tx_length     ( app_tx_length     ),
        .app_tx_req        ( app_tx_req        ),
        .app_tx_ready      ( app_tx_ready      )
    );






endmodule
