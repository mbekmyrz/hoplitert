# create ip project with part name
create_project rtl_kernel ./rtl_kernel -part xc7z020clg400-1

# add design sources into project
add_files -norecurse \
       {                        \
        ../rtl/counter.v        \
        ../rtl/mux.v            \
        ../rtl/pe.v             \
        ../rtl/pewrap.v         \
        ../rtl/switch.v         \
        ../rtl/torus.v          \
        ../rtl/include.h        \
       }

update_compile_order -fileset sources_1
# set_property top torus [current_fileset]

# create IP packaging project
ipx::package_project -root_dir ./rtl_kernel_ip -vendor user.org -library user -taxonomy /UserIP -import_files -set_current true

##################################### Step 2: Inference clock, reset, AXI interfaces and associate them with clock

# inference clock and reset signals
ipx::infer_bus_interface ap_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface ap_rst_n xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

# associate AXIS interface with clock
ipx::associate_bus_interfaces -busif axis_m         -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif axis_s         -clock ap_clk [ipx::current_core]

# associate reset signal with clock
ipx::associate_bus_interfaces -clock ap_clk -reset ap_rst_n [ipx::current_core]

#### Step 4: Package Vivado IP and generate Vitis kernel file

# Set required property for Vitis kernel
set_property sdx_kernel true [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]
set_property ipi_drc {ignore_freq_hz true} [ipx::current_core]
set_property vitis_drc {ctrl_protocol ap_ctrl_none} [ipx::current_core]

# Packaging Vivado IP
ipx::save_core [ipx::current_core]

# Generate Vitis Kernel from Vivado IP
package_xo -force -xo_path ./torus.xo -kernel_name torus -ctrl_protocol ap_ctrl_none -ip_directory ./rtl_kernel_ip -output_kernel_xml ./torus.xml
close_project -delete
