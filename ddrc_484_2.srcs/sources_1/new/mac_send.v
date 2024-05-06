`timescale 1ns / 1ps

module mac_send#(
    parameter LOCAL_MAC_ADDR  = 48'hffff_ffff_ffff,
    parameter TARGET_MAC_ADDR = 48'hffff_ffff_ffff
)(
    input                   clk                 ,
    input                   phy_tx_clk          ,

    input                   reset               ,
    input                   phy_tx_reset        ,

//========================= rgmii_send ==================================

    output reg              gmii_tx_data_vld    ,
    output reg [7:0]        gmii_tx_data        ,

//========================= ip_send =====================================

    input                   mac_tx_data_vld     ,
    input                   mac_tx_data_last    ,
    input [7:0]             mac_tx_data         ,
    input [15:0]            mac_tx_frame_type   ,
    input [15:0]            mac_tx_length       , //not used

//========================= tx_crc32_d8 =================================

    output reg              tx_crc_din_vld      ,
    output [7:0]            tx_crc_din          ,
    output reg              tx_crc_done         ,
    input [31:0]            tx_crc_dout
    );

    reg [1:0]               cur_state           ;
    reg [1:0]               nex_state           ;

    localparam              TX_IDLE = 2'b00     ;
    localparam              TX_PRE  = 2'b01     ;
    localparam              TX_DATA = 3'b11     ;
    localparam              TX_END  = 3'b10     ;

    reg                     frame_wren          ;
    reg [16:0]              frame_din           ;
    reg                     frame_rden          ;
    wire [16:0]             frame_dout          ;
    wire                    frame_wrfull        ;
    wire                    frame_rdempty       ;
    wire [3:0]              frame_rdcount       ;
    wire [3:0]              frame_wrcount       ;

    reg [8:0]               data_din            ;
    reg                     data_wren           ;
    reg                     data_rden           ;
    wire [8:0]              data_dout           ;
    wire                    data_wrfull         ;
    wire                    data_rdempty        ;
    wire [10:0]             data_rdcount        ;
    wire [10:0]             data_wrcount        ;
    wire                    data_wr_rst_busy    ;
    wire                    data_rd_rst_busy    ;

    reg [10:0]              tx_cnt              ;
    reg                     crc_data_en         ;
    reg [7:0]               crc_data            ;
    reg [2:0]               crc_cnt             ;
    reg                     send_data_en        ;
    reg [7:0]               send_data           ;
    reg                     send_data_last      ;
    reg [15:0]              mac_type            ;

//======================== data_fifo & frame_fifo write in =================================

    always@(posedge clk)begin
        data_din <= {mac_tx_data_last , mac_tx_data};
        data_wren <= mac_tx_data_vld;
    end

    always@(posedge clk)begin
        frame_wren <= mac_tx_data_last;
        frame_din <= {1'b0 , mac_tx_frame_type};
    end

//======================== FSM =============================================================

    always@(posedge phy_tx_clk)begin
        if(phy_tx_reset)
            cur_state <= TX_IDLE;
        else
            cur_state <= nex_state;
    end

    always@(*)begin
        if(phy_tx_reset)
            nex_state <= TX_IDLE;
        else begin
            case(cur_state)
                TX_IDLE : nex_state <= (~frame_rdempty) ? TX_PRE : cur_state;
                TX_PRE  : nex_state <= TX_DATA;
                TX_DATA : nex_state <= (crc_data_en & crc_cnt == 'd3) ? TX_END : cur_state;
                TX_END  : nex_state <= TX_IDLE;
                default : nex_state <= TX_IDLE;
            endcase
        end
    end

//=========================================== cnt ===================================================

    always@(posedge phy_tx_clk)begin
        if(phy_tx_reset)
            tx_cnt <= 'd0;
        else if(cur_state == TX_DATA)
            tx_cnt <= tx_cnt + 1'b1;
        else
            tx_cnt <= 'd0;
    end

//========================================== send_data ===============================================

    always@(posedge phy_tx_clk)begin
        if(phy_tx_reset)
            send_data <= 'd0;
        else begin
            case(tx_cnt)
                0,1,2,3,4,5,6 : send_data <= 8'h55;
                7             : send_data <= 8'hd5;

                8             : send_data <= TARGET_MAC_ADDR[47:40];
                9             : send_data <= TARGET_MAC_ADDR[39:32];
                10            : send_data <= TARGET_MAC_ADDR[31:24];
                11            : send_data <= TARGET_MAC_ADDR[23:16];
                12            : send_data <= TARGET_MAC_ADDR[15:8];
                13            : send_data <= TARGET_MAC_ADDR[7:0];

                14            : send_data <= LOCAL_MAC_ADDR[47:40];
                15            : send_data <= LOCAL_MAC_ADDR[39:32];
                16            : send_data <= LOCAL_MAC_ADDR[31:24];
                17            : send_data <= LOCAL_MAC_ADDR[23:16];
                18            : send_data <= LOCAL_MAC_ADDR[15:8];
                19            : send_data <= LOCAL_MAC_ADDR[7:0];

                20            : send_data <= mac_type[15:8];
                21            : send_data <= mac_type[7:0];
                default       : send_data <= data_dout[7:0];
            endcase
        end
    end

    always@(*)begin
        frame_rden <= (cur_state == TX_PRE);
    end

    always@(posedge phy_tx_clk)begin
        if(frame_rden)
            mac_type <= frame_dout[15:0];
        else
            mac_type <= mac_type;
    end

    always@(posedge phy_tx_clk)begin
        if(cur_state == TX_DATA & tx_cnt == 'd21)
            data_rden <= 1'b1;
        else if(data_rden & data_dout[8])
            data_rden <= 1'b0;
        else
            data_rden <= data_rden;
    end

    always@(posedge phy_tx_clk)begin
        if(data_rden & data_dout[8])
            send_data_last <= 1'b1;
        else
            send_data_last <= 1'b0;
    end

    always@(posedge phy_tx_clk)begin
        if(cur_state == TX_DATA & tx_cnt == 'd0)
            send_data_en <= 1'b1;
        else if(send_data_last)
            send_data_en <= 1'b0;
        else
            send_data_en <= send_data_en;
    end

//================================== crc ============================================

    always@(posedge phy_tx_clk)begin
        if(tx_cnt == 'd8)
            tx_crc_din_vld <= 1'b1;
        else if(send_data_last)
            tx_crc_din_vld <= 1'b0;
        else
            tx_crc_din_vld <= tx_crc_din_vld;
    end

    assign tx_crc_din = send_data;

    always@(posedge phy_tx_clk)begin
        if(crc_data_en & crc_cnt == 'd3)
            tx_crc_done <= 1'b1;
        else
            tx_crc_done <= 1'b0;
    end

    always@(posedge phy_tx_clk)begin
        if(crc_data_en & crc_cnt == 'd3)
            crc_data_en <= 1'b0;
        else if(send_data_last)
            crc_data_en <= 1'b1;
        else
            crc_data_en <= crc_data_en;
    end

    always@(posedge phy_tx_clk)begin
        if(phy_tx_reset)
            crc_cnt <= 'd0;
        else if(crc_data_en & crc_cnt == 'd3)
            crc_cnt <= 'd0;
        else if(crc_data_en)
            crc_cnt <= crc_cnt + 1'b1;
        else
            crc_cnt <= crc_cnt;
    end

    always@(*)begin
        if(phy_tx_reset)
            crc_data <= 0;
        else begin
            case(crc_cnt)
                0 : crc_data <= tx_crc_dout[7:0];
                1 : crc_data <= tx_crc_dout[15:8];
                2 : crc_data <= tx_crc_dout[23:16];
                3 : crc_data <= tx_crc_dout[31:24];
            endcase
        end
    end

//=================================== mac package ==========================================

    always@(posedge phy_tx_clk)begin
        if(phy_tx_reset)
            gmii_tx_data_vld <= 1'b0;
        else
            gmii_tx_data_vld <= crc_data_en | send_data_en;
    end

    always@(posedge phy_tx_clk)begin
        if(phy_tx_reset)
            gmii_tx_data <= 'd0;
        else if(send_data_en)
            gmii_tx_data <= send_data;
        else if(crc_data_en)
            gmii_tx_data <= crc_data;
        else
            gmii_tx_data <= gmii_tx_data;
    end

//================================= FIFO inst =================================================



    frame_fifo_w17xd16 u_rx_frame_fifo (
        .rst                (reset          ),  // input wire rst
        .wr_clk             (clk            ),  // input wire wr_clk
        .rd_clk             (phy_tx_clk     ),  // input wire rd_clk
        .din                (frame_din      ),  // input wire [16 : 0] din
        .wr_en              (frame_wren     ),  // input wire wr_en
        .rd_en              (frame_rden     ),  // input wire rd_en
        .dout               (frame_dout     ),  // output wire [16 : 0] dout
        .full               (frame_wrfull   ),  // output wire full
        .empty              (frame_rdempty  ),  // output wire empty
        .rd_data_count      (frame_rdcount  ),  // output wire [3 : 0] rd_data_count
        .wr_data_count      (frame_wrcount  )   // output wire [3 : 0] wr_data_count
    );

    data_fifo_w9xd2048 u_rx_data_fifo (
        .rst                (reset          ),      // input wire rst
        .wr_clk             (clk            ),      // input wire wr_clk
        .rd_clk             (phy_tx_clk     ),      // input wire rd_clk
        .din                (data_din       ),      // input wire [8 : 0] din
        .wr_en              (data_wren      ),      // input wire wr_en
        .rd_en              (data_rden      ),      // input wire rd_en
        .dout               (data_dout      ),      // output wire [8 : 0] dout
        .full               (data_wrfull    ),      // output wire full
        .empty              (data_rdempty   ),      // output wire empty
        .rd_data_count      (data_rdcount   ),      // output wire [10 : 0] rd_data_count
        .wr_data_count      (data_wrcount   ),      // output wire [10 : 0] wr_data_count
        .wr_rst_busy        (data_wr_rst_busy),     // output wire wr_rst_busy
        .rd_rst_busy        (data_rd_rst_busy)      // output wire rd_rst_busy
    );
endmodule
