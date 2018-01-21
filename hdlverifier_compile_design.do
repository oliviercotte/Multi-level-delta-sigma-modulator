# Create design library
vlib work
# Create and open project
project new . compile_project
project open compile_project
# Add source files to project
project addfile "C:/Newcomputer/dsm_modelsim/dsm_pkg.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/cordic_types.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/channel_filter.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/cordic_core.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/ddfs_ctrl.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/halfband_1.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/halfband_2.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/halfband_3.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/halfband_4.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/MATLAB_Function.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/my_clock_ip.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/phase_accumulator.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/phase_generator.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/Subsystem.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/top_fpga.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/top_fpga_tb.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/top_level_ddfs.vhd"
project addfile "C:/Newcomputer/dsm_modelsim/trigonometric_fct_generator.vhd"
# Calculate compilation order
project calculateorder
set compcmd [project compileall -n]
# Close project
project close
# Compile all files and report error
if [catch {eval $compcmd}] {
    exit -code 1
}
