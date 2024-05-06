`timescale 1ns / 1ps

module ddr_to_eth_send(

	input				    clk					,
	input				    reset               ,

	input				    user_rd_valid       ,
	input				    user_rd_last        ,
	input	    [7:0]		user_rd_data        ,

    output reg			    app_tx_data_vld     ,
    output reg			    app_tx_data_last    ,
    output reg	[7:0]	    app_tx_data         ,
    output	    [15:0]		app_tx_length       , //最大不能超过1500 - 28 = 1472
    input				    app_tx_ready
    );

    reg [7:0] wait_cnt;
/*------------------------------------------*\
                FIFO端口信号定义
\*------------------------------------------*/
    reg  [8:0]  din             ;
    reg         wr_en           ;
    reg         rd_en           ;
    wire [8:0]  dout            ;
    wire        full            ;
    wire        empty           ;
    (* mark_debug = "true" *) wire [12:0] data_count      ;

/*------------------------------------------*\
                状态机信号定义
\*------------------------------------------*/
    reg [3:0]       cur_status;
    reg [3:0]       nxt_status;
    localparam      IDLE        = 4'b0000;
    localparam      PRE         = 4'b0001;
    localparam      DATA_EN     = 4'b0010;
    localparam      WAIT        = 4'b0100;
    localparam      OVER        = 4'b1000;
/*------------------------------------------*\
                    复位信号
\*------------------------------------------*/
    (* dont_touch = "true"*)reg [19:0] reset_timer      ;
    (* dont_touch = "true"*)reg        reset_sync_d0    ;
    (* dont_touch = "true"*)reg        reset_sync_d1    ;
    (* dont_touch = "true"*)reg        reset_sync       ;
/*------------------------------------------*\
                    assign
\*------------------------------------------*/

    assign app_tx_length = 16'd1024;

/*--------------------------------------------------*\
                    复位信号延长并同步
\*--------------------------------------------------*/

	always @(posedge clk or posedge reset) begin
		if (reset) 
			reset_timer <= 20'd0;
		else if (reset_timer <= 20'h00ff)
			reset_timer <= reset_timer + 1'b1;
		else 
			reset_timer <= reset_timer;
	end

	always @(posedge clk or posedge reset) begin
		if (reset)begin
			reset_sync_d0 <= 1'b1;
			reset_sync_d1 <= 1'b1;
			reset_sync    <= 1'b1;
		end		
		else begin
			reset_sync_d0 <= reset_timer <= 20'h00ff;
			reset_sync_d1 <= reset_sync_d0;
			reset_sync    <= reset_sync_d1;
		end		
	end

/*------------------------------------------*\
            用户读数据写入FIFO
\*------------------------------------------*/
    always @(posedge clk) begin
            wr_en <= user_rd_valid;
            din   <= {user_rd_last,user_rd_data};
    end

/*------------------------------------------*\
                    状态机
\*------------------------------------------*/
    always @(posedge clk) begin
        if (reset_sync) 
            cur_status <= IDLE;
        else 
            cur_status <= nxt_status;
    end

    always @(*) begin
        if (reset_sync) 
            nxt_status <= IDLE;
        else 
            case(cur_status)
                IDLE : begin
                    if (data_count >= 1024 && app_tx_ready)
                        nxt_status <= PRE;
                    else 
                        nxt_status <= cur_status;
                    end
                PRE : begin
                    nxt_status <= DATA_EN;
                end
                DATA_EN : begin
                    if (rd_en && dout[8])
                        nxt_status <= WAIT;
                    else 
                        nxt_status <= cur_status;
                end
                WAIT : begin
                    if (wait_cnt >= 10 && app_tx_ready)
                        nxt_status <= OVER;
                    else 
                        nxt_status <= cur_status;
                end
                OVER : begin
                    nxt_status <= IDLE;
                end
                default : nxt_status <= IDLE;
            endcase    
    end

    always @(posedge clk) begin
        if (reset_sync) 
            wait_cnt <= 0;
        else if (cur_status == WAIT ) 
            wait_cnt <= wait_cnt + 1;
        else 
            wait_cnt <= 0;
    end

/*------------------------------------------*\
                从FIFO里面读出数据
\*------------------------------------------*/
    always @(posedge clk) begin
        if (reset_sync) 
            rd_en <= 0;
        else if (cur_status == PRE) 
            rd_en <= 1'b1;
        else if (rd_en && dout[8])
            rd_en <= 0;
        else 
            rd_en <= rd_en;
    end

    always @(posedge clk) begin
        if (rd_en) begin
            app_tx_data_vld  <= 1;
            app_tx_data_last <= dout[8];
            app_tx_data      <= dout[7:0];
        end
        else begin
            app_tx_data_vld  <= 0;
            app_tx_data_last <= 0;
            app_tx_data      <= 0;		
        end      
    end

    ddr_to_eth_fifo_w9xd4096 u_ddr_to_eth_fifo_w9xd4096 (
        .clk            ( clk        ),      // input wire clk
        .srst           ( reset_sync ),      // input wire srst
        .din            ( din        ),      // input wire [8 : 0] din
        .wr_en          ( wr_en      ),      // input wire wr_en
        .rd_en          ( rd_en      ),      // input wire rd_en
        .dout           ( dout       ),      // output wire [8 : 0] dout
        .full           ( full       ),      // output wire full
        .empty          ( empty      ),      // output wire empty
        .data_count     ( data_count )       // output wire [12 : 0] data_count
    );

endmodule

