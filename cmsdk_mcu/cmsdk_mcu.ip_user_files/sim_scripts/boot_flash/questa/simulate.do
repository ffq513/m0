onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib boot_flash_opt

do {wave.do}

view wave
view structure
view signals

do {boot_flash.udo}

run -all

quit -force
