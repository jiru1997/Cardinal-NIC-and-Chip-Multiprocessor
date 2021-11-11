// Description: Pipeline module for EE577b Project Phase 2 Processor Design
// Author: Sihao Chen
// Create Date: Oct.21.2021
// Module Name: cpu

module cpu(clk, rst, pc_out, inst_in, d_in, d_out, addr_out, memWrEn, memEn, addr_nic, d_out_nic, d_in_nic, nicEn, nicWrEn);
	input clk, rst;
	input [0:31] inst_in;
	input [0:63] d_in, d_in_nic; // data send in from data memory and nic
	output memWrEn, memEn, nicEn, nicWrEn;
	output [0:31] pc_out, addr_out;
	output reg [0:63] d_out, d_out_nic; // data out for data mem and nic 
	output [0:1] addr_nic; //address for nic

	wire IF_ID_stall, pc_stall;
	reg flush;
	wire [0:31] PCin;
	//assign PCin = flush ? ID_immediate : PCout + 4; // IF flush, pc goes to immediate address

	wire [0:31] IF_Instr; // Instruction read from i-mem

	// Control signal decoded from instruction at IF/ID stage register
	wire [0:4] ID_reg1, ID_reg2, ID_Wreg;
	wire [0:15] ID_immediate;
	wire ID_Wmem_en, ID_Wreg_en, ID_mem_en, ID_Wnic_en, ID_nic_en;
	wire [0:5] ID_instr_type, ID_opcode;
	wire [0:1] ID_ww;
	wire [0:2] ID_ppp;
	wire [0:63] ID_reg1_out, ID_reg2_out; // data read from register file

	// Control signal pass through ID/EXMEM stage register
	wire [0:63] EXMEM_reg1_out, EXMEM_reg2_out;
	wire [0:4] EXMEM_reg1, EXMEM_reg2, EXMEM_Wreg; // reg1 reg2 used for dependency determination
	wire [0:15] EXMEM_immediate;
	wire [0:5] EXMEM_instr_type, EXMEM_opcode;
	wire [0:1] EXMEM_ww;
	wire [0:2] EXMEM_ppp;
	wire EXMEM_mem_en, EXMEM_Wmem_en, EXMEM_Wreg_en;

	// ALU result
	wire [0:63] EXMEM_ALUresult;

	// Control signal and ALU result and data loaded from memory pass through EXMEM/WB stage register
	wire [0:63] WB_ALUresult, WB_MEMout, WB_Wreg_data; 
	wire [0:4] WB_Wreg;
	wire WB_Wreg_en;
	wire [0:5] WB_instr_type, WB_opcode;
	wire [0:2] WB_ppp;
	// use instruction type to decide which data need to be write back to register file
	assign WB_Wreg_data = (WB_instr_type == 6'b100000) ? WB_MEMout : WB_ALUresult;

	assign PCin = flush ? {16'b0000000000000000,ID_immediate} : pc_out + 4; // IF flush, pc goes to immediate address

	PC myPC(.PCin(PCin),
			.PCout(pc_out),// connect to output, imem module
			.clk(clk),
			.rst(rst),
			.stall(pc_stall)
			);
	/* imem connect outside of cpu module
	imem myimem(.memAddr(PCout[22:29]),
				.dataOut(IF_Instr)
				);
	*/
	IF_ID myIF_ID(.IF_Instr(inst_in), // instruction read from imem 
				  .ID_reg1(ID_reg1), 
				  .ID_reg2(ID_reg2), 
				  .ID_Wreg(ID_Wreg), 
				  .ID_immediate(ID_immediate), 
				  .ID_Wmem_en(ID_Wmem_en), 
				  .ID_mem_en(ID_mem_en), 
				  .ID_Wreg_en(ID_Wreg_en), 
				  .ID_Wnic_en(ID_Wnic_en),
				  .ID_nic_en(ID_nic_en),
				  .ID_instr_type(ID_instr_type), 
				  .ID_opcode(ID_opcode), 
				  .ID_ww(ID_ww), 
				  .ID_ppp(ID_ppp), 
				  .clk(clk), 
				  .rst(rst), 
				  .flush(flush), 
				  .stall(IF_ID_stall)
				  );

	regFile myregFile(.reg1(ID_reg1), 
					  .reg2(ID_reg2), 
					  .Wreg(WB_Wreg), 
					  .Wdata(WB_Wreg_data), 
					  .Wreg_en(WB_Wreg_en), 
					  .reg1_out(ID_reg1_out), 
					  .reg2_out(ID_reg2_out), 
					  .ppp(WB_ppp),
					  .clk(clk), 
					  .rst(rst)
					  );

	// BEQ and BNEQ determination in ID stage
	always@(*) begin
		if (ID_instr_type == 6'b100010) begin
			flush = (!ID_reg1_out) ? 1 : 0; // if contents of register rD are zero, then branch executed, flush asserted
		end else if (ID_instr_type == 6'b100011) begin
			flush = (ID_reg1_out) ? 1 : 0; // if contents of register rD are not zero, then branch executed, flush asserted
		end else flush = 0;
	end

	ID_EXMEM myID_EXMEM(.ID_reg1_out(pc_stall ? 64'b0:ID_reg1_out), 
						.ID_reg2_out(pc_stall ? 64'b0:ID_reg2_out), 
						.ID_reg1(pc_stall ? 5'b0:ID_reg1), 
						.ID_reg2(pc_stall ? 5'b0:ID_reg2), 
						.ID_Wreg(pc_stall ? 5'b0:ID_Wreg), 
						.ID_immediate(pc_stall ? 16'b0:ID_immediate), 
						.ID_Wmem_en(pc_stall ? 1'b0:ID_Wmem_en), 
						.ID_mem_en(pc_stall ? 1'b0:ID_mem_en), 
						.ID_Wreg_en(pc_stall ? 1'b0:ID_Wreg_en), 
						.ID_instr_type(pc_stall ? 6'b0:ID_instr_type), 
						.ID_opcode(pc_stall ? 6'b0:ID_opcode), 
						.ID_ww(pc_stall ? 2'b0:ID_ww), 
						.ID_ppp(pc_stall ? 3'b0:ID_ppp), 
						.EXMEM_reg1_out(EXMEM_reg1_out), 
						.EXMEM_reg2_out(EXMEM_reg2_out), 
						.EXMEM_reg1(EXMEM_reg1), 
						.EXMEM_reg2(EXMEM_reg2), 
						.EXMEM_Wreg(EXMEM_Wreg), 
						.EXMEM_immediate(EXMEM_immediate), // connect to output 
						.EXMEM_Wmem_en(EXMEM_Wmem_en), //connect to output 
						.EXMEM_mem_en(EXMEM_mem_en), //connect to output
						.EXMEM_Wreg_en(EXMEM_Wreg_en), 
						.EXMEM_instr_type(EXMEM_instr_type), 
						.EXMEM_opcode(EXMEM_opcode), 
						.EXMEM_ww(EXMEM_ww), 
						.EXMEM_ppp(EXMEM_ppp), 
						.clk(clk), 
						.rst(rst)
						);

	//HDU
	HDU myHDU(.write_back_enable(WB_Wreg_en),
			  .EXMEM_WB_destination(WB_Wreg),
			  .ID_EXMEM_destination(EXMEM_Wreg),
			  .IF_ID_reg1(ID_reg1),
			  .IF_ID_reg2(ID_reg2),
			  .IF_ID_instr_type(ID_instr_type),
			  .ID_EXMEM_instr_type(EXMEM_instr_type),
			  .pc_stall(pc_stall),
			  .IF_ID_stall(IF_ID_stall)
			  );

	ALU myALU(.data2(EXMEM_reg1_out), //ra
			  .data1(EXMEM_reg2_out), //rb
			  .type_op(EXMEM_opcode), 
			  .operation(EXMEM_ww), 
			  .data_out(EXMEM_ALUresult)
			  );

	// data memory port 
	always@(*) begin 
		d_out = ID_reg1_out; // data need to write into dmem, since data mem has input register, it need get data from ID stage
		d_out_nic = ID_reg1_out;
		//$display(d_out);
	end

	assign addr_out[16:31] = ID_immediate;
	assign memWrEn = ID_Wmem_en;
	assign memEn = ID_mem_en;
	assign addr_nic = ID_immediate[14:15];
	assign nicEn = ID_nic_en;
	assign nicWrEn = ID_Wnic_en;


/* dmem connected outside of cpu module
	dmem mydmem(.clk(clk), 
				.memEn(EXMEM_mem_en), 
				.memWrEn(EXMEM_Wmem_en), 
				.memAddr(EXMEM_immediate), 
				.dataIn(EXMEM_reg1_out), 
				.dataOut(EXMEM_MEMout)
				);
*/

	EXMEM_WB myEXMEM_WB(.EXMEM_ALUresult(EXMEM_ALUresult), 
						.EXMEM_MEMout( (EXMEM_immediate[0:1] == 2'b11) ? d_in_nic : d_in), // if it is nic operation, connect ro d_in_nic, otherwise d_in
						.EXMEM_Wreg(EXMEM_Wreg), 
						.EXMEM_Wreg_en(EXMEM_Wreg_en), 
						.EXMEM_instr_type(EXMEM_instr_type), 
						.EXMEM_opcode(EXMEM_opcode), 
						.EXMEM_ppp(EXMEM_ppp),
						.WB_ALUresult(WB_ALUresult), 
						.WB_MEMout(WB_MEMout),
						.WB_Wreg(WB_Wreg), 
						.WB_Wreg_en(WB_Wreg_en), 
						.WB_instr_type(WB_instr_type), 
						.WB_opcode(WB_opcode), 
						.WB_ppp(WB_ppp),
						.clk(clk), 
						.rst(rst)
						);

endmodule










