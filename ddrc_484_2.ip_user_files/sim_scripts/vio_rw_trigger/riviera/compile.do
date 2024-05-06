vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ddrc_484_2.srcs/sources_1/ip/vio_rw_trigger/hdl/verilog" "+incdir+../../../../ddrc_484_2.srcs/sources_1/ip/vio_rw_trigger/hdl" \
"../../../../ddrc_484_2.srcs/sources_1/ip/vio_rw_trigger/sim/vio_rw_trigger.v" \


vlog -work xil_defaultlib \
"glbl.v"

