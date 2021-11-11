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
// AUTHOR:    Jay Zhu	          September 7, 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 30d62021
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// MODIFICATIONS:
//
//      2/10/15 RJK
//      Eliminated derived reset and enable signals and use of assign
//      inside always block
//
//      9/22/11 DLL
//      Changed position of "k_char" in the port ordering.
//      This addresses STAR#9000493562.
//
//      10/06/2008 RJK
//      Added rst_mode as well as rd_err_bus and code_err_bus outputs.
//
//      2/19/08 DLL 
//      Added 'op_iso_mode' parameter and checking logic
//
//      8/23/04 RJK
//      Corrected interpretation of coding versus RD error
//      in separate output flags (code_err vs. rd_err)
//      STAR #9000024623
//
//      8/18/04 Doug Lee
//      Enhancement : Added init_mode parameter
//
//      RJK 11/21/2002 added enable and separate code
//              and RD error outputs
//
////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------
// ABSTRACT:8b10b decoder
//	Parameters:
//		bytes:Number of bytes to encode.
//		k28_5_only:Special character subset control
//			parameter (0 for all special characters
//			decoded, 1 for only K28.5 decoded[when
//			k_char =HIGH implies K28.5, all other special
//			characters indicate a code error])
//		en_mode:enable input control parameter (0 for
//			disconnected enable input, 1 for enable
//			input controls register in module)
//		init_mode: during initialization the method in which
//			input init_rd_val is applied to data_in (0 for having
//			init_rd_val to be registered first, 1 for not
//			registering)
//		rst_mode:select reset type (0 for asynchrnonous reset,
//			1 for synchronous reset
//              op_iso_mode : Operand Isolation Mode
//                      (0 = Follow intent defined by Power Compiler user setting
//                       1 = no operand isolation
//                       2 = 'and' gate isolaton
//                       3 = 'or' gate isolation
//                       4 = preferred isolation style: 'and' gate)
//	Inputs:
//		clk:	Clock
//		rst_n:	Asynchronous reset, active low
//		init_rd_n:Synchronous initialization, active low
//		init_rd_val:Value of initial running disparity
//		data_in:Input data for decoding, normally should be
//			8b10b encoded data
//	Outputs:
//		error:Error output indicator, active high
//		rd:	Current running disparity (after decoding data
//			presented at data_in)
//		k_char:Special character indicators (one indicator
//			per decoded byte)
//		data_out:decoded output data
//		rd_err:Running Displarity error indicator, active high
//		code_err:Code violation error indicator, active high
//	Input:
//		enable:Enable input to registers (the control input is
//			disconnected when parameter en_mode=0, which
//			is the default)
//
// MODIFIED:
//      DLL     2/19/08 Added 'op_iso_mode' parameter and checking logic
//
//----------------------------------------------------------------------


module DW_8b10b_dec(
	// Inputs
	    clk,	    // - Clock input pin
	    rst_n,	    // - Reset input pin (active low)
	    init_rd_n,	    // - Running Disparity initialization
			    //    control input pin (active low)
	    init_rd_val,    // - Running Disparity initial value
			    //    input pin
	    data_in,	    // - Input data bus (ten bits per byte)

	// Outputs
	    error,	    // - Error status flag (active high)
	    rd,		    // - Current Running Disparity state
	    k_char,	    // - Special character status output
			    //    bus (active high, one status bit
			    //    per data byte)
	    data_out,	    // - Decoded output data bus (eight
			    //    bits per byte)
	    rd_err,	    // - Running Disparity error status flag
			    //    (active high)
	    code_err,	    // - Code violation error status flag
			    //    (active high)

	// Input
	    enable,	    // - Enable (enable=1 => process data_in,
			    //    enable=0 => maintain current state)
			    //    parameter en_mode=0 disconnects enable

	// Outputs
	    rd_err_bus,	    // - Running Disparity error status bus
			    //    one status bit per data byte
	    code_err_bus    // - Code violation error status bus
			    //    one status bit per data byte
	    );


// Parameters
    parameter bytes = 2;	// number of bytes decode per clock cycle

    parameter k28_5_only = 0;	// special character control mode :
				//	0 => all 12 special characters decoded
				//
				//	1 => K28.5 available only (other
				//		special characters are
				//		flagged as errors)

    parameter en_mode = 0;	// enable mode :
				//      0 => enable input is disconnected
				//      1 => enable=1 processes while
				//           enable=0 stalls registers

    parameter init_mode = 0;    // initialization mode :
                                //      0 => init_rd_val input is registered
                                //           before being applied to data in
                                //      1 => init_rd_val input is not registered
                                //           before being applied to data in

    parameter rst_mode = 0;	// reset mode :
				//      0 => use asynchronous reset
				//      1 => use synchronous reset

   parameter op_iso_mode = 0;   // operand isolation mode:
                                //      0 => Follow intent defined by Power Compiler user setting
                                //      1 => no operand isolation
                                //      2 => 'and' gate isolaton
                                //      3 => 'or' gate isolation
                                //      4 => preferred isolation style: 'and' gate


input	 		clk;
input	 		rst_n;
input	 		init_rd_n;
input	 		init_rd_val;
input[bytes*10-1:0]	data_in;

output	 		error;
output	 		rd;
output[bytes-1:0]	k_char;
output[bytes*8-1:0]	data_out;
output			rd_err;
output			code_err;

input			enable;

output [bytes-1 : 0]	rd_err_bus;
output [bytes-1 : 0]	code_err_bus;

reg			error;
reg			rd;
reg[bytes-1:0]		k_char;
reg[bytes*8-1:0]	data_out;
reg			rd_err;
reg			code_err;
reg[bytes-1:0]		rd_err_bus;
reg[bytes-1:0]		code_err_bus;

wire                    rd_int_selected;


  function [5:0]  dec_6_to_5_lookup;
	input[5:0]      abcdei;
	input           RD_in;

  begin : dec_6_to_5_lookup_func

    reg[5:0]	dec_6_to_5_tbl;


    dec_6_to_5_tbl = {
   6'b101000,   6'b101000,
   6'b100000,   6'b100000,
   6'b000000,   6'b000000,
   6'b100100,   6'b100100,
   6'b100000,   6'b100000,
   6'b101110,   6'b101110,
   6'b010000,   6'b010000,
   6'b001111,   6'b001111,
   6'b010010,   6'b010010,
   6'b110110,   6'b110110,
   6'b001000,   6'b001000,
   6'b101000,   6'b101001,
   6'b110000,   6'b110000,
   6'b011000,   6'b011001,
   6'b111000,   6'b111001,
   6'b111001,   6'b111001,
   6'b111000,   6'b111000,
   6'b111010,   6'b111010,
   6'b000100,   6'b000100,
   6'b100100,   6'b100101,
   6'b111110,   6'b111110,
   6'b010100,   6'b010101,
   6'b110100,   6'b110101,
   6'b011111,   6'b011111,
   6'b000000,   6'b000000,
   6'b001100,   6'b001101,
   6'b101100,   6'b101101,
   6'b100001,   6'b100001,
   6'b011100,   6'b011101,
   6'b000011,   6'b000011,
   6'b111101,   6'b111101,
   6'b111011,   6'b111011,
   6'b101000,   6'b101000,
   6'b111100,   6'b111100,
   6'b000010,   6'b000010,
   6'b100010,   6'b100011,
   6'b100000,   6'b100000,
   6'b010010,   6'b010011,
   6'b110010,   6'b110011,
   6'b000001,   6'b000001,
   6'b011110,   6'b011110,
   6'b001010,   6'b001011,
   6'b101010,   6'b101011,
   6'b111111,   6'b111111,
   6'b011010,   6'b011011,
   6'b000101,   6'b000101,
   6'b111011,   6'b111011,
   6'b111101,   6'b111101,
   6'b111000,   6'b111000,
   6'b000110,   6'b000111,
   6'b100110,   6'b100111,
   6'b110001,   6'b110001,
   6'b010110,   6'b010111,
   6'b001001,   6'b001001,
   6'b110111,   6'b110111,
   6'b111001,   6'b111001,
   6'b001110,   6'b001110,
   6'b010001,   6'b010001,
   6'b101111,   6'b101111,
   6'b110101,   6'b110101,
   6'b011111,   6'b011111,
   6'b011111,   6'b011111,
   6'b111111,   6'b111111,
   6'b111111,   6'b111111}

	>> (((63-abcdei)*2+(1-RD_in))*6);

    dec_6_to_5_lookup = dec_6_to_5_tbl[5:0];
    disable dec_6_to_5_lookup_func;
  end
  endfunction


  function [3:0]  dec_4_to_3_lookup;
	input[3:0]      fghj;
	input           RD_in;

  begin : dec_4_to_3_lookup_func
    reg[3:0]	dec_4_to_3_tbl;

    dec_4_to_3_tbl = {
   4'b1010,    4'b1010,
   4'b1110,    4'b1110,
   4'b1000,    4'b1000,
   4'b0111,    4'b0111,
   4'b0000,    4'b0000,
   4'b0100,    4'b0101,
   4'b1100,    4'b1101,
   4'b1111,    4'b1111,
   4'b1110,    4'b1110,
   4'b0010,    4'b0011,
   4'b1010,    4'b1011,
   4'b0001,    4'b0001,
   4'b0110,    4'b0110,
   4'b1001,    4'b1001,
   4'b1111,    4'b1111,
   4'b1101,    4'b1101
	} >> (((15-fghj)*2+(1-RD_in))*4);
    dec_4_to_3_lookup = dec_4_to_3_tbl[3:0];
    disable dec_4_to_3_lookup_func;
  end
  endfunction





  function any_error_lookup;
	input[9:0]      abcdeifghj;
	input           RD_in;
	input		which;

  begin : any_error_lookup_func
    reg[4095:0]	any_error;

    any_error = {
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b1, 1'b0, 1'b1, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b1,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b0, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b0, 1'b1, 1'b0, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0,
   1'b1, 1'b1, 1'b1, 1'b0
	} >> ((1023-abcdeifghj)*4);
    any_error_lookup = any_error[2*RD_in+which];
    disable any_error_lookup_func;
  end
  endfunction





  function[11:0]	decode_10b_to_8b;
	input[31:0]	byte_idx;
	input		RD_in;

   begin : block_decode_10b_to_8b

    reg[9:0]	abcdeifghj;
    reg[7:0]	HGFEDCBA;
    reg		RD_out;
    reg		error_out;
    reg		rd_err_out;
    reg		code_err_out;
    reg		k_char1;
    integer		abcdei;
    reg[5:0]	EDCBA_r;
    reg[3:0]	HGF_r;
    integer		fghj;
    integer		bit_idx;

    for(bit_idx=9; bit_idx>=0; bit_idx=bit_idx-1) begin
      abcdeifghj[bit_idx] = data_in[byte_idx*10+bit_idx];
    end
    abcdei = abcdeifghj[9:4];
    fghj = abcdeifghj[3:0];

    if ((^({abcdeifghj, RD_in} ^ {abcdeifghj, RD_in}) !== 1'b0)) begin
      HGFEDCBA = 8'bx ;
      RD_out = 1'bx ;
      error_out = 1'bx ;
      k_char1 = 1'bx ;
    end else begin

      EDCBA_r = dec_6_to_5_lookup(abcdei, RD_in);

      HGF_r = dec_4_to_3_lookup(fghj, EDCBA_r[0]);

      rd_err_out = any_error_lookup(abcdeifghj, RD_in, 0);
      code_err_out = any_error_lookup(abcdeifghj, RD_in, 1);
      error_out = rd_err_out | code_err_out;

      case (abcdeifghj)
	10'b1100000101 : HGF_r[3:1] = 3'b101;
	10'b1100000110 : HGF_r[3:1] = 3'b001;
	10'b1100001001 : HGF_r[3:1] = 3'b110;
	10'b1100001010 : HGF_r[3:1] = 3'b010;
	default: begin end
      endcase

      RD_out = HGF_r[0];
      HGFEDCBA = {HGF_r[3:1], EDCBA_r[5:1]};

      if ((abcdei == 15 && (fghj >= 2 && fghj <= 10 && fghj != 7))||
	 (abcdei == 48 && (fghj >= 5 && fghj <= 13 && fghj != 8))||
	 ((abcdei == 58 || abcdei == 54 || abcdei == 46 ||
		    abcdei == 30) && fghj == 8)	 ||
	 ((abcdei == 5 || abcdei == 9 || abcdei == 17 ||
		    abcdei == 33) && fghj == 7)) begin
        k_char1 = ~ code_err_out;
        if ((k28_5_only == 1) && (code_err_out == 1'b0)) begin 
	  if (~((abcdei == 15 && fghj == 10) ||
	     (abcdei == 48 && fghj == 5))) begin 
	    error_out = 1'b1 ;
	    code_err_out = 1'b1;
	    k_char1 = 1'b0 ;
	  end 
        end
      end else begin
        k_char1 = 1'b0 ;
      end
    end

    decode_10b_to_8b = {HGFEDCBA, k_char1, RD_out, rd_err_out, code_err_out};

    disable block_decode_10b_to_8b;

  end
  endfunction



  function[11:0]	decode_10b_to_8b_x_rd_in;
	input[31:0]	byte_idx;
	input		RD_in;

  begin : block_decode_10b_to_8b_x_rd_in
    reg[11:0]	decode_10b_to_8b_rd_in0;
    reg[11:0]	decode_10b_to_8b_rd_in1;
    integer		bit_idx;

    if (RD_in === 1'b0 || RD_in === 1'b1) begin
      decode_10b_to_8b_x_rd_in = decode_10b_to_8b(byte_idx, RD_in);
    end 

    else begin
      decode_10b_to_8b_rd_in0 = decode_10b_to_8b(byte_idx, 1'b0);
      decode_10b_to_8b_rd_in1 = decode_10b_to_8b(byte_idx, 1'b1);
      for(bit_idx=11; bit_idx>=0; bit_idx=bit_idx-1) begin
	if (decode_10b_to_8b_rd_in0[bit_idx] ===
			    decode_10b_to_8b_rd_in1[bit_idx]) begin
	  decode_10b_to_8b_x_rd_in[bit_idx] =
			    decode_10b_to_8b_rd_in0[bit_idx];
	end else begin
	  decode_10b_to_8b_x_rd_in[bit_idx] = 1'bx;
	end
      end
    end
    disable block_decode_10b_to_8b_x_rd_in;

  end
  endfunction


task task_decode_10b_to_8b_bytes;
    input                   RD_in;
    output  [11*bytes+2:0]  decode_10b_to_8b_bytes;
    begin

        integer		byte_idx;
        integer		bit_idx;
        reg[11:0]	tmp_signal;
        reg		rd_int_bytes;
        reg		rd_error;
        reg[bytes-1:0] rd_error_bus;
        reg		code_error;
        reg[bytes-1:0] code_error_bus;

        rd_int_bytes = RD_in;
        rd_error = 1'b0;
        rd_error_bus = {bytes{1'b0}};
        code_error = 1'b0;
        code_error_bus = {bytes{1'b0}};
        for (byte_idx=bytes-1; byte_idx>=0; byte_idx=byte_idx-1) begin
          tmp_signal = decode_10b_to_8b_x_rd_in(
            		    byte_idx,
            		    rd_int_bytes
            		    );
          for(bit_idx=8-1; bit_idx>=0; bit_idx=bit_idx-1) begin
            decode_10b_to_8b_bytes[byte_idx*8+bit_idx] =
            		    tmp_signal[bit_idx+4];
          end

          decode_10b_to_8b_bytes[bytes*8+byte_idx] = tmp_signal[3];

          decode_10b_to_8b_bytes[bytes*9+byte_idx] = tmp_signal[1];

          decode_10b_to_8b_bytes[bytes*10+byte_idx] = tmp_signal[0];
          rd_int_bytes = tmp_signal[2];
          rd_error = rd_error | tmp_signal[1];
          code_error = code_error | tmp_signal[0];

        end

        decode_10b_to_8b_bytes[bytes*11] = rd_int_bytes;
        decode_10b_to_8b_bytes[bytes*11+1] = rd_error;
        decode_10b_to_8b_bytes[bytes*11+2] = code_error;

    end 
endtask

generate
  if (init_mode == 0) begin : GEN_IM_EQ_0
    assign rd_int_selected = rd;
  end else begin : GEN_IM_NE_0
    assign rd_int_selected = (init_rd_n === 1'b0)? init_rd_val : rd;
  end
endgenerate

generate
 if (rst_mode == 0) begin : GEN_RM_EQ_0
  if (en_mode == 0) begin : GEN_RM_EQ_0_EM_EQ_0
  always @ (posedge clk or negedge rst_n) begin : mk_regs_ar_PROC
    reg[11*bytes+2:0]	tmp_signal;

    if (rst_n === 1'b0) begin
      rd <= 1'b0;
      error <= 1'b0;
      rd_err <= 1'b0;
      code_err <= 1'b0;
      k_char <= {bytes{1'b0}};
      data_out <= {bytes*8{1'b0}};
      rd_err_bus <= {bytes{1'b0}};
      code_err_bus <= {bytes{1'b0}};
    end else if (rst_n === 1'b1) begin
      task_decode_10b_to_8b_bytes(rd_int_selected, tmp_signal);
      data_out <= tmp_signal[bytes*8-1:0];
      k_char <= tmp_signal[bytes*9-1:bytes*8];
      error <= tmp_signal[11*bytes+1] | tmp_signal[11*bytes+2];
      rd_err <= tmp_signal[11*bytes+1];
      code_err <= tmp_signal[11*bytes+2];
      rd_err_bus <= tmp_signal[10*bytes-1:9*bytes];
      code_err_bus <= tmp_signal[11*bytes-1:10*bytes];

      if((init_rd_n === 1'b0) && (init_mode === 1'b0)) begin
	rd <= init_rd_val;
      end else if((init_rd_n === 1'b1) || (init_mode === 1'b1)) begin
	rd <= tmp_signal[11*bytes];
      end else begin
	rd <= 1'bx;
      end

    end else begin
      data_out <= {bytes*8{1'bx}};
      k_char <= {bytes{1'bx}};
      rd <= 1'bx;
      error <= 1'bx;
      rd_err <= 1'bx;
      code_err <= 1'bx;
    end

  end // PROC_mk_regs_ar
  end else begin : GEN_RM_EQ_0_EM_NE_0
  always @ (posedge clk or negedge rst_n) begin : mk_regs_ar_PROC
    reg[11*bytes+2:0]	tmp_signal;

    if (rst_n === 1'b0) begin
      rd <= 1'b0;
      error <= 1'b0;
      rd_err <= 1'b0;
      code_err <= 1'b0;
      k_char <= {bytes{1'b0}};
      data_out <= {bytes*8{1'b0}};
      rd_err_bus <= {bytes{1'b0}};
      code_err_bus <= {bytes{1'b0}};
    end else if (rst_n === 1'b1) begin
      if (enable === 1'b1) begin
	task_decode_10b_to_8b_bytes(rd_int_selected, tmp_signal);
	data_out <= tmp_signal[bytes*8-1:0];
	k_char <= tmp_signal[bytes*9-1:bytes*8];
	error <= tmp_signal[11*bytes+1] | tmp_signal[11*bytes+2];
	rd_err <= tmp_signal[11*bytes+1];
	code_err <= tmp_signal[11*bytes+2];
	rd_err_bus <= tmp_signal[10*bytes-1:9*bytes];
	code_err_bus <= tmp_signal[11*bytes-1:10*bytes];

	if((init_rd_n === 1'b0) && (init_mode === 1'b0)) begin
	  rd <= init_rd_val;
	end else if((init_rd_n === 1'b1) || (init_mode === 1'b1)) begin
	  rd <= tmp_signal[11*bytes];
	end else begin
	  rd <= 1'bx;
	end

      end else if (enable !== 1'b0) begin
        data_out <= {bytes*8{1'bx}};
        k_char <= {bytes{1'bx}};
        rd <= 1'bx;
        error <= 1'bx;
        rd_err <= 1'bx;
        code_err <= 1'bx;
      end

    end else begin
      data_out <= {bytes*8{1'bx}};
      k_char <= {bytes{1'bx}};
      rd <= 1'bx;
      error <= 1'bx;
      rd_err <= 1'bx;
      code_err <= 1'bx;
    end
    end
  end // PROC_mk_regs_ar
 end else begin : GEN_RM_NE_0
  if (en_mode == 0) begin : GEN_RM_NE_0_EM_EQ_0
  always @ (posedge clk) begin : mk_regs_sr_PROC
    reg[11*bytes+2:0]	tmp_signal;

    if (rst_n === 1'b0) begin
      rd <= 1'b0;
      error <= 1'b0;
      rd_err <= 1'b0;
      code_err <= 1'b0;
      k_char <= {bytes{1'b0}};
      data_out <= {bytes*8{1'b0}};
      rd_err_bus <= {bytes{1'b0}};
      code_err_bus <= {bytes{1'b0}};
    end else if (rst_n === 1'b1) begin
      task_decode_10b_to_8b_bytes(rd_int_selected, tmp_signal);
      data_out <= tmp_signal[bytes*8-1:0];
      k_char <= tmp_signal[bytes*9-1:bytes*8];
      error <= tmp_signal[11*bytes+1] | tmp_signal[11*bytes+2];
      rd_err <= tmp_signal[11*bytes+1];
      code_err <= tmp_signal[11*bytes+2];
      rd_err_bus <= tmp_signal[10*bytes-1:9*bytes];
      code_err_bus <= tmp_signal[11*bytes-1:10*bytes];

      if((init_rd_n === 1'b0) && (init_mode === 1'b0)) begin
	rd <= init_rd_val;
      end else if((init_rd_n === 1'b1) || (init_mode === 1'b1)) begin
	rd <= tmp_signal[11*bytes];
      end else begin
	rd <= 1'bx;
      end

    end else begin
      data_out <= {bytes*8{1'bx}};
      k_char <= {bytes{1'bx}};
      rd <= 1'bx;
      error <= 1'bx;
      rd_err <= 1'bx;
      code_err <= 1'bx;
    end

  end // PROC_mk_regs_sr
  end else begin : GEN_RM_NE_0_EM_NE_0
  always @ (posedge clk) begin : mk_regs_sr_PROC
    reg[11*bytes+2:0]	tmp_signal;

    if (rst_n === 1'b0) begin
      rd <= 1'b0;
      error <= 1'b0;
      rd_err <= 1'b0;
      code_err <= 1'b0;
      k_char <= {bytes{1'b0}};
      data_out <= {bytes*8{1'b0}};
      rd_err_bus <= {bytes{1'b0}};
      code_err_bus <= {bytes{1'b0}};
    end else if (rst_n === 1'b1) begin
      if (enable === 1'b1) begin
	task_decode_10b_to_8b_bytes(rd_int_selected, tmp_signal);
	data_out <= tmp_signal[bytes*8-1:0];
	k_char <= tmp_signal[bytes*9-1:bytes*8];
	error <= tmp_signal[11*bytes+1] | tmp_signal[11*bytes+2];
	rd_err <= tmp_signal[11*bytes+1];
	code_err <= tmp_signal[11*bytes+2];
	rd_err_bus <= tmp_signal[10*bytes-1:9*bytes];
	code_err_bus <= tmp_signal[11*bytes-1:10*bytes];

	if((init_rd_n === 1'b0) && (init_mode === 1'b0)) begin
	  rd <= init_rd_val;
	end else if((init_rd_n === 1'b1) || (init_mode === 1'b1)) begin
	  rd <= tmp_signal[11*bytes];
	end else begin
	  rd <= 1'bx;
	end

      end else if (enable !== 1'b0) begin
        data_out <= {bytes*8{1'bx}};
        k_char <= {bytes{1'bx}};
        rd <= 1'bx;
        error <= 1'bx;
        rd_err <= 1'bx;
        code_err <= 1'bx;
      end

    end else begin
      data_out <= {bytes*8{1'bx}};
      k_char <= {bytes{1'bx}};
      rd <= 1'bx;
      error <= 1'bx;
      rd_err <= 1'bx;
      code_err <= 1'bx;
    end
  end // PROC_mk_regs_sr
 end
 end
endgenerate


  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (bytes < 1) || (bytes > 16 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter bytes (legal range: 1 to 16 )",
	bytes );
    end
  
    if ( (k28_5_only < 0) || (k28_5_only > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter k28_5_only (legal range: 0 to 1 )",
	k28_5_only );
    end
  
    if ( (en_mode < 0) || (en_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter en_mode (legal range: 0 to 1 )",
	en_mode );
    end
  
    if ( (init_mode < 0) || (init_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter init_mode (legal range: 0 to 1 )",
	init_mode );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1 )",
	rst_mode );
    end
  
    if ( (op_iso_mode < 0) || (op_iso_mode > 4 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter op_iso_mode (legal range: 0 to 4 )",
	op_iso_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

endmodule
