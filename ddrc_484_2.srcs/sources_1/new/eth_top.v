`timescale 1ns / 1ps

module eth_top(
    input               fpga_clk_50mhz    ,

	input               phy_rgmii_rx_clk  ,
	input               phy_rgmii_rx_ctl  ,
	input [3:0]         phy_rgmii_rx_data ,

	output              phy_rgmii_tx_clk  ,
	output              phy_rgmii_tx_ctl  ,
	output [3:0]        phy_rgmii_tx_data ,

	output              phy_reset
    );

	parameter   LOCAL_MAC_ADDR  = {8'h48,8'h2c,8'ha0,8'hdf,8'h00,8'hff}   ;
	parameter   TARGET_MAC_ADDR = {8'hbc,8'hec,8'ha0,8'h18,8'h2f,8'hdd}   ;
	parameter   LOCAL_IP_ADDR   = {8'd169,8'd254,8'd157,8'd100}           ;
	parameter   TARGET_IP_ADDR  = {8'd169,8'd254,8'd157,8'd112}           ;
	parameter   LOCAL_PORT      = 16'd1234                                ;
	parameter   TARGET_PORT     = 16'd1234                                ;

	wire			reset               ;
    wire            clkout_25m          ;
    wire            clkout_50m          ;
    wire            clkout_125m         ;
    wire            clkout_200m         ;

    wire			delay_refclk        ;
    wire			phy_tx_clk          ;
    wire			phy_rx_clk          ;
    wire			app_rx_clk          ;
    wire			app_tx_clk          ;

	wire			gmii_rx_vld         ;
	wire			gmii_rx_error       ;
	wire	[7:0]	gmii_rx_data        ;
	wire			gmii_tx_vld         ;
	wire	[7:0]	gmii_tx_data        ;

	wire            app_rx_data_vld     ;
	wire            app_rx_data_last    ;
	wire  [7:0]     app_rx_data         ;
	wire [15:0]     app_rx_length       ;
	wire            app_tx_data_vld     ;
	wire            app_tx_data_last    ;
	wire  [7:0]     app_tx_data         ;
	wire [15:0]     app_tx_length       ;
	wire            app_tx_ready        ;

/*------------------------------------------*\
            clk and reset
\*------------------------------------------*/	
assign delay_refclk = clkout_200m;
assign phy_tx_clk   = clkout_125m;
assign app_rx_clk   = clkout_200m;
assign app_tx_clk   = clkout_200m;
assign phy_reset    = ~reset;

    eth_clock_and_reset u_clock_and_reset(
        .clk_in_50m    ( fpga_clk_50mhz ),
        .clk_out_25m   ( clkout_25m     ),
        .clk_out_50m   ( clkout_50m     ),
        .clk_out_125m  ( clkout_125m    ),
        .clk_out_200m  ( clkout_200m    ),
        .reset         ( reset          )
    );

    rgmii_interface u_rgmii_interface(
        .reset               ( reset                ),

        .delay_ref_200m_clk  ( delay_refclk         ),

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

        .gmii_tx_clk         ( phy_tx_clk           ),
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
        .phy_tx_clk        ( phy_tx_clk             ),
        .phy_rx_clk        ( phy_rx_clk             ),
        .reset             ( reset                  ),

        .gmii_rx_data_vld  ( gmii_rx_vld            ),
        .gmii_rx_data      ( gmii_rx_data           ),
        .gmii_tx_data_vld  ( gmii_tx_vld            ),
        .gmii_tx_data      ( gmii_tx_data           ),

        .app_rx_clk        ( app_rx_clk             ),
        .app_rx_data_vld   ( app_rx_data_vld        ),
        .app_rx_data_last  ( app_rx_data_last       ),
        .app_rx_data       ( app_rx_data            ),
        .app_rx_length     ( app_rx_length          ),

        .app_tx_clk        ( app_tx_clk             ),
        .app_tx_data_vld   ( app_tx_data_vld        ),
        .app_tx_data_last  ( app_tx_data_last       ),
        .app_tx_data       ( app_tx_data            ),
        .app_tx_length     ( app_tx_length          ),
        .app_tx_ready      ( app_tx_ready           )
    );

    shift_ram_IP u_shift_ram_IP_3 (
        .A          (   60                            ),      // input wire [5 : 0] A
        .D          (   {app_rx_data_vld , app_rx_data_last , 6'd0 }     ),      // input wire [7 : 0] D
        .CLK        (   clkout_200m                   ),      // input wire CLK
        .Q          (   {app_tx_data_vld , app_tx_data_last , 6'd0 }     )       // output wire [7 : 0] Q
    );

    shift_ram_IP u_shift_ram_IP_4 (
        .A          (   60                            ),      // input wire [5 : 0] A
        .D          (   app_rx_data                   ),      // input wire [7 : 0] D
        .CLK        (   clkout_200m                   ),      // input wire CLK
        .Q          (   app_tx_data                   )       // output wire [7 : 0] Q
    );

    shift_ram_IP_2 u_shift_ram_IP_5 (
      .A            (   60                  ),      // input wire [5 : 0] A
      .D            (   app_rx_length       ),      // input wire [15 : 0] D
      .CLK          (   clkout_200m         ),  // input wire CLK
      .Q            (   app_tx_length       )      // output wire [15 : 0] Q
    );

endmodule
