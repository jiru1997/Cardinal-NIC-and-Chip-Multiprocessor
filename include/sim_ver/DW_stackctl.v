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
// AUTHOR:    ST                 Oct., 1997
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 1e378efb
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Stack Controller
//           This LIFO's operation is based on Synchronous single-port ram
//   
//           depth : legal range is 2 to 2^24
//           err_mode : legal range is 0 to 1
//           rst_mode : legal range is 0 to 1
//   
//           push request (active low) : push_req_n
//           pop request (active low) : pop_req_n
//           reset (active low) : rst_n
//           flags (active high) : full, empty, error
//   
//   
// MODIFIED:
//   10/08/1998 Jay Zhu, STAR 59741
//   10/22/1999 Reto Zimmermann, rewrite (separating sequential and 
//              combinatorial code)
//   11/12/2001 RJK  Fixed lint error by converting int to vector
//              STAR #129582
//   
//-------------------------------------------------------------------------------
//
module DW_stackctl (clk, rst_n, push_req_n, pop_req_n, 
		    we_n, full, empty, error, wr_addr, rd_addr);

  parameter depth = 8; 
  parameter err_mode = 0; 
  parameter rst_mode = 0;

  `define DW_addr_width ((depth>4096)? ((depth>262144)? ((depth>2097152)? ((depth>8388608)? 24 : ((depth> 4194304)? 23 : 22)) : ((depth>1048576)? 21 : ((depth>524288)? 20 : 19))) : ((depth>32768)? ((depth>131072)?  18 : ((depth>65536)? 17 : 16)) : ((depth>16384)? 15 : ((depth>8192)? 14 : 13)))) : ((depth>64)? ((depth>512)?  ((depth>2048)? 12 : ((depth>1024)? 11 : 10)) : ((depth>256)? 9 : ((depth>128)? 8 : 7))) : ((depth>8)? ((depth> 32)? 6 : ((depth>16)? 5 : 4)) : ((depth>4)? 3 : ((depth>2)? 2 : 1)))))

  input  clk, rst_n, push_req_n, pop_req_n;
  output we_n, full, empty, error;
  output [`DW_addr_width-1:0] wr_addr, rd_addr;

  wire   we_n, empty, full, error;

  reg    empty_int, full_int, error_int, next_error_int;
  wire   [`DW_addr_width-1:0] wr_addr, rd_addr;

  integer wr_addr_int, next_wr_addr_int;
  integer rd_addr_int, next_rd_addr_int;
  integer wrd_count, next_wrd_count;
 wire [31:0] rd_addr_vec, wr_addr_vec;
  
  // synopsys translate_off

 
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
 
    
    if ( (err_mode < 0) || (err_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 1 )",
	err_mode );
    end
    
    if ( (rst_mode < 0) || (rst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1 )",
	rst_mode );
    end
    
    if ( (depth < 2) || (depth > 1<<24 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 1<<24 )",
	depth );
    end

    wrd_count = -1;
    wr_addr_int = -1;
    rd_addr_int = -1;
    
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  always @ (push_req_n or pop_req_n or full_int or empty_int or wrd_count)
  begin : mk_next_wrd_count

    if (push_req_n === 1'b0) 
      if (full_int === 1'b0)
	next_wrd_count = wrd_count + 1;
      else
	next_wrd_count = wrd_count;
        
    else if (push_req_n === 1'b1) 
      if (pop_req_n === 1'b0)
	if (empty_int === 1'b0)
	  next_wrd_count = wrd_count - 1;
	else
	  next_wrd_count = wrd_count;

      else if (pop_req_n === 1'b1)
	next_wrd_count = wrd_count;

      else
	next_wrd_count = -1;

    else
      next_wrd_count = -1;

  end // mk_next_wrd_count


  always @ (next_wrd_count)
  begin : mk_next_addr
    next_wr_addr_int = (next_wrd_count == -1)?   -1 :
  		       (next_wrd_count < depth)? next_wrd_count :
  			                         depth - 1; 
    next_rd_addr_int = (next_wrd_count == -1)?   -1 :
  		       (next_wrd_count > 0)?     next_wrd_count - 1 :
  			                         0;
  end

  
  always @ (push_req_n or pop_req_n or full_int or empty_int or 
	    next_wrd_count or error_int)
  begin : mk_next_error

    if ((err_mode < 1) && (error_int !== 1'b0))
      next_error_int = error_int;
    
    else if (((push_req_n === 1'b0) && (full_int === 1'b1)) ||
	     ((pop_req_n === 1'b0) && (push_req_n === 1'b1) && 
	      (empty_int === 1'b1)))
      next_error_int = 1'b1;

    else if (next_wrd_count >= 0)
      next_error_int = 1'b0;

    else
      next_error_int = 1'bx;
    
  end // mk_next_error


generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0
    always @ (posedge clk or negedge rst_n)
    begin : ar_registers_PROC

      if (rst_n === 1'b0) begin
	wrd_count <= 0;
	wr_addr_int <= 0;
	rd_addr_int <= 0;
	error_int <= 1'b0;
      end

      else if (rst_n === 1'b1) begin
	wrd_count <= next_wrd_count;
	wr_addr_int <= next_wr_addr_int;
	rd_addr_int <= next_rd_addr_int;
	error_int <= next_error_int;
      end

      else begin
	wrd_count <= -1;
	wr_addr_int <= -1;
	rd_addr_int <= -1;
	error_int <= 1'bx;
      end
    end // ar_registers_PROC
  end else begin : GEN_RM_NE_0
    always @ (posedge clk)
    begin : sr_registers_PROC

      if (rst_n === 1'b0) begin
	wrd_count <= 0;
	wr_addr_int <= 0;
	rd_addr_int <= 0;
	error_int <= 1'b0;
      end

      else if (rst_n === 1'b1) begin
	wrd_count <= next_wrd_count;
	wr_addr_int <= next_wr_addr_int;
	rd_addr_int <= next_rd_addr_int;
	error_int <= next_error_int;
      end

      else begin
	wrd_count <= -1;
	wr_addr_int <= -1;
	rd_addr_int <= -1;
	error_int <= 1'bx;
      end
    end // sr_registers_PROC
  end
endgenerate

  always @ (wrd_count)
  begin : mk_flags

    if (wrd_count < 0) begin
      empty_int = 1'bx;
      full_int = 1'bx;
    end

    else begin
      if (wrd_count == 0)
	empty_int = 1'b1;
      else
	empty_int = 1'b0;
      
      if (wrd_count == depth)
	full_int = 1'b1;
      else
	full_int = 1'b0;
    end
    
  end // mk_flags


  assign wr_addr_vec = wr_addr_int;
  assign rd_addr_vec = rd_addr_int;
  assign wr_addr = (wr_addr_int < 0)? {`DW_addr_width{1'bx}} : wr_addr_vec[`DW_addr_width-1:0];
  assign rd_addr = (rd_addr_int < 0)? {`DW_addr_width{1'bx}} : rd_addr_vec[`DW_addr_width-1:0];

  assign we_n  = (push_req_n | full_int);
  assign empty = empty_int;
  assign full = full_int;
  assign error = error_int;


  
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

  // synopsys translate_on

`undef DW_addr_width
endmodule
