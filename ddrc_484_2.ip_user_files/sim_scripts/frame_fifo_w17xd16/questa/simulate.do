onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib frame_fifo_w17xd16_opt

do {wave.do}

view wave
view structure
view signals

do {frame_fifo_w17xd16.udo}

run -all

quit -force
