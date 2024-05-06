onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib vio_rw_trigger_opt

do {wave.do}

view wave
view structure
view signals

do {vio_rw_trigger.udo}

run -all

quit -force
