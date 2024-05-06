vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../ddrc_484_2.srcs/sources_1/ip/vio_phy_init_done/hdl/verilog" "+incdir+../../../../ddrc_484_2.srcs/sources_1/ip/vio_phy_init_done/hdl" \
"../../../../ddrc_484_2.srcs/sources_1/ip/vio_phy_init_done/sim/vio_phy_init_done.v" \


vlog -work xil_defaultlib \
"glbl.v"

