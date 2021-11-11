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
// AUTHOR:    Doug Lee  Feb. 22, 2006
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: abc6d822
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Pipelined Multiply and Accumulate Simulation Model
//
//           This receives two operands that get multiplied and
//           accumulated.  The operation is configurable to be
//           pipelined.  Also, includes pipeline management.
//
//
//              Parameters      Valid Values   Description
//              ==========      ============   ===========
//              a_width           1 to 1024    default: 8
//                                             Width of 'a' input
//
//              b_width           1 to 1024    default: 8
//                                             Width of 'a' input
//
//              acc_width         2 to 2048    default: 16
//                                             Width of 'a' input
//                                               Must be >= (a_width + b_width)
//
//              tc                  0 or 1     default: 0
//                                             Twos complement control
//                                               0 => unsigned
//                                               1 => signed
//
//              pipe_reg            0 to 7     default: 0
//                                             Pipeline register stages
//                                               0 => no pipeline register stages inserted
//                                               1 => pipeline stage0 inserted
//                                               2 => pipeline stage1 inserted
//                                               3 => pipeline stages 0 and 1 inserted
//                                               4 => pipeline stage2 pipeline inserted
//                                               5 => pipeline stages 0 and 2 pipeline inserted
//                                               6 => pipeline stages 1 and 2 inserted
//                                               7 => pipeline stages 0, 1, and 2 inserted
//
//              id_width          1 to 1024    default: 1
//                                             Width of 'launch_id' and 'arrive_id' ports
//
//              no_pm               0 or 1     default: 0
//                                             Pipeline management included control
//                                               0 => DW_pipe_mgr connected to pipeline
//                                               1 => DW_pipe_mgr bypassed
//
//              op_iso_mode         0 to 4     default: 0
//                                             Type of operand isolation
//                                               0 => Follow intent defined by Power Compiler user setting
//                                               1 => no operand isolation
//                                               2 => 'and' gate operand isolaton
//                                               3 => 'or' gate operand isolation
//                                               4 => preferred isolation style: 'and' gate
//
//
//              Input Ports:    Size           Description
//              ===========     ====           ===========
//              clk             1 bit          Input Clock
//              rst_n           1 bit          Active Low Async. Reset
//              init_n          1 bit          Active Low Sync. Reset
//              clr_acc_n       1 bit          Actvie Low Clear accumulate results
//              a               a_width bits   Multiplier
//              b               b_width bits   Multiplicand
//              launch          1 bit          Start a multiply and accumulate with a and b
//              launch_id       id_width bits  Identifier associated with 'launch' assertion
//              accept_n        1 bit          Downstream logic ready to use 'acc' result (active low)
//
//              Output Ports    Size           Description
//              ============    ====           ===========
//              acc             acc_width bits Multiply and accumulate result
//              arrive          1 bit          Valid multiply and accumulate result
//              arrive_id       id_width bits  launch_id from originating launch that produced acc result
//              pipe_full       1 bit          Upstream notification that pipeline is full
//              pipe_ovf        1 bit          Status Flag indicating pipe overflow
//              push_out_n      1 bit          Active Low Output used with FIFO (optional)
//              pipe_census     3 bits         Output bus indicating the number of pipe stages currently occupied
//
//
// MODIFIED: 
//           02/06/08  DLL Enhanced abstract and added 'op_iso_mode' parameter.
//
//
//
////////////////////////////////////////////////////////////////////////////////
module DW_piped_mac (
    clk,
    rst_n,
    init_n,
    clr_acc_n,
    a,
    b,
    acc,

    launch,
    launch_id,
    pipe_full,
    pipe_ovf,

    accept_n,
    arrive,
    arrive_id,
    push_out_n,
    pipe_census
    );

parameter a_width      = 8;  // RANGE 1 to 1024
parameter b_width      = 8;  // RANGE 1 to 1024
parameter acc_width    = 16; // RANGE 2 to 2048
parameter tc           = 0;  // RANGE 0 to 1
parameter pipe_reg     = 0;  // RANGE 0 to 7
parameter id_width     = 1;  // RANGE 1 to 1024
parameter no_pm        = 0;  // RANGE 0 to 1
parameter op_iso_mode  = 0;  // RANGE 0 to 4



input                       clk;        // Input Clock
input                       rst_n;      // Active Low Async. Reset
input                       init_n;     // Active Low Sync. Reset
input                       clr_acc_n;  // Active Low Clear accumulate results
input  [a_width-1:0]        a;          // Multiplier
input  [b_width-1:0]        b;          // Multiplicand
output [acc_width-1:0]      acc;        // Multiply and accumulate result

input                       launch;     // Start a multiply and accumulate with a and b
input  [id_width-1:0]       launch_id;  // Identifier associated with 'launch' assertion
output                      pipe_full;  // Upstream notification that pipeline is full
output                      pipe_ovf;

input                       accept_n;   // Downstream logic ready to use 'acc' result - active low
output                      arrive;     // Valid multiply and accumulate result
output [id_width-1:0]       arrive_id;  // launch_id from originating launch that produced out result
output                      push_out_n;
output [2:0]                pipe_census;



// synopsys translate_off
`define DW_max_stages   ((pipe_reg==0)?1:((pipe_reg==7)?4:(((pipe_reg==1)||(pipe_reg==2)||(pipe_reg==4))?2:3)))

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if (a_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 1)",
	a_width );
    end
  
    if (b_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 1)",
	b_width );
    end
  
    if (acc_width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter acc_width (lower bound: 2)",
	acc_width );
    end
  
    if ( (tc < 0) || (tc > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc (legal range: 0 to 1)",
	tc );
    end
  
    if ( (id_width < 1) || (id_width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter id_width (legal range: 1 to 1024)",
	id_width );
    end
  
    if ( (pipe_reg < 0) || (pipe_reg > 7) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pipe_reg (legal range: 0 to 7)",
	pipe_reg );
    end
  
    if ( (no_pm < 0) || (no_pm > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter no_pm (legal range: 0 to 1)",
	no_pm );
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


wire                        launch_pm;     // Start a multiply and accumulate with a and b
wire   [id_width-1:0]       launch_id_pm;  // Identifier associated with 'launch' assertion
wire                        pipe_full_pm;  // Upstream notification that pipeline is full

wire                        accept_n_pm;   // pipe mgr downstream logic ready to use 'acc' result - active low
wire                        arrive_pm;     // pipe mgr valid multiply and accumulate result
wire   [id_width-1:0]       arrive_id_pm;  // pipe mgr launch_id from originating launch that produced out result
wire                        push_out_n_pm;

wire  [`DW_max_stages-1:0]  pipe_en_bus;
reg   [`DW_max_stages-1:0]  pipe_en_bus_pm;

wire  [2:0]                 pipe_census;
reg   [2:0]		    pipe_census_pm;
wire  [2:0]		    pipe_census_int;

reg   [a_width-1:0]         a_s0_reg;
wire  [a_width-1:0]         a_s0_selected;
reg   [a_width-1:0]         a_s1_reg;
wire  [a_width-1:0]         a_s1_selected;
reg   [b_width-1:0]         b_s0_reg;
wire  [b_width-1:0]         b_s0_selected;
reg   [b_width-1:0]         b_s1_reg;
wire  [b_width-1:0]         b_s1_selected;
reg   [acc_width-1:0]       c_int;
wire  [acc_width-1:0]       next_c_int;
wire  [acc_width-1:0]       c_int_gated;
wire  [acc_width-1:0]       sum;
wire			    tc_bit;
reg                         en0;
reg                         en1;
reg                         en2;
reg                         en_acc;
reg   [acc_width-1:0]       acc_int;
reg                         clr_acc_n_s0_reg;
wire                        clr_acc_n_s0_selected;
reg                         clr_acc_n_s1_reg;
wire                        clr_acc_n_s1_selected;
reg			    pipe_ovf_pm;
wire                        accept;
reg  [`DW_max_stages-1:0]   dtsr;
reg  [`DW_max_stages-1:0]   next_dtsr;
reg  [`DW_max_stages-1:0]   sel;
reg  [(id_width*`DW_max_stages)-1:0] idsr;
reg  [(id_width*`DW_max_stages)-1:0] next_idsr;
integer	i,j,k,l,m,n,p,idx;


always @(pipe_en_bus) begin : a1000_PROC
  case(pipe_reg)
    0: begin
	 en_acc = pipe_en_bus[0];
       end
    1: begin
	 for (idx=0; idx<`DW_max_stages; idx=idx+1) begin
	   if (idx == 0)
	     en0    = pipe_en_bus[idx];
           else
	     en_acc = pipe_en_bus[idx];
         end
       end
    2: begin
	 for (idx=0; idx<`DW_max_stages; idx=idx+1) begin
	   if (idx == 0)
	     en1    = pipe_en_bus[idx];
           else
	     en_acc = pipe_en_bus[idx];
         end
       end
    3: begin
	 for (idx=0; idx<`DW_max_stages; idx=idx+1) begin
	   if (idx == 0)
	     en0    = pipe_en_bus[idx];
           else if (idx == 1)
	     en1    = pipe_en_bus[idx];
           else
	     en_acc = pipe_en_bus[idx];
         end
       end
    4: begin
	 for (idx=0; idx<`DW_max_stages; idx=idx+1) begin
	   if (idx == 0)
	     en_acc = pipe_en_bus[idx];
           else
	     en2    = pipe_en_bus[idx];
         end
       end
    5: begin
	 for (idx=0; idx<`DW_max_stages; idx=idx+1) begin
	   if (idx == 0)
	     en0    = pipe_en_bus[idx];
           else if (idx == 1)
	     en_acc = pipe_en_bus[idx];
           else
	     en2    = pipe_en_bus[idx];
         end
       end
    6: begin
	 for (idx=0; idx<`DW_max_stages; idx=idx+1) begin
	   if (idx == 0)
	     en1    = pipe_en_bus[idx];
           else if (idx == 1)
	     en_acc = pipe_en_bus[idx];
           else
	     en2    = pipe_en_bus[idx];
         end
       end
    7: begin
	 for (idx=0; idx<`DW_max_stages; idx=idx+1) begin
	   if (idx == 0)
	     en0    = pipe_en_bus[idx];
           else if (idx == 1)
	     en1    = pipe_en_bus[idx];
           else if (idx == 2)
	     en_acc = pipe_en_bus[idx];
           else
	     en2    = pipe_en_bus[idx];
         end
       end
  endcase
end

always @(posedge clk or negedge rst_n) begin : a1001_PROC
  if (rst_n === 1'b0) begin
    a_s0_reg          <= {a_width{1'b0}};
    b_s0_reg          <= {b_width{1'b0}};
    clr_acc_n_s0_reg  <= 1'b0;
  end else if (init_n === 1'b0) begin
    a_s0_reg          <= {a_width{1'b0}};
    b_s0_reg          <= {b_width{1'b0}};
    clr_acc_n_s0_reg  <= 1'b0;
  end else if (en0 === 1'b1) begin
    a_s0_reg          <= a;
    b_s0_reg          <= b;
    clr_acc_n_s0_reg  <= clr_acc_n;
  end else begin
    a_s0_reg          <= a_s0_reg;
    b_s0_reg          <= b_s0_reg;
    clr_acc_n_s0_reg  <= clr_acc_n_s0_reg;
  end
end

assign a_s0_selected          = (pipe_reg[0]) ? a_s0_reg : a;
assign b_s0_selected          = (pipe_reg[0]) ? b_s0_reg : b;
assign clr_acc_n_s0_selected  = (pipe_reg[0]) ? clr_acc_n_s0_reg : clr_acc_n;

always @(posedge clk or negedge rst_n) begin : a1002_PROC
  if (rst_n === 1'b0) begin
    a_s1_reg          <= {a_width{1'b0}};
    b_s1_reg          <= {b_width{1'b0}};
    clr_acc_n_s1_reg  <= 1'b0;
  end else if (init_n === 1'b0) begin
    a_s1_reg          <= {a_width{1'b0}};
    b_s1_reg          <= {b_width{1'b0}};
    clr_acc_n_s1_reg  <= 1'b0;
  end else if (en1 === 1'b1) begin
    a_s1_reg          <= a_s0_selected;
    b_s1_reg          <= b_s0_selected;
    clr_acc_n_s1_reg  <= clr_acc_n_s0_selected;
  end else begin
    a_s1_reg          <= a_s1_reg;
    b_s1_reg          <= b_s1_reg;
    clr_acc_n_s1_reg  <= clr_acc_n_s1_reg;
  end
end

assign a_s1_selected          = (pipe_reg[1]) ? a_s1_reg : a_s0_selected;
assign b_s1_selected          = (pipe_reg[1]) ? b_s1_reg : b_s0_selected;
assign clr_acc_n_s1_selected  = (pipe_reg[1]) ? clr_acc_n_s1_reg : clr_acc_n_s0_selected;



assign accept = ~accept_n_pm;

always @(sel or dtsr or accept) begin : a1003_PROC
  for (i=`DW_max_stages-1; i>=0; i=i-1) begin
    if (i == `DW_max_stages-1)
      sel[i] = accept | ~dtsr[i];
    else
      sel[i] = sel[i+1] | ~dtsr[i];
  end
end

always @(sel or dtsr or launch_pm or idsr or launch_id_pm) begin : a1004_PROC
  for (j=0; j<`DW_max_stages; j=j+1) begin
    if (j == 0) begin
      if (sel[0] === 1'b1)
        next_dtsr[0] = launch_pm;
      else
        next_dtsr[0] = dtsr[0];
      if ((sel[0] === 1'b1) && (next_dtsr[0] === 1'b1))
	next_idsr[id_width-1:0] = launch_id_pm;
      else
	next_idsr[id_width-1:0] = idsr[id_width-1:0];
    end else begin
      if (sel[j] === 1'b1)
        next_dtsr[j] = dtsr[j-1];
      else
        next_dtsr[j] = dtsr[j];
      if ((sel[j] === 1'b1) && (next_dtsr[j] === 1'b1))
	for (p=0; p<id_width; p=p+1) begin
          next_idsr[(j*id_width)+p] = idsr[((j-1)*id_width)+p];
	end
      else
	for (p=0; p<id_width; p=p+1) begin
          next_idsr[(j*id_width)+p] = idsr[(j*id_width)+p];
	end
    end
  end
end

always @(sel or next_dtsr) begin : a1005_PROC
  for (k=0; k<`DW_max_stages; k=k+1) begin
     pipe_en_bus_pm[k] = sel[k] & next_dtsr[k];
  end
end

always @(dtsr or pipe_census_pm) begin : a1006_PROC
  pipe_census_pm = 3'b000;
  for (m=0; m<`DW_max_stages; m=m+1) begin
    if (dtsr[m] === 1'b1)
      pipe_census_pm = pipe_census_pm + 1'b1;
  end
end


always @(posedge clk or negedge rst_n) begin : a1007_PROC
  if (rst_n === 1'b0) begin
    dtsr         <= {`DW_max_stages{1'b0}};
    idsr         <= {(`DW_max_stages*id_width){1'b0}};
    pipe_ovf_pm  <= 1'b0;
  end else if (init_n === 1'b0) begin
    dtsr         <= {`DW_max_stages{1'b0}};
    idsr         <= {(`DW_max_stages*id_width){1'b0}};
    pipe_ovf_pm  <= 1'b0;
  end else begin
    dtsr         <= next_dtsr;
    idsr         <= next_idsr;
    pipe_ovf_pm  <= ~sel[0] & launch_pm;
  end
end


assign arrive_pm      = dtsr[`DW_max_stages-1];
assign arrive_id_pm   = idsr[(`DW_max_stages*id_width)-1:(`DW_max_stages-1)*id_width];
assign push_out_n_pm  = ~(accept & dtsr[`DW_max_stages-1]);
assign pipe_full_pm   = (pipe_census_pm == `DW_max_stages) & !accept;

// Bypass around DW_pipe_mgr inputs/outputs if parameter "no_pm" is 1
assign launch_pm       = (no_pm == 1'b1) ? 1'b1 : launch;
assign launch_id_pm    = (no_pm == 1'b1) ? {id_width{1'b0}} : launch_id;
assign pipe_full       = (no_pm == 1'b1) ? 1'b0 : pipe_full_pm;
assign pipe_ovf        = (no_pm == 1'b1) ? 1'b0 : pipe_ovf_pm;
assign pipe_en_bus     = (no_pm == 1'b1) ? {`DW_max_stages{1'b1}} : pipe_en_bus_pm;

assign accept_n_pm     = (no_pm == 1'b1) ? 1'b0 : accept_n;
assign arrive          = (no_pm == 1'b1) ? 1'b1 : arrive_pm;
assign arrive_id       = (no_pm == 1'b1) ? {id_width{1'b0}} : arrive_id_pm;
assign push_out_n      = (no_pm == 1'b1) ? 1'b0 : push_out_n_pm;
assign pipe_census_int = (no_pm == 1'b1) ? 3'b000 : pipe_census_pm;


assign tc_bit = tc[0];
assign c_int_gated = {acc_width{clr_acc_n_s1_selected}} & c_int;
  integer x,y;
  reg [acc_width-1:0] temp1,temp2;
  reg [acc_width-1:0] prod2,prodsum;
  reg [a_width+b_width-1:0] prod1;
  reg [a_width-1:0] abs_a;
  reg [b_width-1:0] abs_b;

  always @(a_s1_selected or b_s1_selected or c_int_gated or tc_bit) 
   begin
     abs_a = (a_s1_selected[a_width-1])? (~a_s1_selected + 1'b1) : a_s1_selected;
     abs_b = (b_s1_selected[b_width-1])? (~b_s1_selected + 1'b1) : b_s1_selected;
 
     temp1 = abs_a * abs_b;
     temp2 = ~(temp1 - 1'b1);
 
     prod1 = (tc_bit) ? (((a_s1_selected[a_width-1] ^ b_s1_selected[b_width-1]) && (|temp1))?
              temp2 : temp1) : a_s1_selected*b_s1_selected;
 
     if ((^(a_s1_selected ^ a_s1_selected) !== 1'b0) || (^(b_s1_selected ^ b_s1_selected) !== 1'b0) || (^(c_int_gated ^ c_int_gated) !== 1'b0) || (^(tc_bit ^ tc_bit) !== 1'b0) )
       prodsum = {acc_width {1'bX}};
     else if (tc_bit === 1'b0)
       prodsum = prod1+c_int_gated;
     else 
      begin
        if (acc_width >= a_width+b_width)
         begin
           y = a_width+b_width-1;
           for(x=(a_width+b_width-1); x>=0; x=x-1)
            begin
              prod2[x] = prod1[y];
              y = y-1;
            end
           if (acc_width > a_width+b_width)
            begin
              if (prod1[a_width+b_width-1])
               begin
                 for(x=(acc_width-1); x>=(a_width+b_width); x=x-1)
                  begin
                    prod2[x] = 1'b1;
                  end
               end
              else
               begin
                 for(x=(acc_width-1); x>=(a_width+b_width); x=x-1)
                  begin
                    prod2[x] = 1'b0;
                  end
               end
            end
         end
        else
         begin
           for(x=(acc_width-1);x>=0;x=x-1)
            begin
              prod2[x] = prod1[x];
            end
         end
        prodsum = prod2+c_int_gated;
      end
   end
  assign sum = prodsum;

 assign next_c_int = en_acc ? sum : c_int;

  always @ (posedge clk or negedge rst_n) begin : a1008_PROC
    if (rst_n === 1'b0) begin
      c_int                <= {acc_width{1'b0}};
      acc_int              <= {acc_width{1'b0}};
    end else if (init_n === 1'b0) begin
      c_int                <= {acc_width{1'b0}};
      acc_int              <= {acc_width{1'b0}};
    end else begin
      c_int                <= next_c_int;
      if (en2 === 1'b1)
        acc_int              <= c_int;
      else
        acc_int              <= acc_int;
    end
  end

  assign acc          = (pipe_reg[2] == 1'b1) ? acc_int : c_int;
  assign pipe_census  = pipe_census_int;

  
  always @ (clk) begin : monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // monitor_clk 

`undef DW_max_stages
// synopsys translate_on
endmodule
