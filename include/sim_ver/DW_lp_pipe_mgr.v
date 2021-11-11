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
// AUTHOR:    Doug Lee  Feb. 21, 2006
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 9fa6a673
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
//  ABSTRACT: Pipeline Manager Simulation Model
//
//       This component tracks the activity in the pipeline
//       throttled by 'launch' and 'accept_n' inputs.  Active
//       launched transactions are allowed to fill the pipeline
//       when the downstream logic is not accepting new arrivals. 
//
//  Parameters:     Valid Range    Default Value
//  ==========      ===========    =============
//  stages          1 to 1023          2
//  id_width        1 to 1024          2
//
//
//  Ports       Size    Direction    Description
//  =====       ====    =========    ===========
//  clk         1 bit     Input      Clock Input
//  rst_n       1 bit     Input      Async. Reset Input, Active Low
//  init_n      1 bit     Input      Sync. Reset Input, Active Low
//
//  launch      1 bit     Input      Active High Control input to lauche data into pipe
//  launch_id  id_width   Input      ID tag for data being launched (optional)
//  pipe_full   1 bit     Output     Status Flag indicating no slot for new data
//  pipe_ovf    1 bit     Output     Status Flag indicating pipe overflow
//
//  pipe_en_bus stages    Output     Bus of enables (one per pipe stage), Active High
//               bits
//
//  accept_n    1 bit     Input      Flow Control Input, Active Low
//  arrive      1 bit     Output     Data Available output 
//  arrive_id  id_width   Output     ID tag for data that'Ol11O1Ol arrived (optional)
//  push_out_n  1 bit     Output     Active Low Output used with FIFO (optional)
//  pipe_census M bits    Output     Output bus indicating the number
//                                   of pipe stages currently occupied
//
//    Note: The value of M is equal to the ceil(log2(stages+1)).
//
//
// Modified:
//    DLL   9-13-07  Changed name from DW_pipe_mgr
//
module DW_lp_pipe_mgr(
	clk,		// Clock Input
	rst_n,		// Async. Reset
	init_n,		// Sync Reset

	launch,		// Input to launch data into pipe
	launch_id,	// ID tag of data launched
	pipe_full,	// Pipe Slots Full Output (used for flow control)
	pipe_ovf,	// Pipe Overflow Signal
	pipe_en_bus,	// Pipe Stage Enable Bus (active high enables, 1 bit per pipe stage)

	accept_n,	// Hold Data Out Input (flow control)
	arrive,		// Data Arrival Output
	arrive_id,	// ID tag of arrival data
	push_out_n,	// Active Low Output used when FIFO follows
	pipe_census	// Pipe Stages Occupied Output
	);

parameter stages = 2;	// POSITIVE
parameter id_width = 2;	// POSITIVE

`define DW_O1O1O0O0 (stages + 1)
`define DW_O0OIO101 ((`DW_O1O1O0O0>256)?((`DW_O1O1O0O0>4096)?((`DW_O1O1O0O0>16384)?((`DW_O1O1O0O0>32768)?16:15):((`DW_O1O1O0O0>8192)?14:13)):((`DW_O1O1O0O0>1024)?((`DW_O1O1O0O0>2048)?12:11):((`DW_O1O1O0O0>512)?10:9))):((`DW_O1O1O0O0>16)?((`DW_O1O1O0O0>64)?((`DW_O1O1O0O0>128)?8:7):((`DW_O1O1O0O0>32)?6:5)):((`DW_O1O1O0O0>4)?((`DW_O1O1O0O0>8)?4:3):((`DW_O1O1O0O0>2)?2:1))))

input 			      clk;
input 			      rst_n;
input 			      init_n;

input 			      launch;
input [id_width-1:0]	      launch_id;
output			      pipe_full;
output			      pipe_ovf;
output [stages-1 : 0]	      pipe_en_bus;

input 			      accept_n;
output			      arrive;
output [id_width-1:0]	      arrive_id;
output			      push_out_n;
output[(`DW_O0OIO101)-1:0]    pipe_census;

// synopsys translate_off

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (stages < 1) || (stages > 1023) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter stages (legal range: 1 to 1023)",
	stages );
    end
  
    if (id_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter id_width (lower bound: 1)",
	id_width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


wire 			      I0OOlIOO;
wire 			      I1OO1OO1;
wire 			      O0OII00O;
wire 			      IIllO1l0;
wire [id_width-1:0]	      I1l0001O;
wire 			      ll1I1II0;

reg			      l0IO0111;
reg   [(`DW_O0OIO101)-1:0]       O0l10O00;
wire                          OOIl0IO0;
reg  [stages-1:0]	      lO0O1llI;
reg  [stages-1:0]	      IOO1O1O1;
reg  [stages-1:0]	      OO1O1111;
reg  [stages-1:0]	      O1101011;
reg  [(id_width*stages)-1:0]  llOI1101;
reg  [(id_width*stages)-1:0]  O01I01I1;
integer			      I111IOO0,OOl0l1OO,OO01OO1l,Ol11O1Ol,O0IOl0IO;


assign I0OOlIOO        = (clk | (clk ^ clk));
assign I1OO1OO1      = (rst_n | (rst_n ^ rst_n));
assign O0OII00O     = (init_n | (init_n ^ init_n));
assign IIllO1l0     = (launch | (launch ^ launch));
assign I1l0001O  = (launch_id | (launch_id ^ launch_id));
assign ll1I1II0   = (accept_n | (accept_n ^ accept_n));


assign OOIl0IO0 = ~ll1I1II0;

always @(OO1O1111 or lO0O1llI or OOIl0IO0) begin : a1000_PROC
  for (I111IOO0=stages-1; I111IOO0>=0; I111IOO0=I111IOO0-1) begin
    if (I111IOO0 == stages-1)
      OO1O1111[I111IOO0] = OOIl0IO0 | ~lO0O1llI[I111IOO0];
    else
      OO1O1111[I111IOO0] = OO1O1111[I111IOO0+1] | ~lO0O1llI[I111IOO0];
  end
end

always @(OO1O1111 or lO0O1llI or IIllO1l0 or llOI1101 or I1l0001O) begin : a1001_PROC
  for (OOl0l1OO=0; OOl0l1OO<stages; OOl0l1OO=OOl0l1OO+1) begin
    if (OOl0l1OO == 0) begin
      if (OO1O1111[0] === 1'b1)
        IOO1O1O1[0] = IIllO1l0;
      else
        IOO1O1O1[0] = lO0O1llI[0];
      if ((OO1O1111[0] === 1'b1) && (IOO1O1O1[0] === 1'b1))
	O01I01I1[id_width-1:0] = I1l0001O;
      else
	O01I01I1[id_width-1:0] = llOI1101[id_width-1:0];
    end else begin
      if (OO1O1111[OOl0l1OO] === 1'b1)
        IOO1O1O1[OOl0l1OO] = lO0O1llI[OOl0l1OO-1];
      else
        IOO1O1O1[OOl0l1OO] = lO0O1llI[OOl0l1OO];
      if ((OO1O1111[OOl0l1OO] === 1'b1) && (IOO1O1O1[OOl0l1OO] === 1'b1))
	for (O0IOl0IO=0; O0IOl0IO<id_width; O0IOl0IO=O0IOl0IO+1) begin
          O01I01I1[(OOl0l1OO*id_width)+O0IOl0IO] = llOI1101[((OOl0l1OO-1)*id_width)+O0IOl0IO];
	end
      else
	for (O0IOl0IO=0; O0IOl0IO<id_width; O0IOl0IO=O0IOl0IO+1) begin
          O01I01I1[(OOl0l1OO*id_width)+O0IOl0IO] = llOI1101[(OOl0l1OO*id_width)+O0IOl0IO];
	end
    end
  end
end

always @(OO1O1111 or IOO1O1O1) begin : a1002_PROC
  for (OO01OO1l=0; OO01OO1l<stages; OO01OO1l=OO01OO1l+1) begin
     O1101011[OO01OO1l] = OO1O1111[OO01OO1l] & IOO1O1O1[OO01OO1l];
  end
end

always @(lO0O1llI or O0l10O00) begin : a1003_PROC
  O0l10O00 = {`DW_O0OIO101{1'b0}};
  for (Ol11O1Ol=0; Ol11O1Ol<stages; Ol11O1Ol=Ol11O1Ol+1) begin
    if (lO0O1llI[Ol11O1Ol] === 1'b1)
      O0l10O00 = O0l10O00 + 1'b1;
  end
end


always @(posedge I0OOlIOO or negedge I1OO1OO1) begin : a1004_PROC
  if (I1OO1OO1 === 1'b0) begin
    lO0O1llI         <= {stages{1'b0}};
    llOI1101         <= {(stages*id_width){1'b0}};
    l0IO0111 <= 1'b0;
  end else if (I1OO1OO1 === 1'b1) begin
    if (O0OII00O === 1'b0) begin
      lO0O1llI         <= {stages{1'b0}};
      llOI1101         <= {(stages*id_width){1'b0}};
      l0IO0111 <= 1'b0;
    end else if (O0OII00O === 1'b1) begin
      lO0O1llI         <= IOO1O1O1;
      llOI1101         <= O01I01I1;
      l0IO0111 <= ~OO1O1111[0] & IIllO1l0;
    end else begin
      lO0O1llI         <= {stages{1'bx}};
      llOI1101         <= {(stages*id_width){1'bx}};
      l0IO0111 <= 1'bx;
    end
  end else begin
    lO0O1llI         <= {stages{1'bx}};
    llOI1101         <= {(stages*id_width){1'bx}};
    l0IO0111 <= 1'bx;
  end
end



assign pipe_en_bus = O1101011;
assign arrive      = lO0O1llI[stages-1];
assign arrive_id   = llOI1101[(stages*id_width)-1:(stages-1)*id_width];
assign push_out_n  = ~(OOIl0IO0 & lO0O1llI[stages-1]);
assign pipe_full   = (O0l10O00 == stages) & !OOIl0IO0;
assign pipe_census = O0l10O00;
assign pipe_ovf    = l0IO0111;

`undef DW_O1O1O0O0
`undef DW_O0OIO101
// synopsys translate_on
endmodule
