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
// AUTHOR:    Doug Lee       1/19/08
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: e769e564
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Low Power Pipelined Multiplier Simulation Model
//
//           This receives two operands that get multiplied.  Configurable
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
//                                  Width of 'b' operand
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
//  a           M bits    Input      Multiplier
//  b           N bits    Input      Multipicand
//  product     P bits    Output     Product a x b
//
//  launch      1 bit     Input      Active High Control input to launch data into pipe
//  launch_id   Q bits    Input      ID tag for operation being launched
//  pipe_full   1 bit     Output     Status Flag indicating no slot for new launch
//  pipe_ovf    1 bit     Output     Status Flag indicating pipe overflow
//
//  accept_n    1 bit     Input      Flow Control Input, Active Low
//  arrive      1 bit     Output     Product available output
//  arrive_id   Q bits    Output     ID tag for product that has arrived
//  push_out_n  1 bit     Output     Active Low Output used with FIFO
//  pipe_census R bits    Output     Output bus indicating the number
//                                   of pipeline register levels currently occupied
//
//     Note: M is the value of "a_width" parameter
//     Note: N is the value of "b_width" parameter
//     Note: P is the value of "a_width + b_width"
//     Note: Q is the value of "id_width" parameter
//     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
//
//
// Modified:
//     LMSU 02/17/15  Updated to eliminate derived internal clock and reset signals
//
////////////////////////////////////////////////////////////////////////////////
module DW_lp_piped_mult(
        clk,            // Clock input
        rst_n,          // Reset

        a,              // Multiplier
        b,              // Multiplicand
        product,        // Pipelined product of a x b

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

parameter a_width  = 8;    // POSITIVE
parameter b_width  = 8;    // POSITIVE
parameter id_width = 8;    // RANGE 1 to 1024
parameter in_reg   = 0;    // RANGE 0 to 1
parameter stages   = 4;    // RANGE 1 to 1022
parameter out_reg  = 0;    // RANGE 0 to 1
parameter tc_mode  = 0;    // RANGE 0 to 1
parameter rst_mode = 0;    // RANGE 0 to 1
parameter op_iso_mode = 0; // RANGE 0 to 4




input                          clk;         // Clock Input
input                          rst_n;       // Reset
input  [a_width-1:0]           a;           // Multiplier
input  [b_width-1:0]           b;           // Multiplicand
output [(a_width+b_width)-1:0]    product;     // Pipelined product of a x b

input                          launch;      // Launch data into pipe
input  [id_width-1:0]          launch_id;   // ID tag of data launched
output                         pipe_full;   // Pipe slots full (used for flow control)
output                         pipe_ovf;    // Pipe overflow

input                          accept_n;    // Take product (flow control)
output                         arrive;      // Product arrival
output [id_width-1:0]          arrive_id;   // ID tag of arrival product
output                         push_out_n;  // Active low output used when FIFO follows

output [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]       pipe_census; // Pipe Stages Occupied Output

// synopsys translate_off

wire  [a_width-1:0]              O01ll0OO;
wire  [b_width-1:0]              OIOl1O0O;
wire                             Ill0Ol1O;
wire  [id_width-1:0]             O1OlOOlO;
wire                             O11O00l0;

wire  [(a_width+b_width)-1:0]       I0IO01l1;
wire  [(a_width+b_width)-1:0]       OOOO11Ol;
wire  [(a_width+b_width)-1:0]       I0lIOOI1;
wire  [(a_width+b_width)-1:0]       OlO1lOl0;
wire  [(a_width+b_width)-1:0]       Il110OO1;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     IIllO11l;

wire                             IOO1I01O;
wire                             OIO1O1l1;
wire                             l0II01OO;
wire  [id_width-1:0]             Oll01I10;
wire                             Il1000I0;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     OII00O00;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          OlO11O1l;

wire                             OO11OIOO;
wire                             I01OO110;
reg                              I001I101;
wire                             OI11IOO0;
wire  [id_width-1:0]             l11lO0lO;
wire                             lI1O0I00;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     lO01OlI0;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          O0O10l0I;



  assign I0IO01l1      = {a, b};
  assign {O01ll0OO, OIOl1O0O} = (I0IO01l1 | (I0IO01l1 ^ I0IO01l1));
  assign Ill0Ol1O     = (launch | (launch ^ launch));
  assign O1OlOOlO  = (launch_id | (launch_id ^ launch_id));
  assign O11O00l0   = (accept_n | (accept_n ^ accept_n));


  assign OOOO11Ol   = O01ll0OO * OIOl1O0O;
  assign I0lIOOI1    = $signed(O01ll0OO) * $signed(OIOl1O0O);
  assign OlO1lOl0 = (tc_mode == 0) ? OOOO11Ol : I0lIOOI1;

reg   [(a_width+b_width)-1 : 0]     IOO00O11 [0 : ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          IOO00O11[i] <= {(a_width+b_width){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (IIllO11l[i] === 1'b1)
            IOO00O11[i] <= (i == 0)? OlO1lOl0 : IOO00O11[i-1];
          else if (IIllO11l[i] !== 1'b0)
            IOO00O11[i] <= ((IOO00O11[i] ^ ((i == 0)? OlO1lOl0 : IOO00O11[i-1]))
          		      & {(a_width+b_width){1'bx}}) ^ IOO00O11[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          IOO00O11[i] <= {(a_width+b_width){1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          IOO00O11[i] <= {(a_width+b_width){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (IIllO11l[i] === 1'b1)
            IOO00O11[i] <= (i == 0)? OlO1lOl0 : IOO00O11[i-1];
          else if (IIllO11l[i] !== 1'b0)
            IOO00O11[i] <= ((IOO00O11[i] ^ ((i == 0)? OlO1lOl0 : IOO00O11[i-1]))
          		      & {(a_width+b_width){1'bx}}) ^ IOO00O11[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          IOO00O11[i] <= {(a_width+b_width){1'bx}};
        end
      end
    end
  end
endgenerate

  assign Il110OO1 = (in_reg+stages+out_reg == 1)? OlO1lOl0 : IOO00O11[((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];





generate
  if (rst_mode==0) begin : DW_l1I00O00
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(rst_n),
                     .init_n(1'b1),
                     .launch(Ill0Ol1O),
                     .launch_id(O1OlOOlO),
                     .accept_n(O11O00l0),
                     .arrive(l0II01OO),
                     .arrive_id(Oll01I10),
                     .pipe_en_bus(OII00O00),
                     .pipe_full(IOO1I01O),
                     .pipe_ovf(OIO1O1l1),
                     .push_out_n(Il1000I0),
                     .pipe_census(OlO11O1l)
                     );
  end else begin : DW_OOOI1O11
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(1'b1),
                     .init_n(rst_n),
                     .launch(Ill0Ol1O),
                     .launch_id(O1OlOOlO),
                     .accept_n(O11O00l0),
                     .arrive(l0II01OO),
                     .arrive_id(Oll01I10),
                     .pipe_en_bus(OII00O00),
                     .pipe_full(IOO1I01O),
                     .pipe_ovf(OIO1O1l1),
                     .push_out_n(Il1000I0),
                     .pipe_census(OlO11O1l)
                     );
  end
endgenerate

assign OI11IOO0         = Ill0Ol1O;
assign l11lO0lO      = O1OlOOlO;
assign lO01OlI0    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b0}};
assign OO11OIOO      = O11O00l0;
assign I01OO110  = OO11OIOO && OI11IOO0;
assign lI1O0I00     = ~(~O11O00l0 && Ill0Ol1O);
assign O0O10l0I    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};


assign arrive           = ((in_reg+stages+out_reg) > 1) ? l0II01OO      : OI11IOO0;
assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? Oll01I10   : l11lO0lO;
assign IIllO11l  = ((in_reg+stages+out_reg) > 1) ? OII00O00 : lO01OlI0;
assign pipe_full        = ((in_reg+stages+out_reg) > 1) ? IOO1I01O   : OO11OIOO;
assign pipe_ovf         = ((in_reg+stages+out_reg) > 1) ? OIO1O1l1    : I001I101;
assign push_out_n       = ((in_reg+stages+out_reg) > 1) ? Il1000I0  : lI1O0I00;
assign pipe_census      = ((in_reg+stages+out_reg) > 1) ? OlO11O1l : O0O10l0I;



generate
  if (rst_mode==0) begin : DW_IO10l0OO
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        I001I101     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        I001I101     <= I01OO110;
      end else begin
        I001I101     <= 1'bx;
      end
    end
  end else begin : DW_O1l0O00O
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        I001I101     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        I001I101     <= I01OO110;
      end else begin
        I001I101     <= 1'bx;
      end
    end
  end
endgenerate


  assign product = ((in_reg==0) && (stages==1) && (out_reg==0) && (launch==1'b0)) ? {(a_width+b_width){1'bx}} : Il110OO1;

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
