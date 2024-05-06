-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Mon May  6 16:36:08 2024
-- Host        : else running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/software_download_zc/Vivado/vivado_my_projects_2/IC/vivado_ddrc_484_2_ddr_eth/ddrc_484_2.srcs/sources_1/ip/ddr_to_eth_fifo_w9xd4096/ddr_to_eth_fifo_w9xd4096_stub.vhdl
-- Design      : ddr_to_eth_fifo_w9xd4096
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ddr_to_eth_fifo_w9xd4096 is
  Port ( 
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 8 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 8 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    data_count : out STD_LOGIC_VECTOR ( 12 downto 0 )
  );

end ddr_to_eth_fifo_w9xd4096;

architecture stub of ddr_to_eth_fifo_w9xd4096 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,srst,din[8:0],wr_en,rd_en,dout[8:0],full,empty,data_count[12:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_2_3,Vivado 2018.3";
begin
end;
