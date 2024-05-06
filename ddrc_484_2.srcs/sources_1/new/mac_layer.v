`timescale 1ns / 1ps

module mac_layer#(
    parameter   LOCAL_MAC_ADDR  = 48'hffffff_ffffff,
    parameter   TARGET_MAC_ADDR = 48'hffffff_ffffff,
    parameter   CRC_CHECK_EN    = 1
)(
    input           app_tx_clk             ,
    input           app_rx_clk             ,
    input           phy_tx_clk              ,
    input           phy_rx_clk              ,

    input           app_tx_reset           ,
    input           app_rx_reset           ,
    input           phy_tx_reset            ,
    input           phy_rx_reset            ,

    input           gmii_rx_data_vld        ,
    input [7:0]     gmii_rx_data            ,
    output          gmii_tx_data_vld        ,
    output [7:0]    gmii_tx_data            ,

    output          mac_rx_data_vld         ,
    output          mac_rx_data_last        ,
    output [7:0]    mac_rx_data             ,
    output [15:0]   mac_rx_frame_type       ,

    input           mac_tx_data_vld         ,
    input           mac_tx_data_last        ,
    input [7:0]     mac_tx_data             ,
    input [15:0]    mac_tx_frame_type       ,
    input [15:0]    mac_tx_length
    );

    wire            tx_crc_din_vld          ;
    wire [7:0]      tx_crc_din              ;
    wire            tx_crc_done             ;
    wire [31:0]     tx_crc_dout             ;

    wire            rx_crc_din_vld          ;
    wire [7:0]      rx_crc_din              ;
    wire            rx_crc_done             ;
    wire [31:0]     rx_crc_dout             ;

mac_send#(
    .LOCAL_MAC_ADDR     (   LOCAL_MAC_ADDR   ),
    .TARGET_MAC_ADDR    (   TARGET_MAC_ADDR  )
)u_mac_send(
    .clk                ( app_tx_clk        ),
    .phy_tx_clk         ( phy_tx_clk         ),
    .reset              ( app_tx_reset       ),
    .phy_tx_reset       ( phy_tx_reset       ),
    .gmii_tx_data_vld   ( gmii_tx_data_vld   ),
    .gmii_tx_data       ( gmii_tx_data       ),
    .mac_tx_data_vld    ( mac_tx_data_vld    ),
    .mac_tx_data_last   ( mac_tx_data_last   ),
    .mac_tx_data        ( mac_tx_data        ),
    .mac_tx_frame_type  ( mac_tx_frame_type  ),
    .mac_tx_length      ( mac_tx_length      ),
    .tx_crc_din_vld     ( tx_crc_din_vld     ),
    .tx_crc_din         ( tx_crc_din         ),
    .tx_crc_done        ( tx_crc_done        ),
    .tx_crc_dout        ( tx_crc_dout        )
);

mac_receive#(
    .LOCAL_MAC_ADDR     (   LOCAL_MAC_ADDR   ),
    .CRC_CHECK_EN       (   CRC_CHECK_EN     )
)u_mac_receive(
    .clk                ( app_rx_clk         ),
    .phy_rx_clk         ( phy_rx_clk         ),
    .reset              ( app_rx_reset      ),
    .phy_rx_reset       ( phy_rx_reset       ),
    .gmii_rx_data_vld   ( gmii_rx_data_vld   ),
    .gmii_rx_data       ( gmii_rx_data       ),
    .mac_rx_data_vld    ( mac_rx_data_vld    ),
    .mac_rx_data_last   ( mac_rx_data_last   ),
    .mac_rx_data        ( mac_rx_data        ),
    .mac_rx_frame_type  ( mac_rx_frame_type  ),
    .rx_crc_din_vld     ( rx_crc_din_vld     ),
    .rx_crc_din         ( rx_crc_din         ),
    .rx_crc_done        ( rx_crc_done        ),
    .rx_crc_dout        ( rx_crc_dout        )
);

crc32_d8 u_crc32_d8_tx(
    .clk         ( phy_tx_clk     ),
    .reset       ( phy_tx_reset   ),
    .crc_din_vld ( tx_crc_din_vld ),
    .crc_din     ( tx_crc_din     ),
    .crc_done    ( tx_crc_done    ),
    .crc_dout    ( tx_crc_dout    )
);

crc32_d8 u_crc32_d8_rx(
    .clk         ( phy_rx_clk     ),
    .reset       ( phy_rx_reset   ),
    .crc_din_vld ( rx_crc_din_vld ),
    .crc_din     ( rx_crc_din     ),
    .crc_done    ( rx_crc_done    ),
    .crc_dout    ( rx_crc_dout    )
);

endmodule

