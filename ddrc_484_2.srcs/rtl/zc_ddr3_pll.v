
module zc_ddr3_pll(
    output  clkout_100m             ,
    output  clkout_400m             ,
    output  clkout_200m             ,
    output  clkout_400m_shift_90    ,

    input   reset                   ,
    output  locked                  ,
    input   clkin_50m
);

    wire    clkin_50m_buffered_w    ;
    wire    clkfbout_w              ;
    wire    clkfbout_buffered_w     ;
    wire    pll_clkout_100m_w       ;
    wire    pll_clkout_400m_w       ;
    wire    pll_clkout_200m_w       ;
    wire    pll_clkout_400m_shift_w ;

    wire    locked_int              ;
    wire    reset_high              ;

    assign  locked      = locked_int;
    assign  reset_high  = reset     ;

/*     IBUF IBUF_IN(
        .I  (clkin_50m              ),
        .O  (clkin_50m_buffered_w   )
    ); */

    PLLE2_ADV#(
        .BANDWIDTH          (   "OPTIMIZED"    ),
        .COMPENSATION       (   "ZHOLD"        ),
        .STARTUP_WAIT       (   "FALSE"        ),    //Delay DONE until PLL locks ("TRUE"/"FALSE")
        .DIVCLK_DIVIDE      (   1              ),
        .CLKFBOUT_MULT      (   24             ),
        .CLKFBOUT_PHASE     (   0.0            ),
        .CLKIN1_PERIOD      (   20.000         ),

        .CLKOUT0_DIVIDE     (   12             ),
        .CLKOUT0_PHASE      (   0.0            ),
        .CLKOUT0_DUTY_CYCLE (   0.5            ),

        .CLKOUT1_DIVIDE     (   3              ),
        .CLKOUT1_PHASE      (   0.0            ),
        .CLKOUT1_DUTY_CYCLE (   0.5            ),

        .CLKOUT2_DIVIDE     (   6              ),
        .CLKOUT2_PHASE      (   0.0            ),
        .CLKOUT2_DUTY_CYCLE (   0.5            ),

        .CLKOUT3_DIVIDE     (   3              ),
        .CLKOUT3_PHASE      (   90.0           ),
        .CLKOUT3_DUTY_CYCLE (   0.5            )
    )PLLE2_ADV_inst(
        .CLKFBOUT           (   clkfbout_w              ),
        .CLKOUT0            (   pll_clkout_100m_w       ),
        .CLKOUT1            (   pll_clkout_400m_w       ),
        .CLKOUT2            (   pll_clkout_200m_w       ),
        .CLKOUT3            (   pll_clkout_400m_shift_w ),
        .CLKOUT4            (                           ),
        .CLKOUT5            (                           ),

        .CLKFBIN            (   clkfbout_buffered_w     ),
        .CLKIN1             (   clkin_50m               ),
        .CLKIN2             (   1'b0                    ),
        .CLKINSEL           (   1'b1                    ),   //tied to always select the primary input clock

//ports for dynamic reconfiguration
        .DADDR              (   7'h0                    ),
        .DCLK               (   1'b0                    ),
        .DEN                (   1'b0                    ),
        .DI                 (   16'h0                   ),
        .DO                 (                           ),
        .DRDY               (                           ),
        .DWE                (   1'b0                    ),
//other control and status signals
        .LOCKED             (   locked_int              ),
        .PWRDWN             (   1'b0                    ),
        .RST                (   reset_high              )
        );

        BUFG clkf_buf(
            .O      (   clkfbout_buffered_w     ),
            .I      (   clkfbout_w              )
        );

        BUFG clkout1_buf(
            .O      (   clkout_100m             ),
            .I      (   pll_clkout_100m_w       )
        );

        BUFG clkout2_buf(
            .O      (   clkout_400m             ),
            .I      (   pll_clkout_400m_w       )
        );

        BUFG clkout3_buf(
            .O      (   clkout_200m             ),
            .I      (   pll_clkout_200m_w       )
        );

        BUFG clkout4_buf(
            .O      (   clkout_400m_shift_90    ),
            .I      (   pll_clkout_400m_shift_w )
        );
endmodule