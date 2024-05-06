// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon May  6 17:37:50 2024
// Host        : else running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/software_download_zc/Vivado/vivado_my_projects_2/IC/vivado_ddrc_484_2_ddr_eth/ddrc_484_2.srcs/sources_1/ip/shift_ram_IP/shift_ram_IP_stub.v
// Design      : shift_ram_IP
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "c_shift_ram_v12_0_12,Vivado 2018.3" *)
module shift_ram_IP(A, D, CLK, Q)
/* synthesis syn_black_box black_box_pad_pin="A[5:0],D[7:0],CLK,Q[7:0]" */;
  input [5:0]A;
  input [7:0]D;
  input CLK;
  output [7:0]Q;
endmodule
