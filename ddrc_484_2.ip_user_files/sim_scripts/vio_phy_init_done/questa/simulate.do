onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib vio_phy_init_done_opt

do {wave.do}

view wave
view structure
view signals

do {vio_phy_init_done.udo}

run -all

quit -force
