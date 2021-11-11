////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1992 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick kelly		Aug 28, 1997
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 598c67fc
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Parity Generator and Checker
//           parameterizable bus size (width > 0), parameteric "odd/even"
//           parameter odd, parameter width
//           datain     - input data to system register.
//           parity     - output parity bit(s).
//
// MODIFIED:
//
//------------------------------------------------------------------------------
module DW04_par_gen(datain, parity);

  parameter width = 8;
  parameter par_type = 0;

  input  [width-1:0] datain;
  output             parity;
  reg                parity;

// synopsys translate_off

  integer index;

    always @ (datain)
	begin

	if (par_type === 0)
	    parity = ~(^datain);
	
	else
	    parity = ^datain;
	end
  
// synopsys translate_on

endmodule // sim;  
