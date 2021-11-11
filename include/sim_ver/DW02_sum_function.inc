////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1996 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly, 		Sept. 4, 1996
//
// VERSION:   Simulation Architecture
//
// NOTE:      This is a subentity.
//            This file is for internal use only.
//
// DesignWare_version: 5c277402
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Function Descriptions for Verilog
//
//           Vector summer function description
//           used for synthesis inference of operators,
//           and for behavioral Verilog simulation.
//
//           The following function is declared:
//
//           DWF_sum(A)  
//
// MODIFIED : - 
//	10/14/1998	Jay Zhu	STAR 59348
//
//------------------------------------------------------------------------------


function [input_width-1 : 0] DWF_sum;
// Function to perform a vector sumation of multiple inputs

// synopsys map_to_operator VECTOR_SUM_OP 
// synopsys return_port_name Z

input [num_inputs*input_width-1:0] A; 

reg [ input_width-1 : 0 ] current_vector_sum, next_vector_sum;
reg carry;
integer i, j;

begin
  // synopsys translate_off

  current_vector_sum = { input_width{ 1'b0 } };

  for (i=0 ; i < num_inputs ; i = i + 1)
    begin
    
    carry = 0;
    for (j=0 ; j < input_width ; j = j + 1)
      begin
	next_vector_sum[j] = current_vector_sum[j] ^ A[j + (i * input_width)] ^ carry;
	carry = (A[j + (i * input_width)] & (current_vector_sum[j] | carry)) |
				(current_vector_sum[j] & carry);
      end

    current_vector_sum = next_vector_sum;

    end
  
  DWF_sum = current_vector_sum;

  // synopsys translate_on 
end

endfunction


//  unified old inference name

function [input_width-1 : 0] DW_sum;
 
// synopsys map_to_operator VECTOR_SUM_OP 
// synopsys return_port_name Z

input [num_inputs*input_width-1:0] A;
 
begin
  DW_sum = DWF_sum(A);
end
 
endfunction
