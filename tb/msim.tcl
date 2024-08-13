vlib work
vlog dut_tb.v torus_tb.v pewrap_tb.v ../rtl/switch.v ../rtl/mux.v ../rtl/counter.v pe_tb.sv
vsim -novopt dut_tb
log -r /*
add wave sim:/dut_tb/*
config wave -signalnamewidth 1

run 10250 ns
