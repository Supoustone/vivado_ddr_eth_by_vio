module zc_m_axi_wr_2_buffer#(
    parameter                               ADDR_WIDTH            = 32      ,
    parameter                               AXI_WR_DATA_WIDTH     = 128     
)(
    input                                   user_clk                        ,
    input                                   user_reset_n                    ,

    input [AXI_WR_DATA_WIDTH - 1 : 0]       buffer_wr_data                  ,
    input                                   buffer_wr_data_valid            ,
    input                                   buffer_wr_data_last             ,
    input [8:0]                             buffer_burst_length             ,
    input [ADDR_WIDTH - 1 : 0]              buffer_wr_addr                  ,

    input                                   axi_clk                         ,

    input                                   axi_awready                     ,
    output reg [ADDR_WIDTH - 1 : 0]         axi_awaddr                      ,
    output reg [8:0]                        axi_awlength                    ,
    output reg                              axi_wr_req                      ,

    input                                   axi_wready                      ,
    output reg [AXI_WR_DATA_WIDTH - 1 : 0]  axi_wdata                       ,
    output reg                              axi_wlast                       ,
    output reg                              axi_wvalid

);

    localparam      AXI_BUFFER_IDLE  =   3'b000     ;
    localparam      AXI_BUFFER_REQ   =   3'b001     ;
    localparam      AXI_BUFFER_WRITE =   3'b011     ;
    localparam      AXI_BUFFER_END   =   3'b010     ;

    reg [2:0]   cur_state;
    reg [2:0]   nex_state;

    (* dont_touch = "true" *) reg user_reset_n_d    ;
    (* dont_touch = "true" *) reg user_reset_n_2d   ;
    (* dont_touch = "true" *) reg reset_n           ;

    (* dont_touch = "true" *) reg async_reset_n_d   ;
    (* dont_touch = "true" *) reg async_reset_n_2d  ;
    (* dont_touch = "true" *) reg async_reset_n     ;

    always@(posedge user_clk)begin
        user_reset_n_d  <= user_reset_n             ;
        user_reset_n_2d <= user_reset_n_d           ;
        reset_n         <= user_reset_n_2d          ;
    end

    always@(posedge axi_clk)begin
        async_reset_n_d     <= user_reset_n         ;
        async_reset_n_2d    <= async_reset_n_d      ;
        async_reset_n       <= async_reset_n_2d     ;
    end

    wire            ecc_dbiterr_o                   ;
    wire [7:0]      ecc_eccparity_o                 ;
    wire            ecc_sbiterr_o                   ;
    wire [7:0]      ecc_dop_o                       ;
    wire            ecc_rderr_o                     ;
    wire            ecc_wrerr_o                     ;
    wire            wr_cmd_fifo_almostempty         ;
    wire            wr_cmd_fifo_almostfull          ;
    wire [12:0]     wr_cmd_fifo_rdcount             ;
    wire [12:0]     wr_cmd_fifo_wrcount             ;

    wire            wr_cmd_fifo_full                ;
    wire            wr_cmd_fifo_empty               ;
    wire            wr_cmd_fifo_rden                ;
    wire [63:0]     wr_cmd_fifo_rdout               ;

    wire            wr_data_fifo_rden               ;
    wire            wr_data_fifo_last               ;

    assign          wr_cmd_fifo_rden  = (axi_wr_req & axi_awready);
    assign          wr_data_fifo_rden = (axi_wvalid & axi_wready);

    always@(*)begin
        if(!async_reset_n)begin
            axi_awaddr      <= 'd0; 
            axi_awlength    <= 'd0;         
        end else if(axi_wr_req & axi_awready)begin
            axi_awaddr      <= wr_cmd_fifo_rdout[31:0];
            axi_awlength    <= wr_cmd_fifo_rdout[40:32];
        end else begin
            axi_awaddr      <= axi_awaddr;
            axi_awlength    <= axi_awlength;
        end
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            axi_wvalid <= 1'b0;
        else if(axi_wvalid & axi_wready & axi_wlast)
            axi_wvalid <= 1'b0;
        else if(axi_wr_req & axi_awready)
            axi_wvalid <= 1'b1;
        else
            axi_wvalid <= axi_wvalid;
    end

   FIFO36E1 #(
      .ALMOST_EMPTY_OFFSET      (   13'h0008               ),   
      .ALMOST_FULL_OFFSET       (   13'h0190               ),
      .INIT                     (   72'h000000000000000000 ),     // Initial values on output port
      .SRVAL                    (   72'h000000000000000000 ),     // Set/Reset value for output port
      .SIM_DEVICE               (   "7SERIES"              ),     // Must be set to "7SERIES" for simulation behavior
      .EN_ECC_READ              (   "FALSE"                ), 
      .EN_ECC_WRITE             (   "FALSE"                ),

      .DATA_WIDTH               (   72                     ),                  
      .DO_REG                   (   1                      ),     // Enable output register (1-0) Must be 1 if EN_SYN = FALSE           
      .EN_SYN                   (   "FALSE"                ),     // Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
      .FIFO_MODE                (   "FIFO36_72"            ),     // Sets mode to "FIFO36" or "FIFO36_72" 
      .FIRST_WORD_FALL_THROUGH  (   "TRUE"                 ) 
   )u_w72xd512_wr_cmd_fifo (
      .DBITERR          (   ecc_dbiterr_o           ),      // 1-bit output: Double bit error status
      .ECCPARITY        (   ecc_eccparity_o         ),      // 8-bit output: Generated error correction parity
      .SBITERR          (   ecc_sbiterr_o           ),      // 1-bit output: Single bit error status
      .INJECTDBITERR    (   1'b0                    ),      // 1-bit input: Inject a double bit error input
      .INJECTSBITERR    (   1'b0                    ),
      .REGCE            (   1'b1                    ),      // 1-bit input: Clock enable
      .RSTREG           (   ~reset_n                ),      // 1-bit input: Output register set/reset
      .DIP              (   8'b0                    ),      // 8-bit input: Parity input
      .DOP              (   ecc_dop_o               ),      // 8-bit output: Parity data output
      .RDERR            (   ecc_rderr_o             ),      // 1-bit output: Read error
      .WRERR            (   ecc_wrerr_o             ),      // 1-bit output: Write error
      .ALMOSTEMPTY      (   wr_cmd_fifo_almostempty ),      // 1-bit output: Almost empty flag
      .ALMOSTFULL       (   wr_cmd_fifo_almostfull  ),      // 1-bit output: Almost full flag
      .RDCOUNT          (   wr_cmd_fifo_rdcount     ),      // 13-bit output: Read count
      .WRCOUNT          (   wr_cmd_fifo_wrcount     ),      // 13-bit output: Write count

      .WRCLK            (   user_clk                                        ),      // 1-bit input: Rising edge write clock.
      .WREN             (   buffer_wr_data_last                             ),      // 1-bit input: Write enable
      .DI               (   { 23'b0 , buffer_burst_length , buffer_wr_addr} ),      // 64-bit input: Data input
      .FULL             (   wr_cmd_fifo_full                                ),      // 1-bit output: Full flag

      .RDCLK            (   axi_clk                                         ),      // 1-bit input: Read clock
      .RDEN             (   wr_cmd_fifo_rden                                ),      // 1-bit input: Read enable
      .DO               (   wr_cmd_fifo_rdout                               ),      // 64-bit output: Data output
      .EMPTY            (   wr_cmd_fifo_empty                               ),      // 1-bit output: Empty flag

      .RST              (   ~reset_n                                        )       // 1-bit input: Reset
   );

    generate
        if(AXI_WR_DATA_WIDTH == 'd128)begin

            wire [1:0]      data_ecc_dbiterr_o          ;
            wire [15:0]     data_ecc_eccparity_o        ;
            wire [1:0]      data_ecc_sbiterr_o          ;
            wire [15:0]     data_ecc_dop_o              ;
            wire [1:0]      data_ecc_rderr_o            ;
            wire [1:0]      data_ecc_wrerr_o            ;
            wire [1:0]      wr_data_fifo_almostempty    ;
            wire [1:0]      wr_data_fifo_almostfull     ;
            wire [25:0]     wr_data_fifo_rdcount        ;
            wire [25:0]     wr_data_fifo_wrcount        ;   

            wire [2:0]      wr_data_fifo_full           ;
            wire [2:0]      wr_data_fifo_empty          ;

            wire [127:0]    wr_data_fifo_dout           ;

            always@(*)begin
                if(!async_reset_n)begin
                    axi_wdata   <= 'd0;
                    axi_wlast   <= 1'b0;
                end else if(cur_state == AXI_BUFFER_WRITE & wr_data_fifo_rden)begin
                    axi_wdata   <= wr_data_fifo_dout;
                    axi_wlast   <= wr_data_fifo_last;
                end else begin
                    axi_wdata   <= 'd0;
                    axi_wlast   <= 1'b0;
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
            )u_w128xd512_wr_data_fifo_1 (
               .DBITERR          (   data_ecc_dbiterr_o[0]       ),      
               .ECCPARITY        (   data_ecc_eccparity_o[7:0]   ),      
               .SBITERR          (   data_ecc_sbiterr_o[0]       ),      
               .INJECTDBITERR    (   1'b0                        ),      
               .INJECTSBITERR    (   1'b0                        ),
               .REGCE            (   1'b1                        ),      
               .RSTREG           (   ~reset_n                    ),      
               .DIP              (   8'b0                        ),      
               .DOP              (   data_ecc_dop_o[7:0]         ),      
               .RDERR            (   data_ecc_rderr_o[0]         ),      
               .WRERR            (   data_ecc_wrerr_o[0]         ),      
               .ALMOSTEMPTY      (   wr_data_fifo_almostempty[0] ),      
               .ALMOSTFULL       (   wr_data_fifo_almostfull[0]  ),      
               .RDCOUNT          (   wr_data_fifo_rdcount[12:0]  ),      
               .WRCOUNT          (   wr_data_fifo_wrcount[12:0]  ),      

               .WRCLK            (   user_clk                    ),      
               .WREN             (   buffer_wr_data_valid        ),      
               .DI               (    buffer_wr_data[63:0]       ),      
               .FULL             (   wr_data_fifo_full[0]        ),      

               .RDCLK            (   axi_clk                     ),      
               .RDEN             (   wr_data_fifo_rden           ),      
               .DO               (   wr_data_fifo_dout[63:0]     ),      
               .EMPTY            (   wr_data_fifo_empty[0]       ),      

               .RST              (   ~reset_n                    )       
            );

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
            )u_w128xd512_wr_data_fifo_2 (
               .DBITERR          (   data_ecc_dbiterr_o[1]       ),      
               .ECCPARITY        (   data_ecc_eccparity_o[15:8]  ),      
               .SBITERR          (   data_ecc_sbiterr_o[1]       ),      
               .INJECTDBITERR    (   1'b0                        ),      
               .INJECTSBITERR    (   1'b0                        ),
               .REGCE            (   1'b1                        ),      
               .RSTREG           (   ~reset_n                    ),      
               .DIP              (   8'b0                        ),      
               .DOP              (   data_ecc_dop_o[15:8]        ),      
               .RDERR            (   data_ecc_rderr_o[1]         ),      
               .WRERR            (   data_ecc_wrerr_o[1]         ),     
               .ALMOSTEMPTY      (   wr_data_fifo_almostempty[1] ),     
               .ALMOSTFULL       (   wr_data_fifo_almostfull[1]  ),     
               .RDCOUNT          (   wr_data_fifo_rdcount[25:13] ),     
               .WRCOUNT          (   wr_data_fifo_wrcount[25:13] ),      

               .WRCLK            (   user_clk                    ),      
               .WREN             (   buffer_wr_data_valid        ),      
               .DI               (    buffer_wr_data[127:64]     ),      
               .FULL             (   wr_data_fifo_full[1]        ),      

               .RDCLK            (   axi_clk                     ),      
               .RDEN             (   wr_data_fifo_rden           ),     
               .DO               (   wr_data_fifo_dout[127:64]   ),   
               .EMPTY            (   wr_data_fifo_empty[1]       ),     

               .RST              (   ~reset_n                    )      
            );

            async_fifo#(                //FWFT
                .DEPTH              ( 512                           ),
                .WIDTH              ( 1                             )
             )u_w1xd512_wr_data_fifo_3(
                .wr_clk             ( user_clk                      ),
                .wr_en              ( buffer_wr_data_valid          ),
                .wr_data            ( buffer_wr_data_last           ),
                .wr_full            ( wr_data_fifo_full[2]          ),
                .rd_clk             ( axi_clk                       ),
                .rd_en              ( wr_data_fifo_rden             ),
                .rd_data            ( wr_data_fifo_last             ),
                .rd_empty           ( wr_data_fifo_empty[2]         ),
                .rst_n              ( reset_n                       )
             );
        end

/*         else if(AXI_WR_DATA_WIDTH == 'd256)begin

            wire [3:0]      data_ecc_dbiterr_o          ;
            wire [31:0]     data_ecc_eccparity_o        ;
            wire [3:0]      data_ecc_sbiterr_o          ;
            wire [31:0]     data_ecc_dop_o              ;
            wire [3:0]      data_ecc_rderr_o            ;
            wire [3:0]      data_ecc_wrerr_o            ;
            wire [3:0]      wr_data_fifo_almostempty    ;
            wire [3:0]      wr_data_fifo_almostfull     ;
            wire [51:0]     wr_data_fifo_rdcount        ;
            wire [51:0]     wr_data_fifo_wrcount        ;   

            wire [4:0]      wr_data_fifo_full           ;
            wire [4:0]      wr_data_fifo_empty          ;

            wire [255:0]    wr_data_fifo_dout           ;

            always@(*)begin
                if(!async_reset_n)begin
                    axi_wdata   <= 'd0;
                    axi_wlast   <= 1'b0;
                end else if(cur_state == AXI_BUFFER_WRITE & wr_data_fifo_rden)begin
                    axi_wdata   <= wr_data_fifo_dout;
                    axi_wlast   <= wr_data_fifo_last;
                end else begin
                    axi_wdata   <= 'd0;
                    axi_wlast   <= 1'b0;
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
            )u_w256xd512_wr_data_fifo_1 (
                .DBITERR          (   data_ecc_dbiterr_o[0]       ),      
                .ECCPARITY        (   data_ecc_eccparity_o[7:0]   ),      
                .SBITERR          (   data_ecc_sbiterr_o[0]       ),      
                .INJECTDBITERR    (   1'b0                        ),      
                .INJECTSBITERR    (   1'b0                        ),
                .REGCE            (   1'b1                        ),      
                .RSTREG           (   ~reset_n                    ),      
                .DIP              (   8'b0                        ),      
                .DOP              (   data_ecc_dop_o[7:0]         ),      
                .RDERR            (   data_ecc_rderr_o[0]         ),      
                .WRERR            (   data_ecc_wrerr_o[0]         ),      
                .ALMOSTEMPTY      (   wr_data_fifo_almostempty[0] ),      
                .ALMOSTFULL       (   wr_data_fifo_almostfull[0]  ),      
                .RDCOUNT          (   wr_data_fifo_rdcount[12:0]  ),      
                .WRCOUNT          (   wr_data_fifo_wrcount[12:0]  ),      

                .WRCLK            (   user_clk                    ),      
                .WREN             (   buffer_wr_data_valid        ),      
                .DI               (    buffer_wr_data[63:0]       ),      
                .FULL             (   wr_data_fifo_full[0]        ),      

                .RDCLK            (   axi_clk                     ),      
                .RDEN             (   wr_data_fifo_rden           ),      
                .DO               (   wr_data_fifo_dout[63:0]     ),      
                .EMPTY            (   wr_data_fifo_empty[0]       ),     
                .RST              (   ~reset_n                    )      
            );

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
            )u_w256xd512_wr_data_fifo_2(
                .DBITERR          (   data_ecc_dbiterr_o[1]       ),      
                .ECCPARITY        (   data_ecc_eccparity_o[15:8]  ),      
                .SBITERR          (   data_ecc_sbiterr_o[1]       ),      
                .INJECTDBITERR    (   1'b0                        ),      
                .INJECTSBITERR    (   1'b0                        ),
                .REGCE            (   1'b1                        ),      
                .RSTREG           (   ~reset_n                    ),      
                .DIP              (   8'b0                        ),      
                .DOP              (   data_ecc_dop_o[15:8]        ),      
                .RDERR            (   data_ecc_rderr_o[1]         ),      
                .WRERR            (   data_ecc_wrerr_o[1]         ),     
                .ALMOSTEMPTY      (   wr_data_fifo_almostempty[1] ),     
                .ALMOSTFULL       (   wr_data_fifo_almostfull[1]  ),     
                .RDCOUNT          (   wr_data_fifo_rdcount[25:13] ),     
                .WRCOUNT          (   wr_data_fifo_wrcount[25:13] ),      

                .WRCLK            (   user_clk                    ),      
                .WREN             (   buffer_wr_data_valid        ),      
                .DI               (    buffer_wr_data[127:64]     ),      
                .FULL             (   wr_data_fifo_full[1]        ),      

                .RDCLK            (   axi_clk                     ),      
                .RDEN             (   wr_data_fifo_rden           ),     
                .DO               (   wr_data_fifo_dout[127:64]   ),   
                .EMPTY            (   wr_data_fifo_empty[1]       ),     

                .RST              (   ~reset_n                    )      
            );

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
            )u_w256xd512_wr_data_fifo_3 (
                .DBITERR          (   data_ecc_dbiterr_o[2]       ),      
                .ECCPARITY        (   data_ecc_eccparity_o[23:16] ),      
                .SBITERR          (   data_ecc_sbiterr_o[2]       ),      
                .INJECTDBITERR    (   1'b0                        ),      
                .INJECTSBITERR    (   1'b0                        ),
                .REGCE            (   1'b1                        ),      
                .RSTREG           (   ~reset_n                    ),      
                .DIP              (   8'b0                        ),      
                .DOP              (   data_ecc_dop_o[23:16]       ),      
                .RDERR            (   data_ecc_rderr_o[2]         ),      
                .WRERR            (   data_ecc_wrerr_o[2]         ),     
                .ALMOSTEMPTY      (   wr_data_fifo_almostempty[2] ),     
                .ALMOSTFULL       (   wr_data_fifo_almostfull[2]  ),     
                .RDCOUNT          (   wr_data_fifo_rdcount[38:26] ),     
                .WRCOUNT          (   wr_data_fifo_wrcount[38:26] ),      

                .WRCLK            (   user_clk                    ),      
                .WREN             (   buffer_wr_data_valid        ),      
                .DI               (    buffer_wr_data[191:128]    ),      
                .FULL             (   wr_data_fifo_full[2]        ),      

                .RDCLK            (   axi_clk                     ),      
                .RDEN             (   wr_data_fifo_rden           ),     
                .DO               (   wr_data_fifo_dout[191:128]  ),   
                .EMPTY            (   wr_data_fifo_empty[2]       ),     

                .RST              (   ~reset_n                    )      
            );

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
            )u_w256xd512_wr_data_fifo_4 (
                .DBITERR          (   data_ecc_dbiterr_o[3]       ),      
                .ECCPARITY        (   data_ecc_eccparity_o[31:24]  ),      
                .SBITERR          (   data_ecc_sbiterr_o[3]       ),      
                .INJECTDBITERR    (   1'b0                        ),      
                .INJECTSBITERR    (   1'b0                        ),
                .REGCE            (   1'b1                        ),      
                .RSTREG           (   ~reset_n                    ),      
                .DIP              (   8'b0                        ),      
                .DOP              (   data_ecc_dop_o[31:24]       ),      
                .RDERR            (   data_ecc_rderr_o[3]         ),      
                .WRERR            (   data_ecc_wrerr_o[3]         ),     
                .ALMOSTEMPTY      (   wr_data_fifo_almostempty[3] ),     
                .ALMOSTFULL       (   wr_data_fifo_almostfull[3]  ),     
                .RDCOUNT          (   wr_data_fifo_rdcount[51:39] ),     
                .WRCOUNT          (   wr_data_fifo_wrcount[51:39] ),      

                .WRCLK            (   user_clk                    ),      
                .WREN             (   buffer_wr_data_valid        ),      
                .DI               (    buffer_wr_data[255:192]    ),      
                .FULL             (   wr_data_fifo_full[3]        ),      

                .RDCLK            (   axi_clk                     ),      
                .RDEN             (   wr_data_fifo_rden           ),     
                .DO               (   wr_data_fifo_dout[255:192]  ),   
                .EMPTY            (   wr_data_fifo_empty[3]       ),     

                .RST              (   ~reset_n                    )      
            );

            async_fifo#(                //FWFT
            .DEPTH              ( 512                           ),
            .WIDTH              ( 1                             )
            )u_w1xd512_wr_data_fifo_5(
            .wr_clk             ( user_clk                      ),
            .wr_en              ( buffer_wr_data_valid          ),
            .wr_data            ( buffer_wr_data_last           ),
            .wr_full            ( wr_data_fifo_full[4]          ),
            .rd_clk             ( axi_clk                       ),
            .rd_en              ( wr_data_fifo_rden             ),
            .rd_data            ( wr_data_fifo_last             ),
            .rd_empty           ( wr_data_fifo_empty[4]         ),
            .rst_n              ( reset_n                       )
            );       
        end */

        else if(AXI_WR_DATA_WIDTH == 'd64)begin

            wire            data_ecc_dbiterr_o          ;
            wire [7:0]      data_ecc_eccparity_o        ;
            wire            data_ecc_sbiterr_o          ;
            wire [7:0]      data_ecc_dop_o              ;
            wire            data_ecc_rderr_o            ;
            wire            data_ecc_wrerr_o            ;
            wire            wr_data_fifo_almostempty    ;
            wire            wr_data_fifo_almostfull     ;
            wire [12:0]     wr_data_fifo_rdcount        ;
            wire [12:0]     wr_data_fifo_wrcount        ;   

            wire [1:0]      wr_data_fifo_full           ;
            wire [1:0]      wr_data_fifo_empty          ;

            wire [63:0]     wr_data_fifo_dout           ;

            always@(*)begin
                if(!async_reset_n)begin
                    axi_wdata   <= 'd0;
                    axi_wlast   <= 1'b0;
                end else if(cur_state == AXI_BUFFER_WRITE & wr_data_fifo_rden)begin
                    axi_wdata   <= wr_data_fifo_dout;
                    axi_wlast   <= wr_data_fifo_last;
                end else begin
                    axi_wdata   <= 'd0;
                    axi_wlast   <= 1'b0;
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
            )u_w64xd512_wr_data_fifo_1 (
                    .DBITERR          (   data_ecc_dbiterr_o          ),      
                    .ECCPARITY        (   data_ecc_eccparity_o[7:0]   ),      
                    .SBITERR          (   data_ecc_sbiterr_o          ),      
                    .INJECTDBITERR    (   1'b0                        ),      
                    .INJECTSBITERR    (   1'b0                        ),
                    .REGCE            (   1'b1                        ),      
                    .RSTREG           (   ~reset_n                    ),      
                    .DIP              (   8'b0                        ),      
                    .DOP              (   data_ecc_dop_o[7:0]         ),      
                    .RDERR            (   data_ecc_rderr_o            ),      
                    .WRERR            (   data_ecc_wrerr_o            ),      
                    .ALMOSTEMPTY      (   wr_data_fifo_almostempty    ),      
                    .ALMOSTFULL       (   wr_data_fifo_almostfull     ),      
                    .RDCOUNT          (   wr_data_fifo_rdcount[12:0]  ),      
                    .WRCOUNT          (   wr_data_fifo_wrcount[12:0]  ),      

                    .WRCLK            (   user_clk                    ),      
                    .WREN             (   buffer_wr_data_valid        ),      
                    .DI               (   buffer_wr_data[63:0]        ),      
                    .FULL             (   wr_data_fifo_full[0]        ),      

                    .RDCLK            (   axi_clk                     ),      
                    .RDEN             (   wr_data_fifo_rden           ),      
                    .DO               (   wr_data_fifo_dout[63:0]     ),      
                    .EMPTY            (   wr_data_fifo_empty[0]       ),

                    .RST              (   ~reset_n                    )       
            );

            async_fifo#(                //FWFT
                .DEPTH              ( 512                           ),
                .WIDTH              ( 1                             )
            )u_w1xd512_wr_data_fifo_2(
                .wr_clk             ( user_clk                      ),
                .wr_en              ( buffer_wr_data_valid          ),
                .wr_data            ( buffer_wr_data_last           ),
                .wr_full            ( wr_data_fifo_full[1]          ),
                .rd_clk             ( axi_clk                       ),
                .rd_en              ( wr_data_fifo_rden             ),
                .rd_data            ( wr_data_fifo_last             ),
                .rd_empty           ( wr_data_fifo_empty[1]         ),
                .rst_n              ( reset_n                       )
            );       
        end
    endgenerate

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            axi_wr_req <= 1'b0;
        else if(axi_wr_req & axi_awready)
            axi_wr_req <= 1'b0;
        else if(cur_state == AXI_BUFFER_REQ)
            axi_wr_req <= 1'b1;
        else
            axi_wr_req <= axi_wr_req;
    end

    always@(posedge axi_clk or negedge async_reset_n)begin
        if(!async_reset_n)
            cur_state <= AXI_BUFFER_IDLE;
        else
            cur_state <= nex_state;
    end

    always@(*)begin
        if(!async_reset_n)
            nex_state <= AXI_BUFFER_IDLE;
        else begin
            case(cur_state)
                AXI_BUFFER_IDLE     : nex_state <= (~wr_cmd_fifo_empty) ? AXI_BUFFER_REQ : cur_state;
                AXI_BUFFER_REQ      : nex_state <= (axi_wr_req & axi_awready) ? AXI_BUFFER_WRITE : cur_state;
                AXI_BUFFER_WRITE    : nex_state <= (axi_wlast & axi_wvalid & axi_wready) ? AXI_BUFFER_END : cur_state;
                AXI_BUFFER_END      : nex_state <= AXI_BUFFER_IDLE;
                default             : nex_state <= AXI_BUFFER_IDLE;
            endcase
        end
    end			
endmodule