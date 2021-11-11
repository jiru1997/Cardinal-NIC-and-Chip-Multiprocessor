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
// DesignWare_version: d58ee583
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Low Power Pipelined Divider Simulation Model
//
//           This receives two operands that get divided.  Configurable
//           to provide pipeline registers for both static and re-timing placement.
//           Also, contains pipeline management to optimized for low power.
//
//
//  Parameters:     Valid Values    Description
//  ==========      ============    =============
//   a_width           >= 1         default: 8
//                                  Width of 'a' operand
//
//   b_width           >= 1         default: 8
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
//   rem_mode	     0 or 1	    default: 0
//                                  Remainder output control:
//				      0 : remainder output is VHDL modulus
//				      1 : remainder output is remainder  
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
//  a           a_width bits    Input      Divider
//  b           b_width bits    Input	   divipicand
//  quotient    a_width bits    Output     quotient a / b
//  rem         b_width bits    Output     rem a / b
//  div_by_0    1 bit           Output     high when b input is zero
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
//     Note: R is equal to the the larger of '1' or ceil(log2(in_reg+stages+out_reg))
//
//
// Modified:
//     LMSU 02/17/15  Updated to eliminate derived internal clock and reset signals
//
//     JBD Modified original DW_lp_piped_mult to div
//
////////////////////////////////////////////////////////////////////////////////
module DW_lp_piped_div(clk,rst_n,a,b,quotient,remainder,div_by_0,launch,launch_id,
                       pipe_full,pipe_ovf,accept_n,arrive,arrive_id,push_out_n,pipe_census);

parameter a_width  = 8;    // RANGE 1 to 1024
parameter b_width  = 8;    // RANGE 1 to 1024
parameter id_width = 8;    // RANGE 1 to 1024
parameter in_reg   = 0;    // RANGE 0 to 1
parameter stages   = 4;    // RANGE 1 to 1022
parameter out_reg  = 0;    // RANGE 0 to 1
parameter tc_mode  = 0;    // RANGE 0 to 1
parameter rst_mode = 0;    // RANGE 0 to 1
parameter rem_mode = 0;    // RANGE 0 to 1
parameter op_iso_mode = 0; // RANGE 0 to 4




input                   clk;         // Clock Input
input                   rst_n;       // Async. Reset
input  [a_width-1:0]    a;           // Divider
input  [b_width-1:0]    b;           // diviplicand
output [a_width-1:0]    quotient;    // Pipelined quotient of a / b
output [b_width-1:0]    remainder;   // Pipelined remainder of a / b
output                  div_by_0;    // Pipelined b == 0 flag

input                   launch;      // Input to launch data into pipe
input  [id_width-1:0]   launch_id;   // ID tag of data launched
output                  pipe_full;   // Pipe Slots Full Output (used for flow control)
output                  pipe_ovf;    // Pipe Overflow Signal

input                   accept_n;    // Hold Data Out Input (flow control)
output                  arrive;      // Data Arrival Output
output [id_width-1:0]   arrive_id;   // ID tag of arrival data
output                  push_out_n;  // Active Low Output used when FIFO follows

output [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0] pipe_census; // Pipe Stages Occupied Output

// synopsys translate_off

wire  [a_width-1:0]         OOlO001O;
wire  [b_width-1:0]         O0lOOI0O;
wire                        O1O10ll0;
wire  [id_width-1:0]        I1lIOO00;
wire                        l0Ol1l1l;

wire  [(a_width+b_width+1)-1:0] IIIO11ll;
wire  [(a_width+b_width+1)-1:0] l0OI1O10;
wire  [(a_width+b_width+1)-1:0] I0I1111O;

reg   [a_width-1:0]         lO1100OO;
reg   [b_width-1:0]         I0Ol0l0I;
reg                         lO1l100I;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]  lOI00O01;

wire                             I0110Ol1;
wire                             O010001I;
wire                             I0O11111;
wire  [id_width-1:0]             l0l010I1;
wire                             OII0lO11;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     O10l0I1O;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          l1l1I10O;

wire                             O101O111;
wire                             lOI1Ol1I;
reg                              O1OI100l;
wire                             IO0l001O;
wire  [id_width-1:0]             IOOlOl1I;
wire                             lO111l11;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     l001OO10;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          I10OO110;

reg 		       l1I111lO;
reg 		       Il0I0OII;

  // include modeling functions
`include "DW_div_function.inc"

  assign IIIO11ll      = {a, b};
  assign {OOlO001O, O0lOOI0O} = (IIIO11ll | (IIIO11ll ^ IIIO11ll));
  assign O1O10ll0     = (launch | (launch ^ launch));
  assign I1lIOO00  = (launch_id | (launch_id ^ launch_id));
  assign l0Ol1l1l   = (accept_n | (accept_n ^ accept_n));

  always @(a or b)
  begin
    if (tc_mode == 0) begin
      lO1100OO = DWF_div_uns (a, b);
      if (rem_mode == 1)
	I0Ol0l0I = DWF_rem_uns (a, b);
      else
	I0Ol0l0I = DWF_mod_uns (a, b);
    end
    else begin
      lO1100OO = DWF_div_tc (a, b);
      if (rem_mode == 1)
	I0Ol0l0I = DWF_rem_tc (a, b);
      else
	I0Ol0l0I = DWF_mod_tc (a, b);
    end
    l1I111lO = ^b;
    if (l1I111lO === 1'bx)
      Il0I0OII = 1'bx;
    else if (b == {b_width{1'b0}})
      Il0I0OII = 1'b1;
    else
      Il0I0OII = 1'b0;
  end 
  assign l0OI1O10 = {lO1100OO,I0Ol0l0I,Il0I0OII};
  

reg   [(a_width+b_width+1)-1 : 0]     l0lIlI11 [0 : ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers
      integer lOO0OO1O;

      if (rst_n === 1'b0) begin
        for (lOO0OO1O=0 ; lOO0OO1O <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; lOO0OO1O=lOO0OO1O+1) begin
          l0lIlI11[lOO0OO1O] <= {(a_width+b_width+1){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lOO0OO1O=0 ; lOO0OO1O <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; lOO0OO1O=lOO0OO1O+1) begin
          if (lOI00O01[lOO0OO1O] === 1'b1)
            l0lIlI11[lOO0OO1O] <= (lOO0OO1O == 0)? l0OI1O10 : l0lIlI11[lOO0OO1O-1];
          else if (lOI00O01[lOO0OO1O] !== 1'b0)
            l0lIlI11[lOO0OO1O] <= ((l0lIlI11[lOO0OO1O] ^ ((lOO0OO1O == 0)? l0OI1O10 : l0lIlI11[lOO0OO1O-1]))
          		      & {(a_width+b_width+1){1'bx}}) ^ l0lIlI11[lOO0OO1O];
        end
      end else begin
        for (lOO0OO1O=0 ; lOO0OO1O <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; lOO0OO1O=lOO0OO1O+1) begin
          l0lIlI11[lOO0OO1O] <= {(a_width+b_width+1){1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers
      integer lOO0OO1O;

      if (rst_n === 1'b0) begin
        for (lOO0OO1O=0 ; lOO0OO1O <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; lOO0OO1O=lOO0OO1O+1) begin
          l0lIlI11[lOO0OO1O] <= {(a_width+b_width+1){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lOO0OO1O=0 ; lOO0OO1O <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; lOO0OO1O=lOO0OO1O+1) begin
          if (lOI00O01[lOO0OO1O] === 1'b1)
            l0lIlI11[lOO0OO1O] <= (lOO0OO1O == 0)? l0OI1O10 : l0lIlI11[lOO0OO1O-1];
          else if (lOI00O01[lOO0OO1O] !== 1'b0)
            l0lIlI11[lOO0OO1O] <= ((l0lIlI11[lOO0OO1O] ^ ((lOO0OO1O == 0)? l0OI1O10 : l0lIlI11[lOO0OO1O-1]))
          		      & {(a_width+b_width+1){1'bx}}) ^ l0lIlI11[lOO0OO1O];
        end
      end else begin
        for (lOO0OO1O=0 ; lOO0OO1O <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; lOO0OO1O=lOO0OO1O+1) begin
          l0lIlI11[lOO0OO1O] <= {(a_width+b_width+1){1'bx}};
        end
      end
    end
  end
endgenerate

  assign I0I1111O = (in_reg+stages+out_reg == 1)? l0OI1O10 : l0lIlI11[((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin : DW_lO1I0Ill
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(rst_n),
                     .init_n(1'b1),
                     .launch(O1O10ll0),
                     .launch_id(I1lIOO00),
                     .accept_n(l0Ol1l1l),
                     .arrive(I0O11111),
                     .arrive_id(l0l010I1),
                     .pipe_en_bus(O10l0I1O),
                     .pipe_full(I0110Ol1),
                     .pipe_ovf(O010001I),
                     .push_out_n(OII0lO11),
                     .pipe_census(l1l1I10O)
                     );
  end else begin : DW_OlIOI10O
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(1'b1),
                     .init_n(rst_n),
                     .launch(O1O10ll0),
                     .launch_id(I1lIOO00),
                     .accept_n(l0Ol1l1l),
                     .arrive(I0O11111),
                     .arrive_id(l0l010I1),
                     .pipe_en_bus(O10l0I1O),
                     .pipe_full(I0110Ol1),
                     .pipe_ovf(O010001I),
                     .push_out_n(OII0lO11),
                     .pipe_census(l1l1I10O)
                     );
  end
endgenerate

assign IO0l001O         = O1O10ll0;
assign IOOlOl1I      = I1lIOO00;
assign l001OO10    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b0}};
assign O101O111      = l0Ol1l1l;
assign lOI1Ol1I  = O101O111 && IO0l001O;
assign lO111l11     = ~(~l0Ol1l1l && O1O10ll0);
assign I10OO110    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};


assign arrive           = ((in_reg+stages+out_reg) > 1) ? I0O11111      : IO0l001O;
assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? l0l010I1   : IOOlOl1I;
assign lOI00O01  = ((in_reg+stages+out_reg) > 1) ? O10l0I1O : l001OO10;
assign pipe_full        = ((in_reg+stages+out_reg) > 1) ? I0110Ol1   : O101O111;
assign pipe_ovf         = ((in_reg+stages+out_reg) > 1) ? O010001I    : O1OI100l;
assign push_out_n       = ((in_reg+stages+out_reg) > 1) ? OII0lO11  : lO111l11;
assign pipe_census      = ((in_reg+stages+out_reg) > 1) ? l1l1I10O : I10OO110;



generate
  if (rst_mode==0) begin : DW_lOII0OO0
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        O1OI100l     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        O1OI100l     <= lOI1Ol1I;
      end else begin
        O1OI100l     <= 1'bx;
      end
    end
  end else begin : DW_OO0lO1OO
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        O1OI100l     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        O1OI100l     <= lOI1Ol1I;
      end else begin
        O1OI100l     <= 1'bx;
      end
    end
  end
endgenerate




  assign quotient  = ((in_reg==0) && (stages==1) && (out_reg==0) && (launch==1'b0)) ? {a_width{1'bx}} :
                                                                                      I0I1111O[a_width+b_width : b_width + 1];
  assign remainder = ((in_reg==0) && (stages==1) && (out_reg==0) && (launch==1'b0)) ? {b_width{1'bx}} : I0I1111O[b_width : 1];
  assign div_by_0  = ((in_reg==0) && (stages==1) && (out_reg==0) && (launch==1'b0)) ? 1'bx : I0I1111O[0];

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
  
    if ( (rem_mode < 0) || (rem_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rem_mode (legal range: 0 to 1)",
	rem_mode );
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
