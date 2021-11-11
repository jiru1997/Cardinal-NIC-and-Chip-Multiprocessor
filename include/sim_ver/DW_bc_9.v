////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2002 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    RPH             Aug 2002
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 4c4f4061
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT:  Boundary Scan Cell Type BC_9
//
//           
//
//              
//  Input Ports:   	Size    Description
//  =========== 	====    ===========
//  capture_clk     	1 bit   Clocks data into the capture stage
//  update_clk      	1 bit   Clocks data into the update stage 
//  capture_en      	1 bit   Enable for data clocked into the capture 
//  update_en       	1 bit   Enable for data clocked into the update stage 
//  shift_dr           	1 bit   Enables the boundary scan chain to shift data
//			        one stage toward its serial output (tdo) 
//  mode1		1 bit  	Determines whether data captured  is controlled by the
//				boundary scan cell or by the output_data signal
//  mode2		1 bit  	Determines whether data_out is controlled by the
//				boundary scan cell or by the output_data signal	
//  si	 		1 bit  	Serial path from the previous boundary scan cell
//  pin_input		1 bit 	Input data
//  output_data         1 bit   IC output logic signal.   
//
//  Output Ports    	Size    Description
//  ============	====    ===========
//  data_out        	1 bit   Output data
//  so              	1 bit   Serial path to the next boundary scan cell
//              
//
//
// MODIFIED: 
//
//-------------------------------------------------------------------------------

module DW_bc_9 (capture_clk, update_clk, capture_en, update_en, shift_dr, mode1, 
		mode2,si, pin_input, output_data, data_out, so );

   input  capture_clk;
   input  update_clk;
   input  capture_en;
   input  update_en;
   input  shift_dr;
   input  mode1;
   input  mode2;
   input  si;
   input  pin_input;
   input  output_data;

   output data_out;
   output so;

   // synopsys translate_off

   reg 	  capture_out;
   reg 	  update_out;
   wire   capture_val;
   wire   tmp1;
   
   assign tmp1 = (mode1 === 1'b0) ? (output_data | (output_data ^ output_data)) :
		 (mode1 === 1'b1) ? (pin_input | (pin_input ^ pin_input)) : 1'bX;
   assign capture_val = (shift_dr === 1'b0) ? tmp1 :
			(shift_dr === 1'b1) ? (si | (si ^ si)) : 1'bX;
   assign data_out = (mode2 === 1'b0) ? (output_data | (output_data ^ output_data)) :
		     (mode2 === 1'b1) ? update_out : 1'bX;

   assign so = capture_out;

   always @(posedge capture_clk)
      begin : CAPTURE_PROC
	 if (capture_en === 1'b1)
	    capture_out <= capture_out;
	 else if (capture_en === 1'b0)
	    capture_out <= capture_val;
	 else
	    capture_out <= 1'bX;
      end // block: CAPTURE_PROC
   
   always @(posedge update_clk)
      begin : UPDATE_PROC
	 if (update_en === 1'b1)
	    update_out <= capture_out;
	 else if (update_en === 1'b0)
	    update_out <= update_out;
	 else
	    update_out <= 1'bX;
      end // block: UPDATE_PROC
   
  //---------------------------------------------------------------------------
  // Parameter legality check
  //---------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    //no parameters to check
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  //---------------------------------------------------------------------------
  // Report unknown clock inputs
  //---------------------------------------------------------------------------
  
  always @ (capture_clk) begin : clk_monitor1 
    if ( (capture_clk !== 1'b0) && (capture_clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on capture_clk input.",
                $time, capture_clk );
    end // clk_monitor1 
  
  always @ (update_clk) begin : clk_monitor2 
    if ( (update_clk !== 1'b0) && (update_clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on update_clk input.",
                $time, update_clk );
    end // clk_monitor2        
   // synopsys translate_on 
   
endmodule // DW_bc_9

	 
