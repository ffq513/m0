onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ahblite_axi_bridge_1 -L xil_defaultlib -L xpm -L ahblite_axi_bridge_v3_0_13 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ahblite_axi_bridge_1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ahblite_axi_bridge_1.udo}

run -all

endsim

quit -force
