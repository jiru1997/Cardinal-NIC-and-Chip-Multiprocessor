////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2006 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Bruce Dean Jul 14 2006     
//
// VERSION:   
//
// DesignWare_version: 3942b61d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT :
//    Arbiter  Round-Robin arbitraton scheme.
//      Parameters      Valid Values    Description
//      ==========      =========       ===========
//      n               {2 to 256}       Number of arbiter clients
//      output_mode     {0 to 1}        Registered or unregistered outputs    
//      index_mode      {0 ro 2}        Index Output Mode
//      
//      Input Ports   Size              Description
//      ===========   ====              ============
//      clk             1               Input clock
//      rst_n           1               Active low reset
//      init_n          1               Active low synchronous reset
//      enable          1               Active high enable
//      request         n               Input request from clients
//      mask            n bits          Setting mask(i) high will disable request(i)
//      
//      Output Ports   Size              Description
//      ===========   ====              ============  
//      grant           n               Grant output    
//      grant_index     m               Index of the current grant
//
//      Where m = ceil(log2(n)) when index_mode=0 or index_mod=2 while
//            m = ceil(log2(n+1)) ehnd index_mode=1
//
// Modification history:
//
//    RJK - 06/19/15
//    Added missing signals to next state always block sensitivity list
//    (STAR 9000913972)
//
//    RJK - 12/12/12
//    Updated to properly model combinational output flow when the
//    output_mode parameter is set to 0 (STAR 9000589357)
//
//    RJK - 10/01/12
//    Enhancement that adds a new parameter to control the operation
//    of the grant_index output.
//
//    RJK - 3/22/12
//    Added `undef for Verilog Macro DW_index_width, to avoid
//    'redefinition' warnings (associated with STAR STS0178572)
//
////////////////////////////////////////////////////////////////////////////////
module DW_arb_rr(clk, rst_n, init_n, enable, request, mask, granted, grant, grant_index );
  parameter n           = 4; // RANGE 2 to 32
  parameter output_mode = 1; // RANGE 0 or 1
  parameter index_mode = 0;  // RANGE 0 to 2

  localparam index_width = (index_mode == 1)?
  			((n+1>16)?((n+1>64)?((n+1>128)?8:7):((n+1>32)?6:5)):((n+1>4)?((n+1>8)?4:3):((n+1>2)?2:1))) :
			((n>16)?((n>64)?((n>128)?8:7):((n>32)?6:5)):((n>4)?((n>8)?4:3):((n>2)?2:1)));

  localparam indx_offset = (index_mode == 2)? 0 : 1;

input clk,rst_n,init_n,enable;
input [n-1: 0] request,mask;
output granted; 
output [n-1: 0] grant;
output [index_width-1: 0] grant_index;  
// synopsys translate_off
reg  grant_ro; 
reg  [index_width-1: 0] token_cs;
reg  [index_width-1: 0] token_ns;
reg  [n-1: 0] grant_cs;
reg  [n-1: 0] grant_ns;
reg  granted_r;
reg  [index_width-1: 0] grant_indxr; // count memory
reg  [index_width-1: 0] grant_indxn; // count memory
wire [n-1: 0]             masked_req;

  assign masked_req = request & ~mask;

  always @ (enable or token_cs or masked_req or granted_r) begin : mk_nxt_state_PROC
    integer count;
    reg req_ro; 

    count = 0;
    grant_ro = 1'b0;
    req_ro   = |masked_req;

    if(enable) begin
      if(masked_req[token_cs] == 1'b1)begin
	grant_ns  	= {n{1'b0}};
	grant_ns[token_cs]   = 1'b1;
	token_ns  	   = token_cs;
	grant_indxn	   = token_cs + indx_offset;
	grant_ro  	   = 1'b1;
      end else if(req_ro) begin
	for(count = ((token_cs+1)%n); count < n ; count = count) begin
	  if(masked_req[count] == 1'b1 )begin
	    grant_ns	   = {n{1'b0}};
	    grant_ns[count]  = 1'b1;
	    token_ns	   = count;
	    grant_indxn	   = count +  indx_offset; 
	    count 	   = n;
	    grant_ro	   = 1'b1;
	  end else
	    count = (count +1)%n;
	end
      end else if(granted_r == 1'b1 & req_ro == 1'b0)begin 
	if (token_cs == n-1) 
	  token_ns = {index_width{1'b0}}; 
	else
	  token_ns = token_cs + 1;
	grant_ns    = {n{1'b0}};
	grant_indxn = {index_width{1'b0}};
      end else begin
	token_ns    = token_cs; 
	grant_ns    = {n{1'b0}};
	grant_indxn = {index_width{1'b0}};
      end
    end else if(enable == 0)begin
      grant_ns	= {n{1'b0}};
      token_ns	= {index_width{1'b0}};
      grant_indxn = {index_width{1'b0}};
    end else begin
      grant_ns	= {n{1'bx}};
      token_ns	= {index_width{1'bx}};
      grant_indxn = {index_width{1'bx}};
      grant_ro	= 1'bx;
    end
  end
  always @ (posedge clk or negedge rst_n) begin : grant_reg_PROC
    if(rst_n == 1'b0) begin
      token_cs  <= {index_width{1'b0}};
      grant_cs  <= {n{1'b0}};
      grant_indxr  <= {index_width{1'b0}};
      granted_r <= 1'b0;
    end else if(rst_n == 1'b1) begin
      if (init_n == 1'b0) begin
	token_cs  <= {index_width{1'b0}};
	grant_cs  <= {n{1'b0}};
	grant_indxr  <= {index_width{1'b0}};
	granted_r <= 1'b0;
      end else if (init_n == 1'b1) begin
	if(clk == 1'b1) begin
	  token_cs     <= token_ns;
	  grant_cs     <= grant_ns;
	  grant_indxr  <= grant_indxn;
	  granted_r    <= grant_ro;
	end else if (clk == 1'b0) begin
	  token_cs    <= token_cs;
	  grant_cs    <= grant_cs;
	  grant_indxr <= grant_indxr;
	  granted_r   <= granted_r;
	end else begin
	  token_cs  <= {index_width{1'bX}};
	  grant_cs  <= {n{1'bX}};
	  grant_indxr  <= {index_width{1'bX}};
	  granted_r <= 1'bX;
	end
      end else begin
	token_cs  <= {index_width{1'bx}};
	grant_cs  <= {n{1'bx}};
	grant_indxr  <= {index_width{1'bx}};
	granted_r <= 1'bx;
      end 
    end else begin
      token_cs  <= {index_width{1'bx}};
      grant_cs  <= {n{1'bx}};
      grant_indxr  <= {index_width{1'bx}};
      granted_r <= 1'bx;
    end
  end

  assign  granted     = output_mode ? granted_r : grant_ro;
  assign  grant	    = output_mode ? grant_cs : grant_ns;
  assign  grant_index = output_mode ? grant_indxr : grant_indxn ;

  /////////////////////////////////////////////////////////////////////////////
  // Parameter legality check
  /////////////////////////////////////////////////////////////////////////////
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if ( (n < 2) || (n > 256) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter n (legal range: 2 to 256)",
	n );
    end
    
    if ( (output_mode < 0) || (output_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter output_mode (legal range: 0 to 1)",
	output_mode );
    end
    
    if ( (index_mode < 0) || (index_mode > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter index_mode (legal range: 0 to 2)",
	index_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  /////////////////////////////////////////////////////////////////////////////
  // Report unknown clock inputs
  /////////////////////////////////////////////////////////////////////////////
  
  always @ (clk) begin : clk_monitor
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor
// synopsys translate_on
endmodule
