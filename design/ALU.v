`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_square.v"
`include "./include/sim_ver/DW_sqrt.v"
`include "./include/sim_ver/DW_div.v"

module ALU(
  input [0:63] data1, //rb
  input [0:63] data2, //ra
  input [0:5]  type_op, 
  input [0:1]  operation,
  output reg [0:63] data_out
);

parameter VAND   = 6'b000001;
parameter VOR    = 6'b000010;
parameter VXOR   = 6'b000011;
parameter VNOT   = 6'b000100;
parameter VMOV   = 6'b000101;
parameter VADD   = 6'b000110;
parameter VSUB   = 6'b000111;
parameter VMULEU = 6'b001000;
parameter VMULOU = 6'b001001;
parameter VSLL   = 6'b001010;
parameter VSRL   = 6'b001011;
parameter VSRA   = 6'b001100;
parameter VRTTH  = 6'b001101;
parameter VDIV   = 6'b001110;
parameter VMOD   = 6'b001111;
parameter VSQEU  = 6'b010000;
parameter VSQOU  = 6'b010001;
parameter VSQRT  = 6'b010010;

parameter operation_b = 2'b00;
parameter operation_h = 2'b01;
parameter operation_w = 2'b10;
parameter operation_d = 2'b11;

reg[0:2] sll_b1, srl_b1, sra_b1;
reg[0:2] sll_b2, srl_b2, sra_b2;
reg[0:2] sll_b3, srl_b3, sra_b3;
reg[0:2] sll_b4, srl_b4, sra_b4;
reg[0:2] sll_b5, srl_b5, sra_b5;
reg[0:2] sll_b6, srl_b6, sra_b6;
reg[0:2] sll_b7, srl_b7, sra_b7;
reg[0:2] sll_b8, srl_b8, sra_b8;

reg[0:3] sll_h1, srl_h1, sra_h1;
reg[0:3] sll_h2, srl_h2, sra_h2;
reg[0:3] sll_h3, srl_h3, sra_h3;
reg[0:3] sll_h4, srl_h4, sra_h4;

reg[0:4] sll_w1, srl_w1, sra_w1;
reg[0:4] sll_w2, srl_w2, sra_w2;

reg[0:5] sll_d, srl_d, sra_d;


//div operation----------------------------------------------------------------------
wire[0:63] quotient_VDIV_B_wire, remainder_VDIV_B_wire, divide_by_0_VDIV_b;

DW_div #(8, 8, 0, 1) VDIV_b1 (.a(data2[0:7]),   .b(data1[0:7]),   .quotient(quotient_VDIV_B_wire[0:7]),   .remainder(remainder_VDIV_B_wire[0:7]),   .divide_by_0(divide_by_0_VDIV_b[0]));
DW_div #(8, 8, 0, 1) VDIV_b2 (.a(data2[8:15]),  .b(data1[8:15]),  .quotient(quotient_VDIV_B_wire[8:15]),  .remainder(remainder_VDIV_B_wire[8:15]),  .divide_by_0(divide_by_0_VDIV_b[8]));
DW_div #(8, 8, 0, 1) VDIV_b3 (.a(data2[16:23]), .b(data1[16:23]), .quotient(quotient_VDIV_B_wire[16:23]), .remainder(remainder_VDIV_B_wire[16:23]), .divide_by_0(divide_by_0_VDIV_b[16]));
DW_div #(8, 8, 0, 1) VDIV_b4 (.a(data2[24:31]), .b(data1[24:31]), .quotient(quotient_VDIV_B_wire[24:31]), .remainder(remainder_VDIV_B_wire[24:31]), .divide_by_0(divide_by_0_VDIV_b[24]));
DW_div #(8, 8, 0, 1) VDIV_b5 (.a(data2[32:39]), .b(data1[32:39]), .quotient(quotient_VDIV_B_wire[32:39]), .remainder(remainder_VDIV_B_wire[32:39]), .divide_by_0(divide_by_0_VDIV_b[32]));
DW_div #(8, 8, 0, 1) VDIV_b6 (.a(data2[40:47]), .b(data1[40:47]), .quotient(quotient_VDIV_B_wire[40:47]), .remainder(remainder_VDIV_B_wire[40:47]), .divide_by_0(divide_by_0_VDIV_b[40]));
DW_div #(8, 8, 0, 1) VDIV_b7 (.a(data2[48:55]), .b(data1[48:55]), .quotient(quotient_VDIV_B_wire[48:55]), .remainder(remainder_VDIV_B_wire[48:55]), .divide_by_0(divide_by_0_VDIV_b[48]));
DW_div #(8, 8, 0, 1) VDIV_b8 (.a(data2[56:63]), .b(data1[56:63]), .quotient(quotient_VDIV_B_wire[56:63]), .remainder(remainder_VDIV_B_wire[56:63]), .divide_by_0(divide_by_0_VDIV_b[56]));

wire[0:63] quotient_VDIV_H_wire, remainder_VDIV_H_wire, divide_by_0_VDIV_h;

DW_div #(16, 16, 0, 1) VDIV_h1 (.a(data2[0:15]),  .b(data1[0:15]),  .quotient(quotient_VDIV_H_wire[0:15]),  .remainder(remainder_VDIV_H_wire[0:15]),  .divide_by_0(divide_by_0_VDIV_h[0]));
DW_div #(16, 16, 0, 1) VDIV_h2 (.a(data2[16:31]), .b(data1[16:31]), .quotient(quotient_VDIV_H_wire[16:31]), .remainder(remainder_VDIV_H_wire[16:31]), .divide_by_0(divide_by_0_VDIV_h[16]));
DW_div #(16, 16, 0, 1) VDIV_h3 (.a(data2[32:47]), .b(data1[32:47]), .quotient(quotient_VDIV_H_wire[32:47]), .remainder(remainder_VDIV_H_wire[32:47]), .divide_by_0(divide_by_0_VDIV_h[32]));
DW_div #(16, 16, 0, 1) VDIV_h4 (.a(data2[48:63]), .b(data1[48:63]), .quotient(quotient_VDIV_H_wire[48:63]), .remainder(remainder_VDIV_H_wire[48:63]), .divide_by_0(divide_by_0_VDIV_h[48]));

wire[0:63] quotient_VDIV_W_wire, remainder_VDIV_W_wire, divide_by_0_VDIV_w;

DW_div #(32, 32, 0, 1) VDIV_w1 (.a(data2[0:31]),  .b(data1[0:31]),  .quotient(quotient_VDIV_W_wire[0:31]),  .remainder(remainder_VDIV_W_wire[0:31]),  .divide_by_0(divide_by_0_VDIV_w[0]));
DW_div #(32, 32, 0, 1) VDIV_w2 (.a(data2[32:63]), .b(data1[32:63]), .quotient(quotient_VDIV_W_wire[32:63]), .remainder(remainder_VDIV_W_wire[32:63]), .divide_by_0(divide_by_0_VDIV_w[32]));

wire[0:63] quotient_VDIV_D_wire, remainder_VDIV_D_wire, divide_by_0_VDIV_d;

DW_div #(64, 64, 0, 1) VDIV_d (.a(data2[0:63]),  .b(data1[0:63]),  .quotient(quotient_VDIV_D_wire[0:63]),  .remainder(remainder_VDIV_D_wire[0:63]),  .divide_by_0(divide_by_0_VDIV_d[0]));


//mod operation--------------------------------------------------------------------
wire[0:63] quotient_VMOD_B_wire, remainder_VMOD_B_wire, divide_by_0_VMOD_b;

DW_div #(8, 8, 0, 1) VMOD_b1 (.a(data2[0:7]),   .b(data1[0:7]),   .quotient(quotient_VMOD_B_wire[0:7]),   .remainder(remainder_VMOD_B_wire[0:7]),   .divide_by_0(divide_by_0_VMOD_b[0]));
DW_div #(8, 8, 0, 1) VMOD_b2 (.a(data2[8:15]),  .b(data1[8:15]),  .quotient(quotient_VMOD_B_wire[8:15]),  .remainder(remainder_VMOD_B_wire[8:15]),  .divide_by_0(divide_by_0_VMOD_b[8]));
DW_div #(8, 8, 0, 1) VMOD_b3 (.a(data2[16:23]), .b(data1[16:23]), .quotient(quotient_VMOD_B_wire[16:23]), .remainder(remainder_VMOD_B_wire[16:23]), .divide_by_0(divide_by_0_VMOD_b[16]));
DW_div #(8, 8, 0, 1) VMOD_b4 (.a(data2[24:31]), .b(data1[24:31]), .quotient(quotient_VMOD_B_wire[24:31]), .remainder(remainder_VMOD_B_wire[24:31]), .divide_by_0(divide_by_0_VMOD_b[24]));
DW_div #(8, 8, 0, 1) VMOD_b5 (.a(data2[32:39]), .b(data1[32:39]), .quotient(quotient_VMOD_B_wire[32:39]), .remainder(remainder_VMOD_B_wire[32:39]), .divide_by_0(divide_by_0_VMOD_b[32]));
DW_div #(8, 8, 0, 1) VMOD_b6 (.a(data2[40:47]), .b(data1[40:47]), .quotient(quotient_VMOD_B_wire[40:47]), .remainder(remainder_VMOD_B_wire[40:47]), .divide_by_0(divide_by_0_VMOD_b[40]));
DW_div #(8, 8, 0, 1) VMOD_b7 (.a(data2[48:55]), .b(data1[48:55]), .quotient(quotient_VMOD_B_wire[48:55]), .remainder(remainder_VMOD_B_wire[48:55]), .divide_by_0(divide_by_0_VMOD_b[48]));
DW_div #(8, 8, 0, 1) VMOD_b8 (.a(data2[56:63]), .b(data1[56:63]), .quotient(quotient_VMOD_B_wire[56:63]), .remainder(remainder_VMOD_B_wire[56:63]), .divide_by_0(divide_by_0_VMOD_b[56]));

wire[0:63] quotient_VMOD_H_wire, remainder_VMOD_H_wire, divide_by_0_VMOD_h;

DW_div #(16, 16, 0, 1) VMOD_h1 (.a(data2[0:15]),  .b(data1[0:15]),  .quotient(quotient_VMOD_H_wire[0:15]),  .remainder(remainder_VMOD_H_wire[0:15]),  .divide_by_0(divide_by_0_VMOD_h[0]));
DW_div #(16, 16, 0, 1) VMOD_h2 (.a(data2[16:31]), .b(data1[16:31]), .quotient(quotient_VMOD_H_wire[16:31]), .remainder(remainder_VMOD_H_wire[16:31]), .divide_by_0(divide_by_0_VMOD_h[1]));
DW_div #(16, 16, 0, 1) VMOD_h3 (.a(data2[32:47]), .b(data1[32:47]), .quotient(quotient_VMOD_H_wire[32:47]), .remainder(remainder_VMOD_H_wire[32:47]), .divide_by_0(divide_by_0_VMOD_h[3]));
DW_div #(16, 16, 0, 1) VMOD_h4 (.a(data2[48:63]), .b(data1[48:63]), .quotient(quotient_VMOD_H_wire[48:63]), .remainder(remainder_VMOD_H_wire[48:63]), .divide_by_0(divide_by_0_VMOD_h[4]));

wire[0:63] quotient_VMOD_W_wire, remainder_VMOD_W_wire, divide_by_0_VMOD_w;

DW_div #(32, 32, 0, 1) VMOD_w1 (.a(data2[0:31]),  .b(data1[0:31]),  .quotient(quotient_VMOD_W_wire[0:31]),  .remainder(remainder_VMOD_W_wire[0:31]),  .divide_by_0(divide_by_0_VMOD_w[0]));
DW_div #(32, 32, 0, 1) VMOD_w2 (.a(data2[32:63]), .b(data1[32:63]), .quotient(quotient_VMOD_W_wire[32:63]), .remainder(remainder_VMOD_W_wire[32:63]), .divide_by_0(divide_by_0_VMOD_w[32]));

wire[0:63] quotient_VMOD_D_wire, remainder_VMOD_D_wire, divide_by_0_VMOD_d;

DW_div #(64, 64, 0, 1) VMOD_d (.a(data2[0:63]),  .b(data1[0:63]),  .quotient(quotient_VMOD_D_wire[0:63]),  .remainder(remainder_VMOD_D_wire[0:63]),  .divide_by_0(divide_by_0_VMOD_d[0]));


//square even operation-----------------------------------------------------------------
wire[0:63] square_inst_VSQEU_B_wire, square_inst_VSQEU_H_wire, square_inst_VSQEU_W_wire;

DW_square #(8) VSQEU_b1 (.a(data2[0:7]),   .tc(1'b0), .square(square_inst_VSQEU_B_wire[0:15]));
DW_square #(8) VSQEU_b2 (.a(data2[16:23]), .tc(1'b0), .square(square_inst_VSQEU_B_wire[16:31]));
DW_square #(8) VSQEU_b3 (.a(data2[32:39]), .tc(1'b0), .square(square_inst_VSQEU_B_wire[32:47]));
DW_square #(8) VSQEU_b4 (.a(data2[48:55]), .tc(1'b0), .square(square_inst_VSQEU_B_wire[48:63]));
DW_square #(16) VSQEU_h1 (.a(data2[0:15]), .tc(1'b0), .square(square_inst_VSQEU_H_wire[0:31]));
DW_square #(16) VSQEU_h2 (.a(data2[32:47]),.tc(1'b0), .square(square_inst_VSQEU_H_wire[32:63]));
DW_square #(32) VSQEU_w  (.a(data2[0:31]), .tc(1'b0), .square(square_inst_VSQEU_W_wire[0:63]));


//square odd operation--------------------------------------------------------------------
wire[0:63] square_inst_VSQOU_B_wire, square_inst_VSQOU_H_wire, square_inst_VSQOU_W_wire;

DW_square #(8) VSQOU_b1 (.a(data2[8:15]),  .tc(1'b0), .square(square_inst_VSQOU_B_wire[0:15]));
DW_square #(8) VSQOU_b2 (.a(data2[24:31]), .tc(1'b0), .square(square_inst_VSQOU_B_wire[16:31]));
DW_square #(8) VSQOU_b3 (.a(data2[40:47]), .tc(1'b0), .square(square_inst_VSQOU_B_wire[32:47]));
DW_square #(8) VSQOU_b4 (.a(data2[56:63]), .tc(1'b0), .square(square_inst_VSQOU_B_wire[48:63]));
DW_square #(16) VSQOU_h1 (.a(data2[16:31]),.tc(1'b0), .square(square_inst_VSQOU_H_wire[0:31]));
DW_square #(16) VSQOU_h2 (.a(data2[48:63]),.tc(1'b0), .square(square_inst_VSQOU_H_wire[32:63]));
DW_square #(32) VSQOU_w  (.a(data2[32:63]),.tc(1'b0), .square(square_inst_VSQOU_W_wire[0:63]));

//sqr operation------------------------------------------------------------------------------------------------
wire[0:63] square_root_VSQRT_B_wire, square_root_VSQRT_H_wire, square_root_VSQRT_W_wire, square_root_VSQRT_D_wire;

DW_sqrt #(8, 0) VSQRT_b1 (.a(data2[0:7]),   .root(square_root_VSQRT_B_wire[0:3]));
DW_sqrt #(8, 0) VSQRT_b2 (.a(data2[8:15]),  .root(square_root_VSQRT_B_wire[8:11]));
DW_sqrt #(8, 0) VSQRT_b3 (.a(data2[16:23]), .root(square_root_VSQRT_B_wire[16:19]));
DW_sqrt #(8, 0) VSQRT_b4 (.a(data2[24:31]), .root(square_root_VSQRT_B_wire[24:27]));
DW_sqrt #(8, 0) VSQRT_b5 (.a(data2[32:39]), .root(square_root_VSQRT_B_wire[32:35]));
DW_sqrt #(8, 0) VSQRT_b6 (.a(data2[40:47]), .root(square_root_VSQRT_B_wire[40:43]));
DW_sqrt #(8, 0) VSQRT_b7 (.a(data2[48:55]), .root(square_root_VSQRT_B_wire[48:51]));
DW_sqrt #(8, 0) VSQRT_b8 (.a(data2[56:63]), .root(square_root_VSQRT_B_wire[56:59]));

DW_sqrt #(16, 0) VSQRT_h1 (.a(data2[0:15]),  .root(square_root_VSQRT_H_wire[0:7]));
DW_sqrt #(16, 0) VSQRT_h2 (.a(data2[16:31]), .root(square_root_VSQRT_H_wire[16:23]));
DW_sqrt #(16, 0) VSQRT_h3 (.a(data2[32:47]), .root(square_root_VSQRT_H_wire[32:39]));
DW_sqrt #(16, 0) VSQRT_h4 (.a(data2[48:63]), .root(square_root_VSQRT_H_wire[48:55]));

DW_sqrt #(32, 0) VSQRT_W1 (.a(data2[0:31]),  .root(square_root_VSQRT_W_wire[0:15]));
DW_sqrt #(32, 0) VSQRT_W2 (.a(data2[32:63]), .root(square_root_VSQRT_W_wire[32:47]));

DW_sqrt #(64, 0) VSQRT_D  (.a(data2[0:63]),  .root(square_root_VSQRT_D_wire[0:31]));


always @(*) begin
  case(type_op)
    VAND   :begin
              data_out = data1 & data2;
            end
    VOR    :begin
              data_out = data1 | data2;
            end
    VXOR   :begin
              data_out = data1 ^ data2;
            end
    VNOT   :begin
              data_out = ~ data2;
            end
    VMOV   :begin
              data_out = data2;
            end
    VADD   :begin
              case(operation)
                operation_b : begin
                                data_out[0:7]   = data1[0:7]   + data2[0:7];
                                data_out[8:15]  = data1[8:15]  + data2[8:15];   
                                data_out[16:23] = data1[16:23] + data2[16:23];   
                                data_out[24:31] = data1[24:31] + data2[24:31];   
                                data_out[32:39] = data1[32:39] + data2[32:39];   
                                data_out[40:47] = data1[40:47] + data2[40:47];   
                                data_out[48:55] = data1[48:55] + data2[48:55];   
                                data_out[56:63] = data1[56:63] + data2[56:63];                                  
                              end
                operation_h : begin
                                data_out[0:15]  = data1[0:15]  + data2[0:15]; 
                                data_out[16:31] = data1[16:31] + data2[16:31];   
                                data_out[32:47] = data1[32:47] + data2[32:47]; 
                                data_out[48:63] = data1[48:63] + data2[48:63]; 
                              end
                operation_w : begin
                                data_out[0:31]  = data1[0:31]  + data2[0:31];    
                                data_out[32:63] = data1[32:63] + data2[32:63]; 
                              end
                operation_d : begin
                                data_out[0:63]  = data1[0:63]  + data2[0:63];
                              end 
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
            end
    VSUB   :begin
              case(operation)
                operation_b : begin
                                data_out[0:7]   = data2[0:7]   - data1[0:7];
                                data_out[8:15]  = data2[8:15]  - data1[8:15];   
                                data_out[16:23] = data2[16:23] - data1[16:23];   
                                data_out[24:31] = data2[24:31] - data1[24:31];   
                                data_out[32:39] = data2[32:39] - data1[32:39];   
                                data_out[40:47] = data2[40:47] - data1[40:47];   
                                data_out[48:55] = data2[48:55] - data1[48:55];   
                                data_out[56:63] = data2[56:63] - data1[56:63];                                  
                              end
                operation_h : begin
                                data_out[0:15]  = data2[0:15]  - data1[0:15]; 
                                data_out[16:31] = data2[16:31] - data1[16:31];   
                                data_out[32:47] = data2[32:47] - data1[32:47]; 
                                data_out[48:63] = data2[48:63] - data1[48:63]; 
                              end
                operation_w : begin
                                data_out[0:31]  = data2[0:31]  - data1[0:31];    
                                data_out[32:63] = data2[32:63] - data1[32:63]; 
                              end
                operation_d : begin
                                data_out[0:63]  = data2[0:63]  - data1[0:63];
                              end 
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
          end
    VMULEU :begin
              case(operation)
                operation_b : begin
                                data_out[0:15]  = data1[0:7]   * data2[0:7];
                                data_out[16:31] = data1[16:23] * data2[16:23];
                                data_out[32:47] = data1[32:39] * data2[32:39];
                                data_out[48:63] = data1[48:55] * data2[48:55];
                              end
                operation_h : begin
                                data_out[0:31]  = data1[0:15]  * data2[0:15];
                                data_out[32:63] = data1[32:47] * data2[32:47];
                              end
                operation_w : begin
                                data_out[0:63]  = data1[0:31]  * data2[0:31];
                              end
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
          end
    VMULOU :begin
              case(operation)
                operation_b : begin
                                data_out[0:15]  = data1[8:15]  * data2[8:15];
                                data_out[16:31] = data1[24:31] * data2[24:31];
                                data_out[32:47] = data1[40:47] * data2[40:47];
                                data_out[48:63] = data1[56:63] * data2[56:63];
                              end
                operation_h : begin
                                data_out[0:31]  = data1[16:31] * data2[16:31];
                                data_out[32:63] = data1[48:63] * data2[48:63];
                              end
                operation_w : begin
                                data_out[0:63]  = data1[32:63] * data2[32:63];
                              end
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
          end
    VSLL   :begin
              case(operation)
                operation_b : begin
                                sll_b1 = data1[5:7];
                                sll_b2 = data1[13:15];
                                sll_b3 = data1[21:23];   
                                sll_b4 = data1[29:31];   
                                sll_b5 = data1[37:39];   
                                sll_b6 = data1[45:47];   
                                sll_b7 = data1[53:55];   
                                sll_b8 = data1[61:63];
                                data_out[0:7]   = (data2[0:7]   << sll_b1);                                
                                data_out[8:15]  = (data2[8:15]  << sll_b2);
                                data_out[16:23] = (data2[16:23] << sll_b3);
                                data_out[24:31] = (data2[24:31] << sll_b4);
                                data_out[32:39] = (data2[32:39] << sll_b5);
                                data_out[40:47] = (data2[40:47] << sll_b6);
                                data_out[48:55] = (data2[48:55] << sll_b7);
                                data_out[56:63] = (data2[56:63] << sll_b8);                                
                              end
                operation_h : begin
                                sll_h1 = data1[12:15];
                                sll_h2 = data1[27:31];
                                sll_h3 = data1[43:47];
                                sll_h4 = data1[59:63];
                                data_out[0:15]  = data2[0:15]  << sll_h1;
                                data_out[16:31] = data2[16:31] << sll_h2;
                                data_out[32:47] = data2[32:47] << sll_h3;
                                data_out[48:63] = data2[48:63] << sll_h4;
                              end
                operation_w : begin
                                sll_w1 = data1[27:31];
                                sll_w2 = data1[59:63];
                                data_out[0:31]  = data2[0:31]  << sll_w1;
                                data_out[32:63] = data2[32:63] << sll_w2;
                              end
                operation_d : begin
                                sll_d = data1[58:63];
                                data_out[0:63]  = data2[0:63] << sll_d;
                              end 
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
          end
    VSRL   :begin
              case(operation)
                operation_b : begin
                                srl_b1 = data1[5:7];
                                srl_b2 = data1[13:15];
                                srl_b3 = data1[21:23];   
                                srl_b4 = data1[29:31];   
                                srl_b5 = data1[37:39];   
                                srl_b6 = data1[45:47];   
                                srl_b7 = data1[53:55];   
                                srl_b8 = data1[61:63];
                                data_out[0:7]   = data2[0:7]   >> srl_b1;                                
                                data_out[8:15]  = data2[8:15]  >> srl_b2;
                                data_out[16:23] = data2[16:23] >> srl_b3;
                                data_out[24:31] = data2[24:31] >> srl_b4;
                                data_out[32:39] = data2[32:39] >> srl_b5;
                                data_out[40:47] = data2[40:47] >> srl_b6;
                                data_out[48:55] = data2[48:55] >> srl_b7;
                                data_out[56:63] = data2[56:63] >> srl_b8;                                
                              end
                operation_h : begin
                                srl_h1 = data1[12:15];
                                srl_h2 = data1[27:31];
                                srl_h3 = data1[43:47];
                                srl_h4 = data1[59:63];
                                data_out[0:15]  = data2[0:15]  >> srl_h1;
                                data_out[16:31] = data2[16:31] >> srl_h2;
                                data_out[32:47] = data2[32:47] >> srl_h3;
                                data_out[48:63] = data2[48:63] >> srl_h4;
                              end
                operation_w : begin
                                srl_w1 = data1[27:31];
                                srl_w2 = data1[59:63];
                                data_out[0:31]  = data2[0 :31] >> srl_w1;
                                data_out[32:63] = data2[32:63] >> srl_w2;
                              end
                operation_d : begin
                                srl_d = data1[58:63];
                                data_out[0:63]  = data2[0:63] >> srl_d;
                              end 
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
          end
    VSRA   :begin
              case(operation)
                operation_b : begin
                                sra_b1 = data1[5:7];
                                sra_b2 = data1[13:15];
                                sra_b3 = data1[21:23];   
                                sra_b4 = data1[29:31];   
                                sra_b5 = data1[37:39];   
                                sra_b6 = data1[45:47];   
                                sra_b7 = data1[53:55];   
                                sra_b8 = data1[61:63];
                                data_out[0:7]   = $signed(data2[0:7])   >>> sra_b1;                                
                                data_out[8:15]  = $signed(data2[8:15])  >>> sra_b2;
                                data_out[16:23] = $signed(data2[16:23]) >>> sra_b3;
                                data_out[24:31] = $signed(data2[24:31]) >>> sra_b4;
                                data_out[32:39] = $signed(data2[32:39]) >>> sra_b5;
                                data_out[40:47] = $signed(data2[40:47]) >>> sra_b6;
                                data_out[48:55] = $signed(data2[48:55]) >>> sra_b7;
                                data_out[56:63] = $signed(data2[56:63]) >>> sra_b8;                                
                              end
                operation_h : begin
                                sra_h1 = data1[12:15];
                                sra_h2 = data1[27:31];
                                sra_h3 = data1[43:47];
                                sra_h4 = data1[59:63];
                                data_out[0:15]  = $signed(data2[0:15])  >>> sra_h1;
                                data_out[16:31] = $signed(data2[16:31]) >>> sra_h2;
                                data_out[32:47] = $signed(data2[32:47]) >>> sra_h3;
                                data_out[48:63] = $signed(data2[48:63]) >>> sra_h4;
                              end
                operation_w : begin
                                sra_w1 = data1[27:31];
                                sra_w2 = data1[59:63];
                                data_out[0:31]  = $signed(data2[0:31])  >>> sra_w1;
                                data_out[32:63] = $signed(data2[32:63]) >>> sra_w2;
                              end
                operation_d : begin
                                sra_d = data1[58:63];
                                data_out[0:63]  = $signed(data2[0:63]) >>> sra_d;
                              end 
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
            end
    VRTTH  :begin
              case(operation)
                operation_b : begin
                                data_out[0:7]   = {data2[4:7],   data2[0:3]};
                                data_out[8:15]  = {data2[12:15], data2[8:11]};
                                data_out[16:23] = {data2[20:23], data2[16:19]};
                                data_out[24:31] = {data2[28:31], data2[24:27]};
                                data_out[32:39] = {data2[36:39], data2[32:35]};
                                data_out[40:47] = {data2[44:47], data2[40:43]};
                                data_out[48:55] = {data2[52:55], data2[48:51]};
                                data_out[56:63] = {data2[60:63], data2[56:59]};                         
                              end
                operation_h : begin
                                data_out[0:15]  = {data2[8:15],  data2[0:7]};
                                data_out[16:31] = {data2[24:31], data2[16:23]};
                                data_out[32:47] = {data2[40:47], data2[32:39]};
                                data_out[48:63] = {data2[56:63], data2[48:55]};
                              end
                operation_w : begin
                                data_out[0:31]  = {data2[16:31], data2[0:15]};
                                data_out[32:63] = {data2[48:63], data2[32:47]};
                              end
                operation_d : begin
                                data_out[0:63]  = {data2[32:63], data2[0:31]};
                              end 
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
            end
    VDIV   :begin
              case(operation)
                operation_b : begin
                                data_out = quotient_VDIV_B_wire;
                              end
                operation_h : begin
                                data_out = quotient_VDIV_H_wire;
                              end
                operation_w : begin
                                data_out = quotient_VDIV_W_wire;
                              end
                operation_d : begin
                                data_out = quotient_VDIV_D_wire;
                              end
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
            end
    VMOD   :begin
              case(operation)
                operation_b : begin
                                data_out = remainder_VMOD_B_wire;
                              end
                operation_h : begin
                                data_out = remainder_VMOD_H_wire;
                              end
                operation_w : begin
                                data_out = remainder_VMOD_W_wire;
                              end
                operation_d : begin
                                data_out = remainder_VMOD_D_wire;
                              end
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
            end
    VSQEU  :begin
              case(operation)
                operation_b : begin
                                data_out = square_inst_VSQEU_B_wire;
                              end
                operation_h : begin
                                data_out = square_inst_VSQEU_H_wire;
                              end
                operation_w : begin
                                data_out = square_inst_VSQEU_W_wire;
                              end
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
          end
    VSQOU  :begin
              case(operation)
                operation_b : begin
                                data_out = square_inst_VSQOU_B_wire;
                              end
                operation_h : begin
                                data_out = square_inst_VSQOU_H_wire;
                              end
                operation_w : begin
                                data_out = square_inst_VSQOU_W_wire;
                              end
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
          end
    VSQRT  :begin
              case(operation)
                operation_b : begin
                                data_out = 64'b0;
                                data_out[4:7]   = square_root_VSQRT_B_wire[0:3];
                                data_out[12:15]  = square_root_VSQRT_B_wire[8:11];
                                data_out[20:23] = square_root_VSQRT_B_wire[16:19];
                                data_out[28:31] = square_root_VSQRT_B_wire[24:27];
                                data_out[36:39] = square_root_VSQRT_B_wire[32:35];
                                data_out[44:47] = square_root_VSQRT_B_wire[40:43];
                                data_out[52:55] = square_root_VSQRT_B_wire[48:51];
                                data_out[60:63] = square_root_VSQRT_B_wire[56:59];
                              end
                operation_h : begin
                                data_out = 64'b0;
                                data_out[8:15]   = square_root_VSQRT_H_wire[0:7];
                                data_out[24:31] = square_root_VSQRT_H_wire[16:23];
                                data_out[40:47] = square_root_VSQRT_H_wire[32:39];
                                data_out[56:63] = square_root_VSQRT_H_wire[48:55];
                              end
                operation_w : begin
                                data_out = 64'b0;
                                data_out[16:31]  = square_root_VSQRT_W_wire[0:15];
                                data_out[48:63] = square_root_VSQRT_W_wire[32:47];
                              end
                operation_d : begin
                                data_out = 64'b0;
                                data_out[32:63] = square_root_VSQRT_D_wire[0:31];
                              end 
                default     : begin
                                data_out[0:63]  = data_out[0:63];
                              end                
              endcase
          end
    default: begin
              data_out[0:63]  = data_out[0:63];
             end
  endcase
end


endmodule
