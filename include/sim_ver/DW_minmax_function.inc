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
// AUTHOR:    Reto Zimmermann	Aug 25, 1999
//
// VERSION:   Simulation Architecture
//
// NOTE:      This is a subentity.
//            This file is for internal use only.
//
// DesignWare_version: a8036dd2
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT: Function Descriptions for Verilog
//
//           Minimum/maximum value detector/selector function description
//           used for synthesis inference of operators,
//           and for behavioral Verilog simulation.
//
//           The following functions are declared:
//
//           DWF_min_uns(a)
//           DWF_min_tc(a)
//           DWF_max_uns(a)
//           DWF_max_tc(a)
//
// MODIFIED : 
//
//-----------------------------------------------------------------------------

  
  function [width-1 : 0] DWF_min_uns;
    // Function to select the minimum value of multiple inputs

    // synopsys map_to_operator MIN_UNS_OP 
    // synopsys return_port_name value

    input [num_inputs*width-1 : 0] a;

    reg [width-1 : 0] a_v;
    reg [width-1 : 0] value_v;
    integer k;
    reg a_x;

    begin
      // synopsys translate_off
      a_x = ^a;
      if (a_x === 1'bx) begin
	value_v = {width{1'bx}};
      end
      else begin
	value_v = {width{1'b1}};
	for (k = 0; k < num_inputs; k = k+1) begin
	  a_v = a[width-1 : 0];
	  a = a >> width;
	  if (a_v < value_v) begin
	    value_v = a_v;
	  end
	end
      end
      DWF_min_uns = value_v;
      // synopsys translate_on
    end
  endfunction

  
  function [width-1 : 0] DWF_min_tc;
    // Function to select the minimum value of multiple inputs

    // synopsys map_to_operator MIN_TC_OP 
    // synopsys return_port_name value

    input [num_inputs*width-1 : 0] a;

    reg [width-1 : 0] a_v;
    reg [width-1 : 0] value_v;
    integer k;
    reg a_x;

    begin
      // synopsys translate_off
      a_x = ^a;
      if (a_x === 1'bx) begin
	value_v = {width{1'bx}};
      end
      else begin
	value_v = {width{1'b1}};
	for (k = 0; k < num_inputs; k = k+1) begin
	  a_v = a[width-1 : 0];
	  a_v[width-1] = ! a[width-1];
	  a = a >> width;
	  if (a_v < value_v) begin
	    value_v = a_v;
	  end
	end
	value_v[width-1] = ! value_v[width-1];
      end
      DWF_min_tc = value_v;
      // synopsys translate_on
    end
  endfunction


  function [width-1 : 0] DWF_max_uns;
    // Function to select the maximum value of multiple inputs

    // synopsys map_to_operator MAX_UNS_OP 
    // synopsys return_port_name value

    input [num_inputs*width-1 : 0] a;

    reg [width-1 : 0] a_v;
    reg [width-1 : 0] value_v;
    integer k;
    reg a_x;

    begin
      // synopsys translate_off
      a_x = ^a;
      if (a_x === 1'bx) begin
	value_v = {width{1'bx}};
      end
      else begin
	value_v = {width{1'b0}};
	for (k = 0; k < num_inputs; k = k+1) begin
	  a_v = a[width-1 : 0];
	  a = a >> width;
	  if (a_v >= value_v) begin
	    value_v = a_v;
	  end
	end
      end
      DWF_max_uns = value_v;
      // synopsys translate_on
    end
  endfunction


  function [width-1 : 0] DWF_max_tc;
    // Function to select the maximum value of multiple inputs

    // synopsys map_to_operator MAX_TC_OP 
    // synopsys return_port_name value

    input [num_inputs*width-1 : 0] a;

    reg [width-1 : 0] a_v;
    reg [width-1 : 0] value_v;
    integer k;
    reg a_x;

    begin
      // synopsys translate_off
      a_x = ^a;
      if (a_x === 1'bx) begin
	value_v = {width{1'bx}};
      end
      else begin
	value_v = {width{1'b0}};
	for (k = 0; k < num_inputs; k = k+1) begin
	  a_v = a[width-1 : 0];
	  a_v[width-1] = ! a[width-1];
	  a = a >> width;
	  if (a_v >= value_v) begin
	    value_v = a_v;
	  end
	end
	value_v[width-1] = ! value_v[width-1];
      end
      DWF_max_tc = value_v;
      // synopsys translate_on
    end
  endfunction
