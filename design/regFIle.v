// Description: Register file module for EE577b Project Phase 2 Processor Design
// Author: Sihao Chen
// Create Date: Oct.21.2021
// Module Name: regFile

module regFile(reg1, reg2, Wreg, Wdata, Wreg_en, reg1_out, reg2_out, ppp, clk, rst);
	input [0:4] reg1, reg2; // read address
	input [0:4] Wreg;// write address
	input [0:63] Wdata; // write back data
	input Wreg_en; //write enable signal
	input clk, rst;
	input [0:2] ppp;// selective write back
	output [0:63] reg1_out, reg2_out; // read data

	reg [0:63] regfile_ram [0:31];

	//read asynchronously
	assign reg1_out = (reg1 == 0) ? 0 : regfile_ram[reg1];
	assign reg2_out = (reg2 == 0) ? 0 : regfile_ram[reg2];

	//write synchronously, only write when enable asserted and address is not 0, since location 0 cannot be modified
	always@(posedge clk) begin
		//if (rst) begin
		//	regfile_ram <= 0;
		//end else begin
			if ((Wreg != 0) & Wreg_en) begin 
				case(ppp)
					3'b000 : regfile_ram[Wreg] <= Wdata;
					3'b001 : regfile_ram[Wreg][0:31] <= Wdata[0:31];
					3'b010 : regfile_ram[Wreg][32:63] <= Wdata[32:63];
					3'b011 : 
						begin
							regfile_ram[Wreg][0:7] <= Wdata[0:7];
							regfile_ram[Wreg][16:23] <= Wdata[16:23];
							regfile_ram[Wreg][32:39] <= Wdata[32:39];
							regfile_ram[Wreg][48:55] <= Wdata[48:55];
						end
					3'b100 : 
						begin
							regfile_ram[Wreg][6:7] <= Wdata[0:3];
							regfile_ram[Wreg][24:31] <= Wdata[24:31];
							regfile_ram[Wreg][40:47] <= Wdata[40:47];
							regfile_ram[Wreg][56:63] <= Wdata[56:63];
						end
					default : regfile_ram[Wreg] <= Wdata;
				endcase
			end else regfile_ram[Wreg] <= regfile_ram[Wreg];
		//end
	end
  ///////// ********** ///////// selective write back need to be confirmed
endmodule // regFile