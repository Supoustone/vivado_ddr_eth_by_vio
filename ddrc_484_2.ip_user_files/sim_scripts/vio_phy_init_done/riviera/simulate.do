onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+vio_phy_init_done -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.vio_phy_init_done xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {vio_phy_init_done.udo}

run -all

endsim

quit -force
