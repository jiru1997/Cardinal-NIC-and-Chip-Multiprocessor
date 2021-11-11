////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2008 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Alexandre Tenca   Feb 2008
//
// VERSION:   Verilog Simulation Model - DW_thermdec
//
// DesignWare_version: 2f26a602
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT: Binary Thermometer decoder 
//           A binary thermometer decoder of an n-bit input has 2^n outputs.
//           Each output corresponds to one value of the binary input, and 
//           for an input value i, all the outputs corresponding to j<=i area
//           active.
//           eg. n=3 
//           A(2:0) en     B(7:0)
//           000    1   -> 00000001
//           001    1   -> 00000011
//           010    1   -> 00000111
//           011    1   -> 00001111
//           100    1   -> 00011111
//           101    1   -> 00111111
//           110    1   -> 01111111
//           111    1   -> 11111111
//           xxx    0   -> 00000000
// 
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              width           input size
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               width bits
//                              Input to be decoded
//              en              bit
//                              Enable 
//
//              Output ports    Size & Description
//              ===========     ==================
//              b               2**width bits
//                              Decoded output for value in port a
//
// MODIFIED:
//
//-----------------------------------------------------------------------------

module DW_thermdec (en, a, b);
parameter width=3;

// declaration of inputs and outputs
input  en;
input  [width-1:0] a;
output [(1 << width)-1:0] b;

// synopsys translate_off
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


reg [(1 << width)-1:0] temp_out;
integer i;

always @ (a or en)
begin
  temp_out = 0;
  for (i = 0; i <= a; i=i+1)
  begin
    temp_out[i] = 1'b1;
  end
  if ((^(a ^ a) !== 1'b0) || (^(en ^ en) !== 1'b0))
    temp_out = {(1 << width){1'bX}};
  if (en == 0)
    temp_out = 0;
end

assign b = temp_out;
  
// synopsys translate_on

endmodule
