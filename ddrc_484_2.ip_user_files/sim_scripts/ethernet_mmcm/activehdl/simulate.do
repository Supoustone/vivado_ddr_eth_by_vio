onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ethernet_mmcm -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ethernet_mmcm xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ethernet_mmcm.udo}

run -all

endsim

quit -force
