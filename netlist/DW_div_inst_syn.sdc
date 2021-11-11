###################################################################

# Created by write_sdc on Sat Oct  2 11:32:49 2021

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
set_max_delay 5  -to [get_ports {quotient_b[7]}]
set_max_delay 5  -to [get_ports {quotient_b[6]}]
set_max_delay 5  -to [get_ports {quotient_b[5]}]
set_max_delay 5  -to [get_ports {quotient_b[4]}]
set_max_delay 5  -to [get_ports {quotient_b[3]}]
set_max_delay 5  -to [get_ports {quotient_b[2]}]
set_max_delay 5  -to [get_ports {quotient_b[1]}]
set_max_delay 5  -to [get_ports {quotient_b[0]}]
set_max_delay 5  -to [get_ports {remainder_b[7]}]
set_max_delay 5  -to [get_ports {remainder_b[6]}]
set_max_delay 5  -to [get_ports {remainder_b[5]}]
set_max_delay 5  -to [get_ports {remainder_b[4]}]
set_max_delay 5  -to [get_ports {remainder_b[3]}]
set_max_delay 5  -to [get_ports {remainder_b[2]}]
set_max_delay 5  -to [get_ports {remainder_b[1]}]
set_max_delay 5  -to [get_ports {remainder_b[0]}]
set_max_delay 5  -from [list [get_ports {di_A[7]}] [get_ports {di_A[6]}] [get_ports {di_A[5]}] \
[get_ports {di_A[4]}] [get_ports {di_A[3]}] [get_ports {di_A[2]}] [get_ports   \
{di_A[1]}] [get_ports {di_A[0]}] [get_ports {di_B[7]}] [get_ports {di_B[6]}]   \
[get_ports {di_B[5]}] [get_ports {di_B[4]}] [get_ports {di_B[3]}] [get_ports   \
{di_B[2]}] [get_ports {di_B[1]}] [get_ports {di_B[0]}]]
