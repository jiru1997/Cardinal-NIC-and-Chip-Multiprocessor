######################################################################
#
# EE-577b 2020 FALL
# : DesignCompiler synthesis script
#   modified by Linyi Hong
#
# use this script as a template for synthesizing combinational logic
#
######################################################################

# Setting variable for design_name. (top module name)
set design_name $env(DESIGN_NAME);

## For NCSUFreePDK45nm library
set search_path [ list . \
                  /home/scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files ]
set target_library { gscl45nm.db }
set synthetic_library [list dw_foundation.sldb standard.sldb ]
set link_library [list * gscl45nm.db dw_foundation.sldb standard.sldb]


# Reading source verilog file.
# copy your verilog file into ./src/ before synthesis.
read_verilog ./src/${design_name}.v ;
read_verilog ./src/cardinal_router.v ;
read_verilog ./src/ALU.v;
read_verilog ./src/cardinal_cpu.v;
read_verilog ./src/cardinal_nic.v;
read_verilog ./src/cardinal_ring.v;
read_verilog ./src/ccw_input.v;
read_verilog ./src/ccw_output.v;
read_verilog ./src/cw_input.v;
read_verilog ./src/cw_output.v;
read_verilog ./src/EXMEM_WB.v;
read_verilog ./src/HDU.v;
read_verilog ./src/ID_EXMEM.v;
read_verilog ./src/IF_ID.v;
read_verilog ./src/NIC_router.v;
read_verilog ./src/PC.v;
read_verilog ./src/pe_input.v;
read_verilog ./src/pe_output.v;
read_verilog ./src/regFile.v;

# Inside of read_verilog, for design with parameters, use these two lines below: analyze + elaborate
analyze -format verilog /usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_div.v
elaborate DW_div

analyze -format verilog /usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_square.v
elaborate DW_square

analyze -format verilog /usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_sqrt.v
elaborate DW_sqrt

analyze -format verilog ./src/cardinal_router.v
elaborate cardinal_router
analyze -format verilog ./src/cw_input.v
elaborate cw_input
analyze -format verilog ./src/ccw_input.v
elaborate ccw_input
analyze -format verilog ./src/pe_input.v
elaborate pe_input
analyze -format verilog ./src/cw_output.v
elaborate cw_output
analyze -format verilog ./src/ccw_output.v
elaborate ccw_output
analyze -format verilog ./src/pe_output.v
elaborate pe_output
analyze -format verilog ./src/cardinal_ring.v
elaborate cardinal_ring
analyze -format verilog ./src/cardinal_nic.v
elaborate cardinal_nic

# Setting $design_name as current working design.
# Use this command before setting any constraints.
current_design $design_name ;

# If you have multiple instances of the same module,
# use this so that DesignCompiler optimizes each instance separately.
uniquify ;

# Linking your design into the cells in standard cell libraries.
# This command checks whether your design can be compiled
link ;

create_clock -name clk -period 4.0 -waveform [list 0 2] [get_ports clk]

# start with a large clock period e.g 100
# then try shorter period until find minimum period


# Setting timing constraints for combinational logic.
# Specifying maximum delay from inputs to outputs
# set_max_delay 5.0 -to [all_outputs];
# set_max_delay 5.0 -from [all_inputs];

set_input_delay -max 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]];
set_output_delay -max 1.0 -clock clk [all_outputs];

set_clock_latency -source 0.5 [get_ports clk];

# Perforing synthesis and optimization on the current_design.
compile ;

# For better synthesis result, use "compile_ultra" command.
# compile_ultra is doing automatic ungrouping during optimization,
# therefore sometimes it's hard to figure out the critical path 
# from the synthesized netlist.
# So, use "compile" command for now.

# Writing the synthesis result into Synopsys db format.
# You can read the saved db file into DesignCompiler later using
# "read_db" command for further analysis (timing, area...).
#write -xg_force_db -format db -hierarchy -out db/$design_name.db ;

# Generating timing and are report of the synthezied design.
report_timing > report/$design_name.timing ;
report_area > report/$design_name.area ;
report_power > report/$design_name.power ;

# Writing synthesized gate-level verilog netlist.
# This verilog netlist will be used for post-synthesis gate-level simulation.
change_names -rules verilog -hierarchy ;
write -format verilog -hierarchy -out netlist/${design_name}_syn.v ;

# Writing Standard Delay Format (SDF) back-annotation file.
# This delay information can be used for post-synthesis simulation.
write_sdf netlist/${design_name}_syn.sdf;
write_sdc netlist/${design_name}_syn.sdc

