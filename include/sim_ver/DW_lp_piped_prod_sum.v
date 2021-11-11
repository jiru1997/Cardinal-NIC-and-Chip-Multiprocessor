////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2008 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Doug Lee       01/17/08
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 6e6d3057
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Low Power Pipelined Sum of Products Simulation Model
//
//           This receives two set of 'concatenated' operands that result
//           in a summation from a set of products.  Configurable to provide
//           pipeline registers for both static and re-timing placement.
//           Also, contains pipeline management to optimized for low power.
//
//
//  Parameters:     Valid Values    Description
//  ==========      ============    =============
//   a_width           >= 1         default: 8
//                                  Width of 'a' operand
//
//   b_width           >= 1         default: 8
//                                  Width of 'b' operand
//
//   num_inputs        >= 1         default: 2
//                                  Number of inputs each in 'a' and 'b'
//
//   sum_width         >= 1         default: 17
//                                  Width of 'sum' result
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
//   tc_mode          0 to 1        default: 0
//                                  Two's complement control
//                                    0 => unsigned
//                                    1 => two's complement
//
//   rst_mode         0 to 1        default: 0
//                                  Control asynchronous or synchronous reset
//                                  behavior of rst_n
//                                    0 => asynchronous reset
//                                    1 => synchronous reset
//
//   op_iso_mode      0 to 4        default: 0
//                                  Type of operand isolation
//                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
//                                    0 => Follow intent defined by Power Compiler user setting
//                                    1 => no operand isolation
//                                    2 => 'and' gate operand isolaton
//                                    3 => 'or' gate operand isolation
//                                    4 => preferred isolation style: 'and'
//
//
//  Ports       Size    Direction    Description
//  =====       ====    =========    ===========
//  clk         1 bit     Input      Clock Input
//  rst_n       1 bit     Input      Reset Input, Active Low
//
//  a           M bits    Input      Concatenated multiplier(s)
//  b           N bits    Input      Concatenated multipicand(s)
//  sum         P bits    Output     Sum of products
//
//  launch      1 bit     Input      Active High Control input to launch data into pipe
//  launch_id   Q bits    Input      ID tag for operation being launched
//  pipe_full   1 bit     Output     Status Flag indicating no slot for a new launch
//  pipe_ovf    1 bit     Output     Status Flag indicating pipe overflow
//
//  accept_n    1 bit     Input      Flow Control Input, Active Low
//  arrive      1 bit     Output     Product available output
//  arrive_id   Q bits    Output     ID tag for product that has arrived
//  push_out_n  1 bit     Output     Active Low Output used with FIFO
//  pipe_census R bits    Output     Output bus indicating the number
//                                   of pipeline register levels currently occupied
//
//     Note: M is "a_width x num_inputs"
//     Note: N is "b_width x num_inputs"
//     Note: P is the value of "sum_width" parameter
//     Note: Q is the value of "id_width" parameter
//     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
//
//
// Modified:
//     LMSU 02/17/15  Updated to eliminate derived internal clock and reset signals
//
////////////////////////////////////////////////////////////////////////////////
module DW_lp_piped_prod_sum (
        clk,            // Clock Input
        rst_n,          // Reset

        a,              // Concatenated multiplier(s)
        b,              // Concatenated multiplicand(s)
        sum,            // Pipelined some of products

        launch,         // Launch data into pipe input
        launch_id,      // ID tag of data launched input
        pipe_full,      // Pipe slots full output (used for flow control)
        pipe_ovf,       // Pipe overflow output

        accept_n,       // Take product input (flow control)
        arrive,         // Data arrival output
        arrive_id,      // ID tag of arrival product output
        push_out_n,     // Active low output used when FIFO follows
        pipe_census     // Pipe stages occupied count output
        );

parameter a_width = 8;     // POSITIVE
parameter b_width = 8;     // POSITIVE
parameter num_inputs = 2;  // POSITIVE
parameter sum_width = 8;   // POSITIVE
parameter id_width = 8;    // RANGE 1 to 1024
parameter in_reg = 0;      // RANGE 0 to 1
parameter stages = 4;      // RANGE 1 to 1022
parameter out_reg = 0;     // RANGE 0 to 1
parameter tc_mode = 0;     // RANGE 0 to 1
parameter rst_mode = 0;    // RANGE 0 to 1
parameter op_iso_mode = 0; // RANGE 0 to 4




input                          clk;         // Clock
input                          rst_n;       // Reset
input [(a_width*num_inputs)-1:0]        a;           // Concatenated multipliers
input [(b_width*num_inputs)-1:0]        b;           // Concatenated multiplicands
output [sum_width-1:0]         sum;         // Sum of product

input                          launch;      // Launch data into pipe
input  [id_width-1:0]          launch_id;   // ID tag of data launched
output                         pipe_full;   // Pipe slots full (used for flow control)
output                         pipe_ovf;    // Pipe overflow

input                          accept_n;    // Take product (flow control)
output                         arrive;      // Product arrival
output [id_width-1:0]          arrive_id;   // ID tag of arrival product
output                         push_out_n;  // Active low output used when FIFO follows

output [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]       pipe_census; // Pipe stages occupied count output

// synopsys translate_off 



wire [(a_width*num_inputs)-1:0]           Il1OOII0;
wire [(b_width*num_inputs)-1:0]           Il0O0O00;

reg  [a_width-1:0]               lOO11l1O;
reg  [b_width-1:0]               OO0Ol10l;
reg  [sum_width-1 : 0]           Il000OII;
reg  [sum_width-1 : 0]           OOO1I100[num_inputs-1 :0];
reg                              I011O0I0;
reg                              l100I1O1;

wire                             lOO1I00O;
wire  [id_width-1:0]             I110l1O0;
wire                             I01O0IlI;

wire  [(a_width+b_width)-1:0]       O0100OO0;
wire  [(a_width+b_width)-1:0]       Oll1OI10;
wire  [sum_width-1:0]            l0O0OO10;
wire  [sum_width-1:0]            IlIOI0ll;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     lO10OO0I;

wire                             I1011OI0;
wire                             O1O0lll0;
wire                             O0IOl101;
wire  [id_width-1:0]             O1IOOl0O;
wire                             IIOOOO01;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     OIOl11O1;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          OO0O0O01;

wire                             l101I1l1;
wire                             O101lO0O;
reg                              OO0I00I0;
wire                             Ol0I1OlO;
wire  [id_width-1:0]             OO1O110I;
wire                             O1l1O00I;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     l0I0OO1O;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          OI10OOO0;


  //---------------------------------------------------------------------------
  // Parameter legality check
  //---------------------------------------------------------------------------

  
 
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
  
    if (num_inputs < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_inputs (lower bound: 1)",
	num_inputs );
    end
  
    if (sum_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sum_width (lower bound: 1)",
	sum_width );
    end
  
    if ( (stages < 1) || (stages > 1022) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter stages (legal range: 1 to 1022)",
	stages );
    end
  
    if ( (id_width < 1) || (id_width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter id_width (legal range: 1 to 1024)",
	id_width );
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
  
  

  assign Il1OOII0          = (a | (a ^ a));
  assign Il0O0O00          = (b | (b ^ b));
  assign lOO1I00O     = (launch | (launch ^ launch));
  assign I110l1O0  = (launch_id | (launch_id ^ launch_id));
  assign I01O0IlI   = (accept_n | (accept_n ^ accept_n));


  always @(Il1OOII0 or Il0O0O00) begin : prod_sum_calc_PROC
    integer Ol0I1OO0, OII111O1, lIOI1OO1;

    for(Ol0I1OO0=0; Ol0I1OO0 <= num_inputs-1; Ol0I1OO0=Ol0I1OO0+1) begin 
      I011O0I0 = Il1OOII0[(Ol0I1OO0+1)*a_width-1];
      l100I1O1 = Il0O0O00[(Ol0I1OO0+1)*b_width-1];
      for(OII111O1=Ol0I1OO0*a_width;OII111O1 <= (Ol0I1OO0+1) * a_width-1;OII111O1=OII111O1+1) begin
        lOO11l1O[OII111O1 -Ol0I1OO0*a_width] = Il1OOII0[OII111O1]; 
      end
      for(lIOI1OO1=Ol0I1OO0*b_width;lIOI1OO1 <= (Ol0I1OO0+1) * b_width-1;lIOI1OO1=lIOI1OO1+1) begin
        OO0Ol10l[lIOI1OO1 -Ol0I1OO0*b_width] = Il0O0O00[lIOI1OO1];
      end
	    
      if (I011O0I0 && tc_mode) 
	lOO11l1O = ~lOO11l1O + 1'b1;
      if (l100I1O1 && tc_mode) 
	OO0Ol10l = ~OO0Ol10l + 1'b1;
	    
      OOO1I100[Ol0I1OO0] = lOO11l1O * OO0Ol10l;
      if ( (I011O0I0 ^ l100I1O1) && tc_mode) 
        OOO1I100[Ol0I1OO0] = ~(OOO1I100[Ol0I1OO0] -1'b1);
    end

    Il000OII = {sum_width{1'b0}};
    for(Ol0I1OO0=0; Ol0I1OO0 <= num_inputs-1; Ol0I1OO0=Ol0I1OO0+1) begin 
      Il000OII = Il000OII + OOO1I100[Ol0I1OO0];
    end
  end
  assign l0O0OO10 = Il000OII;

reg   [sum_width-1 : 0]     O0l10l11 [0 : ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers
      integer Ol0I1OO0;

      if (rst_n === 1'b0) begin
        for (Ol0I1OO0=0 ; Ol0I1OO0 <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; Ol0I1OO0=Ol0I1OO0+1) begin
          O0l10l11[Ol0I1OO0] <= {sum_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (Ol0I1OO0=0 ; Ol0I1OO0 <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; Ol0I1OO0=Ol0I1OO0+1) begin
          if (lO10OO0I[Ol0I1OO0] === 1'b1)
            O0l10l11[Ol0I1OO0] <= (Ol0I1OO0 == 0)? l0O0OO10 : O0l10l11[Ol0I1OO0-1];
          else if (lO10OO0I[Ol0I1OO0] !== 1'b0)
            O0l10l11[Ol0I1OO0] <= ((O0l10l11[Ol0I1OO0] ^ ((Ol0I1OO0 == 0)? l0O0OO10 : O0l10l11[Ol0I1OO0-1]))
          		      & {sum_width{1'bx}}) ^ O0l10l11[Ol0I1OO0];
        end
      end else begin
        for (Ol0I1OO0=0 ; Ol0I1OO0 <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; Ol0I1OO0=Ol0I1OO0+1) begin
          O0l10l11[Ol0I1OO0] <= {sum_width{1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers
      integer Ol0I1OO0;

      if (rst_n === 1'b0) begin
        for (Ol0I1OO0=0 ; Ol0I1OO0 <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; Ol0I1OO0=Ol0I1OO0+1) begin
          O0l10l11[Ol0I1OO0] <= {sum_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (Ol0I1OO0=0 ; Ol0I1OO0 <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; Ol0I1OO0=Ol0I1OO0+1) begin
          if (lO10OO0I[Ol0I1OO0] === 1'b1)
            O0l10l11[Ol0I1OO0] <= (Ol0I1OO0 == 0)? l0O0OO10 : O0l10l11[Ol0I1OO0-1];
          else if (lO10OO0I[Ol0I1OO0] !== 1'b0)
            O0l10l11[Ol0I1OO0] <= ((O0l10l11[Ol0I1OO0] ^ ((Ol0I1OO0 == 0)? l0O0OO10 : O0l10l11[Ol0I1OO0-1]))
          		      & {sum_width{1'bx}}) ^ O0l10l11[Ol0I1OO0];
        end
      end else begin
        for (Ol0I1OO0=0 ; Ol0I1OO0 <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; Ol0I1OO0=Ol0I1OO0+1) begin
          O0l10l11[Ol0I1OO0] <= {sum_width{1'bx}};
        end
      end
    end
  end
endgenerate

  assign IlIOI0ll = (in_reg+stages+out_reg == 1)? l0O0OO10 : O0l10l11[((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];





generate
  if (rst_mode==0) begin : DW_O010001O
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(rst_n),
                     .init_n(1'b1),
                     .launch(lOO1I00O),
                     .launch_id(I110l1O0),
                     .accept_n(I01O0IlI),
                     .arrive(O0IOl101),
                     .arrive_id(O1IOOl0O),
                     .pipe_en_bus(OIOl11O1),
                     .pipe_full(I1011OI0),
                     .pipe_ovf(O1O0lll0),
                     .push_out_n(IIOOOO01),
                     .pipe_census(OO0O0O01)
                     );
  end else begin : DW_l00OIl01
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(1'b1),
                     .init_n(rst_n),
                     .launch(lOO1I00O),
                     .launch_id(I110l1O0),
                     .accept_n(I01O0IlI),
                     .arrive(O0IOl101),
                     .arrive_id(O1IOOl0O),
                     .pipe_en_bus(OIOl11O1),
                     .pipe_full(I1011OI0),
                     .pipe_ovf(O1O0lll0),
                     .push_out_n(IIOOOO01),
                     .pipe_census(OO0O0O01)
                     );
  end
endgenerate

assign Ol0I1OlO         = lOO1I00O;
assign OO1O110I      = I110l1O0;
assign l0I0OO1O    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b0}};
assign l101I1l1      = I01O0IlI;
assign O101lO0O  = l101I1l1 && Ol0I1OlO;
assign O1l1O00I     = ~(~I01O0IlI && lOO1I00O);
assign OI10OOO0    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};


assign arrive           = ((in_reg+stages+out_reg) > 1) ? O0IOl101      : Ol0I1OlO;
assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? O1IOOl0O   : OO1O110I;
assign lO10OO0I  = ((in_reg+stages+out_reg) > 1) ? OIOl11O1 : l0I0OO1O;
assign pipe_full        = ((in_reg+stages+out_reg) > 1) ? I1011OI0   : l101I1l1;
assign pipe_ovf         = ((in_reg+stages+out_reg) > 1) ? O1O0lll0    : OO0I00I0;
assign push_out_n       = ((in_reg+stages+out_reg) > 1) ? IIOOOO01  : O1l1O00I;
assign pipe_census      = ((in_reg+stages+out_reg) > 1) ? OO0O0O01 : OI10OOO0;


generate
  if (rst_mode==0) begin : DW_IOO1l0I1
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        OO0I00I0     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        OO0I00I0     <= O101lO0O;
      end else begin
        OO0I00I0     <= 1'bx;
      end
    end
  end else begin : DW_lO0IO0lI
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        OO0I00I0     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        OO0I00I0     <= O101lO0O;
      end else begin
        OO0I00I0     <= 1'bx;
      end
    end
  end
endgenerate



  assign sum = ((in_reg==0) && (stages==1) && (out_reg==0) && (launch==1'b0)) ? {sum_width{1'bx}} : IlIOI0ll;
  // synopsys translate_on

endmodule
