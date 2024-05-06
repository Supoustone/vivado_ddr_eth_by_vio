`timescale 1ns / 1ps

module udp_send#(
    parameter   	        LOCAL_PORT  = 16'h0     ,
    parameter   	        TARGET_PORT = 16'h0
    )(
        input 		        clk			            ,
        input 		        reset			        ,

//====================== ip_send =================================

    output reg 		    udp_tx_data_vld		        ,
    output reg 		    udp_tx_data_last	        ,
    output reg [7:0] 	udp_tx_data		            ,
    output reg [15:0] 	udp_tx_length		        ,

//====================== user send ===============================
    input 		        app_tx_data_vld		        ,
    input 		        app_tx_data_last	        ,
    input [7:0] 	    app_tx_data		            ,
    input [15:0] 	    app_tx_length		        ,
    output 		        app_tx_req		            ,  //reserved for other use
    output   		    app_tx_ready
    );

    localparam 		READY_CNT_MAX = 50	;

    reg 		    app_tx_data_vld_r	;
    reg 		    app_tx_data_last_r	;
    reg [7:0] 		app_tx_data_r		;
    reg [15:0] 		app_tx_length_r		;
    reg [10:0] 		tx_cnt			    ;
    reg [7:0] 		ready_cnt		    ;
    wire [7:0] 		app_tx_data_delay	;

    assign app_tx_req = app_tx_data_vld;

//======================= beat ====================================

    always@(posedge clk)begin
        if(app_tx_ready)begin
            app_tx_data_vld_r  <= app_tx_data_vld;
            app_tx_data_last_r <= app_tx_data_last;
            app_tx_data_r 	   <= app_tx_data;
        end else begin
            app_tx_data_vld_r  <= 0;
            app_tx_data_last_r <= 0;
            app_tx_data_r 	   <= 0;
        end
    end

    always@(posedge clk)begin
        if(app_tx_data_vld & app_tx_ready)
            app_tx_length_r <= app_tx_length;
        else
            app_tx_length_r <= app_tx_length_r;
    end

//===================== tx_cnt ====================================

    always@(posedge clk)begin
        if(reset)
            tx_cnt <= 'd0;
        else if(app_tx_length_r < 18 & tx_cnt == 25)
            tx_cnt <= 'd0;
        else if(app_tx_length_r >= 18 & tx_cnt == app_tx_length_r + 'd7)
            tx_cnt <= 'd0;
        else if(app_tx_data_vld_r | tx_cnt != 0)
            tx_cnt <= tx_cnt + 1'b1;
        else
            tx_cnt <= tx_cnt;
    end

//====================== package ===================================

    always@(posedge clk)begin
        if(reset)
            udp_tx_data <= 'd0;
        else begin
            case(tx_cnt)
                0 : udp_tx_data <= LOCAL_PORT[15:8];
                1 : udp_tx_data <= LOCAL_PORT[7:0];

                2 : udp_tx_data <= TARGET_PORT[15:8];
                3 : udp_tx_data <= TARGET_PORT[7:0];

                4 : udp_tx_data <= udp_tx_length[15:8];
                5 : udp_tx_data <= udp_tx_length[7:0];

                6 : udp_tx_data <= 'd0;
                7 : udp_tx_data <= 'd0;

                default : udp_tx_data <= app_tx_data_delay;
            endcase
        end
    end

    always@(posedge clk)begin
        if( app_tx_data_vld_r & app_tx_length_r <= 18)
            udp_tx_length <= 26;
        else if(app_tx_data_vld_r & app_tx_length_r > 18)
            udp_tx_length <= app_tx_length_r + 'd8;
        else
            udp_tx_length <= udp_tx_length;
    end

    always @(posedge clk) begin
        if (reset) 
            udp_tx_data_vld <= 0;
        else if (udp_tx_data_last) 
            udp_tx_data_vld <= 0;
        else if (app_tx_data_vld_r)
            udp_tx_data_vld <= 1;
        else 
            udp_tx_data_vld <= udp_tx_data_vld;  
    end

    always @(posedge clk) begin
        if (reset) 
            udp_tx_data_last <= 0;
        else if (app_tx_length_r < 18 && tx_cnt == 25) 
            udp_tx_data_last <= 1'b1;
        else if (app_tx_length_r >= 18 && tx_cnt == app_tx_length_r + 7)
            udp_tx_data_last <= 1'b1;
        else 
            udp_tx_data_last <= 0;
    end

//==================== ready =====================================

    always @(posedge clk) begin
        if (reset) 
            ready_cnt <= 0;
        else if (ready_cnt == READY_CNT_MAX) 
            ready_cnt <= 0;
        else if (app_tx_data_last | ready_cnt != 0)
            ready_cnt <= ready_cnt + 1;
        else 
            ready_cnt <= ready_cnt;
    end

    assign app_tx_ready = reset ? 1'b1 : ready_cnt == 0;

    shift_ram_IP u_shift_ram_IP_2 (
        .A            (   7                   ),      // input wire [5 : 0] A
        .D            (   app_tx_data_r       ),      // input wire [7 : 0] D
        .CLK          (   clk                 ),      // input wire CLK
        .Q            (   app_tx_data_delay   )       // output wire [7 : 0] Q
    );

endmodule
