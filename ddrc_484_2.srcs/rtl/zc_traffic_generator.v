
//test passed!

module zc_traffic_generator(
    input                       clkin_100m          ,
    input                       sys_rst_n           ,
    input                       mc_init_done        ,

    output reg [15:0]           outport_wr_o        ,
    output reg                  outport_rd_o        ,
    output reg [31:0]           outport_addr_o      ,
    output reg [127:0]          outport_wr_data_o   ,

    input                       inport_accept_i     ,
    input                       inport_ack_i
);

    localparam                  STATE_INIT   = 3'b001        ;
    localparam                  STATE_WAIT_1 = 3'b010        ;
    localparam                  STATE_WRITE  = 3'b011        ;
    localparam                  STATE_WAIT_2 = 3'b100        ;
    localparam                  STATE_READ   = 3'b101        ;
    localparam                  STATE_OVER   = 3'b110        ;

    localparam                  WR_IDLE      = 3'b001        ;
    localparam                  WR_1         = 3'b010        ;
    localparam                  WR_2         = 3'b011        ;
    localparam                  WR_3         = 3'b100        ;
    localparam                  WR_END       = 3'b101        ;

    localparam                  RD_IDLE      = 3'b001        ;
    localparam                  RD_1         = 3'b010        ;
    localparam                  RD_2         = 3'b011        ;
    localparam                  RD_3         = 3'b100        ;
    localparam                  RD_END       = 3'b101        ;

    reg  [2 : 0]                cur_state                    ;
    reg  [2 : 0]                nex_state                    ;
    reg  [2 : 0]                cur_wr_state                 ;
    reg  [2 : 0]                nex_wr_state                 ;
    reg  [2 : 0]                cur_rd_state                 ;
    reg  [2 : 0]                nex_rd_state                 ;

    reg  [15 : 0]               state_cnt                    ;
    reg  [15 : 0]               wr_state_cnt                 ;
    reg  [15 : 0]               rd_state_cnt                 ;
 
    reg  [2 : 0]                state_run_times              ;


//main FSM
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
            STATE_INIT   :  nex_state <= (mc_init_done == 1 && state_run_times <= 2)    ?   STATE_WAIT_1    :   cur_state   ;
            STATE_WAIT_1 :  nex_state <= (state_cnt == 'd20)                            ?   STATE_WRITE     :   cur_state   ;
            STATE_WRITE  :  nex_state <= (cur_wr_state == WR_END)                       ?   STATE_WAIT_2    :   cur_state   ;
            STATE_WAIT_2 :  nex_state <= (state_cnt == 'd20)                            ?   STATE_READ      :   cur_state   ;
            STATE_READ   :  nex_state <= (cur_rd_state == RD_END)                       ?   STATE_OVER      :   cur_state   ;
            STATE_OVER   :  nex_state <= STATE_INIT ;
            default      :  nex_state <= STATE_INIT ;
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

//write control
    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            cur_wr_state <= WR_IDLE;
        else
            cur_wr_state <= nex_wr_state;
    end 

    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            wr_state_cnt <= 0;
        else if(nex_wr_state != cur_wr_state)
            wr_state_cnt <= 0;
        else
            wr_state_cnt <= wr_state_cnt + 1'b1; 
    end

    always@(*)begin
        if(!sys_rst_n)
            nex_wr_state <= WR_IDLE; 
        else case(cur_wr_state)
            WR_IDLE : nex_wr_state <= (cur_state == STATE_WRITE && state_cnt == 1)  ? WR_1   : cur_wr_state;
            WR_1    : nex_wr_state <= (inport_accept_i == 1)                        ? WR_2   : cur_wr_state;
            WR_2    : nex_wr_state <= (inport_accept_i == 1)                        ? WR_3   : cur_wr_state;
            WR_3    : nex_wr_state <= (inport_accept_i == 1)                        ? WR_END : cur_wr_state;
            WR_END  : nex_wr_state <= WR_IDLE;
            default : nex_wr_state <= WR_IDLE;
        endcase
    end

    //todo : 这种写法是不被综合允许的，因为outport_data_o处于多个always块里，但是仿真允许，最好将该信号集中放到一个always块里面。

    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            outport_wr_o          <= 'd0                                        ;
            outport_addr_o        <= {5'd0, 3'd1, 14'd10, 10'd16}               ;
            outport_wr_data_o     <= 128'h99998888777766665555cccc11110000      ;
        end
        else if(cur_state == STATE_WRITE)begin
            if(((cur_wr_state == WR_1)|| (cur_wr_state == WR_2) || (cur_wr_state == WR_3)) && inport_accept_i)
                outport_wr_o      <= 'd0                                        ;
            else if(((cur_wr_state == WR_1)|| (cur_wr_state == WR_2) || (cur_wr_state == WR_3)) && wr_state_cnt == 0)begin
                outport_wr_o      <= 'hffff                                     ;
                outport_addr_o    <= outport_addr_o + 'd16                      ;
                outport_wr_data_o <= outport_wr_data_o + 'h1111                 ;            
            end
            else begin
                outport_wr_o      <= outport_wr_o                               ;
                outport_addr_o    <= outport_addr_o                             ;
                outport_wr_data_o <= outport_wr_data_o                          ;            
            end
        end
    end

//read control
    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            cur_rd_state <= WR_IDLE;
        else
            cur_rd_state <= nex_rd_state;
    end 

    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)
            rd_state_cnt <= 0;
        else if(nex_rd_state != cur_rd_state)
            rd_state_cnt <= 0;
        else
            rd_state_cnt <= rd_state_cnt + 1'b1; 
    end

    always@(*)begin
        if(!sys_rst_n)
            nex_rd_state <= RD_IDLE; 
        else case(cur_rd_state)
            RD_IDLE : nex_rd_state <= (cur_state == STATE_READ && state_cnt == 1)   ? RD_1   : cur_rd_state;
            RD_1    : nex_rd_state <= (inport_accept_i == 1)                        ? RD_2   : cur_rd_state;
            RD_2    : nex_rd_state <= (inport_accept_i == 1)                        ? RD_3   : cur_rd_state;
            RD_3    : nex_rd_state <= (inport_accept_i == 1)                        ? RD_END : cur_rd_state;
            RD_END  : nex_rd_state <= RD_IDLE;
            default : nex_rd_state <= RD_IDLE;
        endcase
    end

    always@(posedge clkin_100m or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            outport_rd_o   <= 'd0                               ;
            outport_addr_o <= {5'd0, 3'd1, 14'd10, 10'd16}      ;
        end
        else if(cur_state == STATE_READ)begin
            if(cur_state == STATE_READ && state_cnt == 0)            //从开始写的地方读
                outport_addr_o   <= outport_addr_o - 'd48       ;
            else if(((cur_rd_state == RD_1)|| (cur_rd_state == RD_2) || (cur_rd_state == RD_3)) && inport_accept_i)
                outport_rd_o    <= 'd0                          ;
            else if(((cur_rd_state == RD_1)|| (cur_rd_state == RD_2) || (cur_rd_state == RD_3)) && rd_state_cnt == 0)begin
                outport_rd_o    <= 1'b1                         ;
                outport_addr_o  <= outport_addr_o + 'd16        ;            
            end
            else begin
                outport_rd_o    <= outport_rd_o                 ;
                outport_addr_o  <= outport_addr_o               ;            
            end
        end
    end  
endmodule