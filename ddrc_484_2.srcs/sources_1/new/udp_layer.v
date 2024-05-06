`timescale 1ns / 1ps

module udp_layer#(
    parameter 		LOCAL_PORT 	    = 16'h0 	,
    parameter 		TARGET_PORT 	= 16'h0
)(
    input 		    app_tx_clk			    ,
    input 		    app_rx_clk			    ,

    input 		    app_tx_reset			,
    input 		    app_rx_reset			,

    input 		    udp_rx_data_vld			,
    input 		    udp_rx_data_last		,
    input [7:0] 	udp_rx_data			    ,
    input [15:0] 	udp_rx_length			,

    output 		    udp_tx_data_vld			,
    output 		    udp_tx_data_last		,
    output [7:0] 	udp_tx_data			    ,
    output [15:0] 	udp_tx_length			,

    output 		    app_rx_data_vld			,
    output 		    app_rx_data_last		,
    output [7:0] 	app_rx_data			    ,
    output [15:0] 	app_rx_length			,

    input           app_tx_data_vld         ,
    input           app_tx_data_last 		,
    input  [7:0]    app_tx_data      		,
    input  [15:0]   app_tx_length    		,
    output          app_tx_req       		,
	output          app_tx_ready 
    );

udp_receive#(
    .LOCAL_PORT        ( LOCAL_PORT )
)u_udp_receive(
    .clk               ( app_rx_clk        ),
    .reset             ( app_rx_reset      ),
    .udp_rx_data_vld   ( udp_rx_data_vld   ),
    .udp_rx_data_last  ( udp_rx_data_last  ),
    .udp_rx_data       ( udp_rx_data       ),
    .udp_rx_length     ( udp_rx_length     ),
    .app_rx_data_vld   ( app_rx_data_vld   ),
    .app_rx_data_last  ( app_rx_data_last  ),
    .app_rx_data       ( app_rx_data       ),
    .app_rx_length     ( app_rx_length     )
);

udp_send#(
    .LOCAL_PORT       ( LOCAL_PORT ),
    .TARGET_PORT      ( TARGET_PORT )
)u_udp_send(
    .clk              ( app_tx_clk       ),
    .reset            ( app_tx_reset     ),
    .udp_tx_data_vld  ( udp_tx_data_vld  ),
    .udp_tx_data_last ( udp_tx_data_last ),
    .udp_tx_data      ( udp_tx_data      ),
    .udp_tx_length    ( udp_tx_length    ),
    .app_tx_data_vld  ( app_tx_data_vld  ),
    .app_tx_data_last ( app_tx_data_last ),
    .app_tx_data      ( app_tx_data      ),
    .app_tx_length    ( app_tx_length    ),
    .app_tx_req       ( app_tx_req       ),
    .app_tx_ready     ( app_tx_ready     )
);


endmodule
