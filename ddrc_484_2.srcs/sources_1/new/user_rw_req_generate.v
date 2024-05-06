`timescale 1ns / 1ps

module user_rw_req_generate #(
		parameter USER_WR_DATA_WIDTH    = 16
)(	
	input                                   wr_clk          ,
	input                                   rd_clk          ,
    input                                   clk_100m        ,
	input                                   reset           ,

	output	reg 							user_wr_en      ,
	output  reg [USER_WR_DATA_WIDTH-1:0]    user_wr_data    ,

	output  reg                             user_rd_req                     
);

    localparam WR_BURST_BYTE    = 1024  ;
    localparam USER_WR_NUMBER   = 511   ;

    wire vio_wr;
    wire vio_rd;

    reg  vio_wr_d0;
    reg  vio_wr_d1;
    reg  vio_wr_d2;
    reg  vio_rd_d0;
    reg  vio_rd_d1;
    reg  vio_rd_d2;

    reg [$clog2(USER_WR_NUMBER)-1 : 0] wr_cnt;

    always @(posedge wr_clk) begin
        vio_wr_d0 <= vio_wr;
        vio_wr_d1 <= vio_wr_d0;
        vio_wr_d2 <= vio_wr_d1;	
    end

    always @(posedge rd_clk) begin
        vio_rd_d0 <= vio_rd;
        vio_rd_d1 <= vio_rd_d0;
        vio_rd_d2 <= vio_rd_d1;	
    end


    always @(posedge wr_clk) begin
        if (reset) begin 
            user_wr_en <= 0;
        end
        else if (vio_wr_d1 && ~vio_wr_d2) begin
            user_wr_en <= 1;
        end
        else if (user_wr_en && wr_cnt == USER_WR_NUMBER) begin
            user_wr_en <= 0;
        end
    end

    always @(posedge wr_clk) begin
        if (reset) begin
            wr_cnt <= 0;
        end
        else if (user_wr_en && wr_cnt == USER_WR_NUMBER) begin
            wr_cnt <= 0; 
        end
        else if (user_wr_en) begin
            wr_cnt <= wr_cnt + 1;
        end
    end

    always @(posedge wr_clk) begin
        if (reset) begin
            user_wr_data <= 0;
        end
        else if (user_wr_en) begin
            user_wr_data <= user_wr_data + 1;
        end
    end

always @(posedge rd_clk) begin
	user_rd_req <= vio_rd_d2;	
end

    vio_rw_trigger u_vio_rw_trigger (
      .clk(clk_100m),                // input wire clk
      .probe_out0(vio_wr),  // output wire [0 : 0] probe_out0
      .probe_out1(vio_rd)  // output wire [0 : 0] probe_out1
    );

endmodule

