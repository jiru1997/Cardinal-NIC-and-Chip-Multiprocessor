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
// AUTHOR:    Rajeev Huralikoppi         Feb 15, 2002
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 1d4a2b02
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT:   An n stage pipelined Square root simulation model
//
//      Parameters      Valid Values    Description
//      ==========      =========       ===========
//      width           >= 1            default: 2
//                                      Word length of a
//
//      tc_mode         0 to 1          default: 0
//                                      Two's complement control
//                                        0 => unsigned
//                                        1 => two's complement
//
//      num_stages      >= 2            default: 2
//                                      Number of pipelined stages
//
//      stall_mode      0 or 1          default: 1
//                                      Stall mode
//                                        0 => non-stallable
//                                        1 => stallable
//
//      rst_mode        0 to 2          default: 1
//                                      Reset mode
//                                        0 => no reset
//                                        1 => asynchronous reset
//                                        2 => synchronous reset
//
//      op_iso_mode     0 to 4         default: 0
//                                     Type of operand isolation
//                                       If 'stall_mode' is '0', this parameter is ignored and no isolation is applied
//                                       0 => Follow intent defined by Power Compiler user setting
//                                       1 => no operand isolation
//                                       2 => 'and' gate operand isolaton
//                                       3 => 'or' gate operand isolation
//                                       4 => preferred isolation style: 'or'
//
//
//      Input Ports     Size            Description
//      ===========     ====            ============
//      clk             1               Clock
//      rst_n           1               Reset, active low
//      en              1               Register enable, active high
//      a               width           radicand
//
//      Output Ports     Size            Description
//      ===========     ====            ============--
//      root            int(width+1)/2) square root of a
//
//
// MODIFIED:
//            LMSU 05/20/15   Updated model to work with less propagated 'X's
//                            so as to be more friendly with VCS-NLP
//
//            RJK  05/28/13   Updated documentation in comments to properly
//                            describe the "en" input (STAR 9000627580)
//
//            DLL  02/04/08   Enhanced abstract and added "op_iso_mode" parameter
//                            and related code.
//           
//            DLL  11/14/05   Changed legality checking of 'num_stages'
//                            parameter along with its abstract "Valid Values"
//
//
//-----------------------------------------------------------------------------
`include "./include/sim_ver/DW_sqrt.v"

module DW_sqrt_pipe (clk,rst_n,en,a,root);
   
   parameter width = 2;
   parameter tc_mode = 0;
   parameter num_stages = 2;
   parameter stall_mode = 1;
   parameter rst_mode = 1;
   parameter op_iso_mode = 0;

   
   input clk;
   input rst_n;
   input [width-1 : 0] a;
   input en;
   
   output [((width+1)/2)-1 : 0] root;
   
   reg [width-1 : 0] a_reg[0 : num_stages-2];

  // synopsys translate_off
  //---------------------------------------------------------------------------
  // Behavioral model
  //---------------------------------------------------------------------------   
   
generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0

    if (stall_mode == 0) begin : GEN_RM0_SM0
      always @(posedge clk) begin: rm0_sm0_pipe_reg_PROC
	integer i;

	for(i= 0; i < num_stages-1; i=i+1) begin 
	   if (i == 0) begin
	     a_reg[0]  <= a;
	   end else begin
	     a_reg[i]  <= a_reg[i-1];
	   end
	end	  // for (i= 0; i < num_stages-1; i++)
      end // block: rm0_pipe_reg_PROC
    end else begin : GEN_RM0_SM1
      always @(posedge clk) begin: rm0_sm1_pipe_reg_PROC
	integer i;

	for(i= 0; i < num_stages-1; i=i+1) begin 
	   if (i == 0) begin
	     a_reg[0]  <= (en == 1'b0)? a_reg[0] : ((en == 1'b1)? a : {width{1'bx}});
	   end else begin
	     a_reg[i]  <= (en == 1'b0)? a_reg[i] : ((en == 1'b1)? a_reg[i-1] : {width{1'bx}});
	   end
        end
      end
    end

  end else if (rst_mode == 1) begin : GEN_RM_EQ_1

    if (stall_mode == 0) begin : GEN_RM1_SM0
      always @(posedge clk or negedge rst_n) begin: rm1_pipe_reg_PROC
	integer i;
	 
	if (rst_n == 1'b0) begin
	  for (i= 0; i < num_stages-1; i=i+1) begin
	    a_reg[i] <= {width{1'b0}};
	  end // for (i= 0; i < num_stages-1; i++)
	end else if  (rst_n == 1'b1) begin
	  for(i= 0; i < num_stages-1; i=i+1) begin 
	     if (i == 0) begin
	       a_reg[0]  <= a;
	     end else begin
	       a_reg[i]  <= a_reg[i-1];
	     end
	  end	  // for (i= 0; i < num_stages-1; i++)
	end else begin // rst_n not 1'b0 and not 1'b1
	  for (i= 0; i < num_stages-1; i=i+1) begin
	    a_reg[i] <= {width{1'bx}};
	  end // for (i= 0; i < num_stages-1; i++)
	end
      end // block: rm1_pipe_reg_PROC
    end else begin : GEN_RM1_SM1
      always @(posedge clk or negedge rst_n) begin: rm1_pipe_reg_PROC
	integer i;
	 
	if (rst_n == 1'b0) begin
	  for (i= 0; i < num_stages-1; i=i+1) begin
	    a_reg[i] <= {width{1'b0}};
	  end // for (i= 0; i < num_stages-1; i++)
	end else if  (rst_n == 1'b1) begin
	  for(i= 0; i < num_stages-1; i=i+1) begin 
	    if (i == 0) begin
	      a_reg[0]  <= (en == 1'b0)? a_reg[0] : ((en == 1'b1)? a : {width{1'bx}});
	    end else begin
	      a_reg[i]  <= (en == 1'b0)? a_reg[i] : ((en == 1'b1)? a_reg[i-1] : {width{1'bx}});
	    end
	  end	  // for (i= 0; i < num_stages-1; i++)
	end else begin // rst_n not 1'b0 and not 1'b1
	  for (i= 0; i < num_stages-1; i=i+1) begin
	    a_reg[i] <= {width{1'bx}};
	  end // for (i= 0; i < num_stages-1; i++)
	end
      end // block: rm1_pipe_reg_PROC
    end

  end else begin : GEN_RM_GT_1

    if (stall_mode == 0) begin : GEN_RM2_SM0
      always @(posedge clk) begin: rm2_pipe_reg_PROC
	integer i;
	 
	if (rst_n == 1'b0) begin
	  for (i= 0; i < num_stages-1; i=i+1) begin
	    a_reg[i] <= {width{1'b0}};
	  end // for (i= 0; i < num_stages-1; i++)
	end else if  (rst_n == 1'b1) begin
	  for(i= 0; i < num_stages-1; i=i+1) begin 
	     if (i == 0) begin
	       a_reg[0]  <= a;
	     end else begin
	       a_reg[i]  <= a_reg[i-1];
	     end
	  end	  // for (i= 0; i < num_stages-1; i++)
	end else begin // rst_n not 1'b0 and not 1'b1
	  for (i= 0; i < num_stages-1; i=i+1) begin
	    a_reg[i] <= {width{1'bx}};
	  end // for (i= 0; i < num_stages-1; i++)
	end
      end // block: rm2_pipe_reg_PROC
    end else begin : GEN_RM2_SM1
      always @(posedge clk) begin: rm2_pipe_reg_PROC
	integer i;
	 
	if (rst_n == 1'b0) begin
	  for (i= 0; i < num_stages-1; i=i+1) begin
	    a_reg[i] <= {width{1'b0}};
	  end // for (i= 0; i < num_stages-1; i++)
	end else if  (rst_n == 1'b1) begin
	  for(i= 0; i < num_stages-1; i=i+1) begin 
	    if (i == 0) begin
	      a_reg[0]  <= (en == 1'b0)? a_reg[0] : ((en == 1'b1)? a : {width{1'bx}});
	    end else begin
	      a_reg[i]  <= (en == 1'b0)? a_reg[i] : ((en == 1'b1)? a_reg[i-1] : {width{1'bx}});
	    end
	  end	  // for (i= 0; i < num_stages-1; i++)
	end else begin // rst_n not 1'b0 and not 1'b1
	  for (i= 0; i < num_stages-1; i=i+1) begin
	    a_reg[i] <= {width{1'bx}};
	  end // for (i= 0; i < num_stages-1; i++)
	end
      end // block: rm2_pipe_reg_PROC
    end

  end
endgenerate
   
   DW_sqrt #(width, tc_mode)
      U1 (.a(a_reg[num_stages-2]),
	  .root(root));
 //---------------------------------------------------------------------------
  // Parameter legality check and initializations
  //---------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end      
    
    if (num_stages < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_stages (lower bound: 2)",
	num_stages );
    end   
    
    if ( (stall_mode < 0) || (stall_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter stall_mode (legal range: 0 to 1)",
	stall_mode );
    end   
    
    if ( (rst_mode < 0) || (rst_mode > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 2)",
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

 
  //---------------------------------------------------------------------------
  // Report unknown clock inputs
  //---------------------------------------------------------------------------
  
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 
    
  // synopsys translate_on   
endmodule //
