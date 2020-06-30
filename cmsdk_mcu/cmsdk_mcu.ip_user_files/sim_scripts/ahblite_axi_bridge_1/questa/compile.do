vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm
vlib questa_lib/msim/ahblite_axi_bridge_v3_0_13

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm
vmap ahblite_axi_bridge_v3_0_13 questa_lib/msim/ahblite_axi_bridge_v3_0_13

vlog -work xil_defaultlib -64 -sv \
"C:/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work ahblite_axi_bridge_v3_0_13 -64 -93 \
"../../../ipstatic/hdl/ahblite_axi_bridge_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../ip/ahblite_axi_bridge_1/sim/ahblite_axi_bridge_1.vhd" \


vlog -work xil_defaultlib \
"glbl.v"

