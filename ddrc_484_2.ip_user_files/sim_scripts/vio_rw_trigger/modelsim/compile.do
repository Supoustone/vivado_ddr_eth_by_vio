vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../ddrc_484_2.srcs/sources_1/ip/vio_rw_trigger/hdl/verilog" "+incdir+../../../../ddrc_484_2.srcs/sources_1/ip/vio_rw_trigger/hdl" \
"../../../../ddrc_484_2.srcs/sources_1/ip/vio_rw_trigger/sim/vio_rw_trigger.v" \


vlog -work xil_defaultlib \
"glbl.v"

