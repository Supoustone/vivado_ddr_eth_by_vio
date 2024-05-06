onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ddr_to_eth_fifo_w9xd4096 -L xil_defaultlib -L xpm -L fifo_generator_v13_2_3 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ddr_to_eth_fifo_w9xd4096 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ddr_to_eth_fifo_w9xd4096.udo}

run -all

endsim

quit -force
