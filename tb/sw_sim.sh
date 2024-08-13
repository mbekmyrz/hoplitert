python3 sw_gen_mem.py
xvlog switch_tb.v ../rtl/switch.v ../rtl/mux.v
xelab -debug typical switch_tb -s switch_tb

if (( $1 > 0 )) then
    echo "set GUI 1" > args.tcl
    #echo "set var $2" >> args.tcl
    xsim switch_tb -gui -t xsim.tcl
else
    echo "set GUI 0" > args.tcl
    xsim switch_tb -t xsim.tcl
fi

#remove first 6 lines
cd mem && tail -n +7 sw_out.mem > temp.mem && mv temp.mem sw_out.mem
