-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Mon May  6 17:33:36 2024
-- Host        : else running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/software_download_zc/Vivado/vivado_my_projects_2/IC/vivado_ddrc_484_2_ddr_eth/ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm_stub.vhdl
-- Design      : ethernet_mmcm
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ethernet_mmcm is
  Port ( 
    clk_out_25m : out STD_LOGIC;
    clk_out_50m : out STD_LOGIC;
    clk_out_125m : out STD_LOGIC;
    clk_out_200m : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in_50m : in STD_LOGIC
  );

end ethernet_mmcm;

architecture stub of ethernet_mmcm is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out_25m,clk_out_50m,clk_out_125m,clk_out_200m,reset,locked,clk_in_50m";
begin
end;
