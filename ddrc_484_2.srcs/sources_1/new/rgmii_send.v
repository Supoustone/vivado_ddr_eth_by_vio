`timescale 1ns / 1ps

module rgmii_send(
    input           reset               ,

    input           gmii_tx_clk         ,
    input           gmii_tx_vld         ,
    input [7:0]     gmii_tx_data        ,

    output          phy_rgmii_tx_clk    ,
    output          phy_rgmii_tx_ctl    ,
    output [3:0]    phy_rgmii_tx_data
    );

    wire        rgmii_tx_ctl_unbuffed   ;
    wire [3:0]  rgmii_tx_data_unbuffed  ;

    ODDR #(
        .DDR_CLK_EDGE   ("SAME_EDGE"),      // "OPPOSITE_EDGE" or "SAME_EDGE" 
        .INIT           (1'b0       ),      // Initial value of Q: 1'b0 or 1'b1
        .SRTYPE         ("SYNC"     )       // Set/Reset type: "SYNC" or "ASYNC" 
    ) u_ODDR_gmii_tx_vld (
        .Q              (rgmii_tx_ctl_unbuffed) ,    // 1-bit DDR output
        .C              (gmii_tx_clk)           ,    // 1-bit clock input
        .CE             (1)                     ,    // 1-bit clock enable input
        .D1             (gmii_tx_vld)           ,    // 1-bit data input (positive edge)
        .D2             (gmii_tx_vld)           ,    // 1-bit data input (negative edge)
        .R              (0)                     ,    // 1-bit reset
        .S              (0)                          // 1-bit set
    );

    genvar i;
    generate
        for( i = 0 ; i < 4 ; i = i + 1)begin
            ODDR #(
                .DDR_CLK_EDGE   ("SAME_EDGE"),      // "OPPOSITE_EDGE" or "SAME_EDGE" 
                .INIT           (1'b0       ),      // Initial value of Q: 1'b0 or 1'b1
                .SRTYPE         ("SYNC"     )       // Set/Reset type: "SYNC" or "ASYNC" 
            ) u_ODDR_gmii_tx_data (
                .Q              (rgmii_tx_data_unbuffed[i]) ,    // 1-bit DDR output
                .C              (gmii_tx_clk)               ,    // 1-bit clock input
                .CE             (1)                         ,    // 1-bit clock enable input
                .D1             (gmii_tx_data[i])           ,    // 1-bit data input (positive edge)
                .D2             (gmii_tx_data[i + 4])       ,    // 1-bit data input (negative edge)
                .R              (0)                         ,    // 1-bit reset
                .S              (0)                              // 1-bit set
            );            
        end
    endgenerate

    OBUF #(
      .DRIVE            (12),           // Specify the output drive strength
      .IOSTANDARD       ("DEFAULT"),    // Specify the output I/O standard
      .SLEW             ("SLOW")        // Specify the output slew rate
    ) u_OBUF_gmii_clk (
      .O                (phy_rgmii_tx_clk),      // Buffer output (connect directly to top-level port)
      .I                (gmii_tx_clk      )      // Buffer input
    );

    OBUF u_OBUF_rgmii_tx_ctl_unbuffed (
      .O                (phy_rgmii_tx_ctl       ),      // Buffer output (connect directly to top-level port)
      .I                (rgmii_tx_ctl_unbuffed  )      // Buffer input
    );

    genvar j;
    generate
        for( j = 0 ; j < 4 ; j = j + 1)begin
            OBUF u_OBUF_rgmii_tx_ctl_unbuffed (
              .O        (phy_rgmii_tx_data[j]       ),      // Buffer output (connect directly to top-level port)
              .I        (rgmii_tx_data_unbuffed[j]  )       // Buffer input
            );     
        end
    endgenerate

endmodule
