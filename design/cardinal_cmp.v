// Description: cmp module for EE577b Project Phase 2 Processor Design
// Author: Sihao Chen
// Create Date: Oct.21.2021
// Module Name: cardinal_cmp

module cardinal_cmp(clk, reset, 
					node0_inst_in, node0_d_in, node0_pc_out, node0_d_out, node0_addr_out, node0_memWrEn, node0_memEn,
					node1_inst_in, node1_d_in, node1_pc_out, node1_d_out, node1_addr_out, node1_memWrEn, node1_memEn,
					node2_inst_in, node2_d_in, node2_pc_out, node2_d_out, node2_addr_out, node2_memWrEn, node2_memEn,
					node3_inst_in, node3_d_in, node3_pc_out, node3_d_out, node3_addr_out, node3_memWrEn, node3_memEn,
					);
	input clk, reset;
	input [0:31] node0_inst_in, node1_inst_in, node2_inst_in, node3_inst_in;
	input [0:63] node0_d_in, node1_d_in, node2_d_in, node3_d_in;
	output [0:31] node0_pc_out, node1_pc_out, node2_pc_out, node3_pc_out, node0_addr_out, node1_addr_out, node2_addr_out, node3_addr_out;
	output [0:63] node0_d_out, node1_d_out, node2_d_out, node3_d_out;
	output node0_memWrEn, node0_memEn, node1_memWrEn, node1_memEn, node2_memWrEn, node2_memEn, node3_memWrEn, node3_memEn;

	wire [0:63] d_nic2cpu0, d_nic2cpu1, d_nic2cpu2, d_nic2cpu3, d_cpu2nic0, d_cpu2nic1, d_cpu2nic2, d_cpu2nic3;
	wire [0:1] addr0, addr1, addr2, addr3;
	wire nicEn0, nicEn1, nicEn2, nicEn3, nicWrEn0, nicWrEn1, nicWrEn2, nicWrEn3;
	integer fd;

    cpu cpu0(.clk(clk), 
    		 .rst(reset),
    		 .pc_out(node0_pc_out), 
    		 .inst_in(node0_inst_in), 
    		 .d_in(node0_d_in), 
    		 .d_out(node0_d_out), 
    		 .addr_out(node0_addr_out), 
    		 .memWrEn(node0_memWrEn), 
    		 .memEn(node0_memEn),
    		 .addr_nic(addr0), 
    		 .d_out_nic(d_cpu2nic0), 
    		 .d_in_nic(d_nic2cpu0), 
    		 .nicEn(nicEn0), 
    		 .nicWrEn(nicWrEn0)
    		 );

    cpu cpu1(.clk(clk), 
    		 .rst(reset),
    		 .pc_out(node1_pc_out), 
    		 .inst_in(node1_inst_in), 
    		 .d_in(node1_d_in), 
    		 .d_out(node1_d_out), 
    		 .addr_out(node1_addr_out), 
    		 .memWrEn(node1_memWrEn), 
    		 .memEn(node1_memEn),
    		 .addr_nic(addr1), 
    		 .d_out_nic(d_cpu2nic1), 
    		 .d_in_nic(d_nic2cpu1), 
    		 .nicEn(nicEn1), 
    		 .nicWrEn(nicWrEn1)
    		 );

    cpu cpu2(.clk(clk), 
    		 .rst(reset),
    		 .pc_out(node2_pc_out), 
    		 .inst_in(node2_inst_in), 
    		 .d_in(node2_d_in), 
    		 .d_out(node2_d_out), 
    		 .addr_out(node2_addr_out), 
    		 .memWrEn(node2_memWrEn), 
    		 .memEn(node2_memEn),
    		 .addr_nic(addr2), 
    		 .d_out_nic(d_cpu2nic2), 
    		 .d_in_nic(d_nic2cpu2), 
    		 .nicEn(nicEn2), 
    		 .nicWrEn(nicWrEn2)
    		 );

    cpu cpu3(.clk(clk), 
    		 .rst(reset),
    		 .pc_out(node3_pc_out), 
    		 .inst_in(node3_inst_in), 
    		 .d_in(node3_d_in), 
    		 .d_out(node3_d_out), 
    		 .addr_out(node3_addr_out), 
    		 .memWrEn(node3_memWrEn), 
    		 .memEn(node3_memEn),
    		 .addr_nic(addr3), 
    		 .d_out_nic(d_cpu2nic3), 
    		 .d_in_nic(d_nic2cpu3), 
    		 .nicEn(nicEn3), 
    		 .nicWrEn(nicWrEn3)
    		 );

    nic_router nr(.clk(clk),
    			  .reset(reset),
    			  .addr_nic0(addr0),
    			  .d_in0(d_cpu2nic0),
    			  .nicEn0(nicEn0),
    			  .nicWrEn0(nicWrEn0),
    			  .d_out0(d_nic2cpu0),
    			  .addr_nic1(addr1),
    			  .d_in1(d_cpu2nic1),
    			  .nicEn1(nicEn1),
    			  .nicWrEn1(nicWrEn1),
    			  .d_out1(d_nic2cpu1),
    			  .addr_nic2(addr2),
    			  .d_in2(d_cpu2nic2),
    			  .nicEn2(nicEn2),
    			  .nicWrEn2(nicWrEn2),
    			  .d_out2(d_nic2cpu2),
    			  .addr_nic3(addr3),
    			  .d_in3(d_cpu2nic3),
    			  .nicEn3(nicEn3),
    			  .nicWrEn3(nicWrEn3),
    			  .d_out3(d_nic2cpu3)
    	);

initial begin
	fd = $fopen("nic2cpu0.dump","w");
	$fmonitor(fd,"time = %t, clk = %b, nic2cpu = %h, addr = %h",$realtime, clk, d_nic2cpu0, addr0);
	#10000;
	$fclose(fd);
end

endmodule 

