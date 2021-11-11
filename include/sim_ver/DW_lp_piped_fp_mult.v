////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2009 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Doug Lee       2/20/09
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: fd91bd10
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//
// ABSTRACT: Low power pipelined Floating point Divider Synthetic Model 
//
//           This receives two operands that get multicated(is this a word?).  Configurable
//           to provide pipeline registers for both static and re-timing placement.  
//           Also, contains pipeline management to optimized for low power.
//
//  parameters:     Valid Values    Description
//  ==========      ============    =============
//   sig_width           >= 1         default: 8
//                                  Width of 'a' operand
//
//   exp_width           >= 1         default: 8
//                                  Width of 'a' operand
//
//   ieee_compliance    0 to 1      support the IEEE Compliance 
//                       0        - IEEE 754 compatible without denormal support
//                                  (NaN becomes Infinity, Denormal becomes Zero)
//                       1        - IEEE 754 compatible with denormal support
//                                  (NaN and denormal numbers are supported)
//   op_iso_mode      0 to 4        default: 0
//                                  Type of operand isolation
//                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
//                                    0 => Follow intent defined by Power Compiler user setting
//                                    1 => no operand isolation
//                                    2 => 'and' gate isolaton
//                                    3 => 'or' gate isolation
//                                    4 => preferred isolation style: 'and' gate
//
//   id_width        1 to 1024      default: 8
//                                  Launch identifier width
//
//   in_reg          0 to 1         default: 0
//                                  Input register control
//                                    0 => no input register
//                                    1 => include input register
//
//   stages          1 to 1022      default: 4
//                                  Number of logic stages in the pipeline
//
//   out_reg         0 to 1         default: 0
//                                  Output register control
//                                    0 => no output register
//                                    1 => include output register
//
//   no_pm            0 to 1        default: 1
//                                  No pipeline management used
//                                    0 => Use pipeline management
//                                    1 => Do not use pipeline management - launch input
//                                          becomes global register enable to block
//
//   rst_mode        0 to 1         default: 0
//                                  Control asynchronous or synchronous reset 
//                                  behavior of rst_n
//                                    0 => asynchronous reset
//                                    1 -> synchronous reset 
//
//  ports       Size            Direction    Description
//  =====       ====            =========    ===========
//  clk         1 bit           Input	     Clock Input
//  rst_n       1 bit           Input	     Reset Input, Active Low
//
//  a           M bits	        Input	     Divisor
//  b           M bits	        Input	     Dividend
//  z           M bits	        Output       z = a/b
//  I0I0001l  8 bits          Output     
//
//  launch      1 bit           Input	     Active High Control input to launch data into pipe
//  launch_id   id_width bits   Input	     ID tag for data being launched (optional)
//  pipe_full   1 bit           Output       Status Flag indicating no slot for new data
//  pipe_ovf    1 bit           Output       Status Flag indicating pipe overflow
//
//  accept_n    1 bit           Input	     Flow Control Input, Active Low
//  arrive      1 bit           Output       Data Available output
//  arrive_id   id_width bits   Output       ID tag for data that's arrived (optional)
//  push_out_n  1 bit           Output       Active Low Output used with FIFO (optional)
//  pipe_census R bits          Output       Output bus indicating the number
//                                           of pipe stages currently occupied
//
//  * where M equals   sig_width +exp_width+1 bits                                       
//                                           
// Modified:
//  LMSU 02/17/15  Updated to eliminate derived internal clock and reset signals
//
////////////////////////////////////////////////////////////////////////////////
module DW_lp_piped_fp_mult(clk,rst_n,a,b,z,rnd,status,launch,launch_id,
                       pipe_full,pipe_ovf,accept_n,arrive,arrive_id,push_out_n,pipe_census);

parameter sig_width       = 23;
parameter exp_width       = 8;
parameter ieee_compliance = 0;
parameter op_iso_mode     = 0;
parameter id_width        = 8;
parameter in_reg          = 0;
parameter stages          = 4;
parameter out_reg         = 0;
parameter no_pm           = 1;
parameter rst_mode        = 0;



input                    clk;    // Clock Input
input                    rst_n;  // Async. Reset
input  [(sig_width+exp_width):0]     a;      // Dividend In
input  [(sig_width+exp_width):0]     b;      // Divisor In
input  [2:0]             rnd;    // rounding mode
output [(sig_width+exp_width):0]     z;      // Pipelined z of a / b
output [7:0]             status; // Pipelined b == 0 flag

input                    launch;      // Input to launch data into pipe
input  [id_width-1:0]    launch_id;   // ID tag of data launched
output                   pipe_full;   // Pipe Slots Full Output (used for flow control)
output                   pipe_ovf;    // Pipe Overflow Signal

input                    accept_n;    // Hold Data Out Input (flow control)
output                   arrive;      // Data Arrival Output
output [id_width-1:0]    arrive_id;   // ID tag of arrival data
output                   push_out_n;  // Active Low Output used when FIFO follows

output [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0] pipe_census; // Pipe Stages Occupied Output

// synopsys translate_off
wire  [(sig_width+exp_width):0]          l11lIO00;
wire  [(sig_width+exp_width):0]          l00llO00;
wire  [2:0]                  I1100O11;
wire                         OI10lO01;
wire  [id_width-1:0]         O1O0O11O;
wire                         OI1OlO00;

wire  [((2*(sig_width+exp_width + 1))+2):0]         O00ll10l;

wire  [(sig_width+exp_width):0]          O0Ol00I1;
wire  [(sig_width+exp_width + 8):0]        OO1101Ol;
wire  [(sig_width+exp_width + 8):0]        l1I011OI;

wire  [7:0]                  I0I0001l;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] O1I01OO0;

wire                         lIl001O1;
wire                         OOI0OO1O;
wire                         OI01IlOO;
wire  [id_width-1:0]         O0OlO1l1;
wire                         OIO1Il0l;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] l11lOO1l;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]      O10010Ol;

wire                         Ol1O1O10;
wire                         O001lIO1;
reg                          OIOO1Ol1;
wire                         Ol000110;
wire  [id_width-1:0]         IOI0O01l;
wire  [id_width-1:0]         O1II1l1l;
wire                         l1O0OOl0;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] OI00l01O;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]      l0I1011I;

assign O00ll10l    = {a,b, rnd};

assign {l11lIO00, l00llO00, I1100O11} = (O00ll10l | (O00ll10l ^ O00ll10l));
assign OI10lO01              = (launch | (launch ^ launch));
assign O1O0O11O           = (launch_id | (launch_id ^ launch_id));
assign OI1OlO00            = (accept_n | (accept_n ^ accept_n));

reg   [id_width-1 : 0]     O11I01O1 [0 : ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_arrive_id
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          O11I01O1[i] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          if (O1I01OO0[i] === 1'b1)
            O11I01O1[i] <= (i == 0)? O1O0O11O : O11I01O1[i-1];
          else if (O1I01OO0[i] !== 1'b0)
            O11I01O1[i] <= ((O11I01O1[i] ^ ((i == 0)? O1O0O11O : O11I01O1[i-1]))
          		      & {id_width{1'bx}}) ^ O11I01O1[i];
        end
      end else begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          O11I01O1[i] <= {id_width{1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_arrive_id
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          O11I01O1[i] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          if (O1I01OO0[i] === 1'b1)
            O11I01O1[i] <= (i == 0)? O1O0O11O : O11I01O1[i-1];
          else if (O1I01OO0[i] !== 1'b0)
            O11I01O1[i] <= ((O11I01O1[i] ^ ((i == 0)? O1O0O11O : O11I01O1[i-1]))
          		      & {id_width{1'bx}}) ^ O11I01O1[i];
        end
      end else begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          O11I01O1[i] <= {id_width{1'bx}};
        end
      end
    end
  end
endgenerate

  assign O1II1l1l = (in_reg+stages+out_reg == 1)? O1O0O11O : O11I01O1[((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];


DW_fp_mult #(sig_width, exp_width, 
	    ieee_compliance) 
  U_fp_mult (
	    .a(l11lIO00),
	    .b(l00llO00),
	    .rnd(I1100O11),
	    .z(O0Ol00I1),
	    .status(I0I0001l) );

assign OO1101Ol = {O0Ol00I1,(I0I0001l ^ 8'b00000001)};
  

reg   [(sig_width+exp_width + 8) : 0]     IOIOO1I0 [0 : ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          IOIOO1I0[i] <= {(sig_width+exp_width + 8) +1 {1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (O1I01OO0[i] === 1'b1)
            IOIOO1I0[i] <= (i == 0)? OO1101Ol : IOIOO1I0[i-1];
          else if (O1I01OO0[i] !== 1'b0)
            IOIOO1I0[i] <= ((IOIOO1I0[i] ^ ((i == 0)? OO1101Ol : IOIOO1I0[i-1]))
          		      & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ IOIOO1I0[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          IOIOO1I0[i] <= {(sig_width+exp_width + 8) +1 {1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          IOIOO1I0[i] <= {(sig_width+exp_width + 8) +1 {1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (O1I01OO0[i] === 1'b1)
            IOIOO1I0[i] <= (i == 0)? OO1101Ol : IOIOO1I0[i-1];
          else if (O1I01OO0[i] !== 1'b0)
            IOIOO1I0[i] <= ((IOIOO1I0[i] ^ ((i == 0)? OO1101Ol : IOIOO1I0[i-1]))
          		      & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ IOIOO1I0[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          IOIOO1I0[i] <= {(sig_width+exp_width + 8) +1 {1'bx}};
        end
      end
    end
  end
endgenerate

  assign l1I011OI = (in_reg+stages+out_reg == 1)? OO1101Ol : IOIOO1I0[((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin : DW_lOO11O00
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) 
      U_PIPE_MGR (
              .clk(clk),
              .rst_n(rst_n),
              .init_n(1'b1),
              .launch(OI10lO01),
              .launch_id(O1O0O11O),
              .accept_n(OI1OlO00),
              .arrive(OI01IlOO),
              .arrive_id(O0OlO1l1),
              .pipe_en_bus(l11lOO1l),
              .pipe_full(lIl001O1),
              .pipe_ovf(OOI0OO1O),
              .push_out_n(OIO1Il0l),
              .pipe_census(O10010Ol)
              );
  end else begin : DW_lI110I1O
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) 
      U_PIPE_MGR (
              .clk(clk),
              .rst_n(1'b1),
              .init_n(rst_n),
              .launch(OI10lO01),
              .launch_id(O1O0O11O),
              .accept_n(OI1OlO00),
              .arrive(OI01IlOO),
              .arrive_id(O0OlO1l1),
              .pipe_en_bus(l11lOO1l),
              .pipe_full(lIl001O1),
              .pipe_ovf(OOI0OO1O),
              .push_out_n(OIO1Il0l),
              .pipe_census(O10010Ol)
              );
  end
endgenerate

assign Ol000110         = OI10lO01;
assign IOI0O01l      = O1O0O11O;
assign OI00l01O    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b1}};
assign Ol1O1O10      = OI1OlO00;
assign O001lIO1  = Ol1O1O10 && Ol000110;
assign l1O0OOl0     = ~(~OI1OlO00 && OI10lO01);
assign l0I1011I    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};

assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? (no_pm ? O1II1l1l: O0OlO1l1) : IOI0O01l;
assign O1I01OO0  = ((in_reg+stages+out_reg) > 1) ? (no_pm ? {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){launch}} : l11lOO1l) : OI00l01O;
assign pipe_full        =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? lIl001O1     : Ol1O1O10;
assign pipe_ovf         =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OOI0OO1O      : OIOO1Ol1;

assign arrive           =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OI01IlOO        : Ol000110;
assign push_out_n       =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OIO1Il0l    : l1O0OOl0;
assign pipe_census      =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? O10010Ol   : l0I1011I;

generate
  if (rst_mode==0) begin : DW_O01O01O0
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        OIOO1Ol1     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        OIOO1Ol1     <= O001lIO1;
      end else begin
        OIOO1Ol1     <= 1'bx;
      end
    end
  end else begin : DW_lO000l11
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        OIOO1Ol1     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        OIOO1Ol1     <= O001lIO1;
      end else begin
        OIOO1Ol1     <= 1'bx;
      end
    end
  end
endgenerate

  assign z      = l1I011OI[sig_width+exp_width+8 : 8];
  assign status = l1I011OI[7:0] ^ 8'b00000001;


  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (sig_width < 3) || (sig_width > 253) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 3 to 253)",
	sig_width );
    end
  
    if ( (exp_width < 3) || (exp_width > 31) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_width (legal range: 3 to 31)",
	exp_width );
    end
  
    if ( (ieee_compliance < 0) || (ieee_compliance > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ieee_compliance (legal range: 0 to 1)",
	ieee_compliance );
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
  
    if ( (no_pm < 0) || (no_pm > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter no_pm (legal range: 0 to 1)",
	no_pm );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1)",
	rst_mode );
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
