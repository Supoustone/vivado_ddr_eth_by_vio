vlib work
vlib activehdl

vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ddrc_484_2.srcs/sources_1/ip/vio_phy_init_done/hdl/verilog" "+incdir+../../../../ddrc_484_2.srcs/sources_1/ip/vio_phy_init_done/hdl" \
"../../../../ddrc_484_2.srcs/sources_1/ip/vio_phy_init_done/sim/vio_phy_init_done.v" \


vlog -work xil_defaultlib \
"glbl.v"

