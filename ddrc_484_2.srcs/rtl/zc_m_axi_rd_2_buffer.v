module zc_m_axi_rd_2_buffer#(
    parameter                               ADDR_WIDTH                  =       32      ,
    parameter                               USER_RD_DATA_WIDTH          =       16      ,
    parameter                               AXI_RD_DATA_WIDTH           =       128         
)(
    input                                   user_clk                        ,
    input                                   user_reset_n                    ,

    input                                   axi_clk                         ,

    input [8:0]                             buffer_burst_length             ,
    input [ADDR_WIDTH - 1 : 0]              buffer_rd_addr                  ,
    input                                   read_req_en                     ,
    output                                  user_rd_ready                   ,

    input                                   axi_ar_ready                    ,
    output reg[ADDR_WIDTH - 1 : 0]          axi_ar_addr                    ,
    output reg[8:0]                         axi_ar_length                   ,
    output reg                              axi_rd_req                      ,

    input                                   axi_r_valid                     ,
    input [AXI_RD_DATA_WIDTH - 1 : 0]       axi_r_data                      ,
    input                                   axi_r_last                      ,

    (* dont_touch = "true" *)output reg                              user_rd_valid                   ,
    (* dont_touch = "true" *)output reg [USER_RD_DATA_WIDTH - 1 : 0] user_rd_data                    ,
    (* dont_touch = "true" *)output reg                              user_rd_last
);

    localparam MAX_BIT_CNT = AXI_RD_DATA_WIDTH / USER_RD_DATA_WIDTH ;

    reg [$clog2(MAX_BIT_CNT) - 1 : 0] bit_cnt;

    localparam BUFFER_RD_IDLE  = 2'b00;
    localparam BUFFER_RD_REQ   = 2'b01;
    localparam BUFFER_RD_READ  = 2'b11;
    localparam BUFFER_RD_END   = 2'b10;

    reg [1:0] cur_state;
    reg [1:0] nex_state;

    (* dont_touch = "true" *) reg user_reset_n_d;
    (* dont_touch = "true" *) reg user_reset_n_2d;
    (* dont_touch = "true" *) reg reset_n;

    (* dont_touch = "true" *) reg async_reset_n_d;
    (* dont_touch = "true" *) reg async_reset_n_2d;
    (* dont_touch = "true" *) reg async_reset_n;

    reg                                 rd_data_fifo_rden   ;
    reg                                 fifo_data_flag      ;
    reg [AXI_RD_DATA_WIDTH - 1 : 0]     fifo_data_out       ;
    reg                                 fifo_data_last      ;

    wire                                rd_data_buffer_ready;

    always@(posedge user_clk)begin
        user_reset_n_d <= user_reset_n;
        user_reset_n_2d <= user_reset_n_d;
        reset_n <= user_reset_n_2d;
    end

    always@(posedge axi_clk)begin
        async_reset_n_d <= user_reset_n;
        async_reset_n_2d <= async_reset_n_d;
        async_reset_n <= async_reset_n_2d;
    end

    reg             rd_cmd_fifo_wr_en               ;
    reg [63:0]      rd_cmd_fifo_wr_data             ;
    wire            rd_cmd_fifo_rd_en               ;
    wire [63:0]     rd_cmd_fifo_rd_data             ;

    wire            ecc_dbiterr_o                   ;
    wire [7:0]      ecc_eccparity_o                 ;
    wire            ecc_sbiterr_o                   ;
    wire [7:0]      ecc_dop_o                       ;
    wire            ecc_rderr_o                     ;
    wire            ecc_wrerr_o                     ;
    wire            rd_cmd_fifo_almostempty         ;
    wire            rd_cmd_fifo_almostfull          ;
    wire [12:0]     rd_cmd_fifo_rdcount             ;
    wire [12:0]     rd_cmd_fifo_wrcount             ;

    wire            rd_cmd_fifo_full                ;
    wire            rd_cmd_fifo_empty               ;

    assign          user_rd_ready = ((async_reset_n) & ((rd_cmd_fifo_wrcount[8:0] >= rd_cmd_fifo_rdcount[8:0]) ? 
                    ((rd_cmd_fifo_wrcount[8:0] - rd_cmd_fifo_rdcount[8:0])  <= 'd12 ) :
                     ((rd_cmd_fifo_wrcount[9:0] - rd_cmd_fifo_rdcount[8:0]) <= 'd12))) ? 1'b1 : 1'b0;
    assign          rd_cmd_fifo_rd_en = (axi_rd_req & axi_ar_ready);

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)begin
            rd_cmd_fifo_wr_en   <= 1'b0 ;
            rd_cmd_fifo_wr_data <= 'd0  ;        
        end else if(user_rd_ready & read_req_en)begin
            rd_cmd_fifo_wr_en   <= 1'b1;
            rd_cmd_fifo_wr_data <= {23'b0 , buffer_burst_length , buffer_rd_addr};
        end else begin
            rd_cmd_fifo_wr_en   <= 1'b0;
            rd_cmd_fifo_wr_data <= rd_cmd_fifo_wr_data;
        end
    end

    always@(*)begin
        if(!reset_n)begin
            axi_ar_addr   <= 'd0;
            axi_ar_length <= 'd0;
        end else if(axi_rd_req & axi_ar_ready)begin
            axi_ar_addr   <= rd_cmd_fifo_rd_data[31:0];
            axi_ar_length <= rd_cmd_fifo_rd_data[40:32];
        end else begin
            axi_ar_addr <= axi_ar_addr;
            axi_ar_length <= axi_ar_length;
        end
    end

   FIFO36E1#(
      .ALMOST_EMPTY_OFFSET      (   13'h0008               ),   
      .ALMOST_FULL_OFFSET       (   13'h0190               ),
      .INIT                     (   72'h000000000000000000 ),     
      .SRVAL                    (   72'h000000000000000000 ),     
      .SIM_DEVICE               (   "7SERIES"              ),     
      .EN_ECC_READ              (   "FALSE"                ), 
      .EN_ECC_WRITE             (   "FALSE"                ),

      .DATA_WIDTH               (   72                     ),                  
      .DO_REG                   (   1                      ),        
      .EN_SYN                   (   "FALSE"                ),     
      .FIFO_MODE                (   "FIFO36_72"            ),     
      .FIRST_WORD_FALL_THROUGH  (   "TRUE"                 ) 
   )u_w72xd512_rd_cmd_fifo (
      .DBITERR          (   ecc_dbiterr_o           ),      
      .ECCPARITY        (   ecc_eccparity_o         ),      
      .SBITERR          (   ecc_sbiterr_o           ),      
      .INJECTDBITERR    (   1'b0                    ),      
      .INJECTSBITERR    (   1'b0                    ),
      .REGCE            (   1'b1                    ),      
      .RSTREG           (   ~reset_n                ),      
      .DIP              (   8'b0                    ),      
      .DOP              (   ecc_dop_o               ),      
      .RDERR            (   ecc_rderr_o             ),      
      .WRERR            (   ecc_wrerr_o             ),      
      .ALMOSTEMPTY      (   rd_cmd_fifo_almostempty ),      
      .ALMOSTFULL       (   rd_cmd_fifo_almostfull  ),      
      .RDCOUNT          (   rd_cmd_fifo_rdcount     ),      
      .WRCOUNT          (   rd_cmd_fifo_wrcount     ),      

      .WRCLK            (   user_clk                                        ),      
      .WREN             (   rd_cmd_fifo_wr_en                               ),      
      .DI               (   rd_cmd_fifo_wr_data                             ),      
      .FULL             (   rd_cmd_fifo_full                                ),      

      .RDCLK            (   axi_clk                                         ),      

      .RDEN             (  rd_cmd_fifo_rd_en                                ),      
      .DO               (  rd_cmd_fifo_rd_data                              ),      
      .EMPTY            (  rd_cmd_fifo_empty                                ),      

      .RST              (   ~reset_n                                        )       
   );

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            cur_state <= BUFFER_RD_IDLE;
        else
            cur_state <= nex_state; 
    end

    always@(*)begin
        if(!async_reset_n)
            nex_state <= BUFFER_RD_IDLE;
        else begin
            case(cur_state)
                BUFFER_RD_IDLE  : nex_state <= (~rd_cmd_fifo_empty && rd_data_buffer_ready) ? BUFFER_RD_REQ : cur_state;
                BUFFER_RD_REQ   : nex_state <= (axi_rd_req & axi_ar_ready) ? BUFFER_RD_READ : cur_state;
                BUFFER_RD_READ  : nex_state <= (axi_r_valid & axi_r_last) ? BUFFER_RD_END : cur_state;
                BUFFER_RD_END   : nex_state <= BUFFER_RD_IDLE;
                default         : nex_state <= BUFFER_RD_IDLE;
            endcase
        end
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            axi_rd_req <= 1'b0;
        else if(axi_rd_req & axi_ar_ready)
            axi_rd_req <= 1'b0;
        else if(cur_state == BUFFER_RD_REQ)
            axi_rd_req <= 1'b1;
        else
            axi_rd_req <= axi_rd_req;
    end

///////////////////////////////////////////////////////////////////////////////////////////////////////
    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            fifo_data_flag <= 1'b0;
        else if(bit_cnt == MAX_BIT_CNT - 1 && fifo_data_flag)
            fifo_data_flag <= 1'b0;
        else if(rd_data_fifo_rden)
            fifo_data_flag <= 1'b1;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            bit_cnt <= 'd0;
        else if(rd_data_fifo_rden)
            bit_cnt <= 'd0;
        else if(bit_cnt == MAX_BIT_CNT - 1 & fifo_data_flag)
            bit_cnt <= 'd0;
        else if(fifo_data_flag)
            bit_cnt <= bit_cnt + 1'b1;
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)begin
            user_rd_data <= 'd0;
            user_rd_valid <= 1'b0;
        end else if(fifo_data_flag)begin
            user_rd_data <= fifo_data_out[USER_RD_DATA_WIDTH - 1 : 0];
            user_rd_valid <= 1'b1;
        end else begin
            user_rd_data <= user_rd_data;
            user_rd_valid <= 1'b0;
        end
    end

    always@(posedge user_clk or negedge reset_n)begin
        if(!reset_n)
            user_rd_last <= 1'b0;
        else if(user_rd_last)
            user_rd_last <= 1'b0;
        else if(fifo_data_last && bit_cnt == MAX_BIT_CNT - 1 & fifo_data_flag)
            user_rd_last <= 1'b1;
        else
            user_rd_last <= 1'b0;
    end

    generate
        if(AXI_RD_DATA_WIDTH == 'd128)begin
        
            wire [1:0]      data_ecc_dbiterr_o          ;
            wire [15:0]     data_ecc_eccparity_o        ;
            wire [1:0]      data_ecc_sbiterr_o          ;
            wire [15:0]     data_ecc_dop_o              ;
            wire [1:0]      data_ecc_rderr_o            ;
            wire [1:0]      data_ecc_wrerr_o            ;
            wire [1:0]      rd_data_fifo_almostempty    ;
            wire [1:0]      rd_data_fifo_almostfull     ;
            wire [25:0]     rd_data_fifo_rdcount        ;
            wire [25:0]     rd_data_fifo_wrcount        ;   

            wire [2:0]      rd_data_fifo_full           ;
            wire [2:0]      rd_data_fifo_empty          ;

            wire [127:0]    rd_data_fifo_rdout          ;
            wire            rd_data_fifo_rdlast         ;
        
            assign rd_data_buffer_ready = (async_reset_n) ? 
            ((rd_data_fifo_wrcount[8:0] >= rd_data_fifo_rdcount[8:0]) ? 
                 ((rd_data_fifo_wrcount[8:0] - rd_data_fifo_rdcount[8:0])  <= 'd384 ) :
                  ((rd_data_fifo_wrcount[9:0] - rd_data_fifo_rdcount[8:0]) <= 'd384)) : 1'b0;   //todo:这个FIFO36E1的wrcount和rdcount仅仅是一个计数的作用，写进一个就加1，读出一个也加1，并且多出来的位数全是1;我需要保证当FIFO里的座位能容纳得下我一次突发的量时才允许释放我的读cmd信息
        
            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    rd_data_fifo_rden <= 1'b0;
                else if(rd_data_fifo_rden)
                    rd_data_fifo_rden <= 1'b0;
                else if((rd_data_fifo_empty[1:0]!=2'b11) & ~fifo_data_flag)
                    rd_data_fifo_rden <= 1'b1;
            end

            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    fifo_data_out <= 'd0;
                else if(rd_data_fifo_rden)
                    fifo_data_out <= rd_data_fifo_rdout[AXI_RD_DATA_WIDTH - 1 : 0];
                else if(fifo_data_flag)
                    fifo_data_out <= fifo_data_out >> USER_RD_DATA_WIDTH;
            end

            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    fifo_data_last <= 1'b0;
                else if(fifo_data_flag & bit_cnt == MAX_BIT_CNT - 1)
                    fifo_data_last <= 1'b0;
                else if(rd_data_fifo_rden)
                    fifo_data_last <= rd_data_fifo_rdlast;
            end

            FIFO36E1#(
               .ALMOST_EMPTY_OFFSET         (   13'h0008                   ),   
               .ALMOST_FULL_OFFSET          (   13'h0190                   ),
               .INIT                        (   72'h000000000000000000     ),     
               .SRVAL                       (   72'h000000000000000000     ),     
               .SIM_DEVICE                  (   "7SERIES"                  ),     
               .EN_ECC_READ                 (   "FALSE"                    ), 
               .EN_ECC_WRITE                (   "FALSE"                    ),

               .DATA_WIDTH                  (   72                         ),                  
               .DO_REG                      (   1                          ),           
               .EN_SYN                      (   "FALSE"                    ),     
               .FIFO_MODE                   (   "FIFO36_72"                ),     
               .FIRST_WORD_FALL_THROUGH     (   "TRUE"                     ) 
            )u_w128xd512_rd_data_fifo_1 (
               .DBITERR                     (   data_ecc_dbiterr_o[0]       ),      
               .ECCPARITY                   (   data_ecc_eccparity_o[7:0]   ),      
               .SBITERR                     (   data_ecc_sbiterr_o[0]       ),      
               .INJECTDBITERR               (   1'b0                        ),      
               .INJECTSBITERR               (   1'b0                        ),
               .REGCE                       (   1'b1                        ),      
               .RSTREG                      (   ~reset_n                    ),      
               .DIP                         (   8'b0                        ),      
               .DOP                         (   data_ecc_dop_o[7:0]         ),      
               .RDERR                       (   data_ecc_rderr_o[0]         ),      
               .WRERR                       (   data_ecc_wrerr_o[0]         ),      
               .ALMOSTEMPTY                 (   rd_data_fifo_almostempty[0] ),      
               .ALMOSTFULL                  (   rd_data_fifo_almostfull[0]  ),      
               .RDCOUNT                     (   rd_data_fifo_rdcount[12:0]  ),      
               .WRCOUNT                     (   rd_data_fifo_wrcount[12:0]  ),      

               .WRCLK                       (   axi_clk                     ),      
               .WREN                        (   axi_r_valid                 ),      
               .DI                          (   axi_r_data[63:0]            ),      
               .FULL                        (   rd_data_fifo_full[0]        ),      

               .RDCLK                       (   user_clk                    ),    
               .RDEN                        (   rd_data_fifo_rden           ),      
               .DO                          (   rd_data_fifo_rdout[63:0]    ),      
               .EMPTY                       (   rd_data_fifo_empty[0]       ),    

               .RST                         (   ~reset_n                    )      
            );

            FIFO36E1#(
               .ALMOST_EMPTY_OFFSET         (   13'h0008                    ),   
               .ALMOST_FULL_OFFSET          (   13'h0190                    ),
               .INIT                        (   72'h000000000000000000      ),     
               .SRVAL                       (   72'h000000000000000000      ),     
               .SIM_DEVICE                  (   "7SERIES"                   ),     
               .EN_ECC_READ                 (   "FALSE"                     ), 
               .EN_ECC_WRITE                (   "FALSE"                     ),

               .DATA_WIDTH                  (   72                          ),                  
               .DO_REG                      (   1                           ),         
               .EN_SYN                      (   "FALSE"                     ),     
               .FIFO_MODE                   (   "FIFO36_72"                 ),     
               .FIRST_WORD_FALL_THROUGH     (   "TRUE"                      ) 
            )u_w128xd512_rd_data_fifo_2(
               .DBITERR                     (   data_ecc_dbiterr_o[1]       ),      
               .ECCPARITY                   (   data_ecc_eccparity_o[15:8]  ),      
               .SBITERR                     (   data_ecc_sbiterr_o[1]       ),      
               .INJECTDBITERR               (   1'b0                        ),      
               .INJECTSBITERR               (   1'b0                        ),
               .REGCE                       (   1'b1                        ),      
               .RSTREG                      (   ~reset_n                    ),      
               .DIP                         (   8'b0                        ),      
               .DOP                         (   data_ecc_dop_o[15:8]        ),      
               .RDERR                       (   data_ecc_rderr_o[1]         ),      
               .WRERR                       (   data_ecc_wrerr_o[1]         ),     
               .ALMOSTEMPTY                 (   rd_data_fifo_almostempty[1] ),     
               .ALMOSTFULL                  (   rd_data_fifo_almostfull[1]  ),     
               .RDCOUNT                     (   rd_data_fifo_rdcount[25:13] ),     
               .WRCOUNT                     (   rd_data_fifo_wrcount[25:13] ),      

               .WRCLK                       (   axi_clk                     ),      
               .WREN                        (   axi_r_valid                 ),      
               .DI                          (   axi_r_data[127:64]          ),      
               .FULL                        (   rd_data_fifo_full[1]        ),      

               .RDCLK                       (   user_clk                    ),      
               .RDEN                        (   rd_data_fifo_rden           ),     
               .DO                          (   rd_data_fifo_rdout[127:64]  ),   
               .EMPTY                       (   rd_data_fifo_empty[1]       ),     

               .RST                         (   ~reset_n                    )      
            );

            async_fifo#(                //FWFT
                .DEPTH                      ( 512                           ),
                .WIDTH                      ( 1                             )
            )u_w1xd512_rd_data_fifo_3(
                .wr_clk                     ( axi_clk                       ),
                .wr_en                      ( axi_r_valid                   ),
                .wr_data                    ( axi_r_last                    ),
                .wr_full                    ( rd_data_fifo_full[2]          ),
                .rd_clk                     ( user_clk                      ),
                .rd_en                      ( rd_data_fifo_rden             ),
                .rd_data                    ( rd_data_fifo_rdlast           ),
                .rd_empty                   ( rd_data_fifo_empty[2]         ),
                .rst_n                      ( reset_n                       )
             );
        end

/*         else if(AXI_RD_DATA_WIDTH == 'd256)begin

            wire [3:0]      data_ecc_dbiterr_o          ;
            wire [31:0]     data_ecc_eccparity_o        ;
            wire [3:0]      data_ecc_sbiterr_o          ;
            wire [31:0]     data_ecc_dop_o              ;
            wire [3:0]      data_ecc_rderr_o            ;
            wire [3:0]      data_ecc_wrerr_o            ;
            wire [3:0]      rd_data_fifo_almostempty    ;
            wire [3:0]      rd_data_fifo_almostfull     ;
            wire [51:0]     rd_data_fifo_rdcount        ;
            wire [51:0]     rd_data_fifo_wrcount        ;   

            wire [4:0]      rd_data_fifo_full           ;
            wire [4:0]      rd_data_fifo_empty          ;

            wire [255:0]    rd_data_fifo_rdout          ;
            wire            rd_data_fifo_rdlast         ;


            assign rd_data_buffer_ready = (async_reset_n) ? 
            ((rd_data_fifo_wrcount[8:0] >= rd_data_fifo_rdcount[8:0]) ? 
                 ((rd_data_fifo_wrcount[8:0] - rd_data_fifo_rdcount[8:0])  <= 'd448) :
                  ((rd_data_fifo_wrcount[9:0] - rd_data_fifo_rdcount[8:0]) <= 'd448)) : 1'b0; 

            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    rd_data_fifo_rden <= 1'b0;
                else if(rd_data_fifo_rden)
                    rd_data_fifo_rden <= 1'b0;
                else if((rd_data_fifo_empty[3:0]!=4'b1111) & ~fifo_data_flag)
                    rd_data_fifo_rden <= 1'b1;
            end

            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    fifo_data_out <= 'd0;
                else if(rd_data_fifo_rden)
                    fifo_data_out <= rd_data_fifo_rdout[AXI_RD_DATA_WIDTH - 1 : 0];
                else if(fifo_data_flag)
                    fifo_data_out <= fifo_data_out >> USER_RD_DATA_WIDTH;
            end

            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    fifo_data_last <= 1'b0;
                else if(fifo_data_flag & bit_cnt == MAX_BIT_CNT - 1)
                    fifo_data_last <= 1'b0;
                else if(rd_data_fifo_rden)
                    fifo_data_last <= rd_data_fifo_rdlast;
            end

            FIFO36E1#(
                .ALMOST_EMPTY_OFFSET        (   13'h0008                    ),   
                .ALMOST_FULL_OFFSET         (   13'h0190                    ),
                .INIT                       (   72'h000000000000000000      ),     
                .SRVAL                      (   72'h000000000000000000      ),     
                .SIM_DEVICE                 (   "7SERIES"                   ),     
                .EN_ECC_READ                (   "FALSE"                     ), 
                .EN_ECC_WRITE               (   "FALSE"                     ),

                .DATA_WIDTH                 (   72                          ),                  
                .DO_REG                     (   1                           ),       
                .EN_SYN                     (   "FALSE"                     ),     
                .FIFO_MODE                  (   "FIFO36_72"                 ),     
                .FIRST_WORD_FALL_THROUGH    (   "TRUE"                      ) 
            )u_w256xd512_rd_data_fifo_1 (
                .DBITERR                    (   data_ecc_dbiterr_o[0]       ),      
                .ECCPARITY                  (   data_ecc_eccparity_o[7:0]   ),      
                .SBITERR                    (   data_ecc_sbiterr_o[0]       ),      
                .INJECTDBITERR              (   1'b0                        ),      
                .INJECTSBITERR              (   1'b0                        ),
                .REGCE                      (   1'b1                        ),      
                .RSTREG                     (   ~reset_n                    ),      
                .DIP                        (   8'b0                        ),      
                .DOP                        (   data_ecc_dop_o[7:0]         ),      
                .RDERR                      (   data_ecc_rderr_o[0]         ),      
                .WRERR                      (   data_ecc_wrerr_o[0]         ),      
                .ALMOSTEMPTY                (   rd_data_fifo_almostempty[0] ),      
                .ALMOSTFULL                 (   rd_data_fifo_almostfull[0]  ),      
                .RDCOUNT                    (   rd_data_fifo_rdcount[12:0]  ),      
                .WRCOUNT                    (   rd_data_fifo_wrcount[12:0]  ),      

                .WRCLK                      (   axi_clk                     ),      
                .WREN                       (   axi_r_valid                 ),      
                .DI                         (   axi_r_data[63:0]            ),      
                .FULL                       (   rd_data_fifo_full[0]        ),      

                .RDCLK                      (   user_clk                    ),      
                .RDEN                       (   rd_data_fifo_rden           ),      
                .DO                         (   rd_data_fifo_rdout[63:0]    ),      
                .EMPTY                      (   rd_data_fifo_empty[0]       ),     
                .RST                        (   ~reset_n                    )      
            );

            FIFO36E1#(
                .ALMOST_EMPTY_OFFSET        (   13'h0008                    ),   
                .ALMOST_FULL_OFFSET         (   13'h0190                    ),
                .INIT                       (   72'h000000000000000000      ),     
                .SRVAL                      (   72'h000000000000000000      ),     
                .SIM_DEVICE                 (   "7SERIES"                   ),     
                .EN_ECC_READ                (   "FALSE"                     ), 
                .EN_ECC_WRITE               (   "FALSE"                     ),

                .DATA_WIDTH                 (   72                          ),                  
                .DO_REG                     (   1                           ),         
                .EN_SYN                     (   "FALSE"                     ),     
                .FIFO_MODE                  (   "FIFO36_72"                 ),     
                .FIRST_WORD_FALL_THROUGH    (   "TRUE"                      ) 
            )u_w256xd512_rd_data_fifo_2(
                .DBITERR                    (   data_ecc_dbiterr_o[1]       ),      
                .ECCPARITY                  (   data_ecc_eccparity_o[15:8]  ),      
                .SBITERR                    (   data_ecc_sbiterr_o[1]       ),      
                .INJECTDBITERR              (   1'b0                        ),      
                .INJECTSBITERR              (   1'b0                        ),
                .REGCE                      (   1'b1                        ),      
                .RSTREG                     (   ~reset_n                    ),      
                .DIP                        (   8'b0                        ),      
                .DOP                        (   data_ecc_dop_o[15:8]        ),      
                .RDERR                      (   data_ecc_rderr_o[1]         ),      
                .WRERR                      (   data_ecc_wrerr_o[1]         ),     
                .ALMOSTEMPTY                (   rd_data_fifo_almostempty[1] ),     
                .ALMOSTFULL                 (   rd_data_fifo_almostfull[1]  ),     
                .RDCOUNT                    (   rd_data_fifo_rdcount[25:13] ),     
                .WRCOUNT                    (   rd_data_fifo_wrcount[25:13] ),      

                .WRCLK                      (   user_clk                    ),      
                .WREN                       (   axi_r_valid                 ),      
                .DI                         (   axi_r_data[127:64]          ),      
                .FULL                       (   rd_data_fifo_full[1]        ),      

                .RDCLK                      (   axi_clk                     ),      
                .RDEN                       (   rd_data_fifo_rden           ),     
                .DO                         (   rd_data_fifo_rdout[127:64]  ),   
                .EMPTY                      (   rd_data_fifo_empty[1]       ),     

                .RST                        (   ~reset_n                    )      
            );

            FIFO36E1#(
                .ALMOST_EMPTY_OFFSET        (   13'h0008                    ),   
                .ALMOST_FULL_OFFSET         (   13'h0190                    ),
                .INIT                       (   72'h000000000000000000      ),     
                .SRVAL                      (   72'h000000000000000000      ),     
                .SIM_DEVICE                 (   "7SERIES"                   ),     
                .EN_ECC_READ                (   "FALSE"                     ), 
                .EN_ECC_WRITE               (   "FALSE"                     ),

                .DATA_WIDTH                 (   72                          ),                  
                .DO_REG                     (   1                           ),         
                .EN_SYN                     (   "FALSE"                     ),     
                .FIFO_MODE                  (   "FIFO36_72"                 ),     
                .FIRST_WORD_FALL_THROUGH    (   "TRUE"                      ) 
            )u_w256xd512_rd_data_fifo_3(
                .DBITERR                    (   data_ecc_dbiterr_o[2]       ),      
                .ECCPARITY                  (   data_ecc_eccparity_o[23:16] ),      
                .SBITERR                    (   data_ecc_sbiterr_o[2]       ),      
                .INJECTDBITERR              (   1'b0                        ),      
                .INJECTSBITERR              (   1'b0                        ),
                .REGCE                      (   1'b1                        ),      
                .RSTREG                     (   ~reset_n                    ),      
                .DIP                        (   8'b0                        ),      
                .DOP                        (   data_ecc_dop_o[23:16]       ),      
                .RDERR                      (   data_ecc_rderr_o[2]         ),      
                .WRERR                      (   data_ecc_wrerr_o[2]         ),     
                .ALMOSTEMPTY                (   rd_data_fifo_almostempty[2] ),     
                .ALMOSTFULL                 (   rd_data_fifo_almostfull[2]  ),     
                .RDCOUNT                    (   rd_data_fifo_rdcount[38:26] ),     
                .WRCOUNT                    (   rd_data_fifo_wrcount[38:26] ),      

                .WRCLK                      (   axi_clk                     ),      
                .WREN                       (   axi_r_valid                 ),      
                .DI                         (   axi_r_data[191:128]         ),      
                .FULL                       (   rd_data_fifo_full[2]        ),      

                .RDCLK                      (   axi_clk                     ),      
                .RDEN                       (   rd_data_fifo_rden           ),     
                .DO                         (   rd_data_fifo_rdout[191:128] ),   
                .EMPTY                      (   rd_data_fifo_empty[2]       ),     

                .RST                        (   ~reset_n                    )      
            );

            FIFO36E1#(
                .ALMOST_EMPTY_OFFSET        (   13'h0008                    ),   
                .ALMOST_FULL_OFFSET         (   13'h0190                    ),
                .INIT                       (   72'h000000000000000000      ),     
                .SRVAL                      (   72'h000000000000000000      ),     
                .SIM_DEVICE                 (   "7SERIES"                   ),     
                .EN_ECC_READ                (   "FALSE"                     ), 
                .EN_ECC_WRITE               (   "FALSE"                     ),

                .DATA_WIDTH                 (   72                          ),                  
                .DO_REG                     (   1                           ),         
                .EN_SYN                     (   "FALSE"                     ),     
                .FIFO_MODE                  (   "FIFO36_72"                 ),     
                .FIRST_WORD_FALL_THROUGH    (   "TRUE"                      ) 
            )u_w256xd512_rd_data_fifo_4 (
                .DBITERR                    (   data_ecc_dbiterr_o[3]       ),      
                .ECCPARITY                  (   data_ecc_eccparity_o[31:24] ),      
                .SBITERR                    (   data_ecc_sbiterr_o[3]       ),      
                .INJECTDBITERR              (   1'b0                        ),      
                .INJECTSBITERR              (   1'b0                        ),
                .REGCE                      (   1'b1                        ),      
                .RSTREG                     (   ~reset_n                    ),      
                .DIP                        (   8'b0                        ),      
                .DOP                        (   data_ecc_dop_o[31:24]       ),      
                .RDERR                      (   data_ecc_rderr_o[3]         ),      
                .WRERR                      (   data_ecc_wrerr_o[3]         ),     
                .ALMOSTEMPTY                (   rd_data_fifo_almostempty[3] ),     
                .ALMOSTFULL                 (   rd_data_fifo_almostfull[3]  ),     
                .RDCOUNT                    (   rd_data_fifo_rdcount[51:39] ),     
                .WRCOUNT                    (   rd_data_fifo_wrcount[51:39] ),      

               .WRCLK                       (   axi_clk                     ),      
               .WREN                        (   axi_r_valid                 ),      
               .DI                          (   axi_r_data[255:192]         ),      
               .FULL                        (   rd_data_fifo_full[3]        ),      

               .RDCLK                       (   user_clk                    ),      
               .RDEN                        (   rd_data_fifo_rden           ),     
               .DO                          (   rd_data_fifo_rdout[255:192] ),   
               .EMPTY                       (   rd_data_fifo_empty[3]       ),     

               .RST                         (   ~reset_n                    )      
            );

            async_fifo#(                //FWFT
            .DEPTH                          ( 512                           ),
            .WIDTH                          ( 1                             )
            )u_w1xd512_rd_data_fifo_5(
            .wr_clk                         ( axi_clk                       ),
            .wr_en                          ( axi_r_valid                   ),
            .wr_data                        ( axi_r_last                    ),
            .wr_full                        ( rd_data_fifo_full[4]          ),
            .rd_clk                         ( user_clk                      ),
            .rd_en                          ( rd_data_fifo_rden             ),
            .rd_data                        ( rd_data_fifo_rdlast           ),
            .rd_empty                       ( rd_data_fifo_empty[4]         ),
            .rst_n                          ( reset_n                       )
            );       
        end */

        else if(AXI_RD_DATA_WIDTH == 'd64)begin

            wire            data_ecc_dbiterr_o          ;
            wire [7:0]      data_ecc_eccparity_o        ;
            wire            data_ecc_sbiterr_o          ;
            wire [7:0]      data_ecc_dop_o              ;
            wire            data_ecc_rderr_o            ;
            wire            data_ecc_wrerr_o            ;
            wire            rd_data_fifo_almostempty    ;
            wire            rd_data_fifo_almostfull     ;
            wire [12:0]     rd_data_fifo_rdcount        ;
            wire [12:0]     rd_data_fifo_wrcount        ;   

            wire [1:0]      rd_data_fifo_full           ;
            wire [1:0]      rd_data_fifo_empty          ;

            wire [63:0]     rd_data_fifo_rdout          ;
            wire            rd_data_fifo_rdlast         ;

            assign rd_data_buffer_ready = (async_reset_n) ? 
            ((rd_data_fifo_wrcount[8:0] >= rd_data_fifo_rdcount[8:0]) ? 
                 ((rd_data_fifo_wrcount[8:0] - rd_data_fifo_rdcount[8:0])  <= 'd256 ) :
                  ((rd_data_fifo_wrcount[9:0] - rd_data_fifo_rdcount[8:0]) <= 'd256)) : 1'b0; 

            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    rd_data_fifo_rden <= 1'b0;
                else if(rd_data_fifo_rden)
                    rd_data_fifo_rden <= 1'b0;
                else if((rd_data_fifo_empty[0]!=1'b1) & ~fifo_data_flag)
                    rd_data_fifo_rden <= 1'b1;
            end 

            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    fifo_data_out <= 'd0;
                else if(rd_data_fifo_rden)
                    fifo_data_out <= rd_data_fifo_rdout[AXI_RD_DATA_WIDTH - 1 : 0];
                else if(fifo_data_flag)
                    fifo_data_out <= fifo_data_out >> USER_RD_DATA_WIDTH;
            end

            always@(posedge user_clk or negedge reset_n)begin
                if(!reset_n)
                    fifo_data_last <= 1'b0;
                else if(fifo_data_flag & bit_cnt == MAX_BIT_CNT - 1)
                    fifo_data_last <= 1'b0;
                else if(rd_data_fifo_rden)
                    fifo_data_last <= rd_data_fifo_rdlast;
            end

            FIFO36E1#(
                .ALMOST_EMPTY_OFFSET        (   13'h0008                    ),   
                .ALMOST_FULL_OFFSET         (   13'h0190                    ),
                .INIT                       (   72'h000000000000000000      ),     
                .SRVAL                      (   72'h000000000000000000      ),     
                .SIM_DEVICE                 (   "7SERIES"                   ),     
                .EN_ECC_READ                (   "FALSE"                     ), 
                .EN_ECC_WRITE               (   "FALSE"                     ),

                .DATA_WIDTH                 (   72                          ),                  
                .DO_REG                     (   1                           ),       
                .EN_SYN                     (   "FALSE"                     ),     
                .FIFO_MODE                  (   "FIFO36_72"                 ),     
                .FIRST_WORD_FALL_THROUGH    (   "TRUE"                      ) 
            )u_w64xd512_wr_data_fifo_1 (
                    .DBITERR                (   data_ecc_dbiterr_o          ),      
                    .ECCPARITY              (   data_ecc_eccparity_o[7:0]   ),      
                    .SBITERR                (   data_ecc_sbiterr_o          ),      
                    .INJECTDBITERR          (   1'b0                        ),      
                    .INJECTSBITERR          (   1'b0                        ),
                    .REGCE                  (   1'b1                        ),      
                    .RSTREG                 (   ~reset_n                    ),      
                    .DIP                    (   8'b0                        ),      
                    .DOP                    (   data_ecc_dop_o[7:0]         ),      
                    .RDERR                  (   data_ecc_rderr_o            ),      
                    .WRERR                  (   data_ecc_wrerr_o            ),      
                    .ALMOSTEMPTY            (   rd_data_fifo_almostempty    ),      
                    .ALMOSTFULL             (   rd_data_fifo_almostfull     ),      
                    .RDCOUNT                (   rd_data_fifo_rdcount[12:0]  ),      
                    .WRCOUNT                (   rd_data_fifo_wrcount[12:0]  ),      

                    .WRCLK                  (   axi_clk                     ),      
                    .WREN                   (   axi_r_valid                 ),      
                    .DI                     (   axi_r_data[63:0]            ),      
                    .FULL                   (   rd_data_fifo_full[0]        ),      

                    .RDCLK                  (   user_clk                    ),      
                    .RDEN                   (   rd_data_fifo_rden           ),      
                    .DO                     (   rd_data_fifo_rdout[63:0]    ),      
                    .EMPTY                  (   rd_data_fifo_empty[0]       ),

                    .RST                    (   ~reset_n                    )       
            );

            async_fifo#(                //FWFT
                .DEPTH                      ( 512                           ),
                .WIDTH                      ( 1                             )
            )u_w1xd512_rd_data_fifo_2(
                .wr_clk                     ( axi_clk                       ),
                .wr_en                      ( axi_r_valid                   ),
                .wr_data                    ( axi_r_last                    ),
                .wr_full                    ( rd_data_fifo_full[1]          ),
                .rd_clk                     ( user_clk                      ),
                .rd_en                      ( rd_data_fifo_rden             ),
                .rd_data                    ( rd_data_fifo_rdlast           ),
                .rd_empty                   ( rd_data_fifo_empty[1]         ),
                .rst_n                      ( reset_n                       )
            );       
        end
    endgenerate
endmodule