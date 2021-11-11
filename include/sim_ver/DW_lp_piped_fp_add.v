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
// DesignWare_version: 0099fd1d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//
// ABSTRACT: Low power pipelined Floating point Divider Synthetic Model 
//
//           This receives two operands that get addicated(is this a word?).  Configurable
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
//  status      8 bits          Output     
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
module DW_lp_piped_fp_add(clk,rst_n,a,b,z,rnd,status,launch,launch_id,
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
wire  [(sig_width+exp_width):0]    OllO1lI0;
wire  [(sig_width+exp_width):0]    l1l1IIl1;
wire  [2:0]            I0O00OOO;
wire                   IO1101IO;
wire  [id_width-1:0]   I0O0IO0l;
wire                   lI11OIO0;

wire  [((2*(sig_width+exp_width + 1))+2):0]   l1O10l0O;

wire  [(sig_width+exp_width):0]    llIIO001;
wire  [(sig_width+exp_width + 9):0]  OOI1Ol11;
wire  [(sig_width+exp_width + 9):0]  lOOI0O00;

wire  [7:0]            O0lOOO01;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] I1l011IO;

wire                         I00O0O11;
wire                         OlO1010O;
wire                         l0100IlO;
wire  [id_width-1:0]         O00OlI1l;
wire                         O00lO1IO;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] OI1O110I;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]      llI000IO;

wire                         Oll0lI10;
wire                         lO1O110l;
reg                          O11II0l1;
wire                         O001O0lO;
wire  [id_width-1:0]         I00lIlI0;
wire  [id_width-1:0]         OOO0l00O;
wire                         O0OOOlO0;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] O10l0011;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]      l00OlllO;

assign l1O10l0O    = {a,b, rnd};

assign {OllO1lI0, l1l1IIl1, I0O00OOO} = (l1O10l0O | (l1O10l0O ^ l1O10l0O));
assign IO1101IO              = (launch | (launch ^ launch));
assign I0O0IO0l           = (launch_id | (launch_id ^ launch_id));
assign lI11OIO0            = (accept_n | (accept_n ^ accept_n));

reg   [id_width-1 : 0]     Il10O0O1 [0 : ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_arrive_id
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          Il10O0O1[i] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          if (I1l011IO[i] === 1'b1)
            Il10O0O1[i] <= (i == 0)? I0O0IO0l : Il10O0O1[i-1];
          else if (I1l011IO[i] !== 1'b0)
            Il10O0O1[i] <= ((Il10O0O1[i] ^ ((i == 0)? I0O0IO0l : Il10O0O1[i-1]))
          		      & {id_width{1'bx}}) ^ Il10O0O1[i];
        end
      end else begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          Il10O0O1[i] <= {id_width{1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_arrive_id
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          Il10O0O1[i] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          if (I1l011IO[i] === 1'b1)
            Il10O0O1[i] <= (i == 0)? I0O0IO0l : Il10O0O1[i-1];
          else if (I1l011IO[i] !== 1'b0)
            Il10O0O1[i] <= ((Il10O0O1[i] ^ ((i == 0)? I0O0IO0l : Il10O0O1[i-1]))
          		      & {id_width{1'bx}}) ^ Il10O0O1[i];
        end
      end else begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          Il10O0O1[i] <= {id_width{1'bx}};
        end
      end
    end
  end
endgenerate

  assign OOO0l00O = (in_reg+stages+out_reg == 1)? I0O0IO0l : Il10O0O1[((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];



DW_fp_add #(sig_width, exp_width, 
	    ieee_compliance) 
  U_fp_add (
	    .a(OllO1lI0),
	    .b(l1l1IIl1),
	    .rnd(I0O00OOO),
	    .z(llIIO001),
	    .status(O0lOOO01) );

assign OOI1Ol11 = {llIIO001,(O0lOOO01 ^ 8'b00000001)};
  

reg   [(sig_width+exp_width + 9) : 0]     lOOIO01l [0 : ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          lOOIO01l[i] <= {(sig_width+exp_width + 9) +1 {1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (I1l011IO[i] === 1'b1)
            lOOIO01l[i] <= (i == 0)? OOI1Ol11 : lOOIO01l[i-1];
          else if (I1l011IO[i] !== 1'b0)
            lOOIO01l[i] <= ((lOOIO01l[i] ^ ((i == 0)? OOI1Ol11 : lOOIO01l[i-1]))
          		      & {(sig_width+exp_width + 9) +1 {1'bx}}) ^ lOOIO01l[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          lOOIO01l[i] <= {(sig_width+exp_width + 9) +1 {1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          lOOIO01l[i] <= {(sig_width+exp_width + 9) +1 {1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (I1l011IO[i] === 1'b1)
            lOOIO01l[i] <= (i == 0)? OOI1Ol11 : lOOIO01l[i-1];
          else if (I1l011IO[i] !== 1'b0)
            lOOIO01l[i] <= ((lOOIO01l[i] ^ ((i == 0)? OOI1Ol11 : lOOIO01l[i-1]))
          		      & {(sig_width+exp_width + 9) +1 {1'bx}}) ^ lOOIO01l[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          lOOIO01l[i] <= {(sig_width+exp_width + 9) +1 {1'bx}};
        end
      end
    end
  end
endgenerate

  assign lOOI0O00 = (in_reg+stages+out_reg == 1)? OOI1Ol11 : lOOIO01l[((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin : DW_IO0l1110
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) 
      U_PIPE_MGR (
              .clk(clk),
              .rst_n(rst_n),
              .init_n(1'b1),
              .launch(IO1101IO),
              .launch_id(I0O0IO0l),
              .accept_n(lI11OIO0),
              .arrive(l0100IlO),
              .arrive_id(O00OlI1l),
              .pipe_en_bus(OI1O110I),
              .pipe_full(I00O0O11),
              .pipe_ovf(OlO1010O),
              .push_out_n(O00lO1IO),
              .pipe_census(llI000IO)
              );
  end else begin : DW_O100OI11
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) 
      U_PIPE_MGR (
              .clk(clk),
              .rst_n(1'b1),
              .init_n(rst_n),
              .launch(IO1101IO),
              .launch_id(I0O0IO0l),
              .accept_n(lI11OIO0),
              .arrive(l0100IlO),
              .arrive_id(O00OlI1l),
              .pipe_en_bus(OI1O110I),
              .pipe_full(I00O0O11),
              .pipe_ovf(OlO1010O),
              .push_out_n(O00lO1IO),
              .pipe_census(llI000IO)
              );
  end
endgenerate

assign O001O0lO         = IO1101IO;
assign I00lIlI0      = I0O0IO0l;
assign O10l0011    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b1}};
assign Oll0lI10      = lI11OIO0;
assign lO1O110l  = Oll0lI10 && O001O0lO;
assign O0OOOlO0     = ~(~lI11OIO0 && IO1101IO);
assign l00OlllO    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};

assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? (no_pm ? OOO0l00O: O00OlI1l) : I00lIlI0;
assign I1l011IO  = ((in_reg+stages+out_reg) > 1) ? (no_pm ? {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){launch}} : OI1O110I) : O10l0011;
assign pipe_full        =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? I00O0O11     : Oll0lI10;
assign pipe_ovf         =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OlO1010O      : O11II0l1;

assign arrive           =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? l0100IlO        : O001O0lO;
assign push_out_n       =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? O00lO1IO    : O0OOOlO0;
assign pipe_census      =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? llI000IO   : l00OlllO;

generate
  if (rst_mode==0) begin : DW_OlllO01O
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        O11II0l1     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        O11II0l1     <= lO1O110l;
      end else begin
        O11II0l1     <= 1'bx;
      end
    end
  end else begin : DW_O1OO1ll1
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        O11II0l1     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        O11II0l1     <= lO1O110l;
      end else begin
        O11II0l1     <= 1'bx;
      end
    end
  end
endgenerate

  assign z      = (arrive | (no_pm == 1))?lOOI0O00[sig_width+exp_width+8 : 8]:{sig_width+exp_width+1{1'bx}};
  assign status = (arrive | (no_pm == 1))?lOOI0O00[7:0] ^ 8'b00000001:{8'bx};

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
