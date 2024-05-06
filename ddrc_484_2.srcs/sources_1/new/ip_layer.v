`timescale 1ns / 1ps

module ip_layer#(
    parameter           LOCAL_IP_ADDR  = 32'h0       ,
    parameter           TARGET_IP_ADDR = 32'h0   
)(
    input               app_tx_clk          ,
    input               app_rx_clk          ,

    input               app_rx_reset        ,
    input               app_tx_reset        ,

    input               ip_rx_data_vld      ,
    input               ip_rx_data_last     ,
    input [7:0]         ip_rx_data          ,

	output              ip_tx_data_vld      ,
	output              ip_tx_data_last     ,
	output [15:0]       ip_tx_length        ,
	output [7:0]        ip_tx_data          ,

	output              udp_rx_data_vld     ,
	output              udp_rx_data_last    ,
	output [7:0]        udp_rx_data         ,	
	output [15:0]       udp_rx_length       ,

	input               udp_tx_data_vld     ,
	input               udp_tx_data_last    ,
	input [7:0]         udp_tx_data         ,	
	input [15:0]        udp_tx_length       ,	

	output              icmp_rx_data_vld    ,
	output              icmp_rx_data_last   ,
	output [7:0]        icmp_rx_data        ,	
	output [15:0]       icmp_rx_length  
    );

    ip_receive#(
        .LOCAL_IP_ADDR      ( LOCAL_IP_ADDR      )
    )u_ip_receive(
        .clk                ( app_rx_clk         ),
        .reset              ( app_rx_reset       ),
        .ip_rx_data_vld     ( ip_rx_data_vld     ),
        .ip_rx_data_last    ( ip_rx_data_last    ),
        .ip_rx_data         ( ip_rx_data         ),
        .udp_rx_data_vld    ( udp_rx_data_vld    ),
        .udp_rx_data_last   ( udp_rx_data_last   ),
        .udp_rx_data        ( udp_rx_data        ),
        .udp_rx_length      ( udp_rx_length      ),
        .icmp_rx_data_vld   ( icmp_rx_data_vld   ),
        .icmp_rx_data_last  ( icmp_rx_data_last  ),
        .icmp_rx_data       ( icmp_rx_data       ),
        .icmp_rx_length     ( icmp_rx_length     )
    );

    ip_send#(
        .LOCAL_IP_ADDR     ( LOCAL_IP_ADDR     ),
        .TARGET_IP_ADDR    ( TARGET_IP_ADDR    )
    )u_ip_send(
        .clk               ( app_tx_clk        ),
        .reset             ( app_tx_reset      ),
        .udp_tx_data_vld   ( udp_tx_data_vld   ),
        .udp_tx_data_last  ( udp_tx_data_last  ),
        .udp_tx_data       ( udp_tx_data       ),
        .udp_tx_length     ( udp_tx_length     ),
        .ip_tx_data_vld    ( ip_tx_data_vld    ),
        .ip_tx_data_last   ( ip_tx_data_last   ),
        .ip_tx_length      ( ip_tx_length      ),
        .ip_tx_data        ( ip_tx_data        )
    );


endmodule
