onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ddr_to_eth_fifo_w9xd4096_opt

do {wave.do}

view wave
view structure
view signals

do {ddr_to_eth_fifo_w9xd4096.udo}

run -all

quit -force
