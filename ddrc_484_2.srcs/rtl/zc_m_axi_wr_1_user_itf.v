module zc_m_axi_wr_1_user_itf#(
    parameter                                  ADDR_WIDTH               = 32    ,
    parameter                                  USER_WR_DATA_WIDTH       = 16    ,
    parameter                                  AXI_WR_DATA_WIDTH        = 128   ,

    parameter                                  FOUR_KB_BOUNDARY        = 1024   ,   //set to 1024 , 1024/(128/8) = 64 , 64个128    (2048 B)
    parameter                                  MAX_AXI_BURST_LENGTH    = FOUR_KB_BOUNDARY / (AXI_WR_DATA_WIDTH / 8)
)(
    input                                       user_clk                ,
    input                                       user_reset_n            ,

    input                                       mc_init_done            ,

    input                                       user_wr_en              ,
    input [USER_WR_DATA_WIDTH - 1 : 0]          user_wr_data            ,
    input [ADDR_WIDTH - 1 : 0]                  user_wr_base_addr       ,
    input [ADDR_WIDTH - 1 : 0]                  user_wr_end_addr        ,

    output reg [AXI_WR_DATA_WIDTH - 1 : 0]      buffer_wr_data          ,
    output reg                                  buffer_wr_data_valid    ,
    output reg                                  buffer_wr_data_last     ,
    output [8:0]                                buffer_burst_length     ,

    output reg [ADDR_WIDTH - 1 : 0]             buffer_wr_addr
);

    localparam BUFFER_USER_DATA_RATIO = AXI_WR_DATA_WIDTH / USER_WR_DATA_WIDTH;

    reg [$clog2(BUFFER_USER_DATA_RATIO) - 1 : 0]    bit_cnt             ;
    reg [$clog2(MAX_AXI_BURST_LENGTH) - 1 : 0]      byte_cnt            ;

    reg                                             trans_start_r       ;
    reg                                             user_wr_en_r        ;
    reg [USER_WR_DATA_WIDTH - 1 : 0]                user_wr_data_r      ;



    (* dont_touch = "true" *) reg                   user_reset_n_d      ;
    (* dont_touch = "true" *) reg                   user_reset_n_2d     ;
    (* dont_touch = "true" *) reg                   reset_n             ;

    wire                                    buffer_wr_data_valid_tag    ;
    wire                                    buffer_wr_data_last_tag     ;


    assign buffer_wr_data_valid_tag = (bit_cnt == BUFFER_USER_DATA_RATIO - 1);
    assign buffer_wr_data_last_tag  = (bit_cnt == BUFFER_USER_DATA_RATIO - 1) & (byte_cnt == MAX_AXI_BURST_LENGTH - 1); 
    assign buffer_burst_length      = MAX_AXI_BURST_LENGTH - 1;

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
        if(!reset_n)begin
            user_wr_en_r    <= 0;
            user_wr_data_r  <= 0;
        end else if(trans_start_r)begin
            user_wr_en_r <= user_wr_en;
            user_wr_data_r <= user_wr_data;
        end
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)begin
            buffer_wr_data_valid <= 1'b0;
            buffer_wr_data_last <= 1'b0;
        end
        else begin
            buffer_wr_data_valid <= buffer_wr_data_valid_tag;
            buffer_wr_data_last <= buffer_wr_data_last_tag;
        end
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            bit_cnt <= 'd0;
        else if(bit_cnt == BUFFER_USER_DATA_RATIO - 1)
            bit_cnt <= 'd0;
        else if(user_wr_en_r)
            bit_cnt <= bit_cnt + 1'b1;
        else
            bit_cnt <= bit_cnt;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            byte_cnt <= 'd0;
        else if(byte_cnt == MAX_AXI_BURST_LENGTH - 1 & bit_cnt == BUFFER_USER_DATA_RATIO - 1)
            byte_cnt <= 'd0;
        else if(bit_cnt == BUFFER_USER_DATA_RATIO - 1)
            byte_cnt <= byte_cnt + 1'b1;
        else
            byte_cnt <= byte_cnt;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            buffer_wr_data <= 'd0;
        else
            buffer_wr_data <= {user_wr_data_r , buffer_wr_data[AXI_WR_DATA_WIDTH - 1 : USER_WR_DATA_WIDTH]};
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            buffer_wr_addr <= user_wr_base_addr;
        else if(buffer_wr_data_last & ((user_wr_end_addr - buffer_wr_addr) <= FOUR_KB_BOUNDARY))
            buffer_wr_addr <= user_wr_base_addr;//地址环回
        else if(buffer_wr_data_last)
            buffer_wr_addr <= buffer_wr_addr + FOUR_KB_BOUNDARY/2;  //AXI的1个地址能存8个字节，而DDR3的一个地址是16个字节
        else
            buffer_wr_addr <= buffer_wr_addr;
    end
endmodule