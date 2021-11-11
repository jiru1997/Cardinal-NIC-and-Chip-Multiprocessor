////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1995 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly         10/18/99
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: ed1d7656
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Synchronous with Dynamic Flags  
//           dynamic programmable almost empty and almost full flags
//
//           This FIFO controller designed to interface to synchronous
//           true dual port RAMs.
//
//              Parameters:     Valid Values
//              ==========      ============
//              depth           [ 2 to 16777216 ]
//              err_mode        [ 0 = sticky error flag w/ ptr check,
//                                1 = sticky error flag (no ptr chk),
//                                2 = dynamic error flag ]
//              reset_mode      [ 0 = asynchronous reset,
//                                1 = synchronous reset ]
//              
//              Input Ports:    Size    Description
//              ===========     ====    ===========
//              clk             1 bit   Input Clock
//              rst_n           1 bit   Active Low Reset
//              push_req_n      1 bit   Active Low Push Request
//              pop_req_n       1 bit   Active Low Pop Request
//              diag_n          1 bit   Active Low diagnostic control
//              ae_level        N bits  Almost Empty Level
//              af_thresh       N bits  Almost Full Threshold
//
//              Output Ports    Size    Description
//              ============    ====    ===========
//              we_n            1 bit   Active low Write Enable (to RAM)
//              empty           1 bit   Empty Flag
//              almost_empty    1 bit   Almost Empty Flag
//              half_full       1 bit   Half Full Flag
//              almost_full     1 bit   Almost Full Flag
//              full            1 bit   Full Flag
//              error           1 bit   Error Flag
//              wr_addr         N bits  Write Address (to RAM)
//              rd_addr         N bits  Read Address (to RAM)
//
//                Note: the value of N for wr_addr and rd_addr is
//                      determined from the parameter, depth.  The
//                      value of N is equal to:
//                              ceil( log2( depth ) )
//              
//
//
// MODIFIED: 
//
//  11/12/01  RJK  Fixed lint error by converting int to vector
//                 STAR #129582
//-------------------------------------------------------------------------------
//
module DW_fifoctl_s1_df (
    clk, rst_n, push_req_n, pop_req_n, diag_n, ae_level, af_thresh, we_n, empty, 
    almost_empty, half_full, almost_full, full, error, wr_addr, rd_addr );

parameter depth  = 4;
parameter err_mode  =  0 ;
parameter rst_mode  =  0 ;

`define DW_addr_width ((depth>4096)? ((depth>262144)? ((depth>2097152)? ((depth>8388608)? 24 : ((depth> 4194304)? 23 : 22)) : ((depth>1048576)? 21 : ((depth>524288)? 20 : 19))) : ((depth>32768)? ((depth>131072)?  18 : ((depth>65536)? 17 : 16)) : ((depth>16384)? 15 : ((depth>8192)? 14 : 13)))) : ((depth>64)? ((depth>512)?  ((depth>2048)? 12 : ((depth>1024)? 11 : 10)) : ((depth>256)? 9 : ((depth>128)? 8 : 7))) : ((depth>8)? ((depth> 32)? 6 : ((depth>16)? 5 : 4)) : ((depth>4)? 3 : ((depth>2)? 2 : 1)))))

 input  clk,  rst_n,  push_req_n,  pop_req_n,  diag_n;
 input [`DW_addr_width-1 : 0 ] ae_level, af_thresh;
 output  we_n,  empty,  almost_empty,  half_full,  almost_full,  full, error;
 output [`DW_addr_width-1 : 0 ]  wr_addr, rd_addr;
 
    // synopsys translate_off

 wire diag_n_int, we_n, empty, full, error;

 reg empty_int, next_almost_empty, almost_empty, half_full;
 reg almost_full, next_almost_full, full_int, next_error_int, error_int;
wire [`DW_addr_width-1 : 0 ] wr_addr, rd_addr;

 integer wrd_count, next_wrd_count;
 integer wr_addr_int, next_wr_addr_int;
 integer rd_addr_int, next_rd_addr_int;
 wire [31:0] rd_addr_vec, wr_addr_vec;

    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    

	
    if ( (err_mode < 0) || (err_mode > 2 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 2 )",
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



    assign diag_n_int = (err_mode == 0)? diag_n : 1'b1;



    always @ (push_req_n or pop_req_n or full_int or wr_addr_int)
	begin : mk_next_wr_addr_int

	if ((push_req_n === 1'b0) && ((full_int === 1'b0)||(pop_req_n === 1'b0)))
	    next_wr_addr_int = (wr_addr_int + 1) % depth;
	
	else
	    next_wr_addr_int = ((push_req_n === 1'b1) || (full_int === 1'b1))?
			    wr_addr_int : -1;
    end // mk_next_wr_addr_int



    always @ (pop_req_n or empty_int or diag_n_int or rd_addr_int)
	begin : mk_next_rd_addr_int
	if (diag_n_int === 1'b0)
	    next_rd_addr_int = 0;
	
	else begin
	    if ((diag_n_int === 1'b1) && (pop_req_n === 1'b0) && (empty_int === 1'b0))
		next_rd_addr_int = (rd_addr_int + 1) % depth;
	    
	    else
		next_rd_addr_int = (((pop_req_n === 1'b1) || (empty_int === 1'b1)) && (diag_n_int === 1'b1))?
				rd_addr_int : -1;
	end
    end // mk_next_rd_addr_int



    always @ (push_req_n or pop_req_n or wrd_count)
	begin : mk_next_wrd_count
	if ( wrd_count < 0 )
	    next_wrd_count = wrd_count;
	
	else
	    if ((push_req_n === 1'b1) && (pop_req_n === 1'b0) && (wrd_count != 0))
		next_wrd_count = wrd_count - 1;
	    
	    else
		if ( ((push_req_n === 1'b0) && (pop_req_n === 1'b0) && (wrd_count == 0)) ||
		     ((push_req_n === 1'b0) && (pop_req_n === 1'b1) && (wrd_count < depth)) )

		    next_wrd_count = wrd_count + 1;
		
		else
		    if ( ((push_req_n === 1'b0) && (pop_req_n === 1'b0) && (wrd_count > 0)) ||
			 ((push_req_n === 1'b0) && (pop_req_n === 1'b1) && (wrd_count == depth)) ||
			 ((push_req_n === 1'b1) && (pop_req_n === 1'b0) && (wrd_count == 0)) ||
			 ((push_req_n === 1'b1) && (pop_req_n === 1'b1)) )
			
			next_wrd_count = wrd_count;
		    
		    else
			next_wrd_count = -1;

    end // mk_next_wrd_count



    always @ (push_req_n or pop_req_n or rd_addr_int or
		    wr_addr_int or wrd_count or next_wrd_count or error_int)
	begin : mk_next_error

	if ((err_mode < 2) && (error_int !== 1'b0))
	    next_error_int = error_int;
	
	else
	    if ((err_mode == 0) && (rd_addr_int >= 0) && (wr_addr_int >= 0) &&
		  ( ((rd_addr_int == wr_addr_int) && (wrd_count > 0) && (wrd_count < depth))  ||
		    ((rd_addr_int != wr_addr_int) && ((wrd_count == 0) || (wrd_count == depth))) ))
	    
		next_error_int = 1'b1;
	    
	    else
		next_error_int =
			    (wrd_count == 0)? ~pop_req_n :
			    (wrd_count == depth)? (pop_req_n & ~push_req_n) :
			    ((wrd_count < 0)&&((push_req_n & pop_req_n)==1'b0))? 1'bx : 1'b0;
		    
    end // mk_next_error



    always @ (next_wrd_count or ae_level)
	begin : mk_next_almost_empty
	if (next_wrd_count < 0)
	    next_almost_empty = 1'bx;
	
	else
	    next_almost_empty = (next_wrd_count > ae_level)?
				1'b0 : 1'b1;

    end // mk_next_almost_empty



    always @ (next_wrd_count or af_thresh)
	begin : mk_next_almost_full
	if (next_wrd_count < 0)
	    next_almost_full = 1'bx;
	
	else
	    next_almost_full = (next_wrd_count < af_thresh)?
				1'b0 : 1'b1;

    end // mk_next_almost_full


generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0
    always @ (posedge clk or negedge rst_n)
	begin : ar_registers_PROC

	if (rst_n === 1'b0) begin
	    wr_addr_int <= 0;
	    rd_addr_int <= 0;
	    wrd_count <= 0;
	    almost_empty <= 1'b1;
	    almost_full <= 1'b0;
	    error_int <= 1'b0;
	end

	else
	    if (rst_n === 1'b1) begin
		wr_addr_int <= next_wr_addr_int;
		rd_addr_int <= next_rd_addr_int;
		wrd_count <= next_wrd_count;
		almost_empty <= next_almost_empty;
		almost_full <= next_almost_full;
		error_int <= next_error_int;
	    end

	    else begin
		wr_addr_int <= -1;
		rd_addr_int <= -1;
		wrd_count <= -1;
		almost_empty <= 1'bx;
		almost_full <= 1'bx;
		error_int <= 1'bx;
	    end
    end // ar_registers_PROC
  end else begin : GEN_RM_NE_0
    always @ (posedge clk)
	begin : sr_registers_PROC

	if (rst_n === 1'b0) begin
	    wr_addr_int <= 0;
	    rd_addr_int <= 0;
	    wrd_count <= 0;
	    almost_empty <= 1'b1;
	    almost_full <= 1'b0;
	    error_int <= 1'b0;
	end

	else
	    if (rst_n === 1'b1) begin
		wr_addr_int <= next_wr_addr_int;
		rd_addr_int <= next_rd_addr_int;
		wrd_count <= next_wrd_count;
		almost_empty <= next_almost_empty;
		almost_full <= next_almost_full;
		error_int <= next_error_int;
	    end

	    else begin
		wr_addr_int <= -1;
		rd_addr_int <= -1;
		wrd_count <= -1;
		almost_empty <= 1'bx;
		almost_full <= 1'bx;
		error_int <= 1'bx;
	    end
    end // sr_registers_PROC
  end
endgenerate


    always @ (wrd_count)
	begin : mk_flags

	if ( wrd_count < 0 ) begin
	    empty_int = 1'bx;
	    half_full = 1'bx;
	    full_int = 1'bx;
	end

	else begin
	    if (wrd_count == 0)
		empty_int = 1'b1;
	    
	    else
		empty_int = 1'b0;
	    

	    if ( wrd_count < ((depth  +  1 )/ 2 ) )
		half_full = 1'b0;
	    
	    else
		half_full = 1'b1;
	    

	    if ( wrd_count == depth )
		full_int = 1'b1;
	    
	    else
		full_int = 1'b0;
        end

    end // mk_flags

		
    assign wr_addr_vec = wr_addr_int;
    assign rd_addr_vec = rd_addr_int;
    assign wr_addr = (wr_addr_int < 0)? {`DW_addr_width{1'bx}} : wr_addr_vec[`DW_addr_width-1:0];
    assign rd_addr = (rd_addr_int < 0)? {`DW_addr_width{1'bx}} : rd_addr_vec[`DW_addr_width-1:0];


    assign  we_n  = (push_req_n  | (pop_req_n  & full_int ));
    assign  empty = empty_int;
    assign  full = full_int;
    assign  error = error_int;


    
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

    // synopsys translate_on

`undef DW_addr_width
endmodule
