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
// DesignWare_version: ebd077bb
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//
// ABSTRACT: Low power pipelined Floating point Divider Synthetic Model 
//
//           This receives two operands that get divicated(is this a word?).  Configurable
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
//   faithful_round     0 to 1      select the faithful_rounding that admits 1 ulp error
//                                  0- default value. it keeps all rounding modes
//                                  1- z has 1 ulp error. RND input does not affect
//                                  the output
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
//  lOOOIOlO  8 bits          Output     
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
module DW_lp_piped_fp_div(clk,rst_n,a,b,z,rnd,status,launch,launch_id,
                       pipe_full,pipe_ovf,accept_n,arrive,arrive_id,push_out_n,pipe_census);

parameter sig_width           = 23;
parameter exp_width           = 8;
parameter ieee_compliance     = 0;
parameter faithful_round      = 0;
parameter op_iso_mode         = 0;
parameter id_width            = 8;
parameter in_reg              = 0;
parameter stages              = 4;
parameter out_reg             = 0;
parameter no_pm               = 1;
parameter rst_mode            = 0;



input                         clk;    // Clock Input
input                         rst_n;  // Async. Reset
input  [(sig_width+exp_width):0]          a;      // Dividend In
input  [(sig_width+exp_width):0]          b;      // Divisor In
input  [2:0]                  rnd;    // rounding mode
output [(sig_width+exp_width):0]          z;      // Pipelined z of a / b
output [7:0]                  status; // Pipelined b == 0 flag

input                         launch;      // Input to launch data into pipe
input  [id_width-1:0]         launch_id;   // ID tag of data launched
output                        pipe_full;   // Pipe Slots Full Output (used for flow control)
output                        pipe_ovf;    // Pipe Overflow Signal

input                         accept_n;    // Hold Data Out Input (flow control)
output                        arrive;      // Data Arrival Output
output [id_width-1:0]         arrive_id;   // ID tag of arrival data
output                        push_out_n;  // Active Low Output used when FIFO follows

output [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]      pipe_census; // Pipe Stages Occupied Output

// synopsys translate_off
wire  [(sig_width+exp_width):0]           lOOO001I;
wire  [(sig_width+exp_width):0]           O1I10OOO;
wire  [2:0]                   l1l1I1O0;
wire                          I1lI010O;
wire  [id_width-1:0]          I1110110;
wire                          OlOO0lO0;

reg   [(sig_width+exp_width):0]           I0I011IO;
reg   [(sig_width+exp_width):0]           l111O0OI;
reg   [2:0]                   l1I10O00;
wire  [(sig_width+exp_width):0]           O1O110OO;
wire  [(sig_width+exp_width):0]           l10lO001;
wire  [2:0]                   O0O0OIlI;

wire  [((2*(sig_width+exp_width + 1))+2):0]          ll1IIIO1;

wire  [(sig_width+exp_width):0]           OI1011Ol;
wire  [(sig_width+exp_width + 8):0]         O0III0l0;
wire  [(sig_width+exp_width + 8):0]         OlI011ll;
reg   [(sig_width+exp_width + 8):0]         OI1O1Il0;

wire  [7:0]                   lOOOIOlO;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]  O11IO1lI;
reg   [((stages-1+out_reg<1) ? 1 : stages-1+out_reg)-1:0] OlIO1IO0;

wire                          l0111O1I;
wire                          O0001l0I;
wire                          l1OOIl1l;
wire  [id_width-1:0]          O1OO100l;
wire                          l10l1O1I;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]  IlO0I10l;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]       O1ll10O0;

wire                          l01llO01;
wire                          llOlI1O1;
reg                           OO01001O;
wire                          IOl11OlO;
wire  [id_width-1:0]          O1I1O011;
wire  [id_width-1:0]          IOO1OII1;
wire                          OIO100OO;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]  OlO0lOOO;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]       O0IlO0l1;

assign ll1IIIO1    = {a,b, rnd};

assign {lOOO001I, O1I10OOO, l1l1I1O0} = (ll1IIIO1 | (ll1IIIO1 ^ ll1IIIO1));
assign I1lI010O              = (launch | (launch ^ launch));
assign I1110110           = (launch_id | (launch_id ^ launch_id));
assign OlOO0lO0            = (accept_n | (accept_n ^ accept_n));

generate if (rst_mode==0) begin : DW_Il0O00OO

  always @ (posedge clk or negedge rst_n) begin : input_registers_PROC
    if (rst_n === 1'b0) begin
      I0I011IO   <= {(sig_width+exp_width)+1{1'b0}};
      l111O0OI   <= {(sig_width+exp_width)+1{1'b0}};
      l1I10O00 <= {3{1'b0}};
    end else if (rst_n === 1'b1) begin
      if (O11IO1lI[0] === 1'b1) begin
        I0I011IO   <= lOOO001I;
        l111O0OI   <= O1I10OOO;
        l1I10O00 <= l1l1I1O0;
      end else if (O11IO1lI[0] !== 1'b0) begin
        I0I011IO   <= ((I0I011IO ^ lOOO001I) & {(sig_width+exp_width)+1{1'bx}}) ^ I0I011IO;
        l111O0OI   <= ((l111O0OI ^ O1I10OOO) & {(sig_width+exp_width)+1{1'bx}}) ^ l111O0OI;
        l1I10O00 <= ((l1I10O00 ^ l1l1I1O0) & {(sig_width+exp_width)+1{1'bx}}) ^ l1I10O00;
      end
    end else begin
      I0I011IO   <= {(sig_width+exp_width)+1{1'bx}};
      l111O0OI   <= {(sig_width+exp_width)+1{1'bx}};
      l1I10O00 <= {3{1'bx}};
    end
  end

end else begin : DW_lO0l011l

  always @ (posedge clk) begin : input_registers_PROC
    if (rst_n === 1'b0) begin
      I0I011IO   <= {(sig_width+exp_width)+1{1'b0}};
      l111O0OI   <= {(sig_width+exp_width)+1{1'b0}};
      l1I10O00 <= {3{1'b0}};
    end else if (rst_n === 1'b1) begin
      if (O11IO1lI[0] === 1'b1) begin
        I0I011IO   <= lOOO001I;
        l111O0OI   <= O1I10OOO;
        l1I10O00 <= l1l1I1O0;
      end else if (O11IO1lI[0] !== 1'b0) begin
        I0I011IO   <= ((I0I011IO ^ lOOO001I) & {(sig_width+exp_width)+1{1'bx}}) ^ I0I011IO;
        l111O0OI   <= ((l111O0OI ^ O1I10OOO) & {(sig_width+exp_width)+1{1'bx}}) ^ l111O0OI;
        l1I10O00 <= ((l1I10O00 ^ l1l1I1O0) & {(sig_width+exp_width)+1{1'bx}}) ^ l1I10O00;
      end
    end else begin
      I0I011IO   <= {(sig_width+exp_width)+1{1'bx}};
      l111O0OI   <= {(sig_width+exp_width)+1{1'bx}};
      l1I10O00 <= {3{1'bx}};
    end
  end

end endgenerate

assign O1O110OO   = (in_reg==0) ?   lOOO001I :   I0I011IO;
assign l10lO001   = (in_reg==0) ?   O1I10OOO :   l111O0OI;
assign O0O0OIlI = (in_reg==0) ? l1l1I1O0 : l1I10O00;

reg   [id_width-1 : 0]     I0I11OIO [0 : ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_arrive_id
      integer OlI1lI1O;

      if (rst_n === 1'b0) begin
        for (OlI1lI1O=0 ; OlI1lI1O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; OlI1lI1O=OlI1lI1O+1) begin
          I0I11OIO[OlI1lI1O] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (OlI1lI1O=0 ; OlI1lI1O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; OlI1lI1O=OlI1lI1O+1) begin
          if (O11IO1lI[OlI1lI1O] === 1'b1)
            I0I11OIO[OlI1lI1O] <= (OlI1lI1O == 0)? I1110110 : I0I11OIO[OlI1lI1O-1];
          else if (O11IO1lI[OlI1lI1O] !== 1'b0)
            I0I11OIO[OlI1lI1O] <= ((I0I11OIO[OlI1lI1O] ^ ((OlI1lI1O == 0)? I1110110 : I0I11OIO[OlI1lI1O-1]))
          		      & {id_width{1'bx}}) ^ I0I11OIO[OlI1lI1O];
        end
      end else begin
        for (OlI1lI1O=0 ; OlI1lI1O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; OlI1lI1O=OlI1lI1O+1) begin
          I0I11OIO[OlI1lI1O] <= {id_width{1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_arrive_id
      integer OlI1lI1O;

      if (rst_n === 1'b0) begin
        for (OlI1lI1O=0 ; OlI1lI1O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; OlI1lI1O=OlI1lI1O+1) begin
          I0I11OIO[OlI1lI1O] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (OlI1lI1O=0 ; OlI1lI1O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; OlI1lI1O=OlI1lI1O+1) begin
          if (O11IO1lI[OlI1lI1O] === 1'b1)
            I0I11OIO[OlI1lI1O] <= (OlI1lI1O == 0)? I1110110 : I0I11OIO[OlI1lI1O-1];
          else if (O11IO1lI[OlI1lI1O] !== 1'b0)
            I0I11OIO[OlI1lI1O] <= ((I0I11OIO[OlI1lI1O] ^ ((OlI1lI1O == 0)? I1110110 : I0I11OIO[OlI1lI1O-1]))
          		      & {id_width{1'bx}}) ^ I0I11OIO[OlI1lI1O];
        end
      end else begin
        for (OlI1lI1O=0 ; OlI1lI1O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; OlI1lI1O=OlI1lI1O+1) begin
          I0I11OIO[OlI1lI1O] <= {id_width{1'bx}};
        end
      end
    end
  end
endgenerate

  assign IOO1OII1 = (in_reg+stages+out_reg == 1)? I1110110 : I0I11OIO[((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];


DW_fp_div #(sig_width, exp_width, 
	    ieee_compliance, faithful_round) 
  U_fp_div (
	    .a(O1O110OO),
	    .b(l10lO001),
	    .rnd(O0O0OIlI),
	    .z(OI1011Ol),
	    .status(lOOOIOlO) );

assign O0III0l0 = {OI1011Ol,(lOOOIOlO ^ 8'b00000001)};
  


reg   [(sig_width+exp_width + 8) : 0]     OOIOIIOO [0 : stages-1];




  reg   [(sig_width+exp_width + 8) +1 -1 : 0]     pl_pipe_in_data;
  reg   [(sig_width+exp_width + 8) +1 -1 : 0]     pl_input_reg;
  reg   [(sig_width+exp_width + 8) +1 -1 : 0]     pl_output_reg;

  assign pl_pipe_in_data = (1-1 == 0) ? O0III0l0 : pl_input_reg;
  assign OOIOIIOO[0] = pl_pipe_in_data;

generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers
      integer OlI1lI1O;

      if (rst_n === 1'b0) begin
        pl_input_reg <= {(sig_width+exp_width + 8) +1 {1'b0}};
        for (OlI1lI1O=1; OlI1lI1O<=stages-1; OlI1lI1O=OlI1lI1O+1) begin
          OOIOIIOO[OlI1lI1O] <= {(sig_width+exp_width + 8) +1 {1'b0}};
        end
        pl_output_reg <= {(sig_width+exp_width + 8) +1 {1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OlIO1IO0[0] === 1'b1)
          pl_input_reg <= O0III0l0;
        else if (OlIO1IO0[0] !== 1'b0)
          pl_input_reg <= (pl_input_reg ^ O0III0l0 & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ pl_input_reg;
        for (OlI1lI1O=1; OlI1lI1O<=stages-1; OlI1lI1O=OlI1lI1O+1) begin
          if (OlIO1IO0[OlI1lI1O-1+1-1] === 1'b1)
            OOIOIIOO[OlI1lI1O] <= OOIOIIOO[OlI1lI1O-1];
          else if (OlIO1IO0[OlI1lI1O-1+1-1] !== 1'b0)
            OOIOIIOO[OlI1lI1O] <= (OOIOIIOO[OlI1lI1O] ^ OOIOIIOO[OlI1lI1O-1] & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ OOIOIIOO[OlI1lI1O];
        end
        if (OlIO1IO0[((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))-in_reg] === 1'b1)
          pl_output_reg <= OOIOIIOO[stages-1];
        else if (OlIO1IO0[((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))-in_reg] !== 1'b0)
          pl_output_reg <= (pl_output_reg ^ OOIOIIOO[stages-1] & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ pl_output_reg;
      end else begin
        pl_input_reg <= {(sig_width+exp_width + 8) +1 {1'bx}};
        for (OlI1lI1O=1; OlI1lI1O<=stages-1; OlI1lI1O=OlI1lI1O+1) begin
          OOIOIIOO[OlI1lI1O] <= {(sig_width+exp_width + 8) +1 {1'bx}};
        end
        pl_output_reg <= {(sig_width+exp_width + 8) +1 {1'bx}};
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers
      integer OlI1lI1O;

      if (rst_n === 1'b0) begin
        pl_input_reg <= {(sig_width+exp_width + 8) +1 {1'b0}};
        for (OlI1lI1O=1; OlI1lI1O<=stages-1; OlI1lI1O=OlI1lI1O+1) begin
          OOIOIIOO[OlI1lI1O] <= {(sig_width+exp_width + 8) +1 {1'b0}};
        end
        pl_output_reg <= {(sig_width+exp_width + 8) +1 {1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OlIO1IO0[0] === 1'b1)
          pl_input_reg <= O0III0l0;
        else if (OlIO1IO0[0] !== 1'b0)
          pl_input_reg <= (pl_input_reg ^ O0III0l0 & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ pl_input_reg;
        for (OlI1lI1O=1; OlI1lI1O<=stages-1; OlI1lI1O=OlI1lI1O+1) begin
          if (OlIO1IO0[OlI1lI1O-1+1-1] === 1'b1)
            OOIOIIOO[OlI1lI1O] <= OOIOIIOO[OlI1lI1O-1];
          else if (OlIO1IO0[OlI1lI1O-1+1-1] !== 1'b0)
            OOIOIIOO[OlI1lI1O] <= (OOIOIIOO[OlI1lI1O] ^ OOIOIIOO[OlI1lI1O-1] & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ OOIOIIOO[OlI1lI1O];
        end
        if (OlIO1IO0[((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))-in_reg] === 1'b1)
          pl_output_reg <= OOIOIIOO[stages-1];
        else if (OlIO1IO0[((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))-in_reg] !== 1'b0)
          pl_output_reg <= (pl_output_reg ^ OOIOIIOO[stages-1] & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ pl_output_reg;
      end else begin
        pl_input_reg <= {(sig_width+exp_width + 8) +1 {1'bx}};
        for (OlI1lI1O=1; OlI1lI1O<=stages-1; OlI1lI1O=OlI1lI1O+1) begin
          OOIOIIOO[OlI1lI1O] <= {(sig_width+exp_width + 8) +1 {1'bx}};
        end
        pl_output_reg <= {(sig_width+exp_width + 8) +1 {1'bx}};
      end
    end
  end
endgenerate

  assign OlI011ll = (in_reg+stages+out_reg == 1) ? O0III0l0 :
                                     (out_reg == 1) ? pl_output_reg :
                                                       OOIOIIOO[stages-1];




generate
  if (rst_mode==0) begin : DW_l1ll1l0O
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) 
      U_PIPE_MGR (
              .clk(clk),
              .rst_n(rst_n),
              .init_n(1'b1),
              .launch(I1lI010O),
              .launch_id(I1110110),
              .accept_n(OlOO0lO0),
              .arrive(l1OOIl1l),
              .arrive_id(O1OO100l),
              .pipe_en_bus(IlO0I10l),
              .pipe_full(l0111O1I),
              .pipe_ovf(O0001l0I),
              .push_out_n(l10l1O1I),
              .pipe_census(O1ll10O0)
              );
  end else begin : DW_ll11IOO1
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) 
      U_PIPE_MGR (
              .clk(clk),
              .rst_n(1'b1),
              .init_n(rst_n),
              .launch(I1lI010O),
              .launch_id(I1110110),
              .accept_n(OlOO0lO0),
              .arrive(l1OOIl1l),
              .arrive_id(O1OO100l),
              .pipe_en_bus(IlO0I10l),
              .pipe_full(l0111O1I),
              .pipe_ovf(O0001l0I),
              .push_out_n(l10l1O1I),
              .pipe_census(O1ll10O0)
              );
  end
endgenerate

assign IOl11OlO         = I1lI010O;
assign O1I1O011      = I1110110;
assign OlO0lOOO    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b1}};
assign l01llO01      = OlOO0lO0;
assign llOlI1O1  = l01llO01 && IOl11OlO;
assign OIO100OO     = ~(~OlOO0lO0 && I1lI010O);
assign O0IlO0l1    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};

assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? (no_pm ? IOO1OII1: O1OO100l) : O1I1O011;
assign O11IO1lI  = ((in_reg+stages+out_reg) > 1) ? (no_pm ? {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){launch}} : IlO0I10l) : OlO0lOOO;
assign pipe_full        =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? l0111O1I     : l01llO01;
assign pipe_ovf         =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? O0001l0I      : OO01001O;

assign arrive           =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? l1OOIl1l        : IOl11OlO;
assign push_out_n       =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? l10l1O1I    : OIO100OO;
assign pipe_census      =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? O1ll10O0   : O0IlO0l1;

always @(O11IO1lI) begin : DW_Ol1lIOl1
  reg [31:0] OlI1lI1O;
  if (in_reg == 1)
    for (OlI1lI1O=1; OlI1lI1O< (((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1); OlI1lI1O=OlI1lI1O+1) begin
      OlIO1IO0[OlI1lI1O-1] = O11IO1lI[OlI1lI1O];
    end
  else
    OlIO1IO0 = O11IO1lI;
end  // DW_Ol1lIOl1

generate
  if (rst_mode==0) begin : DW_OlO1O0OO
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        OO01001O     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        OO01001O     <= llOlI1O1;
      end else begin
        OO01001O     <= 1'bx;
      end
    end
  end else begin : DW_II1l0000
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        OO01001O     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        OO01001O     <= llOlI1O1;
      end else begin
        OO01001O     <= 1'bx;
      end
    end
  end
endgenerate

  assign z      = OlI011ll[sig_width+exp_width+8 : 8];
  assign status = OlI011ll[7:0] ^ 8'b00000001;


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
  
    if ( (faithful_round < 0) || (faithful_round > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter faithful_round (legal range: 0 to 1)",
	faithful_round );
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
