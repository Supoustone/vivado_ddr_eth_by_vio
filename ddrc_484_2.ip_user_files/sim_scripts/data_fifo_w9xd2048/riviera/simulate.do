onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+data_fifo_w9xd2048 -L xil_defaultlib -L xpm -L fifo_generator_v13_2_3 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.data_fifo_w9xd2048 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {data_fifo_w9xd2048.udo}

run -all

endsim

quit -force
