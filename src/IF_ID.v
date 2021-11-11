// Description: IF/ID stage register including decoder module for EE577b Project Phase 2 Processor Design
// Author: Sihao Chen
// Create Date: Oct.21.2021
// Module Name: IF_ID

module IF_ID(IF_Instr, ID_reg1, ID_reg2, ID_Wreg, ID_immediate, ID_Wmem_en, ID_mem_en, ID_Wreg_en, ID_Wnic_en, ID_nic_en, ID_instr_type, ID_opcode, ID_ww, ID_ppp, clk, rst, flush, stall);
	input [0:31] IF_Instr;
	input clk, rst, flush, stall;
	output reg [0:4] ID_reg1, ID_reg2, ID_Wreg; //register file read address1, read address2 and write back address
	output reg [0:15] ID_immediate; // immediate number for branch or memory operation
	output reg ID_Wmem_en, ID_mem_en, ID_Wreg_en, ID_Wnic_en, ID_nic_en; // enable signals for write memory and register file and nic 
	output reg [0:5] ID_instr_type, ID_opcode; // type indicate if the instruction is R type or M type or branch or NOP // R type instruction opcode
	output reg [0:1] ID_ww; // control field defines the width of the operands for the R type instruction
	output reg [0:2] ID_ppp; // control field support selective write mechanism


	reg [0:4] reg1, reg2, Wreg;
	reg [0:15] immediate;
	reg Wmem_en, Wreg_en, mem_en, nic_en, Wnic_en; 
	reg [0:5] instr_type, opcode;
	reg [0:1] ww;
	reg [0:2] ppp;


	always@(posedge clk) begin
		if (rst) begin 
			ID_reg1 <= 0;
			ID_reg2 <= 0;
			ID_Wreg <= 0;
			ID_immediate <= 0;
			ID_Wmem_en <= 0;
			ID_mem_en <= 0;
			ID_Wreg_en <= 0;
			ID_instr_type <= 0;
			ID_opcode <= 0;
			ID_ww <= 0;
			ID_ppp <= 0;
			ID_Wnic_en <= 0;
			ID_nic_en <= 0;
		end else if (stall) begin
			ID_reg1 <= ID_reg1;
			ID_reg2 <= ID_reg2;
			ID_Wreg <= ID_Wreg;
			ID_immediate <= ID_immediate;
			ID_Wmem_en <= ID_Wmem_en;
			ID_mem_en <= ID_mem_en;
			ID_Wreg_en <= ID_Wreg_en;
			ID_instr_type <= ID_instr_type;
			ID_opcode <= ID_opcode;
			ID_ww <= ID_ww;
			ID_ppp <= ID_ppp;
			ID_Wnic_en <= ID_Wnic_en;
			ID_nic_en <= ID_nic_en;
			/*ID_reg1 <= 0;
			ID_reg2 <= 0;
			ID_Wreg <= 0;
			ID_immediate <= 0;
			ID_Wmem_en <= 0;
			ID_mem_en <= 0;
			ID_Wreg_en <= 0;
			ID_instr_type <= 0;
			ID_opcode <= 0;
			ID_ww <= 0;
			ID_ppp <= 0;*/
		end else if (flush) begin 
			ID_reg1 <= 0;
			ID_reg2 <= 0;
			ID_Wreg <= 0;
			ID_immediate <= 0;
			ID_Wmem_en <= 0;
			ID_mem_en <= 0;
			ID_Wreg_en <= 0;
			ID_instr_type <= 0;
			ID_opcode <= 0;
			ID_ww <= 0;
			ID_ppp <= 0;
			ID_Wnic_en <= 0;
			ID_nic_en <= 0;
		end else begin
			ID_reg1 <= reg1;
			ID_reg2 <= reg2;
			ID_Wreg <= Wreg;
			ID_immediate <= immediate;
			ID_Wmem_en <= Wmem_en;
			ID_mem_en <= mem_en;
			ID_Wreg_en <= Wreg_en;
			ID_instr_type <= instr_type;
			ID_opcode <= opcode;
			ID_ww <= ww;
			ID_ppp <= ppp;
			ID_Wnic_en <= Wnic_en;
			ID_nic_en <= nic_en;
		end
	end

	always@(IF_Instr) begin
		case(IF_Instr[0:5])
			6'b101010 : //R type binary, arithmetic, shift and other special instructions 
				begin
					if ((IF_Instr[26:31] == 6'b000100) | (IF_Instr[26:31] == 6'b000101) | (IF_Instr[26:31] == 6'b001101) | (IF_Instr[26:31] == 6'b010000) | (IF_Instr[26:31] == 6'b010001) | (IF_Instr[26:31] == 6'b010010)) begin // instructions only need one operand
						reg1 = IF_Instr[11:15]; //rA
						reg2 = 0; //rB
						Wreg = IF_Instr[6:10]; //rD
						immediate = 0;
						Wmem_en = 0;
						mem_en = 0;
						Wreg_en = 1; // need to write back
						instr_type = IF_Instr[0:5];
						opcode = IF_Instr[26:31]; 
						ww = IF_Instr[24:25];
						ppp = IF_Instr[21:23];
						Wnic_en = 0;
						nic_en = 0;
					end else begin // instructions need two operands
						reg1 = IF_Instr[11:15]; //rA
						reg2 = IF_Instr[16:20]; //rB
						Wreg = IF_Instr[6:10]; //rD
						immediate = 0;
						Wmem_en = 0;
						mem_en = 0;
						Wreg_en = 1; // need to write back
						instr_type = IF_Instr[0:5];
						opcode = IF_Instr[26:31]; 
						ww = IF_Instr[24:25];
						ppp = IF_Instr[21:23];
						Wnic_en = 0;
						nic_en = 0;
					end
				end
			6'b100000 : //load memory
				begin
					if (IF_Instr[16:17] == 2'b11) begin
						reg1 = 0; 
						reg2 = 0;
						Wreg = IF_Instr[6:10]; // rD, data load from memory need to write back to this address in register file
						immediate = IF_Instr[16:31]; // read address for memory
						Wmem_en = 0;//no need to write data mem
						mem_en = 0; //no need to read data mem
						Wreg_en = 1;
						instr_type = IF_Instr[0:5];
						opcode = 0;
						ww = 0;
						ppp = 0;
						Wnic_en = 0; // no need to write nic
						nic_en = 1;// need to read from nic
					end else begin
						reg1 = 0; 
						reg2 = 0;
						Wreg = IF_Instr[6:10]; // rD, data load from memory need to write back to this address in register file
						immediate = IF_Instr[16:31]; // read address for memory
						Wmem_en = 0;
						mem_en = 1;
						Wreg_en = 1;
						instr_type = IF_Instr[0:5];
						opcode = 0;
						ww = 0;
						ppp = 0;
						Wnic_en = 0;
						nic_en = 0;
					end
				end
			6'b100001 : //store memory
				begin
					if (IF_Instr[16:17] == 2'b11) begin
						reg1 = IF_Instr[6:10]; //rD, get data of this address from register file and store it into memory
						reg2 = 0;
						Wreg = 0;
						immediate = IF_Instr[16:31]; // write address for memory
						Wmem_en = 0;
						mem_en = 0;
						Wreg_en = 0;
						instr_type = IF_Instr[0:5];
						opcode = 0;
						ww = 0;
						ppp = 0;
						Wnic_en = 1; // need to write to nic
						nic_en = 1; 
					end else begin
						reg1 = IF_Instr[6:10]; //rD, get data of this address from register file and store it into memory
						reg2 = 0;
						Wreg = 0;
						immediate = IF_Instr[16:31]; // write address for memory
						Wmem_en = 1;
						mem_en = 1;
						Wreg_en = 0;
						instr_type = IF_Instr[0:5];
						opcode = 0;
						ww = 0;
						ppp = 0;
						Wnic_en = 0;
						nic_en = 0;
					end
				end
			6'b100010 : // branch when equal, read register file through reg1 address
				begin
					reg1 = IF_Instr[6:10];
					reg2 = 0;
					Wreg = 0;
					immediate = IF_Instr[16:31];
					Wmem_en = 0;
					mem_en = 0;
					Wreg_en = 0;
					instr_type = IF_Instr[0:5];
					opcode = 0;
					ww = 0;
					ppp = 0;
					Wnic_en = 0;
					nic_en = 0;
				end
			6'b100011 : // branch when not equal, read register file through reg1 address
				begin
					reg1 = IF_Instr[6:10];
					reg2 = 0;
					Wreg = 0;
					immediate = IF_Instr[16:31];
					Wmem_en = 0;
					mem_en = 0;
					Wreg_en = 0;
					instr_type = IF_Instr[0:5];
					opcode = 0;
					ww = 0;
					ppp = 0;
					Wnic_en = 0;
					nic_en = 0;
				end
			6'b111000 : // nop, every control signals are 0
				begin
					reg1 = 0;
					reg2 = 0;
					Wreg = 0;
					immediate = 0;
					Wmem_en = 0;
					mem_en = 0;
					Wreg_en = 0;
					instr_type = IF_Instr[0:5];
					opcode = 0;
					ww = 0;
					ppp = 0;
					Wnic_en = 0;
					nic_en = 0;
				end
			default : 
				begin
					reg1 = 0;
					reg2 = 0;
					Wreg = 0;
					immediate = 0;
					Wmem_en = 0;
					mem_en = 0;
					Wreg_en = 0;
					instr_type = 0;
					opcode = 0;
					ww = 0;
					ppp = 0;
					Wnic_en = 0;
					nic_en = 0;
				end
		endcase
	end

endmodule











