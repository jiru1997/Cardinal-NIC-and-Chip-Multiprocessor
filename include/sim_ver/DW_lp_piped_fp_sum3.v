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
// DesignWare_version: 58c0ce20
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//
// ABSTRACT: Low power pipelined Floating point Divider Synthetic Model 
//
//           This receives two operands that get sum3icated(is this a word?).  Configurable
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
//   arch_type     0 to 1      select the arch_typeing that admits 1 ulp error
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
//  a           M bits	        Input	     
//  b           M bits	        Input	     
//  c           M bits	        Input	     
//  z           M bits	        Output       z = a+b+c
//  O011O1I0  8 bits          Output     
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
module DW_lp_piped_fp_sum3(clk,rst_n,a,b,c,z,rnd,status,launch,launch_id,
                       pipe_full,pipe_ovf,accept_n,arrive,arrive_id,push_out_n,pipe_census);

parameter sig_width       = 23;
parameter exp_width       = 8;
parameter ieee_compliance = 0;
parameter arch_type       = 0;
parameter op_iso_mode     = 0;
parameter id_width        = 8;
parameter in_reg          = 0;
parameter stages          = 4;
parameter out_reg         = 0;
parameter no_pm           = 1;
parameter rst_mode        = 0;



input                    clk;    // Clock Input
input                    rst_n;  // Async. Reset
input  [(sig_width+exp_width):0]     a;      // 
input  [(sig_width+exp_width):0]     b;      // 
input  [(sig_width+exp_width):0]     c;      // 
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
wire  [(sig_width+exp_width):0]          O0O0l10O;
wire  [(sig_width+exp_width):0]          l0l001OO;
wire  [(sig_width+exp_width):0]          O11OOI0O;
wire  [2:0]                  O1l1OO0I;
wire                         O0OO00O0;
wire  [id_width-1:0]         O0100OOO;
wire                         OOO0O0O0;

wire  [((3*(sig_width+exp_width + 1))+2):0]         Ol00I1O0;

wire  [(sig_width+exp_width):0]          II1001O0;
wire  [(sig_width+exp_width + 8):0]        O11I1IOl;
wire  [(sig_width+exp_width + 8):0]        O0IOIOOO;

wire  [7:0]                  O011O1I0;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] Ol11IOIO;

wire                         OI1Oll0O;
wire                         Ol0O1O1I;
wire                         OIO11O11;
wire  [id_width-1:0]         O1lIIO01;
wire                         l0O0OO10;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] lO1OO1I0;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]      IO011000;

wire                         O1lI1OOO;
wire                         lIII101O;
reg                          IO001IOO;
wire                         OOO1II00;
wire  [id_width-1:0]         OOO011IO;
wire  [id_width-1:0]         IO010I10;
wire                         l010O0O0;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0] IO01lOOI;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]      I1110l1I;

assign Ol00I1O0    = {a,b,c, rnd};

assign {O0O0l10O, l0l001OO, O11OOI0O, O1l1OO0I} = (Ol00I1O0 | (Ol00I1O0 ^ Ol00I1O0));
assign O0OO00O0                     = (launch | (launch ^ launch));
assign O0100OOO                  = (launch_id | (launch_id ^ launch_id));
assign OOO0O0O0                   = (accept_n | (accept_n ^ accept_n));

reg   [id_width-1 : 0]     O1I1lO0O [0 : ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_arrive_id
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          O1I1lO0O[i] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          if (Ol11IOIO[i] === 1'b1)
            O1I1lO0O[i] <= (i == 0)? O0100OOO : O1I1lO0O[i-1];
          else if (Ol11IOIO[i] !== 1'b0)
            O1I1lO0O[i] <= ((O1I1lO0O[i] ^ ((i == 0)? O0100OOO : O1I1lO0O[i-1]))
          		      & {id_width{1'bx}}) ^ O1I1lO0O[i];
        end
      end else begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          O1I1lO0O[i] <= {id_width{1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_arrive_id
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          O1I1lO0O[i] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          if (Ol11IOIO[i] === 1'b1)
            O1I1lO0O[i] <= (i == 0)? O0100OOO : O1I1lO0O[i-1];
          else if (Ol11IOIO[i] !== 1'b0)
            O1I1lO0O[i] <= ((O1I1lO0O[i] ^ ((i == 0)? O0100OOO : O1I1lO0O[i-1]))
          		      & {id_width{1'bx}}) ^ O1I1lO0O[i];
        end
      end else begin
        for (i=0 ; i <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; i=i+1) begin
          O1I1lO0O[i] <= {id_width{1'bx}};
        end
      end
    end
  end
endgenerate

  assign IO010I10 = (in_reg+stages+out_reg == 1)? O0100OOO : O1I1lO0O[((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];


DW_fp_sum3 #(sig_width, exp_width, 
	    ieee_compliance, arch_type) 
  U_fp_sum3 (
	    .a(O0O0l10O),
	    .b(l0l001OO),
	    .c(O11OOI0O),
	    .rnd(O1l1OO0I),
	    .z(II1001O0),
	    .status(O011O1I0) );

assign O11I1IOl = {II1001O0,(O011O1I0 ^ 8'b00000001)};
  

reg   [(sig_width+exp_width + 8) : 0]     lI00l0O0 [0 : ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          lI00l0O0[i] <= {(sig_width+exp_width + 8) +1 {1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (Ol11IOIO[i] === 1'b1)
            lI00l0O0[i] <= (i == 0)? O11I1IOl : lI00l0O0[i-1];
          else if (Ol11IOIO[i] !== 1'b0)
            lI00l0O0[i] <= ((lI00l0O0[i] ^ ((i == 0)? O11I1IOl : lI00l0O0[i-1]))
          		      & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ lI00l0O0[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          lI00l0O0[i] <= {(sig_width+exp_width + 8) +1 {1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers
      integer i;

      if (rst_n === 1'b0) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          lI00l0O0[i] <= {(sig_width+exp_width + 8) +1 {1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          if (Ol11IOIO[i] === 1'b1)
            lI00l0O0[i] <= (i == 0)? O11I1IOl : lI00l0O0[i-1];
          else if (Ol11IOIO[i] !== 1'b0)
            lI00l0O0[i] <= ((lI00l0O0[i] ^ ((i == 0)? O11I1IOl : lI00l0O0[i-1]))
          		      & {(sig_width+exp_width + 8) +1 {1'bx}}) ^ lI00l0O0[i];
        end
      end else begin
        for (i=0 ; i <= ((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2)) ; i=i+1) begin
          lI00l0O0[i] <= {(sig_width+exp_width + 8) +1 {1'bx}};
        end
      end
    end
  end
endgenerate

  assign O0IOIOOO = (in_reg+stages+out_reg == 1)? O11I1IOl : lI00l0O0[((stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2))];



generate
  if (rst_mode==0) begin : DW_IOO000I1
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) 
      U_PIPE_MGR (
              .clk(clk),
              .rst_n(rst_n),
              .init_n(1'b1),
              .launch(O0OO00O0),
              .launch_id(O0100OOO),
              .accept_n(OOO0O0O0),
              .arrive(OIO11O11),
              .arrive_id(O1lIIO01),
              .pipe_en_bus(lO1OO1I0),
              .pipe_full(OI1Oll0O),
              .pipe_ovf(Ol0O1O1I),
              .push_out_n(l0O0OO10),
              .pipe_census(IO011000)
              );
  end else begin : DW_O1O0O10l
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) 
      U_PIPE_MGR (
              .clk(clk),
              .rst_n(1'b1),
              .init_n(rst_n),
              .launch(O0OO00O0),
              .launch_id(O0100OOO),
              .accept_n(OOO0O0O0),
              .arrive(OIO11O11),
              .arrive_id(O1lIIO01),
              .pipe_en_bus(lO1OO1I0),
              .pipe_full(OI1Oll0O),
              .pipe_ovf(Ol0O1O1I),
              .push_out_n(l0O0OO10),
              .pipe_census(IO011000)
              );
  end
endgenerate

assign OOO1II00         = O0OO00O0;
assign OOO011IO      = O0100OOO;
assign IO01lOOI    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b1}};
assign O1lI1OOO      = OOO0O0O0;
assign lIII101O  = O1lI1OOO && OOO1II00;
assign l010O0O0     = ~(~OOO0O0O0 && O0OO00O0);
assign I1110l1I    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};

assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? (no_pm ? IO010I10: O1lIIO01) : OOO011IO;
assign Ol11IOIO  = ((in_reg+stages+out_reg) > 1) ? (no_pm ? {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){launch}} : lO1OO1I0) : IO01lOOI;
assign pipe_full        =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OI1Oll0O     : O1lI1OOO;
assign pipe_ovf         =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? Ol0O1O1I      : IO001IOO;

assign arrive           =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OIO11O11        : OOO1II00;
assign push_out_n       =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? l0O0OO10    : l010O0O0;
assign pipe_census      =   no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? IO011000   : I1110l1I;

generate
  if (rst_mode==0) begin : DW_lOOO01lI
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        IO001IOO     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        IO001IOO     <= lIII101O;
      end else begin
        IO001IOO     <= 1'bx;
      end
    end
  end else begin : DW_IOI01IO0
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        IO001IOO     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        IO001IOO     <= lIII101O;
      end else begin
        IO001IOO     <= 1'bx;
      end
    end
  end
endgenerate

  assign z      = O0IOIOOO[sig_width+exp_width+8 : 8];
  assign status = O0IOIOOO[7:0] ^ 8'b00000001;


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
  
    if ( (arch_type < 0) || (arch_type > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch_type (legal range: 0 to 1)",
	arch_type );
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
