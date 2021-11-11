
# NC-Sim Command File
# TOOL:	ncsim(64)	15.20-s079
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
alias iprof profile
database -open -shm -into ncsim.shm ncsim.shm -default
probe -create -database ncsim.shm tb_ALU -all -depth all
probe -create -database ncsim.shm tb_ALU -all -depth all
probe -create -database ncsim.shm tb_ALU -all -depth all
probe -create -database ncsim.shm tb_ALU -all -depth all
probe -create -database ncsim.shm tb_ALU -all -depth all
probe -create -database ncsim.shm tb_ALU -all -depth all

simvision -input /home/viterbi/01/jiruxu/ee577b/prelab2/prelab2/.simvision/208734_jiruxu_viterbi-scf2_autosave.tcl.svcf
