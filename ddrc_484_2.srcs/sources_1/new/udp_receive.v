`timescale 1ns / 1ps

module udp_receive#(
    parameter       LOCAL_PORT = 16'h0
)(
    input               clk                 ,
    input               reset               ,

//===================== ip_receive ==========================

    input               udp_rx_data_vld     ,
    input               udp_rx_data_last    ,
    input [7:0]         udp_rx_data         ,
    input [15:0]        udp_rx_length       ,

//===================== user_receive ========================

    output reg          app_rx_data_vld     ,
    output reg          app_rx_data_last    ,
    output reg [7:0]    app_rx_data         ,
    output reg [15:0]   app_rx_length
    );

    reg [10:0] rx_cnt;
    reg [15:0] rx_target_port;

//====================== cnt ================================

    always@(posedge clk)begin
        if(reset)
            rx_cnt <= 'd0;
        else if(udp_rx_data_vld)
            rx_cnt <= rx_cnt + 1'b1;
        else
            rx_cnt <= 'd0;
    end

    always@(posedge clk)begin
        if(rx_cnt == 2 | rx_cnt == 3)
            rx_target_port <= {rx_target_port[7:0] , udp_rx_data};
        else
            rx_target_port <= rx_target_port;
    end

    always@(posedge clk)begin
        if(rx_target_port == LOCAL_PORT & rx_cnt >= 8)begin
            app_rx_data_vld   <= udp_rx_data_vld;
            app_rx_data_last  <= udp_rx_data_last;
            app_rx_data       <= udp_rx_data;
            app_rx_length     <= udp_rx_length - 8;
        end else begin
            app_rx_data_vld  <= 1'b0;
            app_rx_data_last <= 1'b0;
            app_rx_data      <= 'd0;
            app_rx_length    <= 'd0;
        end
    end
endmodule

