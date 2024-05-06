-makelib ies_lib/xil_defaultlib -sv \
  "D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/software_download_zc/Vivado/download/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm_clk_wiz.v" \
  "../../../../ddrc_484_2.srcs/sources_1/ip/ethernet_mmcm/ethernet_mmcm.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

