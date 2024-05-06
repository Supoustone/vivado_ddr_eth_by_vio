onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ethernet_mmcm_opt

do {wave.do}

view wave
view structure
view signals

do {ethernet_mmcm.udo}

run -all

quit -force
