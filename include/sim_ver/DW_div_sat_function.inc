////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2013 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann		Sep 25, 2013
//
// VERSION:   Verilog Simulation Functions
//
// DesignWare_version: 0971285d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Verilog Function Descriptions for Combinational Divider with Saturation
//
//           Function descriptions for division quotient
//           used for synthesis inference of function calls
//           and for behavioral Verilog simulation.
//
//           The following functions are declared:
//
//           DWF_div_sat_uns (a, b)
//           DWF_div_sat_tc (a, b)
//
//-----------------------------------------------------------------------------

// maximum value
`define MAX(p,q) ((p)>(q)?(p):(q))


  function [q_width-1 : 0] DWF_div_sat_uns;
    // Function to compute the unsigned quotient
    
    // synopsys map_to_operator DIV_SAT_UNS_OP
    // synopsys return_port_name QUOTIENT

    input [a_width-1 : 0] A;
    input [b_width-1 : 0] B;

    reg [q_width-1 : 0] QUOTIENT_v;
    reg [a_width-1 : 0] QUOTIENT_i;
    reg                 A_x, B_x;


    begin
      // synopsys translate_off
      A_x = ^A;
      B_x = ^B;
      if ((A_x === 1'bx) || (B_x === 1'bx)) begin
	QUOTIENT_v = {q_width{1'bx}};
      end
      else begin
	if (B == 0) begin
	  QUOTIENT_v = {q_width{1'b1}};
`ifdef DW_SUPPRESS_WARN `else
	  $write ("WARNING: %m: Division by zero\n");
`endif
	end
	else begin
          QUOTIENT_i = A / B;
          if (q_width < a_width) begin
            if ((| QUOTIENT_i[`MAX(a_width-1,q_width) : q_width]) == 1'b1)
              QUOTIENT_v = {q_width{1'b1}};
            else
              QUOTIENT_v = QUOTIENT_i[q_width-1 : 0];
          end
          else
            QUOTIENT_v = QUOTIENT_i;
	end
      end
      DWF_div_sat_uns = QUOTIENT_v;
      // synopsys translate_on
    end
  endfunction

  
  function [q_width-1 : 0] DWF_div_sat_tc;
    // Function to compute the signed quotient
    
    // synopsys map_to_operator DIV_SAT_TC_OP
    // synopsys return_port_name QUOTIENT

    input [a_width-1 : 0] A;
    input [b_width-1 : 0] B;

    reg [a_width-1 : 0] A_v;
    reg [b_width-1 : 0] B_v;
    reg [q_width-1 : 0] QUOTIENT_v;
    reg [a_width-1 : 0] QUOTIENT_i;
    reg A_x, B_x;


    begin
      // synopsys translate_off
      A_x = ^A;
      B_x = ^B;
      if ((A_x === 1'bx) || (B_x === 1'bx)) begin
	QUOTIENT_v = {a_width{1'bx}};
      end
      else begin
	if (B == 0) begin
	  if (A[a_width-1] == 1'b0)
	    QUOTIENT_v = {1'b0, {q_width-1{1'b1}}};
	  else
	    QUOTIENT_v = {1'b1, {q_width-1{1'b0}}};
`ifdef DW_SUPPRESS_WARN `else
	  $write ("WARNING: %m: Division by zero\n");
`endif
	end
	else begin
          if (A[a_width-1] == 1'b1)
            A_v = ~A + 1'b1;
	  else 
            A_v = A;
	  if (B[b_width-1] == 1'b1)
            B_v = ~B + 1'b1;
	  else
            B_v = B;
          QUOTIENT_i = A_v / B_v;	 
	  if (A[a_width-1] != B[b_width-1])
	    QUOTIENT_i = ~QUOTIENT_i + 1'b1;
          if ((a == {1'b1, {a_width-1{1'b0}}}) && (b == {b_width{1'b1}} ))
            QUOTIENT_v = {1'b0, {q_width-1{1'b1}}};
          else if (q_width < a_width) begin
            if ((QUOTIENT_i[a_width-1] == 1'b0) && 
                ((| QUOTIENT_i[`MAX(a_width-2,q_width-1) : q_width-1]) == 1'b1))
              QUOTIENT_v = {1'b0, {q_width-1{1'b1}}};
            else if ((QUOTIENT_i[a_width-1] == 1'b1) && 
                     ((& QUOTIENT_i[`MAX(a_width-2,q_width-1) : q_width-1]) == 1'b0))
              QUOTIENT_v = {1'b1, {q_width-1{1'b0}}};
            else
              QUOTIENT_v = QUOTIENT_i[q_width-1 : 0];
          end
          else
            QUOTIENT_v = QUOTIENT_i;
	end
      end
      DWF_div_sat_tc = QUOTIENT_v;
      // synopsys translate_on
    end
  endfunction

//-----------------------------------------------------------------------------
