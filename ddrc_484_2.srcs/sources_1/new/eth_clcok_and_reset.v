`timescale 1ns / 1ps

module eth_clock_and_reset(
    input  clk_in_50m     ,
    output clk_out_25m    ,
    output clk_out_50m    ,
    output clk_out_125m   ,
    output clk_out_200m   ,
    output reg reset
    );

    reg [11:0]cnt;

    wire clk_out_25;
    wire clk_out_50;
    wire clk_out_125;
    wire clk_out_200;

    wire locked;

    assign clk_out_25m = clk_out_25;
    assign clk_out_50m = clk_out_50;
    assign clk_out_125m = clk_out_125;
    assign clk_out_200m = clk_out_200;

    always@(posedge clk_out_50 or negedge locked)begin
        if(!locked)begin
            cnt <= 0;
            reset <= 1'b1;
        end 
        else if(cnt < 'd500)begin
            cnt <= cnt + 1'b1;
            reset <= 1'b1;
        end
        else begin
            cnt <= cnt;
            reset <= 0;
        end

    end

    ethernet_mmcm u_ethernet_mmcm
    (
        .clk_out_25m    (clk_out_25 )       ,   // output clk_out_25m
        .clk_out_50m    (clk_out_50 )       ,   // output clk_out_50m
        .clk_out_125m   (clk_out_125)       ,   // output clk_out_125m
        .clk_out_200m   (clk_out_200)       ,   // output clk_out_200m
        .reset          (1'b0       )       ,   // input reset
        .locked         (locked     )       ,   // output locked
        .clk_in_50m     (clk_in_50m));          // input clk_in_50m    
endmodule
