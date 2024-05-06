module zc_ddr_clk_gen(
    input   outer_clkin_50m             ,
    input   outer_rst_n                 ,

    output  clkout_100m                 ,
    output  clkout_400m                 ,
    output  clkout_200m                 ,
    output  clkout_400m_shift_90        ,

    output  sys_rst_n                     //pll reset done and locked for a moment
);

    reg [7:0]   sys_rst_n_timer                         ;

    wire        locked                                  ;

    assign      sys_rst_n   = ~(sys_rst_n_timer < 99)   ;

    always@(posedge clkout_100m)begin
        if(!locked)
            sys_rst_n_timer <= 0;
        else if(sys_rst_n_timer >= 100)
            sys_rst_n_timer <= sys_rst_n_timer;
        else
            sys_rst_n_timer <= sys_rst_n_timer + 1'b1;
    end

    zc_ddr3_pll u_zc_ddr3_pll(
        .clkout_100m           ( clkout_100m           ),
        .clkout_400m           ( clkout_400m           ),
        .clkout_200m           ( clkout_200m           ),
        .clkout_400m_shift_90  ( clkout_400m_shift_90  ),
        .reset                 ( ~outer_rst_n          ),
        .locked                ( locked                ),
        .clkin_50m             ( outer_clkin_50m       )
    );
endmodule