vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../ipstatic" \
"D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" \
"../../../../ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm_clk_wiz.v" \
"../../../../ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm.v" \

vlog -work xil_defaultlib \
"glbl.v"

