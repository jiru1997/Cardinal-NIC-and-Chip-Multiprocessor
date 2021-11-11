// Description: PC module for EE577b Project Phase 2 Processor Design
// Author: Sihao Chen
// Create Date: Oct.21.2021
// Module Name: PC

module PC(PCin, PCout, clk, rst, stall);
	input [0:31] PCin;
	input clk, rst, stall;
	output reg [0:31] PCout;

	always@(posedge clk) begin
		if (rst) PCout <= 0;
		else if (stall) PCout <= PCout;
		else PCout <= PCin;
	end 


endmodule