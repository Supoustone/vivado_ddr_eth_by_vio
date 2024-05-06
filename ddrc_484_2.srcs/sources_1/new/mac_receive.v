`timescale 1ns / 1ps

module mac_receive#(
    parameter LOCAL_MAC_ADDR = 48'hffff_ffff_ffff,
    parameter CRC_CHECK_EN   = 1
)(
    input               clk                 ,
    input               phy_rx_clk          ,

    input               reset               ,
    input               phy_rx_reset        ,

//================= rmgii_recieve ===========================

    input               gmii_rx_data_vld    ,
    input [7:0]         gmii_rx_data        ,

//================= mac_to_arp_ip ===========================

    output reg          mac_rx_data_vld     ,
    output reg          mac_rx_data_last    ,
    output reg [7:0]    mac_rx_data         ,
    output reg [15:0]   mac_rx_frame_type   ,

//================= rx_crc32_d8 =============================

    output reg          rx_crc_din_vld      ,
    output reg [7:0]    rx_crc_din          ,
    output reg          rx_crc_done         ,
    input [31:0]        rx_crc_dout
    );

    reg [1:0]           cur_state           ;
    reg [1:0]           nex_state           ;

    localparam          RX_IDLE = 2'b00     ;
    localparam          RX_PRE  = 2'b01     ;
    localparam          RX_DATA = 2'b11     ;
    localparam          RX_END  = 2'b10     ;

    reg                 gmii_rx_data_vld_d0 ;
    reg                 gmii_rx_data_vld_d1 ;
    reg                 gmii_rx_data_vld_d2 ;
    reg                 gmii_rx_data_vld_d3 ;
    reg                 gmii_rx_data_vld_d4 ;
    reg [7:0]           gmii_rx_data_d0     ;
    reg [7:0]           gmii_rx_data_d1     ;
    reg [7:0]           gmii_rx_data_d2     ;
    reg [7:0]           gmii_rx_data_d3     ;
    reg [7:0]           gmii_rx_data_d4     ;

    wire                rx_data_last        ;
    reg                 rx_data_last_d0     ;
    reg                 rx_data_last_d1     ;
    reg                 rx_data_last_d2     ;
    reg                 rx_data_last_d3     ;
    reg                 rx_data_last_d4     ;
    reg                 rx_data_last_d5     ;
    reg                 rx_data_last_d6     ;

    reg [16:0]          frame_din           ;
    reg                 frame_wren          ;
    reg                 frame_rden          ;
    wire [16:0]         frame_dout          ;
    wire                frame_wrfull        ;
    wire                frame_rdempty       ;
    wire [3:0]          frame_rdcount       ;
    wire [3:0]          frame_wrcount       ;

    reg [8:0]           data_din            ;
    reg                 data_wren           ;
    reg                 data_rden           ;
    wire [8:0]          data_dout           ;
    wire                data_wrfull         ;
    wire                data_rdempty        ;
    wire [10:0]         data_rdcount        ;
    wire [10:0]         data_wrcount        ;
    wire                data_wr_rst_busy    ;
    wire                data_rd_rst_busy    ;

    reg [10:0]          rx_cnt              ;
    reg [55:0]          rx_preamble         ;
    reg [47:0]          rx_target_mac       ;

    reg                 rx_preamble_check   ;
    reg                 rx_target_mac_check ;
    reg                 rx_sfd_check        ;
    reg                 rx_crc_check        ;

    reg [15:0]          rx_frame_type       ;
    reg                 rx_wr_vld           ;
    reg                 frame_fifo_crc      ;

    assign rx_data_last = ~gmii_rx_data_vld & gmii_rx_data_vld_d0;

    always@(posedge phy_rx_clk)begin
        gmii_rx_data_vld_d0 <= gmii_rx_data_vld;
        gmii_rx_data_vld_d1 <= gmii_rx_data_vld_d0;
        gmii_rx_data_vld_d2 <= gmii_rx_data_vld_d1;
        gmii_rx_data_vld_d3 <= gmii_rx_data_vld_d2;
        gmii_rx_data_vld_d4 <= gmii_rx_data_vld_d3;

        gmii_rx_data_d0 <= gmii_rx_data;
        gmii_rx_data_d1 <= gmii_rx_data_d0;
        gmii_rx_data_d2 <= gmii_rx_data_d1;
        gmii_rx_data_d3 <= gmii_rx_data_d2;
        gmii_rx_data_d4 <= gmii_rx_data_d3;

        rx_data_last_d0 <= rx_data_last;
        rx_data_last_d1 <= rx_data_last_d0;
        rx_data_last_d2 <= rx_data_last_d1;
        rx_data_last_d3 <= rx_data_last_d2;
        rx_data_last_d4 <= rx_data_last_d3;
        rx_data_last_d5 <= rx_data_last_d4;
        rx_data_last_d6 <= rx_data_last_d5;
    end

//=========================== cnt ====================================

    always@(posedge phy_rx_clk)begin
        if(phy_rx_reset)
            rx_cnt <= 'd0;
        else if(gmii_rx_data_vld_d4)
            rx_cnt <= rx_cnt + 1'b1;
        else
            rx_cnt <= 'd0;
    end

//=========================== sfd \ preamble \ target mac addr =========

    always@(posedge phy_rx_clk)begin
        if(gmii_rx_data_vld_d4 & rx_cnt < 7)
            rx_preamble <= {rx_preamble[47:0] , gmii_rx_data_d4};
        else
            rx_preamble <= rx_preamble;
    end

    always@(posedge phy_rx_clk)begin
        if(gmii_rx_data_vld_d4 & rx_cnt > 7 & rx_cnt < 14)
            rx_target_mac <= {rx_target_mac[39:0] , gmii_rx_data_d4};
        else
            rx_target_mac <= rx_target_mac;
    end

    always@(posedge phy_rx_clk)begin
        if(rx_preamble == 56'h55_555555_555555)
            rx_preamble_check <= 1'b1;
        else if(rx_preamble != 56'h55_555555_555555)
            rx_preamble_check <= 1'b0;
        else
            rx_preamble_check <= rx_preamble_check;
    end

    always@(posedge phy_rx_clk)begin
        if(gmii_rx_data_d4 == 8'hd5 & rx_cnt == 'd7)
            rx_sfd_check <= 1'b1;
        else if(gmii_rx_data_d4 != 8'hd5 & rx_cnt == 'd7)
            rx_sfd_check <= 1'b0;
        else
            rx_sfd_check <= rx_sfd_check;
    end

    always@(posedge phy_rx_clk)begin
        if(rx_target_mac == LOCAL_MAC_ADDR)
            rx_target_mac_check <= 1'b1;
        else if(rx_target_mac != LOCAL_MAC_ADDR)
            rx_target_mac_check <= 1'b0;
        else
            rx_target_mac_check <= rx_target_mac_check;
    end

//================================= CRC ===========================================

    generate
        if(CRC_CHECK_EN == 0)begin
            always@(posedge phy_rx_clk)
                rx_crc_check <= 1'b1;

        end else if(CRC_CHECK_EN == 1)begin
            reg         crc_en;
            reg [31:0]  rx_crc;

            always@(posedge phy_rx_clk)begin
                if(rx_data_last_d0 | rx_data_last_d1 | rx_data_last_d2 | rx_data_last_d3)
                    rx_crc <= {gmii_rx_data_d4 , rx_crc[31:8]};
                else
                    rx_crc <= rx_crc;
            end

            always@(posedge phy_rx_clk)begin
                if(rx_cnt == 7)
                    crc_en <= 1'b1;
                else if(rx_data_last)
                    crc_en <= 1'b0;
                else
                    crc_en <= crc_en;
            end

            always@(posedge phy_rx_clk)begin
                rx_crc_din_vld <= crc_en;
                rx_crc_din <= gmii_rx_data_d4;
                rx_crc_done <= rx_data_last_d6;
            end

            always@(posedge phy_rx_clk)begin
                if(rx_data_last_d5 & rx_crc == rx_crc_dout)
                    rx_crc_check <= 1'b1;
                else if(rx_data_last_d5 & rx_crc != rx_crc_dout)
                    rx_crc_check <= 1'b0;
                else
                    rx_crc_check <= rx_crc_check;
            end
        end
    endgenerate

//============================= frame_fifo write in ================================================

    always@(posedge phy_rx_clk)begin
        if(gmii_rx_data_vld_d4 & rx_cnt > 19 & rx_cnt < 22)
            rx_frame_type <= {rx_frame_type[7:0] , gmii_rx_data_d4};
        else
            rx_frame_type <= rx_frame_type;
    end

    always@(posedge phy_rx_clk)begin
        if(rx_preamble_check & rx_sfd_check & rx_target_mac_check & rx_data_last_d6)begin
            frame_din <= {rx_crc_check , rx_frame_type};
            frame_wren <= 1'b1;
        end else begin
            frame_din <= frame_din;
            frame_wren <= 1'b0;
        end
    end

//============================== data_fifo write in ==================================================

    always@(posedge phy_rx_clk)begin
        if(rx_preamble_check & rx_sfd_check & rx_target_mac_check & rx_cnt == 'd21)
            rx_wr_vld <= 1'b1;
        else if(rx_data_last)
            rx_wr_vld <= 1'b0;
        else
            rx_wr_vld <= rx_wr_vld;
    end

    always@(posedge phy_rx_clk)begin
        data_wren <= rx_wr_vld;
        data_din <= {rx_data_last , gmii_rx_data_d4};
    end

//================================ FSM ==============================================================


    always@(posedge clk)begin
        if(reset)
            cur_state <= RX_IDLE;
        else
            cur_state <= nex_state;
    end

    always@(*)begin
        if(reset)
            nex_state <= RX_IDLE;
        else begin
            case(cur_state)
                RX_IDLE: nex_state <= (~frame_rdempty) ? RX_PRE : cur_state;
                RX_PRE : nex_state <= RX_DATA;
                RX_DATA: nex_state <= (data_rden & data_dout[8]) ? RX_END : cur_state;
                RX_END : nex_state <= RX_IDLE;
                default: nex_state <= RX_IDLE;
            endcase
        end
    end

//============================== frame_fifo read out ================================================

    always@(*)begin
        frame_rden <= (cur_state == RX_PRE);
    end

    always@(posedge clk)begin
        if(frame_rden)begin
            mac_rx_frame_type <= frame_dout[15:0];
            frame_fifo_crc    <= frame_dout[16];
        end else begin
            mac_rx_frame_type <= mac_rx_frame_type;
            frame_fifo_crc <= frame_fifo_crc;
        end
    end

//=============================== data_fifo read out ===============================================

    always@(posedge clk)begin
        if(cur_state == RX_PRE)
            data_rden <= 1'b1;
        else if(data_rden & data_dout[8] & cur_state == RX_DATA)
            data_rden <= 1'b0;
        else
            data_rden <= data_rden;
    end

    always@(posedge clk)begin
        if(data_rden & frame_fifo_crc)begin
            mac_rx_data_vld <= 1'b1;
            mac_rx_data_last <= data_dout[8];
            mac_rx_data <= data_dout[7:0];
        end else begin
            mac_rx_data_vld <= 1'b0;
            mac_rx_data_last <= 1'b0;
            mac_rx_data <= 'd0;
        end
    end

//============================== FIFO inst ========================================================

    frame_fifo_w17xd16 u_rx_frame_fifo (
        .rst                (phy_rx_reset   ),  // input wire rst
        .wr_clk             (phy_rx_clk     ),  // input wire wr_clk
        .rd_clk             (clk            ),  // input wire rd_clk
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
        .rst                (phy_rx_reset   ),      // input wire rst
        .wr_clk             (phy_rx_clk     ),      // input wire wr_clk
        .rd_clk             (clk            ),      // input wire rd_clk
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
