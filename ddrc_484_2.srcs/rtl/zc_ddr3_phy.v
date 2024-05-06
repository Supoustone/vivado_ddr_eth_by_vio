/*preface README:
DDR3 Spec P14 : Vddq    : DQ Power Supply : 1.5V +/- 0.075V ; 
                Vdd     : Power Supply : 1.5V +/- 0.075V.
                Vrefdq  : Reference voltage for DQ      P113 : VrefCA(DC) : Reference Voltage for ADD , CMD inputs (min,max) = (0.49 * VDD , 0.51 * VDD)
                Vrefca  : Reference voltage for CA      P113 : VrefDQ(DC) : Reference Voltage for DQ  , DM  inputs (min,max) = (0.49 * VDD , 0.51 * VDD)  
Note : for input only pins except RESET#, Vref = VrefCA(DC) ; Vref = VrefDQ(DC). For reference: approx. Vref = VDD/2 +/- 15mv , namely choose 0.75V.

Voltage standard: SSTL : Stub Series Termination Logic , generally used in the DDR SDRAM interface.
    SSTL25 I/O  : used for DDR   SDRAM
    SSTL18 I/O  : used for DDR2  SDRAM
    SSTL15 I/O  : used for DDR3  SDRAM
    SSTL135 I/O : used for DDR3L SDRAM (DDR3 Low voltage)
    SSTL12 I/O  : used for DDR4  SDRAM
    DDR5 SDRAM supports the PODL voltage standard (1.1V)

***  To implement on the FPGA board xc7a35tfgg484-1 , I set the XDC to set the INTER_VREF to free up the Vref pin to serve as normal I/O.
        That is , add XDC constraint : " set_property INTERNAL_VREF <reference voltage> [get_iobanks <IO bank numbers> ".
        For my situation ,  AX7035B with 2Gbit Micron DDR3 chip , MT41J128M16HA-125 , BANK34.
        So my constraint is " set_property INTERNAL_VREF 0.75 [get_iobanks 34] " , I used SSTL15 I/O , so Vref = Vdd/2 = 1.5V/2 =  0.75V.      
*/



// Configuration
    `define DDR_PHY_CFG_RDSEL_R         3:0
    `define DDR_PHY_CFG_RDLAT_R         10:8
    `define DDR_PHY_CFG_DLY_DQS_RST_R   17:16
    `define DDR_PHY_CFG_DLY_DQS_INC_R   19:18
    `define DDR_PHY_CFG_DLY_DQ_RST_R    21:20
    `define DDR_PHY_CFG_DLY_DQ_INC_R    23:22

module zc_ddr3_phy#(
    parameter REFCLK_FREQUENCY     = 200    ,
    parameter DQS_TAP_DELAY_INIT   = 15     ,
    parameter DQ_TAP_DELAY_INIT    = 1      ,
    parameter TPHY_RDLAT           = 4      ,
    parameter TPHY_WRLAT           = 3      ,
    parameter TPHY_WRDATA          = 0 
)(
    input           clkin_100m              ,//100mhz   
    input           clkin_400m              ,//400mhz
    input           clkin_400m_shift_90     ,//400mhz shift 90
    input           clkin_200m_ref          ,//200mhz       
    input           rst_i                   ,

    input           config_en_i             ,       
    input  [ 31:0]  config_value_i          ,

    input  [ 13:0]  dfi_address_i          ,      
    input  [  2:0]  dfi_bank_i             ,       
    input           dfi_cas_n_i            ,       
    input           dfi_cke_i              ,       
    input           dfi_cs_n_i             ,       
    input           dfi_odt_i              ,       
    input           dfi_ras_n_i            ,           
    input           dfi_reset_n_i          ,           
    input           dfi_we_n_i             ,       
    input  [ 31:0]  dfi_wrdata_i           ,           
    input           dfi_wrdata_en_i        ,           
    input  [  3:0]  dfi_wrdata_mask_i      ,           
    input           dfi_rddata_en_i        ,           
    output [ 31:0]  dfi_rddata_o           ,                 
    output          dfi_rddata_valid_o     ,                 
    output [  3:0]  dfi_rddata_dnv_o       ,

    output          ddr3_ck_p_o            ,                     
    output          ddr3_ck_n_o            ,                       
    output          ddr3_cke_o             ,               
    output          ddr3_reset_n_o         ,        
    output          ddr3_ras_n_o           ,    
    output          ddr3_cas_n_o           ,    
    output          ddr3_we_n_o            ,    
    output          ddr3_cs_n_o            ,    
    output [  2:0]  ddr3_ba_o              ,
    output [ 13:0]  ddr3_addr_o            ,                  
    output          ddr3_odt_o             ,                           
    output [  1:0]  ddr3_dm_o              ,                             
    inout [  1:0]   ddr3_dqs_p_io          ,                   
    inout [  1:0]   ddr3_dqs_n_io          ,        
    inout [ 15:0]   ddr3_dq_io                      
);
    
    reg config_en_d;

    reg [2:0] phy_rdlat;
    reg [3:0] rd_sel_q;

    reg [1:0] dqs_delay_rst_q   ;
    reg [1:0] dqs_delay_inc_q   ;
    reg [1:0] dq_delay_rst_q    ;
    reg [1:0] dq_delay_inc_q    ;

    wire config_en_rise_edge = config_en_i & ~config_en_d;

    always@(posedge clkin_100m)
        if (rst_i)
            config_en_d <= 1'b0;
        else
            config_en_d <= config_en_i;

    always@(posedge clkin_100m)
    if (rst_i)
        phy_rdlat <= TPHY_RDLAT;
    else if(config_en_i)
        phy_rdlat <= config_value_i[`DDR_PHY_CFG_RDLAT_R];
    
    always@(posedge clkin_100m)
    if (rst_i)
        rd_sel_q <= 4'hF;
    else if(config_en_i)
        rd_sel_q <= config_value_i[`DDR_PHY_CFG_RDSEL_R];

    always@(posedge clkin_100m)
    if (rst_i)
        dqs_delay_rst_q <= 2'b0;
    else if(config_en_rise_edge)
        dqs_delay_rst_q <= config_value_i[`DDR_PHY_CFG_DLY_DQS_RST_R];
    else
        dqs_delay_rst_q <= 2'b0;
    
    always@(posedge clkin_100m)
    if (rst_i)
        dqs_delay_inc_q <= 2'b0;
    else if (config_en_rise_edge)
        dqs_delay_inc_q <= config_value_i[`DDR_PHY_CFG_DLY_DQS_INC_R];
    else
        dqs_delay_inc_q <= 2'b0;
    
    always@(posedge clkin_100m)
    if (rst_i)
        dq_delay_rst_q <= 2'b0;
    else if(config_en_rise_edge)
        dq_delay_rst_q <= config_value_i[`DDR_PHY_CFG_DLY_DQ_RST_R];
    else
        dq_delay_rst_q <= 2'b0;
    
    always@(posedge clkin_100m)
    if (rst_i)
        dq_delay_inc_q <= 2'b0;
    else if(config_en_rise_edge)
        dq_delay_inc_q <= config_value_i[`DDR_PHY_CFG_DLY_DQ_INC_R];
    else
        dq_delay_inc_q <= 2'b0;
    

// DDR Clock : Differential clock output-------------------------------------------------------------------------------------------
    OBUFDS#(
        .IOSTANDARD ("DIFF_SSTL15"  ),
        .SLEW       ("FAST"         )
    )u_pad_ck(
        .I(~clkin_100m),                         // important : reverse the clkin_100m to meet the ddr3 sdram's sample requirement
        .O(ddr3_ck_p_o),
        .OB(ddr3_ck_n_o)
    );

// Command-------------------------------------------------------------------------------------------------------------------------

    //为了保证FPGA输入输出接口的时序，一般会要求将输入管脚首先打一拍再使用，输出接口也要打一拍再输出FPGA。将信号打一拍的方法是将信号通过一次寄存器，而且必须在IOB里面的寄存器中打一拍。因为从FPGA的PAD到IOB里面的寄存器是有专用布线资源的，而到内部其他的寄存器没有专用的布线资源。使用IOB里面的寄存器可以保证每次实现的结果都一样，使用内部其他寄存器则无法保证每次使用的是同一个寄存器且采用同样的布线。同时，为了使用输入输出延时功能(Input/Output delay)，也必须要求信号使用IOB里面的寄存器。

    //约束语法：set_property IOB TRUE [get_ports <port_name>] , 或者使用 (* IOB = "true" *) 。全部约束的语法是 set_property IOB TRUE [all_inputs] / set_property IOB FALSE [all_outputs]
    //或者采用GUI的方式进行配置 ： https://blog.csdn.net/q774318039a/article/details/88778669

    //attention : 对于输入IOB约束，这里的寄存器是第一级寄存器，对于输出IOB约束，这里的寄存器是最后一级寄存器，且寄存器输出不能再作为组合逻辑输入。（ila也不可以观测该信号）


    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg             reset_n_r           ;
    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg             ras_n_r             ;
    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg             cas_n_r             ;
    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg             we_n_r              ;
    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg             cs_n_r              ;
    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg [2 : 0]     ba_r                ;
    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg [13: 0]     addr_r              ;
    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg             cke_r               ;
    (* dont_touch = "TRUE" *)(* IOB = "TRUE" *) reg             odt_r               ;

    always@(posedge clkin_100m)
    if (rst_i)begin
        cke_r       <= 1'b0             ;
        reset_n_r   <= 1'b0             ;
        ras_n_r     <= 1'b0             ;
        cas_n_r     <= 1'b0             ;
        we_n_r      <= 1'b0             ;
        cs_n_r      <= 1'b0             ;
        ba_r        <= 3'b0             ;
        addr_r      <= 13'b0            ;
        odt_r       <= 1'b0             ;
    end
    else begin
        cke_r       <= dfi_cke_i        ;
        reset_n_r   <= dfi_reset_n_i    ;
        ras_n_r     <= dfi_ras_n_i      ;
        cas_n_r     <= dfi_cas_n_i      ;
        we_n_r      <= dfi_we_n_i       ;
        cs_n_r      <= dfi_cs_n_i       ;
        ba_r        <= dfi_bank_i       ;
        addr_r      <= dfi_address_i    ;
        odt_r       <= dfi_odt_i        ;
    end

    assign ddr3_cke_o       = cke_r     ;
    assign ddr3_reset_n_o   = reset_n_r ;
    assign ddr3_ras_n_o     = ras_n_r   ;
    assign ddr3_cas_n_o     = cas_n_r   ;
    assign ddr3_we_n_o      = we_n_r    ;
    assign ddr3_cs_n_o      = cs_n_r    ;
    assign ddr3_ba_o        = ba_r      ;
    assign ddr3_addr_o      = addr_r    ;
    assign ddr3_odt_o       = odt_r     ;
    
// Write Output Enable-------------------------------------------------------------------------------

    reg dfi_wrdata_en_d1;
    reg dfi_wrdata_en_d2;
    reg dqs_out_en_n_q;                     //todo:需要研究该信号的作用

    always@(posedge clkin_100m)
    if (rst_i)begin
        dfi_wrdata_en_d1 <= 1'b0;
        dfi_wrdata_en_d2 <= 1'b0;
    end else begin
        dfi_wrdata_en_d1 <= dfi_wrdata_en_i;
        dfi_wrdata_en_d2 <= dfi_wrdata_en_d1;
        dqs_out_en_n_q <= ~dfi_wrdata_en_d2;   
    end

// DQS I/O Buffers-------------------------------------------------------------------------------------
    wire [1:0] dqs_out_en_n_w   ;
    wire [1:0] dqs_out_w        ;
    wire [1:0] dqs_in_w         ;
    
    IOBUFDS#(
        .IOSTANDARD("DIFF_SSTL15")
    )u_pad_dqs0
    (
        .I      (   dqs_out_w[0]        ),
        .O      (   dqs_in_w[0]         ),
        .T      (   dqs_out_en_n_w[0]   ),    //3-state enable input
        .IO     (   ddr3_dqs_p_io[0]    ),
        .IOB    (   ddr3_dqs_n_io[0]    )
    );
    
    IOBUFDS#(
        .IOSTANDARD("DIFF_SSTL15")
    )u_pad_dqs1
    (
        .I     (    dqs_out_w[1]        ),
        .O     (    dqs_in_w[1]         ),
        .T     (    dqs_out_en_n_w[1]   ),
        .IO    (    ddr3_dqs_p_io[1]    ),
        .IOB   (    ddr3_dqs_n_io[1]    )
    );
    
    // Write Data (DQ)------------------------------------------------------------------------------------------
    reg [31:0] dfi_wrdata_d;
    
    always@(posedge clkin_100m)
    if (rst_i)
        dfi_wrdata_d <= 32'b0;
    else
        dfi_wrdata_d <= dfi_wrdata_i;
    
    wire [15:0] dq_in_w         ;
    wire [15:0] dq_out_w        ;
    wire [15:0] dq_out_en_n_w   ;
    
    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"        ),
        .DATA_WIDTH     (   8               ),
        .TRISTATE_WIDTH (   1               ),  //todo
        .DATA_RATE_OQ   (   "DDR"           ),
        .DATA_RATE_TQ   (   "BUF"           )   //todo
    )u_serdes_dq0
    (
       .CLK         (   clkin_400m          ), //high speed clock input drives the serial side of the parallel-to-serial converters.
       .CLKDIV      (   clkin_100m          ), //dirves the parallel side of the converters.
       .RST         (   rst_i               ), //active high 
       .D1          (   dfi_wrdata_d[0+0]   ), //appear first at OQ
       .D2          (   dfi_wrdata_d[0+0]   ), //D1 - D8  all connect to the FPGA fabric
       .D3          (   dfi_wrdata_d[0+0]   ),
       .D4          (   dfi_wrdata_d[0+0]   ),
       .D5          (   dfi_wrdata_d[0+16]  ),
       .D6          (   dfi_wrdata_d[0+16]  ),
       .D7          (   dfi_wrdata_d[0+16]  ),
       .D8          (   dfi_wrdata_d[0+16]  ),
       .T1          (   dqs_out_en_n_q      ), //parallel 3-state inputs
       .T2          (   dqs_out_en_n_q      ), //T1 - T4 all connect to the FPGA fabric 
       .T3          (   dqs_out_en_n_q      ),
       .T4          (   dqs_out_en_n_q      ),
       .OCE         (   1                   ), // active high clock enable for the data path
       .TCE         (   1                   ), // active high clock enable for the 3-state control path
       .SHIFTIN1    (   0                   ),
       .SHIFTIN2    (   0                   ),
       .TBYTEIN     (   0                   ), //NO USE
    
      .OQ           (   dq_out_w[0]         ), //Data Path output to IOB only. 
      .TQ           (   dq_out_en_n_w[0]    ), //3-State control output to IOB. 
      .OFB          (                       ), //NO USE : output feedback : 1> as a feedback path to the ISERDESE2 OFB Pin. 2> As a connection to ODELAYE2
      .TFB          (                       ), //NO USE : send to fabric to indicate that the OSERDESE2 is 3-states.
      .SHIFTOUT1    (                       ), //NO USE
      .SHIFTOUT2    (                       ), //NO USE
      .TBYTEOUT     (                       )  //NO USE
    );
    
    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq0(
        .I              (   dq_out_w[0]         ),
        .O              (   dq_in_w[0]          ),
        .T              (   dq_out_en_n_w[0]    ),
        .IO             (   ddr3_dq_io[0]       )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq1(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[1+0]       ),
        .D2             (   dfi_wrdata_d[1+0]       ),
        .D3             (   dfi_wrdata_d[1+0]       ),
        .D4             (   dfi_wrdata_d[1+0]       ),
        .D5             (   dfi_wrdata_d[1+16]      ),
        .D6             (   dfi_wrdata_d[1+16]      ),
        .D7             (   dfi_wrdata_d[1+16]      ),
        .D8             (   dfi_wrdata_d[1+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[1]             ),
        .TQ             (   dq_out_en_n_w[1]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq2(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[2+0]       ),
        .D2             (   dfi_wrdata_d[2+0]       ),
        .D3             (   dfi_wrdata_d[2+0]       ),
        .D4             (   dfi_wrdata_d[2+0]       ),
        .D5             (   dfi_wrdata_d[2+16]      ),
        .D6             (   dfi_wrdata_d[2+16]      ),
        .D7             (   dfi_wrdata_d[2+16]      ),
        .D8             (   dfi_wrdata_d[2+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[2]             ),
        .TQ             (   dq_out_en_n_w[2]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq3(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[3+0]       ),
        .D2             (   dfi_wrdata_d[3+0]       ),
        .D3             (   dfi_wrdata_d[3+0]       ),
        .D4             (   dfi_wrdata_d[3+0]       ),
        .D5             (   dfi_wrdata_d[3+16]      ),
        .D6             (   dfi_wrdata_d[3+16]      ),
        .D7             (   dfi_wrdata_d[3+16]      ),
        .D8             (   dfi_wrdata_d[3+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[3]             ),
        .TQ             (   dq_out_en_n_w[3]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq4(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[4+0]       ),
        .D2             (   dfi_wrdata_d[4+0]       ),
        .D3             (   dfi_wrdata_d[4+0]       ),
        .D4             (   dfi_wrdata_d[4+0]       ),
        .D5             (   dfi_wrdata_d[4+16]      ),
        .D6             (   dfi_wrdata_d[4+16]      ),
        .D7             (   dfi_wrdata_d[4+16]      ),
        .D8             (   dfi_wrdata_d[4+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[4]             ),
        .TQ             (   dq_out_en_n_w[4]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq5(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[5+0]       ),
        .D2             (   dfi_wrdata_d[5+0]       ),
        .D3             (   dfi_wrdata_d[5+0]       ),
        .D4             (   dfi_wrdata_d[5+0]       ),
        .D5             (   dfi_wrdata_d[5+16]      ),
        .D6             (   dfi_wrdata_d[5+16]      ),
        .D7             (   dfi_wrdata_d[5+16]      ),
        .D8             (   dfi_wrdata_d[5+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[5]             ),
        .TQ             (   dq_out_en_n_w[5]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq6(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[6+0]       ),
        .D2             (   dfi_wrdata_d[6+0]       ),
        .D3             (   dfi_wrdata_d[6+0]       ),
        .D4             (   dfi_wrdata_d[6+0]       ),
        .D5             (   dfi_wrdata_d[6+16]      ),
        .D6             (   dfi_wrdata_d[6+16]      ),
        .D7             (   dfi_wrdata_d[6+16]      ),
        .D8             (   dfi_wrdata_d[6+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[6]             ),
        .TQ             (   dq_out_en_n_w[6]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq7(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[7+0]       ),
        .D2             (   dfi_wrdata_d[7+0]       ),
        .D3             (   dfi_wrdata_d[7+0]       ),
        .D4             (   dfi_wrdata_d[7+0]       ),
        .D5             (   dfi_wrdata_d[7+16]      ),
        .D6             (   dfi_wrdata_d[7+16]      ),
        .D7             (   dfi_wrdata_d[7+16]      ),
        .D8             (   dfi_wrdata_d[7+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[7]             ),
        .TQ             (   dq_out_en_n_w[7]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq8(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[8+0]       ),
        .D2             (   dfi_wrdata_d[8+0]       ),
        .D3             (   dfi_wrdata_d[8+0]       ),
        .D4             (   dfi_wrdata_d[8+0]       ),
        .D5             (   dfi_wrdata_d[8+16]      ),
        .D6             (   dfi_wrdata_d[8+16]      ),
        .D7             (   dfi_wrdata_d[8+16]      ),
        .D8             (   dfi_wrdata_d[8+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[8]             ),
        .TQ             (   dq_out_en_n_w[8]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq9(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[9+0]       ),
        .D2             (   dfi_wrdata_d[9+0]       ),
        .D3             (   dfi_wrdata_d[9+0]       ),
        .D4             (   dfi_wrdata_d[9+0]       ),
        .D5             (   dfi_wrdata_d[9+16]      ),
        .D6             (   dfi_wrdata_d[9+16]      ),
        .D7             (   dfi_wrdata_d[9+16]      ),
        .D8             (   dfi_wrdata_d[9+16]      ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[9]             ),
        .TQ             (   dq_out_en_n_w[9]        ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq10(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[10+0]      ),
        .D2             (   dfi_wrdata_d[10+0]      ),
        .D3             (   dfi_wrdata_d[10+0]      ),
        .D4             (   dfi_wrdata_d[10+0]      ),
        .D5             (   dfi_wrdata_d[10+16]     ),
        .D6             (   dfi_wrdata_d[10+16]     ),
        .D7             (   dfi_wrdata_d[10+16]     ),
        .D8             (   dfi_wrdata_d[10+16]     ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[10]            ),
        .TQ             (   dq_out_en_n_w[10]       ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq11(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[11+0]      ),
        .D2             (   dfi_wrdata_d[11+0]      ),
        .D3             (   dfi_wrdata_d[11+0]      ),
        .D4             (   dfi_wrdata_d[11+0]      ),
        .D5             (   dfi_wrdata_d[11+16]     ),
        .D6             (   dfi_wrdata_d[11+16]     ),
        .D7             (   dfi_wrdata_d[11+16]     ),
        .D8             (   dfi_wrdata_d[11+16]     ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[11]            ),
        .TQ             (   dq_out_en_n_w[11]       ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq12(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[12+0]      ),
        .D2             (   dfi_wrdata_d[12+0]      ),
        .D3             (   dfi_wrdata_d[12+0]      ),
        .D4             (   dfi_wrdata_d[12+0]      ),
        .D5             (   dfi_wrdata_d[12+16]     ),
        .D6             (   dfi_wrdata_d[12+16]     ),
        .D7             (   dfi_wrdata_d[12+16]     ),
        .D8             (   dfi_wrdata_d[12+16]     ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[12]            ),
        .TQ             (   dq_out_en_n_w[12]       ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq13(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[13+0]      ),
        .D2             (   dfi_wrdata_d[13+0]      ),
        .D3             (   dfi_wrdata_d[13+0]      ),
        .D4             (   dfi_wrdata_d[13+0]      ),
        .D5             (   dfi_wrdata_d[13+16]     ),
        .D6             (   dfi_wrdata_d[13+16]     ),
        .D7             (   dfi_wrdata_d[13+16]     ),
        .D8             (   dfi_wrdata_d[13+16]     ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[13]            ),
        .TQ             (   dq_out_en_n_w[13]       ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq14(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[14+0]      ),
        .D2             (   dfi_wrdata_d[14+0]      ),
        .D3             (   dfi_wrdata_d[14+0]      ),
        .D4             (   dfi_wrdata_d[14+0]      ),
        .D5             (   dfi_wrdata_d[14+16]     ),
        .D6             (   dfi_wrdata_d[14+16]     ),
        .D7             (   dfi_wrdata_d[14+16]     ),
        .D8             (   dfi_wrdata_d[14+16]     ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[14]            ),
        .TQ             (   dq_out_en_n_w[14]       ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dq15(
        .CLK            (   clkin_400m              ),
        .CLKDIV         (   clkin_100m              ),
        .RST            (   rst_i                   ),
        .D1             (   dfi_wrdata_d[15+0]      ),
        .D2             (   dfi_wrdata_d[15+0]      ),
        .D3             (   dfi_wrdata_d[15+0]      ),
        .D4             (   dfi_wrdata_d[15+0]      ),
        .D5             (   dfi_wrdata_d[15+16]     ),
        .D6             (   dfi_wrdata_d[15+16]     ),
        .D7             (   dfi_wrdata_d[15+16]     ),
        .D8             (   dfi_wrdata_d[15+16]     ),
        .T1             (   dqs_out_en_n_q          ),
        .T2             (   dqs_out_en_n_q          ),
        .T3             (   dqs_out_en_n_q          ),
        .T4             (   dqs_out_en_n_q          ),
        .OCE            (   1                       ),
        .TCE            (   1                       ),
        .SHIFTIN1       (   0                       ),
        .SHIFTIN2       (   0                       ),
        .TBYTEIN        (   0                       ),

        .OQ             (   dq_out_w[15]            ),
        .TQ             (   dq_out_en_n_w[15]       ),
        .OFB            (                           ),
        .TFB            (                           ),
        .SHIFTOUT1      (                           ),
        .SHIFTOUT2      (                           ),
        .TBYTEOUT       (                           )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq1(
        .I              (   dq_out_w[1]         ),
        .O              (   dq_in_w[1]          ),
        .T              (   dq_out_en_n_w[1]    ),
        .IO             (   ddr3_dq_io[1]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq2(
        .I              (   dq_out_w[2]         ),
        .O              (   dq_in_w[2]          ),
        .T              (   dq_out_en_n_w[2]    ),
        .IO             (   ddr3_dq_io[2]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq3
    (
        .I              (   dq_out_w[3]         ),
        .O              (   dq_in_w[3]          ),
        .T              (   dq_out_en_n_w[3]    ),
        .IO             (   ddr3_dq_io[3]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq4
    (
        .I              (   dq_out_w[4]         ),
        .O              (   dq_in_w[4]          ),
        .T              (   dq_out_en_n_w[4]    ),
        .IO             (   ddr3_dq_io[4]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq5
    (
        .I              (   dq_out_w[5]         ),
        .O              (   dq_in_w[5]          ),
        .T              (   dq_out_en_n_w[5]    ),
        .IO             (   ddr3_dq_io[5]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq6
    (
        .I              (   dq_out_w[6]         ),
        .O              (   dq_in_w[6]          ),
        .T              (   dq_out_en_n_w[6]    ),
        .IO             (   ddr3_dq_io[6]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq7
    (
        .I              (   dq_out_w[7]         ),
        .O              (   dq_in_w[7]          ),
        .T              (   dq_out_en_n_w[7]    ),
        .IO             (   ddr3_dq_io[7]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq8
    (
        .I              (   dq_out_w[8]         ),
        .O              (   dq_in_w[8]          ),
        .T              (   dq_out_en_n_w[8]    ),
        .IO             (   ddr3_dq_io[8]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq9
    (
        .I              (   dq_out_w[9]         ),
        .O              (   dq_in_w[9]          ),
        .T              (   dq_out_en_n_w[9]    ),
        .IO             (   ddr3_dq_io[9]       )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq10
    (
        .I              (   dq_out_w[10]        ),
        .O              (   dq_in_w[10]         ),
        .T              (   dq_out_en_n_w[10]   ),
        .IO             (   ddr3_dq_io[10]      )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq11
    (
        .I              (   dq_out_w[11]        ),
        .O              (   dq_in_w[11]         ),
        .T              (   dq_out_en_n_w[11]   ),
        .IO             (   ddr3_dq_io[11]      )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq12
    (
        .I              (   dq_out_w[12]        ),
        .O              (   dq_in_w[12]         ),
        .T              (   dq_out_en_n_w[12]   ),
        .IO             (   ddr3_dq_io[12]      )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq13
    (
        .I              (   dq_out_w[13]        ),
        .O              (   dq_in_w[13]         ),
        .T              (   dq_out_en_n_w[13]   ),
        .IO             (   ddr3_dq_io[13]      )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq14
    (
        .I              (   dq_out_w[14]        ),
        .O              (   dq_in_w[14]         ),
        .T              (   dq_out_en_n_w[14]   ),
        .IO             (   ddr3_dq_io[14]      )
    );

    IOBUF#(
        .IOSTANDARD     (   "SSTL15"            ),
        .SLEW           (   "FAST"              )
    )u_pad_dq15
    (
        .I              (   dq_out_w[15]         ),
        .O              (   dq_in_w[15]          ),
        .T              (   dq_out_en_n_w[15]    ),
        .IO             (   ddr3_dq_io[15]       )
    );  
    

// Data Mask (DM)------------------------------------------------------------------------------

    wire [1 : 0] dm_out_w           ;
    reg  [3 : 0] dfi_wr_mask_d      ;
    
    always@(posedge clkin_100m)
    if (rst_i)
        dfi_wr_mask_d <= 4'b0;
    else
        dfi_wr_mask_d <= dfi_wrdata_mask_i;
    
    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dm0(
       .CLK             (   clkin_400m          ),
       .CLKDIV          (   clkin_100m          ),
       .RST             (   rst_i               ),
       .D1              (   dfi_wr_mask_d[0]    ),
       .D2              (   dfi_wr_mask_d[0]    ),
       .D3              (   dfi_wr_mask_d[0]    ),
       .D4              (   dfi_wr_mask_d[0]    ),
       .D5              (   dfi_wr_mask_d[2]    ),
       .D6              (   dfi_wr_mask_d[2]    ),
       .D7              (   dfi_wr_mask_d[2]    ),
       .D8              (   dfi_wr_mask_d[2]    ),
       .OCE             (   1                   ),
       .TCE             (   0                   ),
       .T1              (   0                   ),
       .T2              (   0                   ),
       .T3              (   0                   ),
       .T4              (   0                   ),
       .SHIFTIN1        (   0                   ),
       .SHIFTIN2        (   0                   ),
       .TBYTEIN         (   0                   ),

    
       .OQ              (   dm_out_w[0]         ),
       .OFB             (                       ),
       .SHIFTOUT1       (                       ),
       .SHIFTOUT2       (                       ),
       .TBYTEOUT        (                       ),
       .TFB             (                       ),
       .TQ              (                       )
    );
    
    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )
    u_serdes_dm1(
       .CLK             (   clkin_400m          ),
       .CLKDIV          (   clkin_100m          ),
       .RST             (   rst_i               ),
       .D1              (   dfi_wr_mask_d[1]    ),
       .D2              (   dfi_wr_mask_d[1]    ),
       .D3              (   dfi_wr_mask_d[1]    ),
       .D4              (   dfi_wr_mask_d[1]    ),
       .D5              (   dfi_wr_mask_d[3]    ),
       .D6              (   dfi_wr_mask_d[3]    ),
       .D7              (   dfi_wr_mask_d[3]    ),
       .D8              (   dfi_wr_mask_d[3]    ),
       .OCE             (   1                   ),
       .TCE             (   0                   ),
       .T1              (   0                   ),
       .T2              (   0                   ),
       .T3              (   0                   ),
       .T4              (   0                   ),
       .SHIFTIN1        (   0                   ),
       .SHIFTIN2        (   0                   ),
       .TBYTEIN         (   0                   ),

       .OQ              (   dm_out_w[1]         ),
       .OFB             (                       ),
       .SHIFTOUT1       (                       ),
       .SHIFTOUT2       (                       ),
       .TBYTEOUT        (                       ),
       .TFB             (                       ),
       .TQ              (                       )
    );
    
    assign ddr3_dm_o   = dm_out_w;
    
// Write Data Strobe (DQS)-------------------------------------------------------------------------

    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dqs0(
       .CLK             (   clkin_400m_shift_90     ),     //todo :zc
       .CLKDIV          (   clkin_100m              ),
       .RST             (   rst_i                   ),
       .D1              (   0                       ),
       .D2              (   0                       ),
       .D3              (   1                       ),
       .D4              (   1                       ),
       .D5              (   1                       ),
       .D6              (   1                       ),
       .D7              (   0                       ),
       .D8              (   0                       ),
       .T1              (   dqs_out_en_n_q          ),
       .T2              (   dqs_out_en_n_q          ),
       .T3              (   dqs_out_en_n_q          ),
       .T4              (   dqs_out_en_n_q          ),
       .SHIFTIN1        (   0                       ),
       .SHIFTIN2        (   0                       ),
       .TBYTEIN         (   0                       ),
       .TCE             (   1                       ),
       .OCE             (   1                       ),
    
       .OQ              (   dqs_out_w[0]            ),
       .TQ              (   dqs_out_en_n_w[0]       ),
       .OFB             (                           ),
       .SHIFTOUT1       (                           ),
       .SHIFTOUT2       (                           ),
       .TBYTEOUT        (                           ),
       .TFB             (                           )

    );
    
    OSERDESE2#(
        .SERDES_MODE    (   "MASTER"    ),
        .DATA_WIDTH     (   8           ),
        .TRISTATE_WIDTH (   1           ),
        .DATA_RATE_OQ   (   "DDR"       ),
        .DATA_RATE_TQ   (   "BUF"       )
    )u_serdes_dqs1(
       .CLK             (   clkin_400m_shift_90     ),
       .CLKDIV          (   clkin_100m              ),
       .RST             (   rst_i                   ),
       .D1              (   0                       ),
       .D2              (   0                       ),
       .D3              (   1                       ),
       .D4              (   1                       ),
       .D5              (   1                       ),
       .D6              (   1                       ),
       .D7              (   0                       ),
       .D8              (   0                       ),
       .OCE             (   1                       ),
       .TCE             (   1                       ),
       .T1              (   dqs_out_en_n_q          ),
       .T2              (   dqs_out_en_n_q          ),
       .T3              (   dqs_out_en_n_q          ),
       .T4              (   dqs_out_en_n_q          ),
       .SHIFTIN1        (   0                       ),
       .SHIFTIN2        (   0                       ),
       .TBYTEIN         (   0                       ),

       .OQ              (dqs_out_w[1]               ),
       .TQ              (dqs_out_en_n_w[1]          ),
       .OFB             (                           ),
       .SHIFTOUT1       (                           ),
       .SHIFTOUT2       (                           ),
       .TBYTEOUT        (                           ),
       .TFB             (                           )
    );





// Read Data Strobe (DQS)-----------------------------------------------------------------

    wire [1:0] dqs_delayed_w;


    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"  ) ,  // VARIABLE delay dynamically adjusts the delay value 
        .DELAY_SRC              (   "IDATAIN"   ),  //  means that the signal is from outer pins but not internal signals
        .CINVCTRL_SEL           (   "FALSE"     ),  //enable  dynamically switch the polarity of the C pin(clk input). There I disable it.
        .IDELAY_VALUE           (   DQS_TAP_DELAY_INIT  ), //Specifies the initial starting number of taps in VARIABLE mode(input path). integer: 0-31
        .HIGH_PERFORMANCE_MODE  (   "TRUE"      ),  //when true , this attribute reduces the output jitter.
        .REFCLK_FREQUENCY       (   200         ),//sets the tap value (in MHz) used by the timing analyzer for static timing analysis.
        .PIPE_SEL               (   "FALSE"     ), // only used in the VAR_LOAD_PIPE  mode of operation
        .SIGNAL_PATTERN         (   "CLOCK"     ) // cause the timing analyzer to account for the appropriate amount of delay-chain jitter in the data or clock path.
    )u_dqs_delay0(
        .C                      (   clkin_100m              ),
        .CE                     (   dqs_delay_inc_q[0]      ),   //enable increment/decrement function
        .INC                    (   1'b1                    ),   // Increment/decrement number of tap delays.
        .LD                     (   dqs_delay_rst_q[0]      ),   // Set the IDELAYE2 delay to IDELAY_VALUE            //todo: 延时没有加上去
        .IDATAIN                (   dqs_in_w[0]             ),   // Data input for IDELAY from the IBUF.
        .DATAOUT                (   dqs_delayed_w[0]        ),   // Delayed data

        .REGRST                 (   1'b0                    ),   //reset for the pipeline register . only used in VAR_LOAD_PIPE mode.
        .DATAIN                 (   1'b0                    ),  
        .LDPIPEEN               (   1'b0                    ),             
        .CINVCTRL               (   1'b0                    ),
        .CNTVALUEIN             (   5'b0                    ),
        .CNTVALUEOUT            (                           )
    );
    
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"              ),
        .DELAY_SRC              (   "IDATAIN"               ),
        .CINVCTRL_SEL           (   "FALSE"                 ),
        .IDELAY_VALUE           (   DQS_TAP_DELAY_INIT      ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"                  ),
        .REFCLK_FREQUENCY       (   200                     ),
        .PIPE_SEL               (   "FALSE"                 ),
        .SIGNAL_PATTERN         (   "CLOCK"                 )
    )u_dqs_delay1
    (
        .C                      (   clkin_100m              ),
        .CE                     (   dqs_delay_inc_q[1]      ),
        .INC                    (   1'b1                    ),
        .LD                     (   dqs_delay_rst_q[1]      ),       //todo:延时没有加上去
        .IDATAIN                (   dqs_in_w[1]             ),
        .DATAOUT                (   dqs_delayed_w[1]        ), 

        .REGRST                 (   1'b0                    ),     
        .DATAIN                 (   1'b0                    ),
        .LDPIPEEN               (   1'b0                    ),
        .CINVCTRL               (   1'b0                    ),
        .CNTVALUEIN             (   5'b0                    ),
        .CNTVALUEOUT            (                           )
    );
    
// Read capture------------------------------------------------------------------------------

    wire idelayctrl_rdy;
    
    IDELAYCTRL  u_dly_ref(                             //todo #(.SIM_DEVICE ("7SERIES")) 
        .REFCLK     (   clkin_200m_ref  ),         
        .RST        (   rst_i           ),
        .RDY        (   idelayctrl_rdy  )
    );
//--------------------------------DQ 0-------------------------------------------------------- 

    wire [15:0] dq_delayed_w;
    
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay0(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[0]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[0]   ),  
        .IDATAIN                (   dq_in_w[0]          ),      
        .DATAOUT                (   dq_delayed_w[0]     ),  

        .REGRST                 (   1'b0                ),
        .DATAIN                 (   1'b0                ),
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );  
    
    wire [3:0] rd_dq0_in_w;                          

/*     reg dqs_out_en_n_w_d ;                                              //建立时间违例
    always@(posedge clkin_100m)begin
        dqs_out_en_n_w_d <= dqs_out_en_n_w;
    end  */

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in0
    (
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),
        .CLKB                   (   ~dqs_delayed_w[0]    ),
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[0]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq0_in_w[3]      ),
        .Q3                     (   rd_dq0_in_w[2]      ),
        .Q2                     (   rd_dq0_in_w[1]      ),
        .Q1                     (   rd_dq0_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//-------------------------------------------DQ 1------------------------------------------------------------------    
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay1(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[0]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[0]   ),
        .IDATAIN                (   dq_in_w[1]          ),
        .DATAOUT                (   dq_delayed_w[1]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq1_in_w;
    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in1
    (
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),
        .CLKB                   (   ~dqs_delayed_w[0]    ),
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[1]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq1_in_w[3]      ),
        .Q3                     (   rd_dq1_in_w[2]      ),
        .Q2                     (   rd_dq1_in_w[1]      ),
        .Q1                     (   rd_dq1_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//--------------------------------------DQ 2---------------------------------------------------------------  
    IDELAYE2 #(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay2(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[0]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[0]   ),
        .IDATAIN                (   dq_in_w[2]          ),
        .DATAOUT                (   dq_delayed_w[2]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
 
    wire [3:0] rd_dq2_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in2
    (
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),
        .CLKB                   (   ~dqs_delayed_w[0]    ),
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[2]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq2_in_w[3]      ),
        .Q3                     (   rd_dq2_in_w[2]      ),
        .Q2                     (   rd_dq2_in_w[1]      ),
        .Q1                     (   rd_dq2_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//--------------------------------------DQ 3---------------------------------------------------------------  
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay3(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[0]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[0]   ),
        .IDATAIN                (   dq_in_w[3]          ),
        .DATAOUT                (   dq_delayed_w[3]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq3_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in3(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),
        .CLKB                   (   ~dqs_delayed_w[0]    ),
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[3]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq3_in_w[3]      ),
        .Q3                     (   rd_dq3_in_w[2]      ),
        .Q2                     (   rd_dq3_in_w[1]      ),
        .Q1                     (   rd_dq3_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//-------------------------------------DQ 4--------------------------------------------------------------- 
    IDELAYE2 #(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay4(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[0]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[0]   ),
        .IDATAIN                (   dq_in_w[4]          ),
        .DATAOUT                (   dq_delayed_w[4]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
   
    wire [3:0] rd_dq4_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in4(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),
        .CLKB                   (   ~dqs_delayed_w[0]    ),
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[4]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq4_in_w[3]      ),
        .Q3                     (   rd_dq4_in_w[2]      ),
        .Q2                     (   rd_dq4_in_w[1]      ),
        .Q1                     (   rd_dq4_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//----------------------------------------------------DQ 5----------------------------------------------
    IDELAYE2 #(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay5(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[0]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[0]   ),
        .IDATAIN                (   dq_in_w[5]          ),
        .DATAOUT                (   dq_delayed_w[5]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq5_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in5(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),
        .CLKB                   (   ~dqs_delayed_w[0]    ),
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[5]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq5_in_w[3]      ),
        .Q3                     (   rd_dq5_in_w[2]      ),
        .Q2                     (   rd_dq5_in_w[1]      ),
        .Q1                     (   rd_dq5_in_w[0]      ),
    
        // Unused
        .O                      (                       ),    
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//----------------------------------------------DQ 6------------------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay6(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[0]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[0]   ),
        .IDATAIN                (   dq_in_w[6]          ),
        .DATAOUT                (   dq_delayed_w[6]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq6_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )
    u_serdes_dq_in6
    (
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),
        .CLKB                   (   ~dqs_delayed_w[0]    ),
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[6]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq6_in_w[3]      ),
        .Q3                     (   rd_dq6_in_w[2]      ),
        .Q2                     (   rd_dq6_in_w[1]      ),
        .Q1                     (   rd_dq6_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//-----------------------------------------------DQ 7-------------------------------------------
    IDELAYE2 #(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay7(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[0]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[0]   ),
        .IDATAIN                (   dq_in_w[7]          ),
        .DATAOUT                (   dq_delayed_w[7]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq7_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in7(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),
        .CLKB                   (   ~dqs_delayed_w[0]    ),
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[7]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq7_in_w[3]      ),
        .Q3                     (   rd_dq7_in_w[2]      ),
        .Q2                     (   rd_dq7_in_w[1]      ),
        .Q1                     (   rd_dq7_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//---------------------------------------------------DQ 8---------------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay8(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[1]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[1]   ),
        .IDATAIN                (   dq_in_w[8]          ),
        .DATAOUT                (   dq_delayed_w[8]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq8_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )
    u_serdes_dq_in8
    (
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),//
        .CLKB                   (   ~dqs_delayed_w[0]    ),//
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[8]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq8_in_w[3]      ),
        .Q3                     (   rd_dq8_in_w[2]      ),
        .Q2                     (   rd_dq8_in_w[1]      ),
        .Q1                     (   rd_dq8_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//----------------------------------------------------DQ 9------------------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay9(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[1]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[1]   ),
        .IDATAIN                (   dq_in_w[9]          ),
        .DATAOUT                (   dq_delayed_w[9]     ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq9_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in9(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),//
        .CLKB                   (   ~dqs_delayed_w[0]    ),//
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[9]     ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq9_in_w[3]      ),
        .Q3                     (   rd_dq9_in_w[2]      ),
        .Q2                     (   rd_dq9_in_w[1]      ),
        .Q1                     (   rd_dq9_in_w[0]      ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//----------------------------------------------------DQ 10-----------------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay10(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[1]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[1]   ),
        .IDATAIN                (   dq_in_w[10]         ),
        .DATAOUT                (   dq_delayed_w[10]    ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq10_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in10(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),//
        .CLKB                   (   ~dqs_delayed_w[0]    ),//

        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[10]    ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq10_in_w[3]     ),
        .Q3                     (   rd_dq10_in_w[2]     ),
        .Q2                     (   rd_dq10_in_w[1]     ),
        .Q1                     (   rd_dq10_in_w[0]     ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//----------------------------------------------------DQ 11----------------------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay11(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[1]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[1]   ),
        .IDATAIN                (   dq_in_w[11]         ),
        .DATAOUT                (   dq_delayed_w[11]    ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq11_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in11(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),//
        .CLKB                   (   ~dqs_delayed_w[0]    ),//
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[11]    ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq11_in_w[3]     ),
        .Q3                     (   rd_dq11_in_w[2]     ),
        .Q2                     (   rd_dq11_in_w[1]     ),
        .Q1                     (   rd_dq11_in_w[0]     ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (       1'b0            ),
        .CLKDIVP                (       0               ),
        .DYNCLKDIVSEL           (       0               ),
        .DYNCLKSEL              (       0               ),
        .OFB                    (       0               ),
        .SHIFTIN1               (       0               ),
        .SHIFTIN2               (       0               )
    );
//---------------------------------------------------DQ 12---------------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay12(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[1]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[1]   ),
        .IDATAIN                (   dq_in_w[12]         ),
        .DATAOUT                (   dq_delayed_w[12]    ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq12_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in12(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),//
        .CLKB                   (   ~dqs_delayed_w[0]    ),//
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[12]    ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq12_in_w[3]     ),
        .Q3                     (   rd_dq12_in_w[2]     ),
        .Q2                     (   rd_dq12_in_w[1]     ),
        .Q1                     (   rd_dq12_in_w[0]     ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//------------------------------------------------------DQ 13---------------------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay13(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[1]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[1]   ),
        .IDATAIN                (   dq_in_w[13]         ),
        .DATAOUT                (   dq_delayed_w[13]    ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq13_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in13(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),//
        .CLKB                   (   ~dqs_delayed_w[0]    ),//
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[13]    ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq13_in_w[3]     ),
        .Q3                     (   rd_dq13_in_w[2]     ),
        .Q2                     (   rd_dq13_in_w[1]     ),
        .Q1                     (   rd_dq13_in_w[0]     ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//---------------------------------------------------DQ 14----------------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay14(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[1]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[1]   ),
        .IDATAIN                (   dq_in_w[14]         ),
        .DATAOUT                (   dq_delayed_w[14]    ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq14_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in14(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),//
        .CLKB                   (   ~dqs_delayed_w[0]    ),//
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[14]    ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq14_in_w[3]     ),
        .Q3                     (   rd_dq14_in_w[2]     ),
        .Q2                     (   rd_dq14_in_w[1]     ),
        .Q1                     (   rd_dq14_in_w[0]     ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
//-----------------------------------------------------DQ 15-----------------------------------------
    IDELAYE2#(
        .IDELAY_TYPE            (   "VARIABLE"          ),
        .DELAY_SRC              (   "IDATAIN"           ),
        .CINVCTRL_SEL           (   "FALSE"             ),
        .IDELAY_VALUE           (   DQ_TAP_DELAY_INIT   ),
        .HIGH_PERFORMANCE_MODE  (   "TRUE"              ),
        .REFCLK_FREQUENCY       (   200                 ),
        .PIPE_SEL               (   "FALSE"             ),
        .SIGNAL_PATTERN         (   "DATA"              )
    )u_dq_delay15(
        .C                      (   clkin_100m          ),
        .CE                     (   dq_delay_inc_q[1]   ),
        .INC                    (   1'b1                ),
        .LD                     (   dq_delay_rst_q[1]   ),
        .IDATAIN                (   dq_in_w[15]         ),
        .DATAOUT                (   dq_delayed_w[15]    ),

        .REGRST                 (   1'b0                ),                 
        .DATAIN                 (   1'b0                ),     
        .LDPIPEEN               (   1'b0                ),
        .CINVCTRL               (   1'b0                ),
        .CNTVALUEIN             (   5'b0                ),
        .CNTVALUEOUT            (                       )
    );
    
    wire [3:0] rd_dq15_in_w;

    ISERDESE2#(
        .SERDES_MODE            (   "MASTER"            ),
        .INTERFACE_TYPE         (   "MEMORY"            ),
        .DATA_WIDTH             (   4                   ),
        .DATA_RATE              (   "DDR"               ),
        .NUM_CE                 (   1                   ),
        .IOBDELAY               (   "IFD"               )
    )u_serdes_dq_in15(
        // DQS input strobe
        .CLK                    (   dqs_delayed_w[0]     ),//
        .CLKB                   (   ~dqs_delayed_w[0]    ),//
    
        // Fast clock
        .OCLK                   (   clkin_400m          ),
        .OCLKB                  (   ~clkin_400m         ),
    
        // Slow clock
        .CLKDIV                 (   clkin_100m          ),
        .RST                    (   rst_i               ),
    
        .BITSLIP                (   0                   ),
        .CE1                    (   1'b1                ),
        
        // TODO:
        .DDLY                   (   dq_delayed_w[15]    ),
        .D                      (   1'b0                ),
    
        // Parallel output
        .Q4                     (   rd_dq15_in_w[3]     ),
        .Q3                     (   rd_dq15_in_w[2]     ),
        .Q2                     (   rd_dq15_in_w[1]     ),
        .Q1                     (   rd_dq15_in_w[0]     ),
    
        // Unused
        .O                      (                       ),
        .SHIFTOUT1              (                       ),
        .SHIFTOUT2              (                       ),
        .CE2                    (   1'b0                ),
        .CLKDIVP                (   0                   ),
        .DYNCLKDIVSEL           (   0                   ),
        .DYNCLKSEL              (   0                   ),
        .OFB                    (   0                   ),
        .SHIFTIN1               (   0                   ),
        .SHIFTIN2               (   0                   )
    );
    
    /* (* mark_debug = "true" *) */ wire [15:0] rd_data0_w;
    /* (* mark_debug = "true" *) */ wire [15:0] rd_data1_w;
    /* (* mark_debug = "true" *) */ wire [15:0] rd_data2_w;
    /* (* mark_debug = "true" *) */ wire [15:0] rd_data3_w;
    
    assign rd_data0_w[0]  = rd_dq0_in_w[0];
    assign rd_data1_w[0]  = rd_dq0_in_w[1];
    assign rd_data2_w[0]  = rd_dq0_in_w[2];
    assign rd_data3_w[0]  = rd_dq0_in_w[3];
    assign rd_data0_w[1]  = rd_dq1_in_w[0];
    assign rd_data1_w[1]  = rd_dq1_in_w[1];
    assign rd_data2_w[1]  = rd_dq1_in_w[2];
    assign rd_data3_w[1]  = rd_dq1_in_w[3];
    assign rd_data0_w[2]  = rd_dq2_in_w[0];
    assign rd_data1_w[2]  = rd_dq2_in_w[1];
    assign rd_data2_w[2]  = rd_dq2_in_w[2];
    assign rd_data3_w[2]  = rd_dq2_in_w[3];
    assign rd_data0_w[3]  = rd_dq3_in_w[0];
    assign rd_data1_w[3]  = rd_dq3_in_w[1];
    assign rd_data2_w[3]  = rd_dq3_in_w[2];
    assign rd_data3_w[3]  = rd_dq3_in_w[3];
    assign rd_data0_w[4]  = rd_dq4_in_w[0];
    assign rd_data1_w[4]  = rd_dq4_in_w[1];
    assign rd_data2_w[4]  = rd_dq4_in_w[2];
    assign rd_data3_w[4]  = rd_dq4_in_w[3];
    assign rd_data0_w[5]  = rd_dq5_in_w[0];
    assign rd_data1_w[5]  = rd_dq5_in_w[1];
    assign rd_data2_w[5]  = rd_dq5_in_w[2];
    assign rd_data3_w[5]  = rd_dq5_in_w[3];
    assign rd_data0_w[6]  = rd_dq6_in_w[0];
    assign rd_data1_w[6]  = rd_dq6_in_w[1];
    assign rd_data2_w[6]  = rd_dq6_in_w[2];
    assign rd_data3_w[6]  = rd_dq6_in_w[3];
    assign rd_data0_w[7]  = rd_dq7_in_w[0];
    assign rd_data1_w[7]  = rd_dq7_in_w[1];
    assign rd_data2_w[7]  = rd_dq7_in_w[2];
    assign rd_data3_w[7]  = rd_dq7_in_w[3];
    assign rd_data0_w[8]  = rd_dq8_in_w[0];
    assign rd_data1_w[8]  = rd_dq8_in_w[1];
    assign rd_data2_w[8]  = rd_dq8_in_w[2];
    assign rd_data3_w[8]  = rd_dq8_in_w[3];
    assign rd_data0_w[9]  = rd_dq9_in_w[0];
    assign rd_data1_w[9]  = rd_dq9_in_w[1];
    assign rd_data2_w[9]  = rd_dq9_in_w[2];
    assign rd_data3_w[9]  = rd_dq9_in_w[3];
    assign rd_data0_w[10]  = rd_dq10_in_w[0];
    assign rd_data1_w[10]  = rd_dq10_in_w[1];
    assign rd_data2_w[10]  = rd_dq10_in_w[2];
    assign rd_data3_w[10]  = rd_dq10_in_w[3];
    assign rd_data0_w[11]  = rd_dq11_in_w[0];
    assign rd_data1_w[11]  = rd_dq11_in_w[1];
    assign rd_data2_w[11]  = rd_dq11_in_w[2];
    assign rd_data3_w[11]  = rd_dq11_in_w[3];
    assign rd_data0_w[12]  = rd_dq12_in_w[0];
    assign rd_data1_w[12]  = rd_dq12_in_w[1];
    assign rd_data2_w[12]  = rd_dq12_in_w[2];
    assign rd_data3_w[12]  = rd_dq12_in_w[3];
    assign rd_data0_w[13]  = rd_dq13_in_w[0];
    assign rd_data1_w[13]  = rd_dq13_in_w[1];
    assign rd_data2_w[13]  = rd_dq13_in_w[2];
    assign rd_data3_w[13]  = rd_dq13_in_w[3];
    assign rd_data0_w[14]  = rd_dq14_in_w[0];
    assign rd_data1_w[14]  = rd_dq14_in_w[1];
    assign rd_data2_w[14]  = rd_dq14_in_w[2];
    assign rd_data3_w[14]  = rd_dq14_in_w[3];
    assign rd_data0_w[15]  = rd_dq15_in_w[0];
    assign rd_data1_w[15]  = rd_dq15_in_w[1];
    assign rd_data2_w[15]  = rd_dq15_in_w[2];
    assign rd_data3_w[15]  = rd_dq15_in_w[3];

    reg [15:0] rd_data1_w_zc_delayed;

    always@(posedge clkin_100m)//
        rd_data1_w_zc_delayed <= rd_data1_w;//
    
    reg [31:0] rd_capture_d;
    
    always@(posedge clkin_100m)
    if (rst_i)
        rd_capture_d <= 32'b0;
    else
    begin
        case (rd_sel_q)
        4'd0:  rd_capture_d <= {rd_data1_w, rd_data0_w};
        4'd1:  rd_capture_d <= {rd_data1_w, rd_data1_w};
        4'd2:  rd_capture_d <= {rd_data1_w, rd_data2_w};
        4'd3:  rd_capture_d <= {rd_data1_w, rd_data3_w};
        4'd4:  rd_capture_d <= {rd_data2_w, rd_data0_w};
        4'd5:  rd_capture_d <= {rd_data2_w, rd_data1_w};
        4'd6:  rd_capture_d <= {rd_data2_w, rd_data2_w};
        4'd7:  rd_capture_d <= {rd_data2_w, rd_data3_w};
        4'd8:  rd_capture_d <= {rd_data3_w, rd_data0_w};
        4'd9:  rd_capture_d <= {rd_data3_w, rd_data1_w};
        4'd10: rd_capture_d <= {rd_data3_w, rd_data2_w};
        4'd11: rd_capture_d <= {rd_data3_w, rd_data3_w};   
        4'd12: rd_capture_d <= {rd_data0_w, rd_data0_w};
        4'd13: rd_capture_d <= {rd_data0_w, rd_data1_w};
        4'd14: rd_capture_d <= {rd_data0_w, rd_data2_w};
        4'd15: rd_capture_d <= {rd_data0_w, rd_data1_w_zc_delayed};//
        endcase
    end
    
    assign dfi_rddata_o       = rd_capture_d;

// Read Valid-------------------------------------------------------------
    localparam RD_SHIFT_W = 8;
    reg [RD_SHIFT_W-1:0] cur_rden;
    reg [RD_SHIFT_W-1:0] nex_rden;

    always @ (posedge clkin_100m )begin
        if (rst_i)
            cur_rden <= {(RD_SHIFT_W){1'b0}};
        else
            cur_rden <= nex_rden;
    end
    
    always@(*)
    begin
        nex_rden = {1'b0, cur_rden[RD_SHIFT_W-1:1]} ;
        nex_rden[phy_rdlat] = dfi_rddata_en_i       ;
    end  
    assign dfi_rddata_valid_o = cur_rden[0]         ;
    assign dfi_rddata_dnv_o   = 4'b0                ;   //this signal is only required for DFI LPDDR2 support.    

endmodule