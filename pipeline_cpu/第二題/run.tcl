set DESIGN Pipelined_CPU

#read RTL code
read_file -format verilog ./ -autoread -top $DESIGN
#read_file -format verilog ./$DESIGN\.v
current_design $DESIGN
link

#operating conditions and boundary conditions#
set cycle 10

create_clock -period $cycle [get_ports  clk_i]
set_dont_touch_network      [all_clocks]
set_fix_hold                [all_clocks]
set_clock_uncertainty  0.1  [all_clocks]
set_clock_latency      0.5  [all_clocks]
set_ideal_network           [get_ports clk_i]

#Don't touch the basic env setting as below
set_input_delay  1     -clock clk_i [remove_from_collection [all_inputs] [get_ports clk_i]]
#set_output_delay 5     -clock clk_i [all_outputs] 
#set_load         1     [all_outputs]
set_drive        1     [all_inputs]

set_operating_conditions -max_library slow -max slow -min_library fast -mib fast
set_wire_load_model -name tsmc13_wl10 -library slow                        

set_max_fanout 6 [all_inputs]

#=========================

# Optimization

#========================
uniquify
set_fix_multiple_port_nets -all -buffer_constants
set_fix_hold [all_clocks]
set case_analysis_with_logic_constants true
compile

set hdlin_translate_off_skip_text "TRUE"
set edifout_netlist_only "TRUE"
set verilogout_no_tri true

set hdlin_enable_presto_for_vhdl "TRUE"
set sh_enable_line_editing true
set sh_line_editing_mode emacs
history keep 100
alias h history

set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
define_name_rules name_rule -allowed {a-z  0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}


#=================================
#Ourput Reports
#=================================
report_design > Report/$DESIGN\.design
report_port >  Report/$DESIGN\.port
report_net >  Report/$DESIGN\.net
report_timing_requirements >  Report/$DESIGN\.timing_requirements
report_constraint >  Report/$DESIGN\.constraint
report_timing >  Report/$DESIGN\.timing
report_area >  Report/$DESIGN\.area
report_resource >  Report/$DESIGN\.resource

#=================================
#Ourput Reports
#=================================
set verilogout_higher_design_first true
write -format verilog -output Netlist/$DESIGN\_syn.v -hierarchy
write_sdf -version 2.1 -context verilog -load_delay cell Netlist/$DESIGN\_syn.sdf
write_sdc Netlist/$DESIGN\_syn.sdc
write_file -format ddc -hierarchy -output Netlist/$DESIGN\_syn.ddc

#==================
exit
