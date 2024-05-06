vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../ipstatic" \
"D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic" \
"../../../../ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm_clk_wiz.v" \
"../../../../ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm.v" \

vlog -work xil_defaultlib \
"glbl.v"

