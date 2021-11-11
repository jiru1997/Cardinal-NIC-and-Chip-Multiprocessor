////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1994 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Scott MacKay
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 1df179f2
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Arithmetic Saturation and Rounding Logic
//
//           eg. width=9, msb_out=5, lsb_out=2
//
//           input:    8 7 6 5 4 3 2 1 0
//           extract         5 4 3 2
//           output          3 2 1 0
//
//
// MODIFIED: Scott MacKay Jan 11, 1995
//		 Added checking to assert ov when a round up causes overflow.
//
//           RJK          May 15, 1996
//		 Renamed module to part name (DW01_satrnd_sim -> DW01_satrnd)
//	     Jay Zhu Feb 4, 1999
//		Rewrote, and added X behavior
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//
//           dougl      11/5/04
//              Removed usage of din_in[lsb_out-1] and replaced with
//              shifted version of din_in because compile warnings would
//              occur when lsb_out = 0...."index out of range".  This
//              addresses STAR #9000034051.
//
//           dougl      2/6/06
//              Fixed width for vector din_in_LeftShiftByOne in
//              function satrnd.  This addresses STAR #9000102610.
//----------------------------------------------------------------------
module DW01_satrnd (din,tc,sat,rnd,ov,dout);

 parameter width = 16;
 parameter  msb_out = 15;
 parameter  lsb_out = 0;

 input [width-1:0] din;
 input tc;
 input rnd;
 input sat;

 output ov;
 output [msb_out-lsb_out:0] dout;

   
  // synopsys translate_off
 wire[msb_out-lsb_out+1:0] temp_out;
   

function any_unknown;
input [width-1:0] in;
input	[31:0]	low_bound;
input	[31:0]	high_bound;

integer	i;
begin

	any_unknown = 0;
	for (i = high_bound; i >= low_bound; i = i-1)
	begin
	  if ( in[i] === 1'bZ || in[i] === 1'bX)
	    any_unknown = 1;
	end
end
endfunction // any_unknown


function [msb_out-lsb_out+1:0] satrnd;
input [width-1:0] din;
input tc,sat,rnd;

begin : func_satrnd

reg [msb_out-lsb_out:0] max_signed;
reg [msb_out-lsb_out:0] min_signed;
reg [msb_out-lsb_out:0] max_unsigned;
reg [msb_out-lsb_out:0] add_lsb;
reg [width-1:0] din_in;
reg [msb_out-lsb_out:0] dout_rnd;
reg [msb_out-lsb_out:0] dout_final;
reg tc_in;
reg rnd_in;
reg sat_in;
reg [msb_out-lsb_out : 0] dout_ov;
reg [msb_out:0] din_in_LeftShiftByOne;
reg bit_z_value;

integer i;
integer out_of_range;
integer debug_id;

	max_signed = (1'b1 << (msb_out-lsb_out)) - 1;
	min_signed = 1'b1 << (msb_out-lsb_out);
	max_unsigned = (1'b1 << (msb_out-lsb_out+1)) -1;
	add_lsb = 1;

	debug_id = 0;

    // Convert to 01X
    din_in = (din | (din ^ din));
    tc_in = (tc | (tc ^ tc));
    sat_in = (sat | (sat ^ sat));
    rnd_in = (rnd | (rnd ^ rnd));

    // check for saturation and compute saturation value
    out_of_range = 0;
    dout_ov = din_in[msb_out:lsb_out];

    bit_z_value = 1'bz;
    din_in_LeftShiftByOne = (lsb_out == 0) ? {din_in[msb_out-1:0], bit_z_value} : din_in << 1;

    if (msb_out < width-1)  // overflow or underflow is possible
    begin
      if (tc_in === 1'b1)
      begin
	if (din_in[msb_out] === 1'bX)
	  out_of_range = -1;
	else // if (din_in[msb_out] !== 1'bX)
	begin
	  for (i = width-1;
	     (i >= msb_out+1) && (out_of_range !== -1);
	     i = i-1)
          begin
	    if ((din_in[i] === 1'bX))
	    begin
	      out_of_range = -1;
	    end
	    else
	    begin
	      if (din_in[i] !== din_in[msb_out])
              begin
	        out_of_range = 1;
	debug_id = 1000;
	      end // if (din_in[i] !== din_in[msb_out])
	    end // else
	  end // for (i)
	end // // if (din_in[msb_out] !== 1'bX)

        if (din_in[width-1] === 1'b0)
	  dout_ov = max_signed;
	else if (din_in[width-1] === 1'b1)
	  dout_ov = min_signed;	
	else
	  dout_ov = {msb_out-lsb_out+1{1'bX}};
      end
      else if (tc_in === 1'bX && din_in[msb_out] !== 1'b0) // don't know
      begin
	dout_ov = {msb_out-lsb_out+1{1'bX}};
	out_of_range = -1;
      end
      else                     // unsigned
      begin
        dout_ov = max_unsigned;	
	for (i = width-1;
	     ((i >= msb_out+1) && (out_of_range!=-1));
	     i=i-1)
        begin
	  if (din_in[i] === 1'bX)
	    out_of_range = -1;
	  else if (din_in[i] === 1'b1)
	  begin
	    out_of_range = 1;
	    debug_id = 2000;
	  end
	end // for
      end // if
    end

    // check for lsb truncation and compute rounded output
    if (rnd_in === 1'bX)
      dout_rnd = {msb_out-lsb_out+1{1'bX}};
    else if (lsb_out > 0 && rnd_in === 1'b1)
    begin
// check for round up causing an overflow.  Scott M. 1-11-95
      if (tc_in===1'bX)
	out_of_range = -1;
      else
      begin
	if(any_unknown(din_in, lsb_out, msb_out) === 1)
	  out_of_range = -1;
        else if (((tc_in===1'b1 &&
    	           din_in[msb_out:lsb_out] === max_signed) ||
                  (tc_in==1'b0 &&
    	           din_in[msb_out:lsb_out] === max_unsigned)) &&
	           din_in_LeftShiftByOne[lsb_out] === 1'b1)
	  begin
	  if (rnd_in === 1'b1)
	  begin
            out_of_range = 1;
	debug_id = 3000;
	  end
	  else if (rnd_in === 1'bX && out_of_range === 0)
            out_of_range = -1;
	  end
      end
   
      if (din_in_LeftShiftByOne[lsb_out] === 1'b1)
      begin
        dout_rnd = din_in[msb_out:lsb_out] + add_lsb;
      end
      else if (din_in_LeftShiftByOne[lsb_out] === 1'b0)
      begin
        dout_rnd = din_in[msb_out:lsb_out];
      end
      else
      begin
        dout_rnd = {msb_out-lsb_out+1{1'bX}};
      end
    end
    else // lsb_out = 0 OR rnd_in = 0
    begin
      dout_rnd = din_in[msb_out:lsb_out];
    end // if

    if (sat_in === 1'b0)
    begin
      dout_final = dout_rnd;
    end
    else if (sat_in === 1'b1) // sat = '1'
    begin
      if(out_of_range === 1)
        dout_final = dout_ov;
      else if(out_of_range === 0)
        dout_final = dout_rnd;
      else
        dout_final = {msb_out-lsb_out+1{1'bX}};
    end
    else
      dout_final = {msb_out-lsb_out+1{1'bX}};

    if (out_of_range === 1)
      satrnd = {1'b1,dout_final};
    else if (out_of_range === 0)
      satrnd = {1'b0,dout_final};
    else 
      satrnd = {1'bX,dout_final};

  end
endfunction // satrnd
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
   
    if (width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 2)",
	width );
    end
   
    if ( (msb_out < lsb_out) || (msb_out > width-1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter msb_out (legal range: lsb_out to width-1)",
	msb_out );
    end
   
    if ( (msb_out < 0) || (msb_out > msb_out) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter msb_out (legal range: 0 to msb_out)",
	msb_out );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  assign temp_out = ((^(din ^ din) !== 1'b0) || (^(tc ^ tc) !== 1'b0) || (^(sat ^ sat) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? 
		   {msb_out-lsb_out+2{1'bx}} : satrnd(din,tc,sat,rnd);
  assign ov = temp_out[msb_out-lsb_out+1];
  assign dout = temp_out[msb_out-lsb_out : 0];
  
   // synopsys translate_on
endmodule
