////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1997 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    RJK		July 21, 1997
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 5d2c3e7e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Up/Down Binary Counter w. Output Decode
//           parameterizable wordlength (width > 0)
//           data	- data load input
//	     up_dn	- count direction control
//	     load	- load control (active low)
//	     cen	- counter enable
//	     clk	- positive edge-triggering clock
//           reset	- asynchronous reset (active low)
//	     count_dec	- counter state
//	     tercnt	- terminal count
//
// MODIFIED : 
//            
//      RJK  2/26/2016  Updated for compatibility with VCS-NLP
//           
//-------------------------------------------------------------------------------
module DW03_bictr_decode
  (data, up_dn, load, cen, clk, reset, count_dec, tercnt);

  parameter width = 8; 

`define DW_dec_width (1 << width)

  // port list declaration in order
  input [ width- 1: 0] data;
  input up_dn, load, cen, clk, reset;
  output [ `DW_dec_width- 1: 0] count_dec;  reg [ `DW_dec_width- 1: 0] count_dec;
  output tercnt;

// synopsys translate_off

  reg [width-1 : 0] next_state,cur_state;
  reg [width-1 : 0] en_state,next_count;
  reg tcup,tcdn;
  integer bit_pos;

always @ (cur_state)
  begin

    bit_pos = 0;

    while ( (cur_state[bit_pos] !== 1'b0) && (cur_state[bit_pos] !== 1'b1) &&
	    (bit_pos < width) )
      begin
      bit_pos = bit_pos + 1;
      end

    if ( bit_pos >= width )
	count_dec = {`DW_dec_width{1'bx}};
    
    else
      for (bit_pos = 0 ; bit_pos < `DW_dec_width ; bit_pos = bit_pos + 1)
	begin
	if (bit_pos === cur_state)
	    count_dec[bit_pos] = 1'b1;
	
	else
	    count_dec[bit_pos] = 1'b0;
	end
  end

// curent state process

always @ (posedge clk or negedge reset) begin : state_reg_PROC
   if (reset == 1'b0)
     cur_state <= 0;
   else
     cur_state <= next_state;
end

// the next state process

always begin

// When updn = '1' 
   if ( (up_dn === 1'b1) ) begin
	next_count = cur_state + 1;
   end else if ( (up_dn === 1'b0) ) begin
	next_count = cur_state - 1;
   end // if

// when cen = '1' then counter star count up/down
// when cen = '0' counter  unchange value

   if ( (cen === 1'b1) ) begin
     en_state = next_count;
   end else begin
     en_state = cur_state;
   end // if

// When load = '0', data input load to counter
// when load = '1', counter increase/decrease
// depending up/down signal and enable count signal

    if ( (load === 1'b0) ) begin
       next_state = data;
    end else begin
       next_state = en_state;
    end // if

// generate terminal count
   if ( (up_dn === 1'b1) ) begin
      if ( (cur_state === {width{1'b1}} ) ) begin
         tcup = 1'b1;
         tcdn = 1'b0;
       end else begin
         tcup = 1'b0;
         tcdn = 1'b0;
       end // if
   end else if ( (up_dn === 1'b0) ) begin
      if ( (cur_state === {width{1'b0}} ) ) begin
         tcdn = 1'b1;
         tcup = 1'b0;
      end else begin
         tcdn = 1'b0;
	 tcup = 1'b0;
      end // if
   end // if
   @(cur_state or data or load or up_dn or cen);
end // process

  assign tercnt  =  tcup | tcdn;

// synopsys translate_on

`undef DW_dec_width

endmodule // sim;

