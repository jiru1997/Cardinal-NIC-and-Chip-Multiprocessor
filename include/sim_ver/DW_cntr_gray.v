////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2001 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann    11/14/01
//
// VERSION:   Verilog Simulation Model for DW_cntr_gray
//
// DesignWare_version: a2479183
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT:  Gray counter
//
// MODIFIED:
//
//  04/10/15  RJK  Updated to change count_next to a wire using a continuous
//                 assignment outside of the sequential always block to better
//                 support VCS-NLP
//
//-----------------------------------------------------------------------------

module DW_cntr_gray (clk, rst_n, init_n, load_n, data, cen, count);

  parameter width = 4;                  // word width

  input  clk;                           // clock
  input  rst_n;                         // asynchronous reset, active low
  input  init_n;                        // synchronous reset, active low
  input  load_n;                        // load enable, active low
  input  [width-1 : 0]data;             // load data input
  input  cen;                           // count enable
  output [width-1 : 0] count;           // counter output


  // include modeling functions
`include "DW_inc_gray_function.inc"

  // synopsys translate_off

  reg  [width-1 : 0] count_int;         // internal count
  wire [width-1 : 0] count_next;        // next count

  //---------------------------------------------------------------------------
  // Behavioral model
  //---------------------------------------------------------------------------

  assign count_next = (load_n===1'b0)? (data | (data ^ data)) :
	                (load_n===1'b1)? DWF_inc_gray (count_int, cen) :
	                  {width{1'bX}};

  always @(posedge clk or negedge rst_n)
  begin : register_PROC

    if (rst_n === 1'b0) begin
      count_int <= {width{1'b0}};
    end else if (rst_n === 1'b1) begin
      if (init_n === 1'b0) begin
        count_int <= {width{1'b0}};
      end else if (init_n === 1'b1) begin
        count_int <= count_next;
      end else begin
        count_int <= {width{1'bX}};
      end
    end else begin
      count_int <= {width{1'bX}};
    end
 
  end 
   

  assign count = count_int;


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
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  //---------------------------------------------------------------------------
  // Report unknown clock inputs
  //---------------------------------------------------------------------------
  
  always @ (clk) begin : monitor_clk_PROC
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // monitor_clk_PROC

  // synopsys translate_on

endmodule

//-----------------------------------------------------------------------------
