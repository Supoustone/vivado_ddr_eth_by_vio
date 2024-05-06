//attention axi写入的数据不能完全掩码。如果完全掩码，ddrc端会无视该次写请求，并且accept也不会拉高，这会引起写入长度有误。 

//attention zc_ddr3_dfi.v 's fifo width

//for native port , write is piror to read

module zc_ddr3_axi_slave_itf#(
    parameter integer                       AXI_ID_WIDTH        = 4     ,
    parameter integer                       AXI_DATA_WIDTH      = 128   ,    //must be 128
    parameter integer                       AXI_ADDR_WIDTH      = 32    ,
    parameter integer                       AXI_AWUSER_WIDTH    = 1     ,
    parameter integer                       AXI_ARUSER_WIDTH    = 1     ,
    parameter integer                       AXI_WUSER_WIDTH     = 1     ,
    parameter integer                       AXI_RUSER_WIDTH     = 1     ,
    parameter integer                       AXI_BUSER_WIDTH     = 1
)(
    input                                   s_axi_aclk                  ,
    input                                   s_axi_areset_n              ,   //the rst_n is shared with the ddrc clock domain

    input [AXI_ID_WIDTH - 1 : 0]            s_axi_awid      ,
    input [AXI_ADDR_WIDTH - 1 : 0]          s_axi_awaddr    , // 5'b0 , 3'b BA , 14'b RA , 10'b CA
    input [7 : 0]                           s_axi_awlen     , //awlen = Number of data transfers - 1
    input [2 : 0]                           s_axi_awsize    , //indicates bytes in transfer , 3'b100 for 16 Bytes (128 bits) in my situation 
    input [1 : 0]                           s_axi_awburst   , //burst type , 2'b01 for INCR (incrementing-address burst) for noraml sequential memory
    input                                   s_axi_awlock    ,
    input [3 : 0]                           s_axi_awcache   ,
    input [2 : 0]                           s_axi_awprot    ,
    input [3 : 0]                           s_axi_awqos     ,
    input [AXI_AWUSER_WIDTH - 1 : 0]        s_axi_awuser    ,
    input                                   s_axi_awvalid   ,
    output reg                              s_axi_awready   ,

    input [AXI_DATA_WIDTH     - 1 : 0]      s_axi_wdata     ,
    input [(AXI_DATA_WIDTH/8) - 1 : 0]      s_axi_wstrb     ,//write strobe. wstrb[n] corresponds to wdata[(8*n) + 7 :(8*n)]
    input                                   s_axi_wlast     ,
    input [AXI_WUSER_WIDTH - 1 : 0]         s_axi_wuser     ,
    input                                   s_axi_wvalid    ,
    output reg                              s_axi_wready    ,

    output [AXI_ID_WIDTH - 1 : 0]           s_axi_bid       ,
    output reg[1 : 0]                       s_axi_bresp     ,
    output [AXI_BUSER_WIDTH - 1 : 0]        s_axi_buser     ,
    output reg                              s_axi_bvalid    ,
    input                                   s_axi_bready    ,

    input [AXI_ID_WIDTH - 1 : 0]            s_axi_arid      ,
    input [AXI_ADDR_WIDTH - 1 : 0]          s_axi_araddr    ,
    input [7 : 0]                           s_axi_arlen     , //arlen = Number of data transfers - 1
    input [2 : 0]                           s_axi_arsize    ,
    input [1 : 0]                           s_axi_arburst   ,
    input                                   s_axi_arlock    ,
    input [3 : 0]                           s_axi_arcache   ,
    input [2 : 0]                           s_axi_arprot    ,
    input [3 : 0]                           s_axi_arqos     ,
    input [AXI_ARUSER_WIDTH - 1 : 0]        s_axi_aruser    ,
    input                                   s_axi_arvalid   ,
    output reg                              s_axi_arready   ,

    output [AXI_ID_WIDTH - 1 : 0]           s_axi_rid       ,
    output [AXI_DATA_WIDTH - 1 : 0]         s_axi_rdata     ,
    output [1 : 0]                          s_axi_rresp     ,
    output reg                              s_axi_rlast     ,
    output [AXI_RUSER_WIDTH - 1 : 0]        s_axi_ruser     ,
    output                                  s_axi_rvalid    ,
    input                                   s_axi_rready    ,



    input                                   ddrc_clk            ,

    output reg[15:0]                        inport_wr_o         ,
    output reg                              inport_rd_o         ,
    output reg[31:0]                        inport_addr_o       ,
    output reg[127:0]                       inport_wr_data_o    ,

    input                                   inport_accept_i     ,
    input                                   inport_ack_i        ,//no use , equal to inport_accept_i
    input [127:0]                           inport_rd_data_i    ,
    input                                   inport_rd_data_vld_i,

    output                                  aw_fifo_full        ,//virtual full signal of aw fifo , inform user not to start a write burst 
    output                                  ar_fifo_full
);

    (* dont_touch = "true" *)   reg         rst_n_d             ;    //beat some bests to keep the CDC process stable in the asynchronous clock domain
    (* dont_touch = "true" *)   reg         rst_n_2d            ;
    (* dont_touch = "true" *)   reg         rst_n               ;

    wire                                    w_aw_active         ;
    wire                                    w_w_active          ;
    wire                                    w_b_active          ;
    wire                                    w_ar_active         ;
    wire                                    w_r_active          ;

    wire                                    aw_fifo_empty       ;
    wire                                    ar_fifo_empty       ;
    wire                                    w_fifo_full         ;
    wire                                    w_fifo_empty        ;
    wire                                    r_fifo_full         ;
    wire                                    r_fifo_empty        ;

    wire                                    ar_fifo_rden        ;
    wire                                    aw_fifo_rden        ;
    wire                                    w_fifo_rden         ;

    assign w_aw_active  = s_axi_awvalid & s_axi_awready         ;
    assign w_w_active   = s_axi_wvalid  & s_axi_wready          ;
    assign w_b_active   = s_axi_bvalid  & s_axi_bready          ;
    assign w_ar_active  = s_axi_arvalid & s_axi_arready         ;
    assign w_r_active   = s_axi_rvalid  & s_axi_rready          ;

    assign s_axi_bid    = 'd0                                   ;
    assign s_axi_buser  = 'd0                                   ;
    assign s_axi_rid    = 'd0                                   ;
    assign s_axi_ruser  = 'd0                                   ;
    assign s_axi_rresp  = 2'b0                                  ;

    always@(posedge s_axi_aclk)begin
        rst_n_d     <= s_axi_areset_n   ;
        rst_n_2d    <= rst_n_d          ;
        rst_n       <= rst_n_2d         ;
    end

    always@(posedge s_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            s_axi_awready <= 1'b1;
        else if(w_aw_active)
            s_axi_awready <= 1'b0;
        else if(s_axi_wlast & w_w_active)
            s_axi_awready <= 1'b1;
        else
            s_axi_awready <= s_axi_awready;
    end

    always@(posedge s_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            s_axi_wready <= 0;
        else if(s_axi_wlast & w_w_active)
            s_axi_wready <= 1'b0;
        else if(w_aw_active)
            s_axi_wready <= 1'b1;
        else
            s_axi_wready <= s_axi_wready;
    end

    always@(posedge s_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            s_axi_bresp <= 2'bzz;
        else if(s_axi_wlast & w_w_active)
            s_axi_bresp <= 2'b00;
        else
            s_axi_bresp <= 2'bzz;  
    end

    always@(posedge s_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            s_axi_bvalid <= 1'b0;
        else if(w_b_active)
            s_axi_bvalid <= 1'b0;
        else if(s_axi_wlast & w_w_active)
            s_axi_bvalid <= 1'b1;
        else
            s_axi_bvalid <= s_axi_bvalid;
    end

    always@(posedge s_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            s_axi_arready <= 1'b1;
        else if(w_r_active & s_axi_rlast)
            s_axi_arready <= 1'b1;
        else if(w_ar_active)
            s_axi_arready <= 1'b0;
        else 
            s_axi_arready <= s_axi_arready; 
    end

//write fifo
    wire [AXI_ADDR_WIDTH - 1 : 0]   wr_operation_addr;
    wire [7:0]                      wr_operation_len;
    wire [AXI_DATA_WIDTH - 1 : 0]   wr_operation_data;
    wire [AXI_DATA_WIDTH/8 - 1 : 0] wr_operation_mask;

    wire            wr_ecc_dbiterr_o                    ;
    wire [7:0]      wr_ecc_eccparity_o                  ;
    wire            wr_ecc_sbiterr_o                    ;
    wire [7:0]      wr_ecc_dop_o                        ;
    wire            wr_ecc_rderr_o                      ;
    wire            wr_ecc_wrerr_o                      ;
    wire            wr_cmd_fifo_almostempty             ;
    wire            wr_cmd_fifo_almostfull              ;
    wire [12:0]     wr_cmd_fifo_rdcount                 ;
    wire [12:0]     wr_cmd_fifo_wrcount                 ;

       FIFO36E1 #(
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
   )u_w72xd512_wr_cmd_fifo (
      .DBITERR          (   wr_ecc_dbiterr_o            ),      
      .ECCPARITY        (   wr_ecc_eccparity_o          ),      
      .SBITERR          (   wr_ecc_sbiterr_o            ),      
      .INJECTDBITERR    (   1'b0                        ),      
      .INJECTSBITERR    (   1'b0                        ),
      .REGCE            (   1'b1                        ),      
      .RSTREG           (   ~rst_n                      ),      
      .DIP              (   8'b0                        ),      
      .DOP              (   wr_ecc_dop_o                ),      
      .RDERR            (   wr_ecc_rderr_o              ),      
      .WRERR            (   wr_ecc_wrerr_o              ),      
      .ALMOSTEMPTY      (   wr_cmd_fifo_almostempty     ),      
      .ALMOSTFULL       (   wr_cmd_fifo_almostfull      ),      
      .RDCOUNT          (   wr_cmd_fifo_rdcount         ),      
      .WRCOUNT          (   wr_cmd_fifo_wrcount         ),      

      .WRCLK            (   s_axi_aclk                                      ),      
      .WREN             (   w_aw_active                                     ),     
      .DI               (   {24'b0 , s_axi_awaddr , s_axi_awlen}            ),     
      .FULL             (   aw_fifo_full                                    ),     

      .RDCLK            (   ddrc_clk                                        ),     
      .RDEN             (   aw_fifo_rden                                    ),     
      .DO               (   { wr_operation_addr , wr_operation_len}         ),    
      .EMPTY            (   aw_fifo_empty                                   ),     

      .RST              (   ~rst_n                                          )       
   );

/*     async_fifo#(
        .DEPTH     (    1024                                        ),
        .WIDTH     (   AXI_DATA_WIDTH/8 + AXI_DATA_WIDTH            )
    )u_w_fifo(
        .wr_clk    (    s_axi_aclk                                  ),
        .wr_en     (    w_w_active                                  ),
        .wr_data   (    {s_axi_wstrb , s_axi_wdata}                 ),
        .wr_full   (    w_fifo_full                                 ),
        .rd_clk    (    ddrc_clk                                    ),
        .rd_en     (    w_fifo_rden                                 ),
        .rd_data   (    {wr_operation_mask , wr_operation_data}     ),
        .rd_empty  (    w_fifo_empty                                ),
        .rst_n     (    rst_n                                       )
    ); */

    wire [2:0]      data_ecc_dbiterr_o          ;
    wire [23:0]     data_ecc_eccparity_o        ;
    wire [2:0]      data_ecc_sbiterr_o          ;
    wire [23:0]     data_ecc_dop_o              ;
    wire [2:0]      data_ecc_rderr_o            ;
    wire [2:0]      data_ecc_wrerr_o            ;
    wire [2:0]      wr_data_fifo_almostempty    ;
    wire [2:0]      wr_data_fifo_almostfull     ;
    wire [38:0]     wr_data_fifo_rdcount        ;
    wire [38:0]     wr_data_fifo_wrcount        ;   

    FIFO36E1#(
       .ALMOST_EMPTY_OFFSET      (   13'h0008                   ),   
       .ALMOST_FULL_OFFSET       (   13'h0190                   ),
       .INIT                     (   72'h000000000000000000     ),     
       .SRVAL                    (   72'h000000000000000000     ),     
       .SIM_DEVICE               (   "7SERIES"                  ),     
       .EN_ECC_READ              (   "FALSE"                    ), 
       .EN_ECC_WRITE             (   "FALSE"                    ),

       .DATA_WIDTH               (   72                         ),                  
       .DO_REG                   (   1                          ),     
       .EN_SYN                   (   "FALSE"                    ),     
       .FIFO_MODE                (   "FIFO36_72"                ),     
       .FIRST_WORD_FALL_THROUGH  (   "TRUE"                     ) 
    )u_w128xd512_wr_data_fifo_1 (
       .DBITERR                 (   data_ecc_dbiterr_o[0]       ),      
       .ECCPARITY               (   data_ecc_eccparity_o[7:0]   ),      
       .SBITERR                 (   data_ecc_sbiterr_o[0]       ),      
       .INJECTDBITERR           (   1'b0                        ),      
       .INJECTSBITERR           (   1'b0                        ),
       .REGCE                   (   1'b1                        ),      
       .RSTREG                  (   ~rst_n                      ),      
       .DIP                     (   8'b0                        ),      
       .DOP                     (   data_ecc_dop_o[7:0]         ),      
       .RDERR                   (   data_ecc_rderr_o[0]         ),      
       .WRERR                   (   data_ecc_wrerr_o[0]         ),      
       .ALMOSTEMPTY             (   wr_data_fifo_almostempty[0] ),      
       .ALMOSTFULL              (   wr_data_fifo_almostfull[0]  ),      
       .RDCOUNT                 (   wr_data_fifo_rdcount[12:0]  ),      
       .WRCOUNT                 (   wr_data_fifo_wrcount[12:0]  ),      

       .WRCLK                   (   s_axi_aclk                  ),      
       .WREN                    (   w_w_active                  ),      
       .DI                      (   s_axi_wdata[63:0]           ),      
       .FULL                    (   w_fifo_full                 ),      

       .RDCLK                   (   ddrc_clk                    ),      
       .RDEN                    (   w_fifo_rden                 ),      
       .DO                      (   wr_operation_data[63:0]     ),      
       .EMPTY                   (   w_fifo_empty                ),      

       .RST                     (   ~rst_n                      )       
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
        .DBITERR                (   data_ecc_dbiterr_o[1]       ),      
        .ECCPARITY              (   data_ecc_eccparity_o[15:8]  ),      
        .SBITERR                (   data_ecc_sbiterr_o[1]       ),      
        .INJECTDBITERR          (   1'b0                        ),      
        .INJECTSBITERR          (   1'b0                        ),
        .REGCE                  (   1'b1                        ),      
        .RSTREG                 (   ~rst_n                      ),      
        .DIP                    (   8'b0                        ),      
        .DOP                    (   data_ecc_dop_o[15:8]        ),      
        .RDERR                  (   data_ecc_rderr_o[1]         ),      
        .WRERR                  (   data_ecc_wrerr_o[1]         ),     
        .ALMOSTEMPTY            (   wr_data_fifo_almostempty[1] ),     
        .ALMOSTFULL             (   wr_data_fifo_almostfull[1]  ),     
        .RDCOUNT                (   wr_data_fifo_rdcount[25:13] ),     
        .WRCOUNT                (   wr_data_fifo_wrcount[25:13] ),      

        .WRCLK                  (   s_axi_aclk                  ),      
        .WREN                   (   w_w_active                  ),      
        .DI                     (   s_axi_wdata[127:64]         ),      
        .FULL                   (                               ),      

        .RDCLK                  (   ddrc_clk                    ),      
        .RDEN                   (   w_fifo_rden                 ),      
        .DO                     (   wr_operation_data[127:64]   ),      
        .EMPTY                  (                               ),      

        .RST                    (   ~rst_n                      )       
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
    )u_w128xd512_wr_data_fifo_3 (
        .DBITERR          (   data_ecc_dbiterr_o[2]          ),      
        .ECCPARITY        (   data_ecc_eccparity_o[23:16]    ),      
        .SBITERR          (   data_ecc_sbiterr_o[2]          ),      
        .INJECTDBITERR    (   1'b0                           ),      
        .INJECTSBITERR    (   1'b0                           ),
        .REGCE            (   1'b1                           ),      
        .RSTREG           (   ~rst_n                         ),      
        .DIP              (   8'b0                           ),      
        .DOP              (   data_ecc_dop_o[23:16]          ),      
        .RDERR            (   data_ecc_rderr_o[2]            ),      
        .WRERR            (   data_ecc_wrerr_o[2]            ),     
        .ALMOSTEMPTY      (   wr_data_fifo_almostempty[2]    ),     
        .ALMOSTFULL       (   wr_data_fifo_almostfull[2]     ),     
        .RDCOUNT          (   wr_data_fifo_rdcount[38:26]    ),     
        .WRCOUNT          (   wr_data_fifo_wrcount[38:26]    ),      

        .WRCLK            (   s_axi_aclk                     ),      
        .WREN             (   w_w_active                     ),      
        .DI               (   {48'b0 , s_axi_wstrb}          ),      
        .FULL             (                                  ),      

        .RDCLK            (   ddrc_clk                      ),      
        .RDEN             (   w_fifo_rden                   ),      
        .DO               (   wr_operation_mask             ),      
        .EMPTY            (                                 ),      

        .RST              (   ~rst_n                        )      
            );

    reg [8:0] write_req_cnt;

    assign aw_fifo_rden = (write_req_cnt == wr_operation_len) & (|inport_wr_o ) & inport_accept_i;
    assign w_fifo_rden  = ((|inport_wr_o) & inport_accept_i);

    always@(posedge ddrc_clk or negedge rst_n)begin
        if(!rst_n)
            write_req_cnt <= 'd0;
        else if(write_req_cnt == wr_operation_len & (|inport_wr_o ) & inport_accept_i)
            write_req_cnt <= 'd0;
        else if((|inport_wr_o) & inport_accept_i)
            write_req_cnt <= write_req_cnt + 1'b1;
        else
            write_req_cnt <= write_req_cnt;
    end

    always@(posedge ddrc_clk or negedge rst_n)begin
        if(!rst_n)begin
            inport_wr_o         <= 'd0                  ;
            inport_wr_data_o    <= 'd0                  ;
        end else if(write_req_cnt == wr_operation_len & (|inport_wr_o ) & inport_accept_i)begin
            inport_wr_o         <= 'd0                  ;
            inport_wr_data_o    <= 'd0                  ;
        end else if(~aw_fifo_empty & ~w_fifo_empty & (~aw_fifo_rden))begin
            inport_wr_o         <=  wr_operation_mask   ;
            inport_wr_data_o    <= wr_operation_data    ;   
        end else begin
            inport_wr_o         <= inport_wr_o          ;
            inport_wr_data_o    <= inport_wr_data_o     ;
        end
    end

//read fifo
    wire [AXI_ADDR_WIDTH - 1 : 0]   rd_operation_addr;
    wire [7:0]                      rd_operation_len;

    wire            rd_ecc_dbiterr_o                    ;
    wire [7:0]      rd_ecc_eccparity_o                  ;
    wire            rd_ecc_sbiterr_o                    ;
    wire [7:0]      rd_ecc_dop_o                        ;
    wire            rd_ecc_rderr_o                      ;
    wire            rd_ecc_wrerr_o                      ;
    wire            rd_cmd_fifo_almostempty             ;
    wire            rd_cmd_fifo_almostfull              ;
    wire [12:0]     rd_cmd_fifo_rdcount                 ;
    wire [12:0]     rd_cmd_fifo_wrcount                 ;



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
      .DBITERR          (   rd_ecc_dbiterr_o            ),      
      .ECCPARITY        (   rd_ecc_eccparity_o          ),      
      .SBITERR          (   rd_ecc_sbiterr_o            ),      
      .INJECTDBITERR    (   1'b0                        ),      
      .INJECTSBITERR    (   1'b0                        ),
      .REGCE            (   1'b1                        ),      
      .RSTREG           (   ~rst_n                      ),      
      .DIP              (   8'b0                        ),      
      .DOP              (   rd_ecc_dop_o                ),      
      .RDERR            (   rd_ecc_rderr_o              ),      
      .WRERR            (   rd_ecc_wrerr_o              ),      
      .ALMOSTEMPTY      (   rd_cmd_fifo_almostempty     ),      
      .ALMOSTFULL       (   rd_cmd_fifo_almostfull      ),      
      .RDCOUNT          (   rd_cmd_fifo_rdcount         ),      
      .WRCOUNT          (   rd_cmd_fifo_wrcount         ),      

      .WRCLK            (   s_axi_aclk                                      ),      
      .WREN             (   w_ar_active                                     ),      
      .DI               (   {24'b0 , s_axi_araddr , s_axi_arlen}            ),      
      .FULL             (   ar_fifo_full                                    ),      

      .RDCLK            (   ddrc_clk                                        ),      

      .RDEN             (  ar_fifo_rden                                     ),      
      .DO               (   { rd_operation_addr , rd_operation_len}         ),      
      .EMPTY            (  ar_fifo_empty                                    ),      

      .RST              (   ~rst_n                                          )       
   );

/*     async_fifo#(
        .DEPTH     ( 1024                                           ),
        .WIDTH     ( AXI_DATA_WIDTH                                 )
    )u_r_fifo(
        .wr_clk    ( ddrc_clk                                       ),
        .wr_en     ( inport_rd_data_vld_i                           ),
        .wr_data   ( inport_rd_data_i                               ),
        .wr_full   ( r_fifo_full                                    ),
        .rd_clk    ( s_axi_aclk                                     ),
        .rd_en     ( ~r_fifo_empty                                  ),
        .rd_data   ( s_axi_rdata                                    ),
        .rd_empty  ( r_fifo_empty                                   ),
        .rst_n     ( rst_n                                          )
    ); */


    wire [1:0]      rd_data_ecc_dbiterr_o           ;
    wire [15:0]     rd_data_ecc_eccparity_o         ;
    wire [1:0]      rd_data_ecc_sbiterr_o           ;
    wire [15:0]     rd_data_ecc_dop_o               ;
    wire [1:0]      rd_data_ecc_rderr_o             ;
    wire [1:0]      rd_data_ecc_wrerr_o             ;
    wire [1:0]      rd_data_fifo_almostempty        ;
    wire [1:0]      rd_data_fifo_almostfull         ;
    wire [25:0]     rd_data_fifo_rdcount            ;
    wire [25:0]     rd_data_fifo_wrcount            ;   



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
        .DBITERR                     (   rd_data_ecc_dbiterr_o[0]       ),      
        .ECCPARITY                   (   rd_data_ecc_eccparity_o[7:0]   ),      
        .SBITERR                     (   rd_data_ecc_sbiterr_o[0]       ),      
        .INJECTDBITERR               (   1'b0                           ),      
        .INJECTSBITERR               (   1'b0                           ),
        .REGCE                       (   1'b1                           ),      
        .RSTREG                      (   ~rst_n                         ),      
        .DIP                         (   8'b0                           ),      
        .DOP                         (   rd_data_ecc_dop_o[7:0]         ),      
        .RDERR                       (   rd_data_ecc_rderr_o[0]         ),      
        .WRERR                       (   rd_data_ecc_wrerr_o[0]         ),      
        .ALMOSTEMPTY                 (   rd_data_fifo_almostempty[0]    ),      
        .ALMOSTFULL                  (   rd_data_fifo_almostfull[0]     ),      
        .RDCOUNT                     (   rd_data_fifo_rdcount[12:0]     ),      
        .WRCOUNT                     (   rd_data_fifo_wrcount[12:0]     ),      

        .WRCLK                       (   ddrc_clk                       ),      
        .WREN                        (   inport_rd_data_vld_i           ),      
        .DI                          (   inport_rd_data_i[63:0]         ),      
        .FULL                        (   r_fifo_full                    ),      

        .RDCLK                       (   s_axi_aclk                     ),    
        .RDEN                        (   ~r_fifo_empty                  ),      
        .DO                          (   s_axi_rdata[63:0]              ),      
        .EMPTY                       (   r_fifo_empty                   ),    

        .RST                         (   ~rst_n                         )      
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
            .DBITERR                     (   rd_data_ecc_dbiterr_o[1]       ),      
            .ECCPARITY                   (   rd_data_ecc_eccparity_o[15:8]  ),      
            .SBITERR                     (   rd_data_ecc_sbiterr_o[1]       ),      
            .INJECTDBITERR               (   1'b0                           ),      
            .INJECTSBITERR               (   1'b0                           ),
            .REGCE                       (   1'b1                           ),      
            .RSTREG                      (   ~rst_n                         ),      
            .DIP                         (   8'b0                           ),      
            .DOP                         (   rd_data_ecc_dop_o[15:8]        ),      
            .RDERR                       (   rd_data_ecc_rderr_o[1]         ),      
            .WRERR                       (   rd_data_ecc_wrerr_o[1]         ),     
            .ALMOSTEMPTY                 (   rd_data_fifo_almostempty[1]    ),     
            .ALMOSTFULL                  (   rd_data_fifo_almostfull[1]     ),     
            .RDCOUNT                     (   rd_data_fifo_rdcount[25:13]    ),     
            .WRCOUNT                     (   rd_data_fifo_wrcount[25:13]    ),      

            .WRCLK                       (   ddrc_clk                       ),      
            .WREN                        (   inport_rd_data_vld_i           ),      
            .DI                          (   inport_rd_data_i[127:64]       ),      
            .FULL                        (                                  ),      

            .RDCLK                       (   s_axi_aclk                     ),    
            .RDEN                        (   ~r_fifo_empty                  ),      
            .DO                          (   s_axi_rdata[127:64]            ),      
            .EMPTY                       (                                  ),    

            .RST                         (   ~rst_n                         )         
        );

    reg [8:0]   axi_rd_cnt      ;
    reg [7:0]   s_axi_arlen_d   ;

    assign s_axi_rvalid = ~r_fifo_empty;


    always@(posedge s_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            s_axi_arlen_d <= 'd0;
        else if(w_r_active & s_axi_rlast)
            s_axi_arlen_d <= 'd0;
        else if(w_ar_active)
            s_axi_arlen_d <= s_axi_arlen;
        else
            s_axi_arlen_d <= s_axi_arlen_d;
    end

    always@(posedge s_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            axi_rd_cnt <= 0;
        else if(s_axi_rlast & w_r_active)
            axi_rd_cnt <= 0;
        else if(~r_fifo_empty)
            axi_rd_cnt <= axi_rd_cnt + 1'b1;
        else
            axi_rd_cnt <= axi_rd_cnt;
    end

    always@(posedge s_axi_aclk or negedge rst_n)begin
        if(!rst_n)
            s_axi_rlast <= 0;
        else if(s_axi_rlast & w_r_active)
            s_axi_rlast <= 0;
        else if(axi_rd_cnt == s_axi_arlen_d & axi_rd_cnt != 0)
            s_axi_rlast <= 1'b1;
        else
            s_axi_rlast <= s_axi_rlast;
    end

//

    reg [8:0] read_req_cnt;

    always@(posedge ddrc_clk or negedge rst_n)begin
        if(!rst_n)
            read_req_cnt <= 'd0;
        else if(inport_rd_o & inport_accept_i & read_req_cnt == rd_operation_len)    //rd_operation_len = total tranfer length - 1
            read_req_cnt <= 'd0;
        else if(inport_rd_o & inport_accept_i)
            read_req_cnt <= read_req_cnt + 1'b1;
        else
            read_req_cnt <= read_req_cnt;
    end

    always@(posedge ddrc_clk or negedge rst_n)begin
        if(!rst_n)
            inport_rd_o <= 'd0;
        else if(read_req_cnt == rd_operation_len & inport_rd_o & inport_accept_i)
            inport_rd_o <= 'd0;
        else if(aw_fifo_empty & ~ar_fifo_empty & (~ar_fifo_rden))
            inport_rd_o <= 'b1;
        else
            inport_rd_o <= inport_rd_o;
    end

    assign ar_fifo_rden = (read_req_cnt == rd_operation_len & inport_rd_o & inport_accept_i);


//addr control
    always@(posedge ddrc_clk or negedge rst_n)begin
        if(!rst_n)
            inport_addr_o <= 'd0;
        else if(write_req_cnt == wr_operation_len & (|inport_wr_o) & inport_accept_i)
            inport_addr_o <= 'd0;
        else if(read_req_cnt == rd_operation_len & inport_rd_o & inport_accept_i)
            inport_addr_o <= 'd0;
        else if(inport_accept_i)
            inport_addr_o <= inport_addr_o + 'd8;
        else if(~aw_fifo_empty & write_req_cnt == 'd0)
            inport_addr_o <= wr_operation_addr;
        else if(aw_fifo_empty & ~ar_fifo_empty & read_req_cnt == 'd0)
            inport_addr_o <= rd_operation_addr; 
        else
            inport_addr_o <= inport_addr_o;
    end
endmodule

