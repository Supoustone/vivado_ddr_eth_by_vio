
//test passed!

module zc_gen_single_burst(
    input                   clkin_100m          ,
    input                   sys_rst_n           ,
    input                   mc_init_done        ,

    output reg [15:0]       outport_wr_o        ,
    output reg              outport_rd_o        ,
    output reg [31:0]       outport_addr_o      ,
    output reg [127:0]      outport_wr_data_o   ,

    input                   inport_accept_i     ,
    input                   inport_ack_i
);

    localparam              STATE_INIT      =       3'b001          ;
    localparam              STATE_WAIT_1    =       3'b010          ;
    localparam              STATE_WRITE     =       3'b011          ;
    localparam              STATE_WAIT_2    =       3'b100          ;
    localparam              STATE_READ      =       3'b101          ;
    localparam              STATE_OVER      =       3'b110          ;

    reg [2:0]               cur_state                               ;
    reg [2:0]               nex_state                               ;

    reg [15:0]              state_cnt                               ;

    reg [2:0]               state_run_times                         ;

    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            cur_state <= STATE_INIT;
        else
            cur_state <= nex_state;
    end
    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            state_cnt <= 0;
        else if(nex_state != cur_state)
            state_cnt <= 0;
        else
            state_cnt <= state_cnt + 1'b1;
    end

    always@(*)begin
        if(!sys_rst_n)
            nex_state <= STATE_INIT;
        else case(cur_state)
            STATE_INIT      : nex_state <= (mc_init_done == 1 && state_run_times <= 5   ) ? STATE_WAIT_1    : cur_state ;
            STATE_WAIT_1    : nex_state <= (state_cnt == 'd20                           ) ? STATE_WRITE     : cur_state ;
            STATE_WRITE     : nex_state <= (inport_accept_i == 1                        ) ? STATE_WAIT_2    : cur_state ;
            STATE_WAIT_2    : nex_state <= (state_cnt == 'd20                           ) ? STATE_READ      : cur_state ;
            STATE_READ      : nex_state <= (inport_accept_i == 1                        ) ? STATE_OVER      : cur_state ;
            STATE_OVER      : nex_state <= STATE_INIT                                                                   ;
            default         : nex_state <= STATE_INIT                                                                   ;
        endcase
    end

    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            state_run_times <= 0;
        else if(cur_state == STATE_OVER && state_cnt == 0)
            state_run_times <= state_run_times + 1'b1;
        else
            state_run_times <= state_run_times;
    end


//addr control
    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            outport_addr_o <= {5'd0,3'd2,14'd119,10'd128};
        else if(cur_state == STATE_WRITE & state_cnt == 'd0)
            outport_addr_o <= outport_addr_o + 'd32;
        else if(cur_state == STATE_READ & state_cnt == 'd0)
            outport_addr_o <= outport_addr_o - 'd32;
        else if(cur_state == STATE_READ & state_cnt == 'd2)
            outport_addr_o <= outport_addr_o + 'd32;
        else
            outport_addr_o <= outport_addr_o;
    end 

//write control
    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            outport_wr_o <= 'd0;
            outport_wr_data_o <= 128'h99998888777766665555cccc00003333;
        end
        else if(cur_state == STATE_WRITE & inport_accept_i)
            outport_wr_o <= 'd0;
        else if(cur_state == STATE_WRITE & state_cnt == 'd0)begin
            outport_wr_o <= 'hffff;
            outport_wr_data_o <= outport_wr_data_o + 'h2323;
        end
        else begin
            outport_wr_o <= outport_wr_o;
            outport_wr_data_o <= outport_wr_data_o;
        end
    end

//read control
    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            outport_rd_o <= 'd0;
        else if(cur_state == STATE_READ & inport_accept_i)
            outport_rd_o <= 'd0;
        else if(cur_state == STATE_READ & state_cnt == 'd2)
            outport_rd_o <= 1'b1;
        else
            outport_rd_o <= outport_rd_o; 
    end

endmodule