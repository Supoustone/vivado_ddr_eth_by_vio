`timescale 1ns / 1ps

module ip_send#(
    parameter           LOCAL_IP_ADDR   = 32'h0     ,
    parameter           TARGET_IP_ADDR  = 32'h0
)(
    input               clk                         ,
    input               reset                       ,

//====================== udp_send ===========================

    input               udp_tx_data_vld             ,
    input               udp_tx_data_last            ,
    input [7:0]         udp_tx_data                 ,
    input [15:0]        udp_tx_length               ,

//====================== mac_send ===========================

    output reg          ip_tx_data_vld              ,
    output reg          ip_tx_data_last             ,
    output reg [15:0]   ip_tx_length                ,
    output reg [7:0]    ip_tx_data
    );

    reg [10:0]          tx_cnt                      ;
    wire [7:0]          udp_tx_data_delay           ;

    reg [15:0]          package_id                  ;
    reg [15:0]          ip_head_check               ;
    reg [31:0]          add0                        ;
    reg [31:0]          add1                        ;
    reg [31:0]          add2                        ;
    reg [31:0]          check_sum                   ;

//======================= length ============================

    always@(posedge clk)begin
        if(udp_tx_data_vld)
            ip_tx_length <= udp_tx_length + 20;
        else
            ip_tx_length <= ip_tx_length;
    end

//======================= tx_cnt ============================

    always@(posedge clk)begin
        if(reset)
            tx_cnt <= 'd0;
        else if(tx_cnt == ip_tx_length - 1)
            tx_cnt <= 'd0;
        else if(udp_tx_data_vld | tx_cnt != 0)
            tx_cnt <= tx_cnt + 1'b1;
        else
            tx_cnt <= tx_cnt;
    end

//======================== package ==========================

    always@(posedge clk)begin
        if(reset)
            ip_tx_data <= 'd0;
        else begin
            case(tx_cnt)
                0 : ip_tx_data <= {4'h4 , 4'h5};

                1 : ip_tx_data <= 0;

                2 : ip_tx_data <= ip_tx_length[15:8];
                3 : ip_tx_data <= ip_tx_length[7:0];

                4 : ip_tx_data <= package_id[15:8];
                5 : ip_tx_data <= package_id[7:0];

                6 : ip_tx_data <= {3'b010 , 5'h0};
                7 : ip_tx_data <= 8'h0;

                8 : ip_tx_data <= 8'h80;

                9 : ip_tx_data <= 8'd17;

                10 : ip_tx_data <= ip_head_check[15:8];
                11 : ip_tx_data <= ip_head_check[7:0];

                12 : ip_tx_data <= LOCAL_IP_ADDR[31:24];
                13 : ip_tx_data <= LOCAL_IP_ADDR[23:16];
                14 : ip_tx_data <= LOCAL_IP_ADDR[15:8];
                15 : ip_tx_data <= LOCAL_IP_ADDR[7:0];

                16 : ip_tx_data <= TARGET_IP_ADDR[31:24];
                17 : ip_tx_data <= TARGET_IP_ADDR[23:16];
                18 : ip_tx_data <= TARGET_IP_ADDR[15:8];
                19 : ip_tx_data <= TARGET_IP_ADDR[7:0];

                default : ip_tx_data <= udp_tx_data_delay;
            endcase
        end
    end

    always@(posedge clk)begin
        if(tx_cnt == ip_tx_length - 1)
            ip_tx_data_last <= 1'b1;
        else
            ip_tx_data_last <= 1'b0;
    end

    always@(posedge clk)begin
        if(ip_tx_data_last)
            ip_tx_data_vld <= 1'b0;
        else if(udp_tx_data_vld)
            ip_tx_data_vld <= 1'b1;
        else
            ip_tx_data_vld <= ip_tx_data_vld;
    end

//======================= package_id ==========================

    always@(posedge clk)begin
        if(reset)
            package_id <= 'd0;
        else if(ip_tx_data_last)
            package_id <= package_id + 1'b1;
        else
            package_id <= package_id;
    end

//================ IP head verification ========================

    always@(posedge clk)begin
        add0 <= 16'h4500 + ip_tx_length + package_id;
        add1 <= 16'h4000 + {8'h80 , 8'd17} + LOCAL_IP_ADDR[31:16];
        add2 <= LOCAL_IP_ADDR[15:0] + TARGET_IP_ADDR[31:16] + TARGET_IP_ADDR[15:0];
        check_sum <= add0 + add1 + add2;
    end

    always@(posedge clk)begin
        if(reset)
            ip_head_check <= 0;
        else if(tx_cnt == 5)
            ip_head_check <= check_sum[31:16] + check_sum[15:0];
        else if(tx_cnt == 6)
            ip_head_check <= ~ip_head_check;
        else
            ip_head_check <= ip_head_check;
    end

    shift_ram_IP u_shift_ram_IP (
        .A            (   19                  ),      // input wire [5 : 0] A
        .D            (   udp_tx_data         ),      // input wire [7 : 0] D
        .CLK          (   clk                 ),      // input wire CLK
        .Q            (   udp_tx_data_delay   )       // output wire [7 : 0] Q
    );

endmodule
