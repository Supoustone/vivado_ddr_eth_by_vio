module zc_m_axi_rd_1_user_itf#(
    parameter                                   ADDR_WIDTH                  =       32      ,
    parameter                                   USER_RD_DATA_WIDTH          =       16      ,
    parameter                                   AXI_RD_DATA_WIDTH           =       128     ,

    parameter                                   FOUR_KB_BOUNDARY            =       1024    ,
    parameter                                   MAX_AXI_BURST_LENGTH        = FOUR_KB_BOUNDARY / (AXI_RD_DATA_WIDTH / 8)//1024/(128/8) = 64 
)(
    input                                       user_clk            ,
    input                                       user_reset_n        ,

    input                                       mc_init_done        ,

    input                                       user_rd_en          , //rise edge valid
    output                                      user_rd_busy        ,

    input [ADDR_WIDTH - 1 : 0]                  user_rd_base_addr   ,
    input [ADDR_WIDTH - 1 : 0]                  user_rd_end_addr    ,

    output [8:0]                                buffer_burst_length ,
    output reg [ADDR_WIDTH - 1 : 0]             buffer_rd_addr      ,
    output reg                                  read_req_en         ,
    input                                       user_rd_ready        //important
);

    localparam          USER_RD_IDLE    =   2'b00   ;
    localparam          USER_RD_REQ     =   2'b01   ;
    localparam          USER_RD_END     =   2'b11   ;

    reg [1:0]           cur_state                   ;
    reg [1:0]           nex_state                   ;


    (* dont_touch = "true" *) reg user_reset_n_d    ;
    (* dont_touch = "true" *) reg user_reset_n_2d   ;
    (* dont_touch = "true" *) reg reset_n           ;

    reg                 trans_start_r               ;

    reg                 user_rd_en_r                ;
    reg                 user_rd_en_r_d              ;
    reg                 user_rd_trigger             ;

    wire                user_rd_rise_edge           ;

    assign user_rd_rise_edge = (~user_rd_en_r_d) & user_rd_en_r;

    assign buffer_burst_length  = MAX_AXI_BURST_LENGTH - 1      ;
    assign user_rd_busy         = (cur_state != USER_RD_IDLE)   ;

    always@(posedge user_clk)begin
        user_reset_n_d <= user_reset_n;
        user_reset_n_2d <= user_reset_n_d;
        reset_n <= user_reset_n_2d;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            trans_start_r <= 1'b0;
        else if(mc_init_done)
            trans_start_r <= 1'b1;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            user_rd_en_r <= 1'b0;
        else if(trans_start_r)
            user_rd_en_r <= user_rd_en;
    end

    always@(posedge user_clk)begin
        user_rd_en_r_d <= user_rd_en_r;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            user_rd_trigger <= 1'b0;
        else if(user_rd_rise_edge) 
            user_rd_trigger <= 1'b1;
        else
            user_rd_trigger <= 1'b0;   
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            cur_state <= USER_RD_IDLE;
        else
            cur_state <= nex_state;
    end

    always@(*)begin
        if(!reset_n)
            nex_state <= USER_RD_IDLE;
        else begin
            case(cur_state)
                USER_RD_IDLE    : nex_state <= (user_rd_trigger == 1 ) ? USER_RD_REQ : cur_state; 
                USER_RD_REQ     : nex_state <= (read_req_en & user_rd_ready) ? USER_RD_END : cur_state;
                USER_RD_END     : nex_state <= USER_RD_IDLE;
                default         : nex_state <= USER_RD_IDLE;
            endcase
        end
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            read_req_en <= 1'b0;
        else if(read_req_en & user_rd_ready)
            read_req_en <= 1'b0;
        else if(cur_state == USER_RD_REQ)
            read_req_en <= 1'b1;
        else
            read_req_en <= read_req_en;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            buffer_rd_addr <= user_rd_base_addr;
        else if(read_req_en & user_rd_ready & (buffer_rd_addr >= user_rd_end_addr - FOUR_KB_BOUNDARY))
            buffer_rd_addr <= user_rd_base_addr;
        else if(read_req_en & user_rd_ready)
            buffer_rd_addr <= buffer_rd_addr + FOUR_KB_BOUNDARY/2;
        else
            buffer_rd_addr <= buffer_rd_addr;       
    end
endmodule