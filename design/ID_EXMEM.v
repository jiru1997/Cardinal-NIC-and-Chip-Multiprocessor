// Description: ID/EXMEM stage register including decoder module for EE577b Project Phase 2 Processor Design
// Author: Sihao Chen
// Create Date: Oct.21.2021
// Module Name: ID_EXMEM

module ID_EXMEM(ID_reg1_out, ID_reg2_out, ID_reg1, ID_reg2, ID_Wreg, ID_immediate, ID_Wmem_en, ID_mem_en, ID_Wreg_en, ID_instr_type, ID_opcode, ID_ww, ID_ppp, 
				EXMEM_reg1_out, EXMEM_reg2_out, EXMEM_reg1, EXMEM_reg2, EXMEM_Wreg, EXMEM_immediate, EXMEM_Wmem_en, EXMEM_mem_en, EXMEM_Wreg_en, EXMEM_instr_type, EXMEM_opcode, EXMEM_ww, EXMEM_ppp, 
				clk, rst);

	input clk, rst;
	input [0:63] ID_reg1_out, ID_reg2_out; //data read from register file, will be needed by alu
	input [0:4] ID_reg1, ID_reg2, ID_Wreg; //reg addresses are still needed for determining dependency 
	input [0:15] ID_immediate; //immediate is needed for memory operation
	input ID_Wmem_en, ID_Wreg_en, ID_mem_en; // write memory enable and write back register file enable
	input [0:5] ID_instr_type, ID_opcode; // instruction type is needed for dependency determination, opcode is actually not needed
	input [0:1] ID_ww; // control signal is needed for operand bits width selection
	input [0:2] ID_ppp; // control signal is needed for write back bits selection

	output reg [0:63] EXMEM_reg1_out, EXMEM_reg2_out;
	output reg [0:4] EXMEM_reg1, EXMEM_reg2, EXMEM_Wreg;
	output reg [0:15] EXMEM_immediate;
	output reg EXMEM_Wmem_en, EXMEM_Wreg_en, EXMEM_mem_en;
	output reg [0:5] EXMEM_instr_type, EXMEM_opcode;
	output reg [0:1] EXMEM_ww;
	output reg [0:2] EXMEM_ppp;

	always@(posedge clk) begin
		if (rst) begin
			EXMEM_reg1_out <= 0;
			EXMEM_reg2_out <= 0;
			EXMEM_reg1 <= 0;
			EXMEM_reg2 <= 0;
			EXMEM_Wreg <= 0;
			EXMEM_immediate <= 0;
			EXMEM_Wmem_en <= 0;
			EXMEM_mem_en <= 0;
			EXMEM_Wreg_en <= 0;
			EXMEM_instr_type <= 0;
			EXMEM_opcode <= 0;
			EXMEM_ww <= 0;
			EXMEM_ppp <= 0;
		end else begin
			EXMEM_reg1_out <= ID_reg1_out;
			EXMEM_reg2_out <= ID_reg2_out;
			EXMEM_reg1 <= ID_reg1;
			EXMEM_reg2 <= ID_reg2;
			EXMEM_Wreg <= ID_Wreg;
			EXMEM_immediate <= ID_immediate;
			EXMEM_Wmem_en <= ID_Wmem_en;
			EXMEM_mem_en <= ID_mem_en;
			EXMEM_Wreg_en <= ID_Wreg_en;
			EXMEM_instr_type <= ID_instr_type;
			EXMEM_opcode <= ID_opcode;
			EXMEM_ww <= ID_ww;
			EXMEM_ppp <= ID_ppp;
		end
	end

endmodule