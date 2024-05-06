onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib data_fifo_w9xd2048_opt

do {wave.do}

view wave
view structure
view signals

do {data_fifo_w9xd2048.udo}

run -all

quit -force
