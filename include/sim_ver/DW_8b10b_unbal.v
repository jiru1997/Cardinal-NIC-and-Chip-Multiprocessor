////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1999 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Jay Zhu,   Sept 21, 1999
//
// VERSION:   Verilog simulation model
//
// DesignWare_version: 8ba57edc
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------
// ABSTRACT: 8b10b unbalanced character predictor
//
//	Parameters:
//		k28_5_only:Special character subset control
//			parameter (0 for all special characters
//			encoded, 1 for only K28.5 decoded[when
//			k_char=HIGH K28.5 is encoded regardless
//			of the value of the input data])
//	Inputs:
//		k_char:Special character control
//		data_in: Input data to be encoded that balance
//			predition is based on
//	Outputs:
//		unbal :Output indicating whether the input
//			data byte will flip the running disparity
//			bit of the encoder (unbalance = HIGH) or
//			keep it in the same state (unbalanced = LOW)
//----------------------------------------------------------------------
//	MODIFIED:
//----------------------------------------------------------------------


module DW_8b10b_unbal(k_char, data_in, unbal);
	parameter	k28_5_only = 0 ;

	input		k_char;
	input[7:0]	data_in;

	output		unbal;

// synopsys translate_off
	wire		k_char;
	wire[7:0]	data_in;
	wire		unbal;


function 		any_unknown_9;
	input	[8:0]	A;
	integer		bit_idx;

begin

	any_unknown_9 = 1'b0;

	for (bit_idx=8; bit_idx>=0; bit_idx=bit_idx-1)
	begin
	  if(A[bit_idx] !== 1'b0 && A[bit_idx] !== 1'b1)
	  begin
	    any_unknown_9 = 1'b1;
	  end
	end

end
endfunction


function		DWF_8b10b_unbal;
	input[7:0]	data_in;
	input		k_char;

begin: block_DWF_8b10b_unbal

	reg		index_tbl;
	reg		unbal_tbl;

	if ((any_unknown_9({data_in, k_char})== 1))
	begin 
	  DWF_8b10b_unbal  = 1'bx ;
	end

	else if (k_char ==1'b0)
	begin 
	  index_tbl = {
      1'b0,
      1'b1,
      1'b1,
      1'b1,
      1'b0,
      1'b1,
      1'b1,
      1'b0
		}
		>> (7-data_in[7:5]);

	  unbal_tbl = {
      32'b00010111011111100111111001101000,
      32'b11101000100000011000000110010111
		}
		>> ((1-index_tbl)*32 +(31-data_in[4:0]));

	  DWF_8b10b_unbal  = unbal_tbl;
	end

	else if (k_char === 1'b1)
	begin 
	  if (k28_5_only == 0)
	  begin 
	    case (data_in)
	      8'b00011100,
	      8'b10011100,
	      8'b11111100,
	      8'b11110111,
	      8'b11111011,
	      8'b11111101,
	      8'b11111110:
	        begin
	          DWF_8b10b_unbal  = 1'b0 ;
	        end
	      8'b00111100,
	      8'b01011100,
	      8'b01111100,
	      8'b10111100,
	      8'b11011100:
	        begin
	          DWF_8b10b_unbal  = 1'b1 ;
	        end
	      default:
	        begin
	          DWF_8b10b_unbal  = 1'bx ;
	          $display("Warning: Invalid data on data_in of DW_8b10b_unbal when k28_5_only=0 and k_char=1.");
	        end
	    endcase
	  end

	  else
	  begin
	    DWF_8b10b_unbal = 1'b1 ;
	  end 
	end 

	disable block_DWF_8b10b_unbal;
end
endfunction

assign  unbal  = DWF_8b10b_unbal(data_in, k_char);

initial
begin 
	if(k28_5_only < 0 || k28_5_only > 1)
	begin
	  $display("Error: k28_5_only(%0d) parameter of DW_8b10b_unbal is out of legal range(0 to 1)",
	  	k28_5_only);
	  $finish;
	end
end

// synopsys translate_on
endmodule
