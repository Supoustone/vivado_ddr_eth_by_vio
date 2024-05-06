`timescale 1ns / 1ps

module rgmii_interface(
    input       reset                   ,

    input       delay_ref_200m_clk      ,
    
    input       phy_rgmii_rx_clk        ,
    input       phy_rgmii_rx_ctl        ,
    input [3:0] phy_rgmii_rx_data       ,

    output      gmii_rx_clk             ,
    output      gmii_rx_vld             ,
    output      gmii_rx_error           ,
    output [7:0] gmii_rx_data           ,

    output      phy_rgmii_tx_clk        , 
    output      phy_rgmii_tx_ctl        , 
    output [3:0] phy_rgmii_tx_data      ,

    input       gmii_tx_clk             ,
    input       gmii_tx_vld             ,
    input [7:0] gmii_tx_data  
    );

    rgmii_receive u_rgmii_receive(
        .reset               ( reset               ),
        .delay_ref_200m_clk  ( delay_ref_200m_clk  ),
        .phy_rgmii_rx_clk    ( phy_rgmii_rx_clk    ),
        .phy_rgmii_rx_ctl    ( phy_rgmii_rx_ctl    ),
        .phy_rgmii_rx_data   ( phy_rgmii_rx_data   ),
        .gmii_rx_clk         ( gmii_rx_clk         ),
        .gmii_rx_vld         ( gmii_rx_vld         ),
        .gmii_rx_error       ( gmii_rx_error       ),
        .gmii_rx_data        ( gmii_rx_data        )
    );

    rgmii_send u_rgmii_send(
        .reset             ( reset             ),
        .gmii_tx_clk       ( gmii_tx_clk       ),
        .gmii_tx_vld       ( gmii_tx_vld       ),
        .gmii_tx_data      ( gmii_tx_data      ),
        .phy_rgmii_tx_clk  ( phy_rgmii_tx_clk  ),
        .phy_rgmii_tx_ctl  ( phy_rgmii_tx_ctl  ),
        .phy_rgmii_tx_data  ( phy_rgmii_tx_data  )
    );
endmodule
