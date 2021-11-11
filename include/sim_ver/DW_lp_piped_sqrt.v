////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2007 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Bruce Dean       9/19/07
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: b9cc666b
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Low Power Pipelined Square Root Simulation Model
//
//           This receives an operand on which the square root operation is performed.
//           Configurable to provide pipeline registers for both static and re-timing 
//           placement.  Also, contains pipeline management to optimized for low power.
//
//
//  Parameters:     Valid Values    Description
//  ==========      ============    =============
//   width           >= 1         default: 8
//                                  Width of 'a' operand
//
//   id_width        1 to 1024      default: 8
//                                  Launch identifier width
//
//   in_reg           0 to 1        default: 0
//                                  Input register control
//                                    0 => no input register
//                                    1 => include input register
//
//   stages          1 to 1022      default: 4
//                                  Number of logic stages in the pipeline
//
//   out_reg          0 to 1        default: 0
//                                  Output register control
//                                    0 => no output register
//                                    1 => include output register
//
//   tc_mode         0 to 1         default: 0
//                                  Two's complement control
//                                    0 => unsigned
//                                    1 => two's complement
//
//   rst_mode        0 to 1         default: 0
//                                  Control asynchronous or synchronous reset
//                                  behavior of rst_n
//                                    0 => asynchronous reset
//                                    1 -> synchronous reset
//
//   op_iso_mode      0 to 4        default: 0
//                                  Type of operand isolation
//                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
//                                    0 => Follow intent defined by Power Compiler user setting
//                                    1 => no operand isolation
//                                    2 => 'and' gate isolaton
//                                    3 => 'or' gate isolation
//                                    4 => preferred isolation style: 'or'
//
//
//  Ports       Size          Direction    Description
//  =====       ====          =========    ===========
//  clk         1 bit           Input      Clock Input
//  rst_n       1 bit           Input      Reset Input, Active Low
//
//  a           width bits      Input      Radicand
//  root        M bits          Output     square root of a
//
//  launch      1 bit           Input      Active High Control input to lauche data into pipe
//  launch_id   id_width bits   Input      ID tag for data being launched (optional)
//  pipe_full   1 bit           Output     Status Flag indicating no slot for new data
//  pipe_ovf    1 bit           Output     Status Flag indicating pipe overflow
//
//  accept_n    1 bit           Input      Flow Control Input, Active Low
//  arrive      1 bit           Output     Data Available output
//  arrive_id   id_width bits   Output     ID tag for data that's arrived (optional)
//  push_out_n  1 bit           Output     Active Low Output used with FIFO (optional)
//  pipe_census R bits          Output     Output bus indicating the number
//                                         of pipe stages currently occupied
//
//     Note: M is equal to (width+1)/2
//     Note: R is equal to the the larger of '1' or ceil(log2(in_reg+stages+out_reg))
//
//
// Modified:
//     LMSU 02/17/15 Updated to eliminate derived internal clock and reset signals
//
//     DLL  02/21/08 Added 'op_iso_mode' parameter, checking logic, special 
//                   driving of 'root' when 'launch' not asserted.
//
////////////////////////////////////////////////////////////////////////////////
module DW_lp_piped_sqrt(clk,rst_n,a,root,launch,launch_id,pipe_full,pipe_ovf,accept_n,
                         arrive,arrive_id,push_out_n,pipe_census);

parameter width       = 8;  // RANGE 1 to 1024
parameter id_width    = 8;  // RANGE 1 to 1024
parameter in_reg      = 0;  // RANGE 0 to 1
parameter stages      = 4;  // RANGE 1 to 1022
parameter out_reg     = 0;  // RANGE 0 to 1
parameter tc_mode     = 0;  // RANGE 0 to 1
parameter rst_mode    = 0;  // RANGE 0 to 1
parameter op_iso_mode = 0;  // RANGE 0 to 4




input                    clk;	   // Clock Input
input                    rst_n;	   // Async. Reset
input  [width-1:0]       a;           // Radicand
output [((width+1)/2)-1:0] root;        // Pipelined root of a 

input                    launch;	   // Input to launch data into pipe
input  [id_width-1:0]    launch_id;   // ID tag of data launched
output                   pipe_full;   // Pipe Slots Full Output (used for flow control)
output                   pipe_ovf;    // Pipe Overflow Signal

input                    accept_n;    // Hold Data Out Input (flow control)
output                   arrive;	   // Data Arrival Output
output [id_width-1:0]    arrive_id;   // ID tag of arrival data
output                   push_out_n;  // Active Low Output used when FIFO follows

output [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0] pipe_census; // Pipe Stages Occupied Output

// synopsys translate_off

wire  [width-1:0]       IOO1I001;
wire                    l0IOOO01;
wire  [id_width-1:0]    lOO0OOIO;
wire                    I1l0O00I;

wire  [((width+1)/2)-1:0] l110101O;
wire  [((width+1)/2)-1:0] O101Il00;

wire  [((width+1)/2)-1:0]       O0O101O0;
wire  [((width+1)/2)-1:0]       I0O0I0O0;


wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]  I0011010;
wire                          OI1O0II1;
wire                          OO11lO1O;
wire                          OII01lII;
wire  [id_width-1:0]          lIllO000;
wire                          lI011I00;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]  ll10100O;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]       llO1101O;

wire                          lO1IO0IO;
wire                          O00I0I10;
reg                           l1l1O1l1;
wire                          I11O110l;
wire  [id_width-1:0]          I1lI10O1;
wire                          OO1l1100;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]  ll11I01I;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]       l11lIO0O;

  assign IOO1I001          = (a | (a ^ a));
  assign l0IOOO01     = (launch | (launch ^ launch));
  assign lOO0OOIO  = (launch_id | (launch_id ^ launch_id));
  assign I1l0O00I   = (accept_n | (accept_n ^ accept_n));

  // include modeling functions
  `include "DW_sqrt_function.inc"
  assign  I0O0I0O0   = DWF_sqrt_uns (IOO1I001);
  assign  O0O101O0    = DWF_sqrt_tc (IOO1I001);
  assign  l110101O = tc_mode == 1 ? O0O101O0 :I0O0I0O0;
  

reg   [((width+1)/2)-1 : 0]     O1IOI1O1 [0 : ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          O1IOI1O1[i] <= {((width+1)/2){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (I0011010[i] === 1'b1)
            O1IOI1O1[i] <= (i == 0)? l110101O : O1IOI1O1[i-1];
          else if (I0011010[i] !== 1'b0)
            O1IOI1O1[i] <= ((O1IOI1O1[i] ^ ((i == 0)? l110101O : O1IOI1O1[i-1]))
          		      & {((width+1)/2){1'bx}}) ^ O1IOI1O1[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          O1IOI1O1[i] <= {((width+1)/2){1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          O1IOI1O1[i] <= {((width+1)/2){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (I0011010[i] === 1'b1)
            O1IOI1O1[i] <= (i == 0)? l110101O : O1IOI1O1[i-1];
          else if (I0011010[i] !== 1'b0)
            O1IOI1O1[i] <= ((O1IOI1O1[i] ^ ((i == 0)? l110101O : O1IOI1O1[i-1]))
          		      & {((width+1)/2){1'bx}}) ^ O1IOI1O1[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          O1IOI1O1[i] <= {((width+1)/2){1'bx}};
        end
      end
    end
  end
endgenerate

  assign O101Il00 = (in_reg+stages+out_reg == 1)? l110101O : O1IOI1O1[((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin : DW_l0Ol0100
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(rst_n),
                     .init_n(1'b1),
                     .launch(l0IOOO01),
                     .launch_id(lOO0OOIO),
                     .accept_n(I1l0O00I),
                     .arrive(OII01lII),
                     .arrive_id(lIllO000),
                     .pipe_en_bus(ll10100O),
                     .pipe_full(OI1O0II1),
                     .pipe_ovf(OO11lO1O),
                     .push_out_n(lI011I00),
                     .pipe_census(llO1101O)
                     );
  end else begin : DW_OIO1OO1O
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(1'b1),
                     .init_n(rst_n),
                     .launch(l0IOOO01),
                     .launch_id(lOO0OOIO),
                     .accept_n(I1l0O00I),
                     .arrive(OII01lII),
                     .arrive_id(lIllO000),
                     .pipe_en_bus(ll10100O),
                     .pipe_full(OI1O0II1),
                     .pipe_ovf(OO11lO1O),
                     .push_out_n(lI011I00),
                     .pipe_census(llO1101O)
                     );
  end
endgenerate

assign I11O110l         = l0IOOO01;
assign I1lI10O1      = lOO0OOIO;
assign ll11I01I    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b0}};
assign lO1IO0IO      = I1l0O00I;
assign O00I0I10  = lO1IO0IO && I11O110l;
assign OO1l1100     = ~(~I1l0O00I && l0IOOO01);
assign l11lIO0O    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};


assign arrive           = ((in_reg+stages+out_reg) > 1) ? OII01lII      : I11O110l;
assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? lIllO000   : I1lI10O1;
assign I0011010  = ((in_reg+stages+out_reg) > 1) ? ll10100O : ll11I01I;
assign pipe_full        = ((in_reg+stages+out_reg) > 1) ? OI1O0II1   : lO1IO0IO;
assign pipe_ovf         = ((in_reg+stages+out_reg) > 1) ? OO11lO1O    : l1l1O1l1;
assign push_out_n       = ((in_reg+stages+out_reg) > 1) ? lI011I00  : OO1l1100;
assign pipe_census      = ((in_reg+stages+out_reg) > 1) ? llO1101O : l11lIO0O;



generate
  if (rst_mode==0) begin : DW_OIO0I1OO
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        l1l1O1l1     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        l1l1O1l1     <= O00I0I10;
      end else begin
        l1l1O1l1     <= 1'bx;
      end
    end
  end else begin : DW_l1010O00
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        l1l1O1l1     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        l1l1O1l1     <= O00I0I10;
      end else begin
        l1l1O1l1     <= 1'bx;
      end
    end
  end
endgenerate


  assign root  = ((in_reg==0) && (stages==1) && (out_reg==0) && (launch==1'b0)) ? {((width+1)/2){1'bx}} : O101Il00;

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
    end
  
    if ( (id_width < 1) || (id_width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter id_width (legal range: 1 to 1024)",
	id_width );
    end
  
    if ( (stages < 1) || (stages > 1022) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter stages (legal range: 1 to 1022)",
	stages );
    end
  
    if ( (in_reg < 0) || (in_reg > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter in_reg (legal range: 0 to 1)",
	in_reg );
    end
  
    if ( (out_reg < 0) || (out_reg > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter out_reg (legal range: 0 to 1)",
	out_reg );
    end
  
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
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


  
  always @ (clk) begin : monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // monitor_clk 

// synopsys translate_on
endmodule
