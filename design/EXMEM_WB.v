// Description: EXMEM/WB stage register including decoder module for EE577b Project Phase 2 Processor Design
// Author: Sihao Chen
// Create date:Oct.21.2021
// Module name: EXMEM_WB

module EXMEM_WB(EXMEM_ALUresult, EXMEM_MEMout, EXMEM_Wreg, EXMEM_Wreg_en, EXMEM_instr_type, EXMEM_opcode, EXMEM_ppp,
				WB_ALUresult, WB_MEMout, WB_Wreg, WB_Wreg_en, WB_instr_type, WB_opcode, WB_ppp,
				clk, rst);
	input clk, rst;
	input [0:63] EXMEM_ALUresult, EXMEM_MEMout; //ALU result from EXMEM stage need to be writed back
	input [0:4] EXMEM_Wreg; // register file write back address
	input EXMEM_Wreg_en; // register file write back enable signal
	input [0:5] EXMEM_instr_type, EXMEM_opcode; // instruction type and opcode, put here for futher debugging
	input [0:2] EXMEM_ppp;

	output reg [0:63] WB_ALUresult, WB_MEMout;
	output reg [0:4] WB_Wreg;
	output reg WB_Wreg_en;
	output reg [0:5] WB_instr_type, WB_opcode;
	output reg [0:2] WB_ppp;

	always@(posedge clk) begin
		if (rst) begin
			WB_ALUresult <= 0;
			WB_MEMout <= 0;
			WB_Wreg <= 0;
			WB_Wreg_en <= 0;
			WB_instr_type <= 0;
			WB_opcode <= 0;
			WB_ppp <= 0;
		end else begin
			WB_ALUresult <= EXMEM_ALUresult;
			WB_MEMout <= EXMEM_MEMout;
			WB_Wreg <= EXMEM_Wreg;
			WB_Wreg_en <= EXMEM_Wreg_en;
			WB_instr_type <= EXMEM_instr_type;
			WB_opcode <= EXMEM_opcode;
			WB_ppp <= EXMEM_ppp;
		end
	end

endmodule