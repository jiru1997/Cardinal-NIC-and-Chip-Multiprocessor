////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2006 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Alex Tenca, March 2006
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 6866295f
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
//
// ABSTRACT: Arithmetic Right Shifter - VHDL style
//           This component performs left and right shifting.
//           When SH_TC = '0', the shift coefficient SH is interpreted as a
//           positive unsigned number and only right shifts are performed.
//           When SH_TC = '1', the shift coefficient SH is a signed two's
//           complement number. A negative coefficient indicates
//           a left shift (division) and a positive coefficient indicates
//           a right shift (multiplication).
//           The input data A is always considered a signed value.
//           The MSB on A is extended when shifted to the right, and the 
//           LSB on A is extended when shifting to the left.
//
// MODIFIED: 
//
//----------------------------------------------------------------------------

module DW_sra(A, SH, SH_TC, B);
  parameter A_width=4;
  parameter SH_width=2;

  input [A_width-1:0] A;
  input [SH_width-1:0] SH;
  input SH_TC;
   
  output [A_width-1:0] B;

  // synopsys translate_off
      
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if (A_width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter A_width (lower bound: 2)",
	A_width );
    end
  
    if (SH_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter SH_width (lower bound: 1)",
	SH_width );
    end 
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  reg [A_width-1:0] B_INT;
  reg [A_width-1:0] mask;
 
  always @ (A or SH or SH_TC)
  begin
    mask = {A_width{1'b1}};
    if ((SH_TC === 1'bx) | ((^A) === 1'bx) | ((^SH) === 1'bx) )
      B_INT = {A_width{1'bx}};
    else
      begin
        if ((SH_TC === 1'b0) | (SH[SH_width-1] === 1'b0))
          begin
            B_INT = $signed(A) >>> SH;
          end
        else
          if (SH_width === 1) 
            B_INT = (SH === 1)?((A << 1)|A[0]):A;
          else
          begin
            B_INT = (A << ~SH) << 1;
            B_INT = B_INT | (~((mask << ~SH)<<1) & {A_width{A[0]}});
          end
      end
  end

  assign B = B_INT;
  // synopsys translate_on

endmodule
