vlib work
vlog tb_EVM.v
vsim tb
add wave -position insertpoint sim:/tb/dut/*
run -all
