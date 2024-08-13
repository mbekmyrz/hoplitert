python3 pe_gen_mem.py --x_dim=$1 --y_dim=$2 --mem_d=$5
xvlog dut_tb.v torus_tb.v pewrap_tb.v ../rtl/switch.v ../rtl/mux.v ../rtl/counter.v
xvlog -d TERMINAL -sv pe_tb.sv
xelab -debug typical dut_tb --generic_top "X_DIM=$1" --generic_top "Y_DIM=$2" --generic_top "MAX_RATE=$3" --generic_top "MAX_TOKEN=$4" --generic_top "MEM_D=$5" -s dut_tb

if (( $6 > 0 )) then
    echo "set GUI 1" > args.tcl
    #echo "set var $2" >> args.tcl
    xsim dut_tb -gui -t xsim.tcl
else
    echo "set GUI 0" > args.tcl
    xsim dut_tb -t xsim.tcl > torus_sim.log
	grep -E '^(Send|Received)' torus_sim.log  > mem/network.txt
fi

