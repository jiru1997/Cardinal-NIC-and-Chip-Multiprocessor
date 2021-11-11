////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2003 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Zhijun (Jerry) Huang    07/21/2003
//
// VERSION:   Verilog Simulation Model for DW_fir
//
// DesignWare_version: 7d9a20e3
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------
//
// ABSTRACT: High-Speed Digital FIR Filter
//
// MODIFIED: 
// 02/26/2016 LMSU Updated to use blocking and non-blocking assigments in
//                 the correct way
//      
//---------------------------------------------------------------------------

module DW_fir ( clk, rst_n, coef_shift_en, data_in, tc,
                coef_in, init_acc_val, data_out, coef_out );

// paramters
parameter data_in_width = 8;
parameter coef_width = 8;
parameter data_out_width = 16;
parameter order = 6;

// ports
input  clk, rst_n, coef_shift_en, tc;
input  [data_in_width-1:0]  data_in;
input  [coef_width-1:0]     coef_in;
input  [data_out_width-1:0] init_acc_val;
output [data_out_width-1:0] data_out;
output [coef_width-1:0]     coef_out;

// verilog function description of prod_sum1
//------------------------------------------------------------------------------
//
// ABSTRACT: Verilog function description of prod_sum1 for behavioral simulation
//
// MODIFIED:
//
//------------------------------------------------------------------------------

function[data_out_width-1:0] DWF_prod_sum1;
  // port list declaration in order
  input [data_in_width-1:0] A;
  input [coef_width-1:0] B;
  input [data_out_width-1:0] C;
  input TC;

  integer i,j;
  reg [data_out_width-1:0] temp1,temp2;
  reg [data_out_width-1:0] prod2;
  reg [data_in_width+coef_width-1:0] prod1;
  reg [data_in_width-1:0] abs_a;
  reg [coef_width-1:0] abs_b;

  begin
  // synopsys translate_off
    abs_a = (A[data_in_width-1])? (~A + 1'b1) : A;
    abs_b = (B[coef_width-1])? (~B + 1'b1) : B;

    temp1 = abs_a * abs_b;
    temp2 = ~(temp1 - 1'b1);

    prod1 = (TC) ? (((A[data_in_width-1] ^ B[coef_width-1]) && (|temp1))?
             temp2 : temp1) : A*B;

    if ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(C ^ C) !== 1'b0) || (^(TC ^ TC) !== 1'b0) )
      DWF_prod_sum1 = {data_out_width {1'bx}};
    else if (TC === 1'b0)
      DWF_prod_sum1 = prod1+C;
    else begin
      if (data_out_width >= data_in_width+coef_width) begin
        j = data_in_width+coef_width-1;
        for(i=(data_in_width+coef_width-1); i>=0; i=i-1) begin
          prod2[i] = prod1[j];
          j = j-1;
        end
        if (data_out_width > data_in_width+coef_width) begin
          if (prod1[data_in_width+coef_width-1]) begin
            for(i=(data_out_width-1); i>=(data_in_width+coef_width); i=i-1) begin
              prod2[i] = 1'b1;
            end
          end
          else begin               
            for(i=(data_out_width-1); i>=(data_in_width+coef_width); i=i-1) begin
              prod2[i] = 1'b0;
            end
          end
        end
      end
      else begin
        for(i=(data_out_width-1);i>=0;i=i-1) begin
          prod2[i] = prod1[i];
        end
      end
      DWF_prod_sum1 = prod2+C;
    end   
     
  // synopsys translate_on
  end
endfunction // end DWF_prod_sum1

// synopsys translate_off

  reg [coef_width-1:0]      next_coef_data [order-1:0];
  reg [data_in_width-1:0]   next_sample_data; 
  reg [data_out_width-1:0]  next_sum_acc [order-1:0];    

  reg [coef_width-1:0]      coef_data [order-1:0];
  reg [data_in_width-1:0]   sample_data;  
  reg [data_out_width-1:0]  sum_acc [order-1:0];

  //---------------------------------------------------------------------------
  // Behavioral model
  //---------------------------------------------------------------------------

  // FIR body without last MAC
  always @(order or tc or coef_shift_en or coef_in or data_in or init_acc_val or
           coef_data or sample_data or sum_acc) begin: combs_PROC
    integer i;
    
    // execute FIR filter
    for (i=1; i<order; i=i+1) begin
      next_sum_acc[i-1] = DWF_prod_sum1(sample_data, coef_data[i], sum_acc[i], tc);
    end 
    
    // load coefficients serially if enabled      
    if (coef_shift_en === 1'b0) begin  // hold coefficients
      for (i=0; i<order-1; i=i+1)
        next_coef_data[i] = coef_data[i];
    end else if (coef_shift_en === 1'b1) begin  // shift coefficients
      for (i=0; i<order-1; i=i+1) begin
        next_coef_data[i] = coef_data[i+1];
      end 
      next_coef_data[order-1] = coef_in;
    end else begin // X-processing
      for (i=0; i<order-1; i=i+1) 
        next_coef_data[i] = {coef_width{1'bx}}; 
    end // end else if (coef_shift_en === 1'bx) 

    // latch incoming data
    next_sample_data = data_in;
    next_sum_acc[order-1] = init_acc_val;
      
  end // block: combs_PROC
        
  always @(posedge clk or negedge rst_n)  begin: regs_PROC
    integer i;

    if (rst_n === 1'b0) begin
      sample_data <= {data_in_width{1'b0}};
      for (i=0; i<order; i=i+1) begin
        coef_data[i] <= {coef_width{1'b0}};
        sum_acc[i] <= {data_out_width{1'b0}};
      end
    end else if (rst_n === 1'b1) begin
      sample_data <= next_sample_data;
      for (i=0; i < order; i=i+1) begin
        coef_data[i] <= next_coef_data[i];
        sum_acc[i] <= next_sum_acc[i];
      end 
    end else begin
      sample_data <= {data_in_width{1'bx}};
      for (i=0; i<order; i=i+1) begin
        coef_data[i] <= {coef_width{1'bx}};
        sum_acc[i] <= {data_out_width{1'bx}};
      end
    end
  end // block: regs_PROC

  // generate output (last MAC)  
  assign data_out = DWF_prod_sum1(sample_data, coef_data[0], sum_acc[0], tc);
  assign coef_out = coef_data[0];

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (data_in_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_in_width (lower bound: 1)",
	data_in_width );
    end
    
    if (coef_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter coef_width (lower bound: 1)",
	coef_width );
    end
    
    if (data_out_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_out_width (lower bound: 1)",
	data_out_width );
    end
    
    if ( (order < 2) || (order > 256) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter order (legal range: 2 to 256)",
	order );
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

endmodule // DW_fir
