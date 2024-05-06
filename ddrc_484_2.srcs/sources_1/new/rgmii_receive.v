`timescale 1ns / 1ps

module rgmii_receive(
    input           reset                       ,
    
    input           delay_ref_200m_clk          ,

    input           phy_rgmii_rx_clk            ,
    input           phy_rgmii_rx_ctl            ,
    input [3:0]     phy_rgmii_rx_data           ,

    output          gmii_rx_clk                 ,
    output          gmii_rx_vld                 ,
    output          gmii_rx_error               ,
    output [7:0]    gmii_rx_data
    );

    wire            phy_rgmii_rx_clk_ibuf_o     ;
    wire            phy_rgmii_rx_ctl_ibuf_o     ;
    wire [3:0]      phy_rgmii_rx_data_ibuf_o    ;

    wire            phy_rgmii_rx_clk_bufio      ;

    wire            phy_rgmii_rx_ctl_delayed    ;
    wire [3:0]      phy_rgmii_rx_data_delayed   ;

    wire            gmii_rx_error_xor		;
    assign gmii_rx_error = gmii_rx_vld ^ gmii_rx_error_xor;

    IBUF #(
      .IBUF_LOW_PWR     ("TRUE"      ),       // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      .IOSTANDARD       ("DEFAULT"   )        // Specify the input I/O standard
    ) u_IBUF_rgmii_rx_ctrl (
        .O              (phy_rgmii_rx_ctl_ibuf_o    ),
        .I              (phy_rgmii_rx_ctl           )
    );

    IBUF u_IBUF_rgmii_rx_clk (
        .O              (phy_rgmii_rx_clk_ibuf_o    ),   
        .I              (phy_rgmii_rx_clk           )  
    );

    BUFG u_BUFG_rgmii_rx_clk_ibuf_o(
        .O              (gmii_rx_clk                ),
        .I              (phy_rgmii_rx_clk_ibuf_o    )
    );

    BUFIO u_BUFIO_rx_clk_ibuf_o(
        .O              (phy_rgmii_rx_clk_bufio     ),
        .I              (phy_rgmii_rx_clk_ibuf_o    )
    );

    genvar i;
    generate
        for(i = 0 ; i < 4 ; i = i + 1)begin
            IBUF u_IBUF_rgmii_data(
                .O  (phy_rgmii_rx_data_ibuf_o[i]    ),
                .I  (phy_rgmii_rx_data[i]           )
            );
        end
    endgenerate


    IDELAYCTRL u_IDELAYCTRL_rgmii_rx (
        .RDY            ()                      ,       
        .REFCLK         (delay_ref_200m_clk)    ,   
        .RST            (0)    // 1-bit input: Active high reset input
    );

    IDELAYE2 #(
        .CINVCTRL_SEL               ("FALSE"        ),          // Enable dynamic clock inversion (FALSE, TRUE)
        .DELAY_SRC                  ("IDATAIN"      ),          // Delay input (IDATAIN, DATAIN)
        .HIGH_PERFORMANCE_MODE      ("FALSE"        ),          // Reduced jitter ("TRUE"), Reduced power ("FALSE")
        .IDELAY_TYPE                ("FIXED"        ),          // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        .IDELAY_VALUE               (0              ),          // Input delay tap setting (0-31)
        .PIPE_SEL                   ("FALSE"        ),          // Select pipelined mode, FALSE, TRUE
        .REFCLK_FREQUENCY           (200.0          ),          // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
        .SIGNAL_PATTERN             ("DATA"         )           // DATA, CLOCK input signal
    ) u_IDELAYE2_rgmii_rx_ctl_ibuf_o (
        .CNTVALUEOUT                (),                         // 5-bit output: Counter value output
        .DATAOUT                    (phy_rgmii_rx_ctl_delayed), // 1-bit output: Delayed data output
        .C                          (0),                        // 1-bit input: Clock input
        .CE                         (0),                        // 1-bit input: Active high enable increment/decrement input
        .CINVCTRL                   (0),                        // 1-bit input: Dynamic clock inversion input
        .CNTVALUEIN                 (0),                        // 5-bit input: Counter value input
        .DATAIN                     (0),                        // 1-bit input: Internal delay data input
        .IDATAIN                    (phy_rgmii_rx_ctl_ibuf_o),  // 1-bit input: Data input from the I/O
        .INC                        (0),                        // 1-bit input: Increment / Decrement tap delay input
        .LD                         (0),                        // 1-bit input: Load IDELAY_VALUE input
        .LDPIPEEN                   (0),                        // 1-bit input: Enable PIPELINE register to load data input
        .REGRST                     (0)                         // 1-bit input: Active-high reset tap-delay input
    );

    genvar j;
    generate
        for(j = 0 ; j < 4 ; j = j + 1)begin
            IDELAYE2 #(
                .CINVCTRL_SEL               ("FALSE"        ),          // Enable dynamic clock inversion (FALSE, TRUE)
                .DELAY_SRC                  ("IDATAIN"      ),          // Delay input (IDATAIN, DATAIN)
                .HIGH_PERFORMANCE_MODE      ("FALSE"        ),          // Reduced jitter ("TRUE"), Reduced power ("FALSE")
                .IDELAY_TYPE                ("FIXED"        ),          // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
                .IDELAY_VALUE               (0              ),          // Input delay tap setting (0-31)
                .PIPE_SEL                   ("FALSE"        ),          // Select pipelined mode, FALSE, TRUE
                .REFCLK_FREQUENCY           (200.0          ),          // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
                .SIGNAL_PATTERN             ("DATA"         )           // DATA, CLOCK input signal
            ) u_IDELAYE2_rgmii_rx_data_ibuf_o (
                .CNTVALUEOUT                (),                             // 5-bit output: Counter value output
                .DATAOUT                    (phy_rgmii_rx_data_delayed[j]), // 1-bit output: Delayed data output
                .C                          (0),                            // 1-bit input: Clock input
                .CE                         (0),                            // 1-bit input: Active high enable increment/decrement input
                .CINVCTRL                   (0),                            // 1-bit input: Dynamic clock inversion input
                .CNTVALUEIN                 (0),                            // 5-bit input: Counter value input
                .DATAIN                     (0),                            // 1-bit input: Internal delay data input
                .IDATAIN                    (phy_rgmii_rx_data_ibuf_o[j]),  // 1-bit input: Data input from the I/O
                .INC                        (0),                            // 1-bit input: Increment / Decrement tap delay input
                .LD                         (0),                            // 1-bit input: Load IDELAY_VALUE input
                .LDPIPEEN                   (0),                            // 1-bit input: Enable PIPELINE register to load data input
                .REGRST                     (0)                             // 1-bit input: Active-high reset tap-delay input
            );            
        end
    endgenerate


    IDDR #(
      .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED"),    // "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED" 
      .INIT_Q1      (1'b0),                     // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2      (1'b0),                     // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE       ("SYNC")                    // Set/Reset type: "SYNC" or "ASYNC" 
    ) u_IDDR_rgmii_rx_ctl_delayed (
      .Q1           (gmii_rx_vld            ),  // 1-bit output for positive edge of clock
      .Q2           (gmii_rx_error_xor      ),  // 1-bit output for negative edge of clock
      .C            (phy_rgmii_rx_clk_bufio ),  // 1-bit clock input
      .CE           (1),                        // 1-bit clock enable input
      .D            (phy_rgmii_rx_ctl_delayed), // 1-bit DDR data input
      .R            (0),                        // 1-bit reset
      .S            (0)                         // 1-bit set
    );

    genvar k;
    generate
        for(k = 0 ; k < 4 ; k = k + 1)begin
            IDDR #(
              .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED"),    // "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED" 
              .INIT_Q1      (1'b0),                     // Initial value of Q1: 1'b0 or 1'b1
              .INIT_Q2      (1'b0),                     // Initial value of Q2: 1'b0 or 1'b1
              .SRTYPE       ("SYNC")                    // Set/Reset type: "SYNC" or "ASYNC" 
            ) u_IDDR_rgmii_rx_data_delayed (
              .Q1           (gmii_rx_data[k]           ),   // 1-bit output for positive edge of clock
              .Q2           (gmii_rx_data[k + 4]       ),   // 1-bit output for negative edge of clock
              .C            (phy_rgmii_rx_clk_bufio    ),   // 1-bit clock input
              .CE           (1),                            // 1-bit clock enable input
              .D            (phy_rgmii_rx_data_delayed[k]), // 1-bit DDR data input
              .R            (0),                            // 1-bit reset
              .S            (0)                             // 1-bit set
            );
        end
    endgenerate
endmodule
