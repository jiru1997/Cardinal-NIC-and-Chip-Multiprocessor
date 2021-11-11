module HDU (
  input  write_back_enable, 
  input[0:4]  EXMEM_WB_destination, 
  input[0:4]  ID_EXMEM_destination,
  input[0:4]  IF_ID_reg1, IF_ID_reg2,
  input[0:5]  IF_ID_instr_type, 
  input[0:5]  ID_EXMEM_instr_type,
  output reg pc_stall, 
  output reg IF_ID_stall
);

always @(*) begin
  if(write_back_enable & ((EXMEM_WB_destination == IF_ID_reg1) | (EXMEM_WB_destination == IF_ID_reg2))) begin
    pc_stall        = 1;
    IF_ID_stall     = 1;
  end 
  else if((IF_ID_instr_type == 6'b101010) & (ID_EXMEM_instr_type == 6'b101010) & ((ID_EXMEM_destination == IF_ID_reg1) | (ID_EXMEM_destination == IF_ID_reg2))) begin
    pc_stall        = 1;
    IF_ID_stall     = 1;
  end
  else if((IF_ID_instr_type == 6'b101010) & (ID_EXMEM_instr_type == 6'b100000) & ((ID_EXMEM_destination == IF_ID_reg1) | (ID_EXMEM_destination == IF_ID_reg2))) begin 
    pc_stall        = 1;
    IF_ID_stall     = 1;
  end
  else if((IF_ID_instr_type == 6'b100010) & (ID_EXMEM_instr_type == 6'b101010) & (ID_EXMEM_destination == IF_ID_reg1)) begin//beq R
    pc_stall        = 1;
    IF_ID_stall     = 1;
  end
  else if((IF_ID_instr_type == 6'b100010) & (ID_EXMEM_instr_type == 6'b100000) & (ID_EXMEM_destination == IF_ID_reg1)) begin//beq load
    pc_stall        = 1;
    IF_ID_stall     = 1;
  end
  else if((IF_ID_instr_type == 6'b100011) & (ID_EXMEM_instr_type == 6'b101010) & (ID_EXMEM_destination == IF_ID_reg1)) begin//bneq R
    pc_stall        = 1;
    IF_ID_stall     = 1;
  end
  else if((IF_ID_instr_type == 6'b100011) & (ID_EXMEM_instr_type == 6'b100000) & (ID_EXMEM_destination == IF_ID_reg1)) begin//bneq load
    pc_stall        = 1;
    IF_ID_stall     = 1;
  end
  else begin
    pc_stall        = 0;
    IF_ID_stall     = 0;
  end    
end


endmodule