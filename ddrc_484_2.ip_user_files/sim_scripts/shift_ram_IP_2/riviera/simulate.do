onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+shift_ram_IP_2 -L xil_defaultlib -L xpm -L xbip_utils_v3_0_9 -L c_reg_fd_v12_0_5 -L c_mux_bit_v12_0_5 -L c_shift_ram_v12_0_12 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.shift_ram_IP_2 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {shift_ram_IP_2.udo}

run -all

endsim

quit -force
