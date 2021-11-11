////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2000 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann         Jun 15, 2000
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 31364679
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT:  Arbiter with dynamic priority scheme
//   
// MODIFIED:
//           01/02/02  RPH      Added output_mode and fixed the X-processing
//           02/12/03  RJK	Updated for width mismatches (STAR 162032)
//           10/13/10  RJK      Corrected "lock while in park state" issue
//           12/15/10  RJK	Updated reset state to be consistant with
//				  normal idle/parked operation
//	     09/17/13  RJK      Updated synchronous reset (init_n) operation
//                                (STAR 9000668457)
//
//----------------------------------------------------------------------------- 

module DW_arb_dp (clk, rst_n, init_n, enable, request, prior, lock, mask, 
                      parked, granted, locked, grant, grant_index);

  parameter n          = 4; 
  parameter park_mode  = 1;
  parameter park_index = 0;
  parameter output_mode = 1;

  `define DW_index_width ((n>16)?((n>64)?((n>128)?8:7):((n>32)?6:5)):((n>4)?((n>8)?4:3):((n>2)?2:1)))

  input  clk, rst_n, init_n;
  input  enable;	 // active high register enable
  input  [n-1 : 0] request, lock, mask;
  input  [`DW_index_width*n-1 : 0] prior;
  output parked, granted, locked;
  output [n-1 : 0] grant;
  output [`DW_index_width-1 : 0] grant_index;

  wire clk, rst_n;
  wire [n-1 : 0] request, lock, mask;
  wire [`DW_index_width*n-1 : 0] prio;
  wire  parked, granted, locked;
  wire [n-1 : 0] grant;
  wire [`DW_index_width-1 : 0] grant_index;

  integer grant_index_int, grant_index_next;
  reg     parked_next, granted_next, locked_next;
  reg 	  parked_int, granted_int, locked_int;

  // synopsys translate_off

  //---------------------------------------------------------------------------
  // Behavioral model
  //---------------------------------------------------------------------------
  assign prio = prior;
  always @(grant_index_int or granted_int or request or lock or mask or prio)
  begin : arbitrate
    reg [n-1 : 0] request_masked_v;
    reg parked_v, granted_v, locked_v;
    reg request_x, lock_x, mask_x, priority_x;
    reg [`DW_index_width*n-1 : 0] priority_tmp;
    integer priority_v[n-1 : 0];
    integer grant_index_v;
    integer i;

    request_x  = ^request;
    lock_x     = ^lock;
    mask_x     = ^mask;
    priority_x = ^prio;

      grant_index_v = -1;
      parked_v      = 1'b0;
      granted_v     = 1'b0;
      locked_v      = 1'b0;
      priority_tmp = prio;
      for (i = 0; i < n; i = i+1) begin
        priority_v[i] = priority_tmp[`DW_index_width-1 : 0];
        priority_tmp  = priority_tmp >> `DW_index_width;
      end
      request_masked_v = request & ~mask;
		if ((grant_index_int < -1) && (lock !== {n{1'b0}})) begin
			  grant_index_v = -2;
			  locked_v      = 1'bx;
			  granted_v     = 1'bx;
		end
		else if ((grant_index_int >= 0) &&
			((granted_int & lock[grant_index_int]) !== 1'b0)) begin
		   if ((granted_int & lock[grant_index_int]) === 1'b1) begin
			  grant_index_v = grant_index_int;
			  locked_v      = 1'b1;
			  granted_v     = 1'b1;
			  //if (granted_int === 1'b0) update_priorities_v = 1;
		   end
		   else begin
			  grant_index_v = -2;
			  locked_v      = 1'bx;
			  granted_v     = 1'bx;
			  parked_v      = 1'b0;
		   end 
		end 
		else if (request_masked_v !== {n{1'b0}}) begin
		   if (request_x === 1'bx || priority_x === 1'bx ) begin
			  grant_index_v = -2;
			  granted_v = 1'bx;
			  parked_v      = 1'bx;
		   end 
		   else begin		   
			  for (i = 0; i < n; i = i+1) begin
				 if (request_masked_v[i] === 1'b1) begin
					if ((grant_index_v < 0) || (priority_v[i] < priority_v[grant_index_v])) begin
					   grant_index_v = i;
					end
				 end
			  end
			  granted_v = 1'b1;
		   end // else: !if(request_x === 1'bx || priority_x === 1'bx )
		end // if (request_masked_v !== {n{1'b0}})
		else if (park_mode == 1) begin
           grant_index_v = park_index;
           parked_v      = 1'b1;
		end
		else begin
           grant_index_v = -1;
		end 
    grant_index_next = grant_index_v;
    parked_next      = parked_v;
    granted_next     = granted_v;
    locked_next      = locked_v;
  end // block: arbitrate
   

  always @(posedge clk or negedge rst_n)
  begin : register
    if (rst_n === 1'b0) begin
       grant_index_int     <= (park_mode==1)? park_index : -1;
       parked_int          <= (park_mode==1)? 1'b1 : 1'b0;
       granted_int         <= 1'b0;
       locked_int          <= 1'b0;
    end else if (rst_n === 1'b1) begin 
      if (init_n === 1'b0) begin
        grant_index_int     <= (park_mode==1)? park_index : -1;
        parked_int          <= (park_mode==1)? 1'b1 : 1'b0;
        granted_int         <= 1'b0;
        locked_int          <= 1'b0;
      end else if (init_n === 1'b1) begin
        if(enable) begin
          grant_index_int     <= grant_index_next;
          parked_int          <= parked_next;
          granted_int         <= granted_next;
          locked_int          <= locked_next;
        end
      end else begin
        grant_index_int     <= -2;
        parked_int          <= 1'bx;
        granted_int         <= 1'bx;
        locked_int          <= 1'bx;
      end
    end else begin
      grant_index_int     <= -2;
      parked_int          <= 1'bx;
      granted_int         <= 1'bx;
      locked_int          <= 1'bx;
    end
  end // register

  assign grant = ((output_mode==0) && (park_mode==0) && (init_n==1'b0))? {n{1'b0}} :
                 ((output_mode==0) && (park_mode==1) && (init_n==1'b0))? 1'b1 << park_index :
                 (grant_index_int == -2)? {n{1'bx}} :
		 (grant_index_next == -1 && output_mode == 0) ? {n{1'b0}} :
		 (output_mode == 0 ) ? 1'b1 << grant_index_next :
                 1'b1 << grant_index_int;
   assign grant_index = ((output_mode==0) && (park_mode==0) && (init_n==1'b0))? {`DW_index_width{1'b1}} :
                       ((output_mode==0) && (park_mode==1) && (init_n==1'b0))? park_index :
                       (grant_index_int == -2)? {`DW_index_width{1'bx}} :
                       (grant_index_int == -1 && output_mode == 1) ? {`DW_index_width{1'b1}} :
	               (grant_index_next == -1 && output_mode == 0) ? {`DW_index_width{1'b1}} :
                       (output_mode == 0) ? grant_index_next[`DW_index_width-1:0] :
                       grant_index_int[`DW_index_width-1:0];
  assign granted = ((output_mode==0) && (init_n==1'b0))? 1'b0 :
                   output_mode == 0 ? granted_next : 
	           granted_int;
   
  assign parked = ((output_mode==0) && (park_mode==0) && (init_n==1'b0))? 1'b0 :
                  ((output_mode==0) && (park_mode==1) && (init_n==1'b0))? 1'b1 :
                   output_mode == 0 ? parked_next : 
	           parked_int;
  assign locked = ((output_mode==0) && (init_n==1'b0))? 1'b0 :
                  output_mode == 0 ? locked_next : 
	          locked_int;


  //---------------------------------------------------------------------------
  // Parameter legality check and initializations
  //---------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if ( (n < 1) || (n > 32) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter n (legal range: 1 to 32)",
	n );
    end
    
    if ( (park_mode < 0) || (park_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter park_mode (legal range: 0 to 1)",
	park_mode );
    end
    
    if ( (park_index < 0) || (park_index > 31) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter park_index (legal range: 0 to 31)",
	park_index );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  //---------------------------------------------------------------------------
  // Report unknown clock inputs
  //---------------------------------------------------------------------------
  
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 
    
  // synopsys translate_on

  `undef DW_index_width 
endmodule

//-----------------------------------------------------------------------------
