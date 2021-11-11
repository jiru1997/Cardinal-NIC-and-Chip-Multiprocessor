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
// AUTHOR:    Zhijun (Jerry) Huang    08/06/2003
//
// VERSION:   Verilog Simulation Model for DW_fir_seq
//
// DesignWare_version: d88c78be
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------
//
// ABSTRACT:  Sequential Digital FIR Filter Processor
//
// MODIFIED:
// 02/26/2016 LMSU Updated to use blocking and non-blocking assigments in
//                 the correct way
//
// 09/11/2003 Zhijun (Jerry) Huang
//            When coef_shift_en = 1, change
//                hold <= 1'b1;
//            to
//                hold_ctl = 1'b1;
//                hold <= hold_ctl;
//            so that when coef_shift_en changes to 0, 
//            hold stays at 1 until run becomes 1
//
// 09/16/2003 Zhijun (Jerry) Huang
//            reversed the order of coefficient register signals 
//            so that coef(0) is loaded first
//            added register with enable "run" for init_acc_val
//
//---------------------------------------------------------------------------

module DW_fir_seq ( clk, rst_n, coef_shift_en, tc, run, 
                    data_in, coef_in, init_acc_val, start, hold, data_out );

// paramters
parameter data_in_width = 8;
parameter coef_width = 8;
parameter data_out_width = 16;
parameter order = 6;

// ports
input  clk, rst_n, coef_shift_en, tc, run;
input  [data_in_width-1:0]  data_in;
input  [coef_width-1:0]     coef_in;
input  [data_out_width-1:0] init_acc_val;
output start, hold;
output [data_out_width-1:0] data_out;

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

`define DW_addr_width ((order>16)?((order>64)?((order>128)?8:7):((order>32)?6:5)):((order>4)?((order>8)?4:3):((order>2)?2:1)))

  wire next_start, next_hold;
  reg  start, hold;
  wire [data_out_width-1:0] next_data_out;
  reg  [data_out_width-1:0] data_out;

  wire  next_run_last;
  reg   run_dly, run_pos;
  wire  [31:0]               next_cycle_ctr;
  reg   [31:0]               cycle_ctr;
  wire  [`DW_addr_width-1:0] next_coef_ptr;
  reg   [`DW_addr_width-1:0] coef_ptr;
  wire  [`DW_addr_width-1:0] next_coef_addr;
  reg   [`DW_addr_width-1:0] coef_addr;
  wire  [`DW_addr_width-1:0] next_data_write_addr;
  reg   [`DW_addr_width-1:0] data_write_addr;
  wire  [`DW_addr_width-1:0] next_data_read_ptr;
  reg   [`DW_addr_width-1:0] data_read_ptr;
  wire  [`DW_addr_width-1:0] next_data_read_addr;
  reg   [`DW_addr_width-1:0] data_read_addr;
  reg   [data_in_width-1:0]  sample_mem [order-1:0];
  wire  [data_in_width-1:0]  sample_data;
  reg   [coef_width-1:0]     coef_mem [order-1:0];
  wire  [coef_width-1:0]     coef_data;
  wire  [data_out_width-1:0] sum_in; 
  wire  [data_out_width-1:0] next_init_acc_val;
  reg   [data_out_width-1:0] init_acc_val_reg;

//---------------------------------------------------------------------------
// Behavioral model
//---------------------------------------------------------------------------

// controller

  // detect rising EDGE of run 
  always @(posedge clk or negedge rst_n) begin : reg_run_PROC
    if      (rst_n === 1'b0) run_dly <= 1'b0;
    else if (rst_n === 1'b1) run_dly <= run;
    else                     run_dly <= 1'bx;
  end
  assign run_pos = run & ~run_dly;

  // cycle counter
  assign next_cycle_ctr = (coef_shift_en === 1'b1) ? cycle_ctr :
                            ((cycle_ctr < order) ? cycle_ctr + 1 :
                              ((run_pos === 1'b1) ? 32'b1 :
                                cycle_ctr));

  // turn off start control signal after first clk cycle of sample processing cycle
  assign next_start = (run_pos === 1'b1) ? 1'b1 : ((start == 1'b1) ? 1'b0 : start);

  assign next_hold = (coef_shift_en === 1'b1) ? 1'b1 :
                       ((run_pos === 1'b1) ? 1'b0 :
                         ((cycle_ctr == order) ? 1'b1 :
                           hold));

  assign next_coef_addr = (coef_shift_en === 1'b1) ? coef_addr :
                            ((run_pos === 1'b1) ? {`DW_addr_width{1'b0}} :
                              coef_ptr);

  assign next_coef_ptr = (coef_shift_en === 1'b1) ? coef_ptr :
                           ((cycle_ctr < order-1) ? coef_ptr + 1 :
                             ((run_pos === 1'b1) ? {{`DW_addr_width-1{1'b0}}, 1'b1} :
                               coef_ptr));

  assign next_data_write_addr = (coef_shift_en === 1'b1) ? {`DW_addr_width{1'b0}} :
                                  ((run_pos === 1'b0) ? data_write_addr :
                                    ((data_write_addr == order-1) ? {`DW_addr_width{1'b0}} :
                                      data_write_addr + 1));

  assign next_data_read_ptr = (coef_shift_en === 1'b1) ?
                                  data_read_ptr :
                                  (run_pos === 1'b1) ?
                                      (data_read_ptr == 0) ?
                                          (order - 1) :
                                          (data_read_ptr - 1) :
                                      (cycle_ctr < order-1) ?
                                          (data_read_ptr == 0) ?
                                              (order - 1) :
                                              (data_read_ptr - 1) :
                                          data_read_ptr;

  assign next_data_read_addr = (coef_shift_en === 1'b1) ? data_read_addr :
                                 ((run_pos === 1'b1) ? data_write_addr :
                                   data_read_ptr);

  always @(posedge clk or negedge rst_n) begin : controller_PROC
    if (rst_n === 1'b0) begin
      cycle_ctr          <= 32'b0;
      start              <= 1'b0;
      hold               <= 1'b0;
      coef_ptr           <= {`DW_addr_width{1'b0}};
      coef_addr          <= {`DW_addr_width{1'b0}};
      data_write_addr    <= {`DW_addr_width{1'b0}};
      data_read_ptr      <= {`DW_addr_width{1'b0}};
      data_read_addr     <= {`DW_addr_width{1'b0}};
    end else if (rst_n === 1'b1) begin 
      cycle_ctr          <= next_cycle_ctr;
      start              <= next_start;
      hold               <= next_hold;      
      coef_ptr           <= next_coef_ptr;
      coef_addr          <= next_coef_addr;
      data_write_addr    <= next_data_write_addr;
      data_read_ptr      <= next_data_read_ptr;
      data_read_addr     <= next_data_read_addr;
    end else begin
      cycle_ctr          <= 32'bx;
      start              <= 1'bx;
      hold               <= 1'bx;
      coef_ptr           <= {`DW_addr_width{1'bx}};
      coef_addr          <= {`DW_addr_width{1'bx}};
      data_write_addr    <= {`DW_addr_width{1'bx}};
      data_read_ptr      <= {`DW_addr_width{1'bx}};
      data_read_addr     <= {`DW_addr_width{1'bx}};
    end // else if (rst_n === 1'bx)
  end // controller
   
  
// data register file  
  always @(posedge clk or negedge rst_n) begin : data_reg_file_PROC
    integer i;
     
    if (rst_n === 1'b0) begin
      for (i=0; i<order; i=i+1) begin
        sample_mem[i] <= {data_in_width{1'b0}};
      end
    end else if (rst_n === 1'b1) begin

      if ((^(run ^ run) !== 1'b0) || (^(data_write_addr ^ data_write_addr) !== 1'b0)) begin
        for (i=0; i<order; i=i+1)
          sample_mem[i] <= {data_in_width{1'bx}};
      end else if (run === 1'b0) 
        sample_mem[data_write_addr] <= sample_mem[data_write_addr];
      else begin 
        if ((^(data_in ^ data_in) !== 1'b0))
          sample_mem[data_write_addr] <= {data_in_width{1'bx}};
        else 
          sample_mem[data_write_addr] <= data_in;
      end // else (run === '1')

    end else begin 
      for (i=0; i<order; i=i+1) begin
        sample_mem[i] <= {data_in_width{1'bx}};
      end    
    end // else (rst_n === 1'bx)
  end // data_reg_file  

  assign sample_data = (^(data_read_addr ^ data_read_addr) !== 1'b0) ? {data_in_width{1'bx}}
                                             : sample_mem[data_read_addr];

 
// coefficient register file
  always @(posedge clk or negedge rst_n) begin : coef_reg_file_PROC
    integer i;
    
    if (rst_n === 1'b0) begin
      for (i=0; i<order; i=i+1) 
        coef_mem[i] <= {data_in_width{1'b0}};
    end else if (rst_n === 1'b1) begin

      if (coef_shift_en === 1'b0) begin
        for (i=0; i<order; i=i+1)
          coef_mem[i] <= coef_mem[i];
      end else if (coef_shift_en === 1'b1) begin
        coef_mem[order-1] <= coef_in;
        for (i=order-2; i>=0; i=i-1) 
          coef_mem[i] <= coef_mem[i+1];
      end else begin
        for (i=0; i<order; i=i+1)
          coef_mem[i] <= {data_in_width{1'bx}};
      end

    end else begin 
      for (i=0; i<order; i=i+1) begin
        coef_mem[i] <= {data_in_width{1'bx}};
      end 
    end // else (rst_n === 1'bx)
  end // coef_reg_file

  assign coef_data = (^(coef_addr ^ coef_addr) !== 1'b0) ? {coef_width{1'bx}}
                                      : coef_mem[coef_addr];

 
// Arithmetic unit 

  // choose accumulator's input
  assign sum_in = (start === 1'b1) ? init_acc_val_reg : data_out;

  // register for init_acc_val
  assign next_init_acc_val = (run === 1'b1) ? init_acc_val : init_acc_val_reg;

  // MAC     
  assign next_data_out = (hold === 1'b1) ? data_out : DWF_prod_sum1(sample_data, coef_data, sum_in, tc); 

  always @(posedge clk or negedge rst_n) begin : arith_unit_PROC
    if (rst_n === 1'b0) begin
      init_acc_val_reg  <= {data_out_width{1'b0}};
      data_out          <= {data_out_width{1'b0}}; 
    end else if (rst_n === 1'b1) begin
      init_acc_val_reg  <= next_init_acc_val;
      data_out          <= next_data_out; 
    end else begin
      init_acc_val_reg  <= {data_out_width{1'bx}};
      data_out          <= {data_out_width{1'bx}};      
    end // else (rst_n === 1'bx)
  end // arith_unit 


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

`undef DW_addr_width

// synopsys translate_on

endmodule // DW_fir_seq
