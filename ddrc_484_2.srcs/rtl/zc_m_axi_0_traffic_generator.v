`timescale 1ns / 1ps

module zc_m_axi_0_traffic_generator#(
    parameter ADDR_WIDTH                    =  32               ,
    parameter USER_WR_DATA_WIDTH            =  16
)(
    input                                   user_clk            ,
    input                                   user_reset_n        ,
    input                                   mc_init_done        ,                   

    output reg[USER_WR_DATA_WIDTH - 1 : 0]  user_wr_data        ,
    output reg                              user_wr_en          ,

    output reg                              user_rd_req               //edge trigger
    );

    localparam     GEN_IDLE  = 3'b000   ;
    localparam     GEN_WAIT1 = 3'b001   ;
    localparam     GEN_WRITE = 3'b011   ;
    localparam     GEN_WAIT2 = 3'b010   ;
    localparam     GEN_READ  = 3'b110   ;
    localparam     GEN_END   = 3'b100   ;

    reg [15:0]      reset_n_cnt         ;
    reg             reset_n             ;

    reg [2:0]       cur_state           ;
    reg [2:0]       nex_state           ;
    reg [15:0]      state_cnt           ;
    reg [2:0]       sim_times           ;

    always@(posedge user_clk)begin
        if(!user_reset_n)
            reset_n_cnt <= 0;
        else if(reset_n_cnt == 3100)
            reset_n_cnt <= reset_n_cnt;
        else
            reset_n_cnt <= reset_n_cnt + 1'b1; 
    end

    always@(posedge user_clk)begin
        if(!user_reset_n)
            reset_n <= 0;
        else if(reset_n_cnt >= 3000)
            reset_n <= 1;
        else 
            reset_n <= reset_n; 
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            cur_state <= GEN_IDLE;
        else
            cur_state <= nex_state;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            state_cnt <= 'd0;
        else if(nex_state != cur_state)
            state_cnt <= 'd0;
        else
            state_cnt <= state_cnt + 1'b1;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            sim_times <= 'd0;
        else if(sim_times >= 'd5)
            sim_times <= sim_times;
        else if(cur_state == GEN_WRITE & state_cnt == 'd0)
            sim_times <= sim_times + 1'b1;
        else
            sim_times <= sim_times;
    end

    always@(*)begin
        if(!reset_n)
            nex_state <= GEN_IDLE;
        else begin
            case(cur_state)
                GEN_IDLE  : nex_state <= (mc_init_done == 1 & sim_times <= 'd4) ? GEN_WAIT1 : cur_state; 
                GEN_WAIT1 : nex_state <= (state_cnt == 'd20)                    ? GEN_WRITE : cur_state;
                GEN_WRITE : nex_state <= (state_cnt == 'd1050)                  ? GEN_WAIT2 : cur_state;
                GEN_WAIT2 : nex_state <= (state_cnt == 'd500)                   ? GEN_READ  : cur_state;
                GEN_READ  : nex_state <= (state_cnt == 'd2000)                  ? GEN_END   : cur_state;  
                GEN_END   : nex_state <= GEN_IDLE;
                default   : nex_state <= GEN_IDLE;                  
            endcase
        end
    end

    always@(posedge user_clk)begin
        if(!reset_n)
            user_wr_en <= 0;
        else if(cur_state == GEN_WRITE & state_cnt <= 1023)
            user_wr_en <= 1;
        else 
            user_wr_en <= 0;
    end 
    always@(posedge user_clk)begin
        if(!reset_n)
            user_wr_data <= 0;
        else if(user_wr_en)
            user_wr_data <= user_wr_data + 1'b1;
        else
            user_wr_data <= user_wr_data; 
    end

    always@(posedge user_clk)begin
        if(!reset_n)
            user_rd_req <= 0;
        else if(state_cnt == 'd500 & cur_state == GEN_READ)
            user_rd_req <= 1;
        else 
            user_rd_req <= 0;
    end

endmodule
