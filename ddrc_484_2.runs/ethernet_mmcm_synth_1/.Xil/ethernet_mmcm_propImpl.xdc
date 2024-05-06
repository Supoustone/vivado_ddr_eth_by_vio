set_property SRC_FILE_INFO {cfile:d:/software_download_zc/Vivado/vivado_my_projects_2/IC/vivado_ddrc_484_2_ddr_eth/ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm.xdc rfile:../../../ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in_50m]] 0.2
