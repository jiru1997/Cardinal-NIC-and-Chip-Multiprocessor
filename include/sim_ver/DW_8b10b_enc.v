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
// AUTHOR:    Jay Zhu              August 27, 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: ca50a219
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------
//
// ABSTRACT:  8b10b encoder
//	Parameters:
//		bytes : Number of bytes to encode.
//		k28_5_only : Special character subset control
//			parameter (0 for all special characters
//			decoded, 1 for only K28.5 decoded [when
//			k_char=HIGH implies K28.5, all other special
//			characters indicate a code error])
//		en_mode : enable input control (0 for no enable
//			input connection, 1 for enable input to
//			control all registers in encoder)
//		init_mode : Running Disparity initialization
//			control (0 for init_rd_val input to be
//			copied to rd output when init_rd_n is
//			active [low], 1 for init_rd_val to be
//			interpretted as the current RD when
//			init_rd_n is active [low])
//		rst_mode : reset mode
//			(0 = using asynchronous reset FFs
//			 1 = using synchronous reset FFs)
//              op_iso_mode : Operand Isolation Mode
//                      (0 = Follow intent defined by Power Compiler user setting
//                       1 = no operand isolation
//                       2 = 'and' gate isolaton
//                       3 = 'or' gate isolation
//                       4 = preferred isolation style: 'or' gate)
//
//	Inputs:
//		clk : 	Clock
//		rst_n :	Asynchronous reset, active low
//		init_rd_n : Synchronous initialization, active low
//		init_rd_val : Value of initial running disparity
//		k_char : Special character controls (one indicator
//			per decoded byte)
//		data_in : Input data for encoding
//	Outputs:
//		rd :	Current running disparity (before encoding data
//			presented at data_in)
//		data_out : decoded output data
//	Optional input:
//		enable : Stalls all registers when inactive (low).
//			 When the parameter, en_mode, is 0, the enable input
//			 is not used (registers al always enabled).  When
//			 en_mode is 1, the input, enable, controls registers.
//
// MODIFIED:
//
//      LMSU    2/3/16  Eliminated function calling from sequential always block
//                      in order for NLP tool to correctly infer FFs
//      RJK     2/10/15 Eliminated derived reset and enable signals
//	RJK	8/4/04	Added enable, enable_mode & init_mode
//      DLL     2/15/08 Added 'op_iso_mode' parameter and checking logic
//      RJK     10/6/08 Added rst_mode parameter to select reset type
//                      (STAR 9000270234)
//
//--------------------------------------------------------------------
 
module	DW_8b10b_enc(clk, rst_n, init_rd_n, init_rd_val, k_char,
		 data_in, rd, data_out, enable);

	parameter		bytes = 2;
	parameter		k28_5_only = 0;
	parameter		en_mode = 0;
	parameter		init_mode = 0;
	parameter		rst_mode = 0;
	parameter		op_iso_mode = 0;

	input			clk;
	input			rst_n;
	input			init_rd_n;
	input			init_rd_val;
	input[bytes-1:0]	k_char;
	input[bytes*8-1:0]	data_in;

	output			rd;
	output[bytes*10-1:0]	data_out;

	input			enable;

// synopsys translate_off
	wire			clk;
	wire			rst_n;
	wire			init_rd_n;
	wire			init_rd_val;
	wire[bytes-1:0]		k_char;
	wire[bytes*8-1:0]	data_in;

	reg			rd;
	reg[bytes*10-1:0]	data_out;


function 		any_unknown_9;
	input	[8:0]	A;

begin : any_unknown_9_function

	integer		bit_idx;

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

function [6:0]  abcdei_lookup;

	input[4:0]	EDCBA;
	input		RD_in;

	reg[5:0]	abcdei;
	reg		RD_out;
	reg[6:0]	abcdei_rd_tbl;

begin : block_abcdei_lookup

	abcdei_rd_tbl = {
	7'b1001111,	7'b0110000,
	7'b0111011,	7'b1000100,
	7'b1011011,	7'b0100100,
	7'b1100010,	7'b1100011,
	7'b1101011,	7'b0010100,
	7'b1010010,	7'b1010011,
	7'b0110010,	7'b0110011,
	7'b1110000,	7'b0001111,
	7'b1110011,	7'b0001100,
	7'b1001010,	7'b1001011,
	7'b0101010,	7'b0101011,
	7'b1101000,	7'b1101001,
	7'b0011010,	7'b0011011,
	7'b1011000,	7'b1011001,
	7'b0111000,	7'b0111001,
	7'b0101111,	7'b1010000,
	7'b0110111,	7'b1001000,
	7'b1000110,	7'b1000111,
	7'b0100110,	7'b0100111,
	7'b1100100,	7'b1100101,
	7'b0010110,	7'b0010111,
	7'b1010100,	7'b1010101,
	7'b0110100,	7'b0110101,
	7'b1110101,	7'b0001010,
	7'b1100111,	7'b0011000,
	7'b1001100,	7'b1001101,
	7'b0101100,	7'b0101101,
	7'b1101101,	7'b0010010,
	7'b0011100,	7'b0011101,
	7'b1011101,	7'b0100010,
	7'b0111101,	7'b1000010,
	7'b1010111,	7'b0101000
		}
			>> (((31-EDCBA)*2+(1-RD_in))*7);

	abcdei = abcdei_rd_tbl[6:1];
	RD_out = abcdei_rd_tbl[0];

	abcdei_lookup = {abcdei, RD_out};

	disable block_abcdei_lookup;

end
endfunction
	

function [4:0]	fghj_lookup;

	input[2:0]	HGF;
	input		RD_in;

	reg[3:0]	fghj;
	reg		RD_out;
	reg[4:0]	fghj_rd_tbl;

begin : block_fghj_lookup

	fghj_rd_tbl = {
	5'b10111,	5'b01000,
	5'b10010,	5'b10011,
	5'b01010,	5'b01011,
	5'b11000,	5'b00111,
	5'b11011,	5'b00100,
	5'b10100,	5'b10101,
	5'b01100,	5'b01101,
	5'b11101,	5'b00010
		}
			>> (((7-HGF)*2 + (1-RD_in))*5);
	fghj = fghj_rd_tbl[4:1];
	RD_out = fghj_rd_tbl[0];

	fghj_lookup = {fghj, RD_out};
	disable block_fghj_lookup;
end
endfunction


function [10:0]	encode_8b_to_10b;
	input[31:0]	byte_idx;
	input		k_char;
	input		RD_in;

begin : block_encode_8b_to_10b
	reg[7:0]	HGFEDCBA;
	reg[9:0]	abcdeifghj;
	reg		RD_out;
	integer		bit_idx;

	for(bit_idx=7; bit_idx>=0; bit_idx=bit_idx-1)
	begin
	  HGFEDCBA[bit_idx] = data_in[byte_idx*8+bit_idx];
	end

	if (k_char == 1'b1)
	begin 

	  if (k28_5_only == 1)
	  begin 

	    if (RD_in == 1'b0)
	    begin
	      abcdeifghj = 10'b0011111010;
	      RD_out = 1'b1 ;
	    end
	    else
	    begin
	      abcdeifghj = 10'b1100000101;
	      RD_out = 1'b0 ;
	    end 
	  end

	  else
	  begin

	    case ({HGFEDCBA ,RD_in } )
	    // case (HGFEDCBA_rd )
	      9'b000111000: begin
		abcdeifghj = 10'b0011110100;
		RD_out = 1'b0 ;
	      end
	      9'b000111001: begin
		abcdeifghj = 10'b1100001011;
		RD_out = 1'b1 ;
	      end
	      9'b001111000: begin
		abcdeifghj = 10'b0011111001;
		RD_out = 1'b1 ;
	      end
	      9'b001111001: begin
		abcdeifghj = 10'b1100000110;
		RD_out = 1'b0 ;
	      end
	      9'b010111000: begin
		abcdeifghj = 10'b0011110101;
		RD_out = 1'b1 ;
	      end
	      9'b010111001: begin
		abcdeifghj = 10'b1100001010;
		RD_out = 1'b0 ;
	      end
	      9'b011111000: begin
		abcdeifghj = 10'b0011110011;
		RD_out = 1'b1 ;
	      end
	      9'b011111001: begin
		abcdeifghj = 10'b1100001100;
		RD_out = 1'b0 ;
	      end
	      9'b100111000: begin
		abcdeifghj = 10'b0011110010;
		RD_out = 1'b0 ;
	      end
	      9'b100111001: begin
		abcdeifghj = 10'b1100001101;
		RD_out = 1'b1 ;
	      end
	      9'b101111000: begin
		abcdeifghj = 10'b0011111010;
		RD_out = 1'b1 ;
	      end
	      9'b101111001: begin
		abcdeifghj = 10'b1100000101;
		RD_out = 1'b0 ;
	      end
	      9'b110111000: begin
		abcdeifghj = 10'b0011110110;
		RD_out = 1'b1 ;
	      end
	      9'b110111001: begin
		abcdeifghj = 10'b1100001001;
		RD_out = 1'b0 ;
	      end
	      9'b111111000: begin
		abcdeifghj = 10'b0011111000;
		RD_out = 1'b0 ;
	      end
	      9'b111111001: begin
		abcdeifghj = 10'b1100000111;
		RD_out = 1'b1 ;
	      end
	      9'b111101110: begin
		abcdeifghj = 10'b1110101000;
		RD_out = 1'b0 ;
	      end
	      9'b111101111: begin
		abcdeifghj = 10'b0001010111;
		RD_out = 1'b1 ;
	      end
	      9'b111110110: begin
		abcdeifghj = 10'b1101101000;
		RD_out = 1'b0 ;
	      end
	      9'b111110111: begin
		abcdeifghj = 10'b0010010111;
		RD_out = 1'b1 ;
	      end
	      9'b111111010: begin
		abcdeifghj = 10'b1011101000;
		RD_out = 1'b0 ;
	      end
	      9'b111111011: begin
		abcdeifghj = 10'b0100010111;
		RD_out = 1'b1 ;
	      end
	      9'b111111100: begin
		abcdeifghj = 10'b0111101000;
		RD_out = 1'b0 ;
	      end
	      9'b111111101: begin
		abcdeifghj = 10'b1000010111;
		RD_out = 1'b1 ;
	      end
	      default: begin
		abcdeifghj = 10'bx ;
		RD_out = 1'bx ;
		$display ("Warning: data on DW_8b10_enc's data_in is invalid for k_char=1 and k28_5_only=0.");
	      end
	    endcase
	  end

	end

	else if (k_char ==1'b0)
	begin 
	  if ( (any_unknown_9 ({HGFEDCBA ,RD_in }) == 1'b1 ))
	  begin 
	    abcdeifghj = 10'bx ;
	    RD_out = 1'bx ;
	  end
	  else
	  begin : no_X_input
	    reg[6:0]	abcdei_rd;
	    reg[4:0]	fghj_rd;

	    abcdei_rd = abcdei_lookup(HGFEDCBA[4:0], RD_in);

	    if (HGFEDCBA[7:5]==3'b111)
	    begin
	      if ((HGFEDCBA[4:0]==5'b01011 ||
	           HGFEDCBA[4:0]==5'b01101 ||
	           HGFEDCBA[4:0]==5'b01110) &&
		  abcdei_rd[0] == 1'b1)
	      begin
		fghj_rd = 5'b10000;
	      end
	      else if ((HGFEDCBA[4:0]==5'b10001 ||
	                HGFEDCBA[4:0]==5'b10010 ||
	                HGFEDCBA[4:0]==5'b10100) &&
		       abcdei_rd[0] == 1'b0)
	      begin
		fghj_rd = 5'b01111;
	      end
	      else 
	      begin
		fghj_rd = fghj_lookup(HGFEDCBA[7:5], abcdei_rd[0]);
	      end
	    end
	    else
	    begin
	      fghj_rd = fghj_lookup(HGFEDCBA[7:5], abcdei_rd[0]);
	    end

	    abcdeifghj = {abcdei_rd[6:1], fghj_rd[4:1]};
	    RD_out = fghj_rd[0];
	  end
	end

	else
	begin
	  abcdeifghj = 10'bx ;
	  RD_out = 1'bx ;
	end 

	encode_8b_to_10b = {abcdeifghj ,RD_out};

	disable block_encode_8b_to_10b;
end
endfunction


task task_encode_8b_to_10b_bytes;
	input		        RD_in;
        output  [10*bytes:0]    encode_8b_to_10b_bytes;

begin : block_encode_8b_to_10b_bytes
	integer		byte_idx;
	integer		bit_idx;
	reg[10:0]	tmp_signal;
	reg		rd_int;


	rd_int = RD_in;
	for (byte_idx=bytes-1; byte_idx>=0; byte_idx=byte_idx-1)
	begin
	  tmp_signal = encode_8b_to_10b(
				byte_idx,
				k_char[byte_idx],
				rd_int
				);
	  for(bit_idx=10-1; bit_idx>=0; bit_idx=bit_idx-1)
	  begin
	    encode_8b_to_10b_bytes[byte_idx*10+bit_idx] =
				tmp_signal[bit_idx+1];
	  end

	  rd_int = tmp_signal[0];

	end
	encode_8b_to_10b_bytes[bytes*10] = rd_int;

end 
endtask



initial
begin

	if (k28_5_only<0 || k28_5_only>1 || bytes<1 || bytes>16)
	begin
	  if (k28_5_only<0 || k28_5_only>1)
	  begin
	    $display ("Error: k28_5_only(%0d) parameter of DW_8b10b_enc is out of legal range(0 to 1)",
		k28_5_only);
	  end

	  if (bytes<1 || bytes>16)
	  begin
	    $display ("Error: bytes(%0d) parameter of DW_8b10b_enc is out of legal range(1 to 16)",
		bytes);
	  end

	  $finish;
	end

end


generate
 if (rst_mode == 0) begin : GEN_RM_EQ_0
   if (en_mode == 0) begin : GEN_RM_EQ_0_EM_EQ_0
    always @ (posedge clk or negedge rst_n) begin: encoder_top_level_ar_PROC
	reg 			rd_effect;
	reg[10*bytes:0]		tmp_signal;

	if (rst_n == 1'b0) begin
	  rd <= 1'b0;
	  data_out <= {bytes*10{1'b0}};
	end
	else if (rst_n == 1'b1) begin
	  if (init_mode == 0 || init_rd_n === 1'b1)
	    rd_effect = rd;
	  else if (init_rd_n === 1'b0)
	    rd_effect = init_rd_val;
	  else
	    rd_effect = 1'bx;
	  task_encode_8b_to_10b_bytes(rd_effect, tmp_signal);
	  data_out <= tmp_signal[bytes*10-1:0];
	  rd <= tmp_signal[10*bytes];

	  if (init_mode == 0) begin
	    if(init_rd_n == 1'b0) begin
	      rd <= init_rd_val;
	    end
	    else if(init_rd_n !== 1'b1) begin
	      rd <= 1'bx;
	    end
	  end

	end

	else
	begin
	  data_out <= {bytes*10{1'bx}};
	  rd <= 1'bx;
	end

    end
   end else begin : GEN_RM_EQ_0_EM_NE_0
    always @ (posedge clk or negedge rst_n) begin: encoder_top_level_ar_PROC
	reg 			rd_effect;
	reg[10*bytes:0]		tmp_signal;

	if (rst_n === 1'b0) begin
	  rd <= 1'b0;
	  data_out <= {bytes*10{1'b0}};
	end
	else if (rst_n === 1'b1) begin
	  if(enable == 1'b1) begin 
	    if (init_mode == 0 || init_rd_n === 1'b1)
	      rd_effect = rd;
	    else if (init_rd_n === 1'b0)
	      rd_effect = init_rd_val;
	    else
	      rd_effect = 1'bx;
	    task_encode_8b_to_10b_bytes(rd_effect, tmp_signal);
	    data_out <= tmp_signal[bytes*10-1:0];
	    rd <= tmp_signal[10*bytes];

	    if (init_mode == 0) begin
	      if(init_rd_n == 1'b0) begin
	        rd <= init_rd_val;
	      end
	      else if(init_rd_n !== 1'b1) begin
	        rd <= 1'bx;
	      end
	    end
	  end

	end

	else
	begin
	  data_out <= {bytes*10{1'bx}};
	  rd <= 1'bx;
	end

    end
   end
 end else begin : GEN_RM_NE_0
   if (en_mode == 0) begin : GEN_RM_NE_0_EM_EQ_0
    always @ (posedge clk) begin: encoder_top_level_sr_PROC
	reg 			rd_effect;
	reg[10*bytes:0]		tmp_signal;

	if (rst_n === 1'b0) begin
	  rd <= 1'b0;
	  data_out <= {bytes*10{1'b0}};
	end
	else if (rst_n === 1'b1) begin
	  if (init_mode == 0 || init_rd_n === 1'b1)
	    rd_effect = rd;
	  else if (init_rd_n === 1'b0)
	    rd_effect = init_rd_val;
	  else
	    rd_effect = 1'bx;
	  task_encode_8b_to_10b_bytes(rd_effect, tmp_signal);
	  data_out <= tmp_signal[bytes*10-1:0];
	  rd <= tmp_signal[10*bytes];

	  if (init_mode == 0) begin
	    if(init_rd_n == 1'b0) begin
	      rd <= init_rd_val;
	    end
	    else if(init_rd_n !== 1'b1) begin
	      rd <= 1'bx;
	    end
	  end

	end

	else
	begin
	  data_out <= {bytes*10{1'bx}};
	  rd <= 1'bx;
	end

    end
   end else begin : GEN_RM_NE_0_EM_NE_0
    always @ (posedge clk) begin: encoder_top_level_sr_PROC
	reg 			rd_effect;
	reg[10*bytes:0]		tmp_signal;

	if (rst_n === 1'b0) begin
	  rd <= 1'b0;
	  data_out <= {bytes*10{1'b0}};
	end
	else if (rst_n === 1'b1) begin
	  if(enable == 1'b1) begin 
	    if (init_mode == 0 || init_rd_n === 1'b1)
	      rd_effect = rd;
	    else if (init_rd_n === 1'b0)
	      rd_effect = init_rd_val;
	    else
	      rd_effect = 1'bx;
	    task_encode_8b_to_10b_bytes(rd_effect, tmp_signal);
	    data_out <= tmp_signal[bytes*10-1:0];
	    rd <= tmp_signal[10*bytes];

	    if (init_mode == 0) begin
	      if(init_rd_n == 1'b0) begin
	        rd <= init_rd_val;
	      end
	      else if(init_rd_n !== 1'b1) begin
	        rd <= 1'bx;
	      end
	    end

	  end

	end

	else
	begin
	  data_out <= {bytes*10{1'bx}};
	  rd <= 1'bx;
	end

    end
   end
 end
endgenerate

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (bytes < 1) || (bytes > 16) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter bytes (legal range: 1 to 16)",
	bytes );
    end
  
    if ( (k28_5_only < 0) || (k28_5_only > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter k28_5_only (legal range: 0 to 1)",
	k28_5_only );
    end
  
    if ( (en_mode < 0) || (en_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter en_mode (legal range: 0 to 1)",
	en_mode );
    end
  
    if ( (init_mode < 0) || (init_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter init_mode (legal range: 0 to 1)",
	init_mode );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1)",
	rst_mode );
    end
  
    if ( (op_iso_mode < 0) || (op_iso_mode > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter op_iso_mode (legal range: 0 to 4)",
	op_iso_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  
  always @ (clk) begin : PROC_check_clk
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // PROC_check_clk

// synopsys translate_on
endmodule
