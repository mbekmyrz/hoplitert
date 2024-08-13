create_project -force synth ./synth -part xc7z020clg400-1
# set_property board_part www.digilentinc.com:pynq-z1:part0:1.0 [current_project]
add_files ../rtl/torus.v ../rtl/pewrap.v ../rtl/pe.v ../rtl/switch.v ../rtl/mux.v ../rtl/counter.v
# read_xdc synth.xdc
# add_files synth.xdc

update_compile_order -fileset sources_1
set_property top torus [current_fileset]

set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

launch_runs synth_1 -jobs 4
wait_on_run synth_1

open_run synth_1 -name synth_1
report_utilization -file utilization.txt

