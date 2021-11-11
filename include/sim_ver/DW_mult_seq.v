////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2002 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Aamir Farooqui                February 12, 2002
//
// VERSION:   Verilog Simulation Model for DW_mult_seq
//
// DesignWare_version: 217cfdf6
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
//ABSTRACT:  Sequential Multiplier 
// Uses modeling functions from DW_Foundation.
//
//MODIFIED:
// 2/26/16 LMSU Updated to use blocking and non-blocking assigments in
//              the correct way
// 8/06/15 RJK Update to support VCS-NLP
// 2/06/15 RJK  Updated input change monitor for input_mode=0 configurations to better
//             inform designers of severity of protocol violations (STAR 9000851903)
// 5/20/14 RJK  Extended corruption of output until next start for configurations
//             with input_mode = 0 (STAR 9000741261)
// 9/25/12 RJK  Corrected data corruption detection to catch input changes
//             during the first cycle of calculation (related to STAR 9000505348)
// 1/5/12 RJK Change behavior when inputs change during calculation with
//          input_mode = 0 to corrupt output (STAR 9000505348)
//
//------------------------------------------------------------------------------

module DW_mult_seq ( clk, rst_n, hold, start, a,  b, complete, product);


// parameters 

  parameter  a_width     = 3; 
  parameter  b_width     = 3;
  parameter  tc_mode     = 0;
  parameter  num_cyc     = 3;
  parameter  rst_mode    = 0;
  parameter  input_mode  = 1;
  parameter  output_mode = 1;
  parameter  early_start = 0;
 
//-----------------------------------------------------------------------------

// ports 
  input clk, rst_n;
  input hold, start;
  input [a_width-1:0] a;
  input [b_width-1:0] b;

  output complete;
  output [a_width+b_width-1:0] product;

//-----------------------------------------------------------------------------
// synopsys translate_off

localparam signed [31:0] CYC_CONT = (input_mode==1 & output_mode==1 & early_start==0)? 3 :
                                    (input_mode==early_start & output_mode==0)? 1 : 2;

//-------------------Integers-----------------------
  integer count;
  integer next_count;
 

//-----------------------------------------------------------------------------
// wire and registers 

  wire clk, rst_n;
  wire hold, start;
  wire [a_width-1:0] a;
  wire [b_width-1:0] b;
  wire complete;
  wire [a_width+b_width-1:0] product;

  wire [a_width+b_width-1:0] temp_product;
  reg [a_width+b_width-1:0] ext_product;
  reg [a_width+b_width-1:0] next_product;
  wire [a_width+b_width-2:0] long_temp1,long_temp2;
  reg [a_width-1:0]   in1;
  reg [b_width-1:0]   in2;
  reg [a_width-1:0]   next_in1;
  reg [b_width-1:0]   next_in2;
 
  wire [a_width-1:0]   temp_a;
  wire [b_width-1:0]   temp_b;

  wire start_n;
  wire hold_n;
  reg ext_complete;
  reg next_complete;
 


//-----------------------------------------------------------------------------
  
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (b_width < 3) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 3)",
	b_width );
    end
    
    if ( (a_width < 3) || (a_width > b_width) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (legal range: 3 to b_width)",
	a_width );
    end
    
    if ( (num_cyc < 3) || (num_cyc > a_width) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_cyc (legal range: 3 to a_width)",
	num_cyc );
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
    
    if ( (input_mode < 0) || (input_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter input_mode (legal range: 0 to 1)",
	input_mode );
    end
    
    if ( (output_mode < 0) || (output_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter output_mode (legal range: 0 to 1)",
	output_mode );
    end
    
    if ( (early_start < 0) || (early_start > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter early_start (legal range: 0 to 1)",
	early_start );
    end
    
    if ( (input_mode===0 && early_start===1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination: when input_mode=0, early_start=1 is not possible" );
    end

  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


//------------------------------------------------------------------------------

  assign start_n      = ~start;
  assign complete     = ext_complete & start_n;

  assign temp_a       = (in1[a_width-1])? (~in1 + 1'b1) : in1;
  assign temp_b       = (in2[b_width-1])? (~in2 + 1'b1) : in2;
  assign long_temp1   = temp_a*temp_b;
  assign long_temp2   = ~(long_temp1 - 1'b1);
  assign temp_product = (tc_mode)? (((in1[a_width-1] ^ in2[b_width-1]) && (|long_temp1))?
                                {1'b1,long_temp2} : {1'b0,long_temp1}) : in1*in2;

// Begin combinational next state assignments
  always @ (start or hold or a or b or count or in1 or in2 or
            temp_product or ext_product or ext_complete) begin
    if (start === 1'b1) begin                     // Start operation
      next_in1      = a;
      next_in2      = b;
      next_count    = 0;
      next_complete = 1'b0;
      next_product  = {a_width+b_width{1'bX}};
    end else if (start === 1'b0) begin            // Normal operation
      if (hold === 1'b0) begin
        if (count >= (num_cyc+CYC_CONT-4)) begin
          next_in1      = in1;
          next_in2      = in2;
          next_count    = count; 
          next_complete = 1'b1;
          next_product  = temp_product;
        end else if (count === -1) begin
          next_in1      = {a_width{1'bX}};
          next_in2      = {b_width{1'bX}};
          next_count    = -1; 
          next_complete = 1'bX;
          next_product  = {a_width+b_width{1'bX}};
        end else begin
          next_in1      = in1;
          next_in2      = in2;
          next_count    = count+1; 
          next_complete = 1'b0;
          next_product  = {a_width+b_width{1'bX}};
        end
      end else if (hold === 1'b1) begin           // Hold operation
        next_in1      = in1;
        next_in2      = in2;
        next_count    = count; 
        next_complete = ext_complete;
        next_product  = ext_product;
      end else begin                              // hold == x
        next_in1      = {a_width{1'bX}};
        next_in2      = {b_width{1'bX}};
        next_count    = -1;
        next_complete = 1'bX;
        next_product  = {a_width+b_width{1'bX}};
      end
    end else begin                                // start == x
      next_in1      = {a_width{1'bX}};
      next_in2      = {b_width{1'bX}};
      next_count    = -1;
      next_complete = 1'bX;
      next_product  = {a_width+b_width{1'bX}};
    end
  end
// end combinational next state assignments

generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0

  // Begin sequential assignments
    always @ ( posedge clk or negedge rst_n ) begin: ar_register_PROC
      if (rst_n === 1'b0) begin                   // initialize everything asyn reset
        count        <= 0;
        in1          <= 0;
        in2          <= 0;
        ext_product  <= 0;
        ext_complete <= 0;
      end else if (rst_n === 1'b1) begin          // rst_n == 1
        count        <= next_count;
        in1          <= next_in1;
        in2          <= next_in2;
        ext_product  <= next_product;
        ext_complete <= next_complete & start_n;
      end else begin                              // rst_n == X
        in1          <= {a_width{1'bX}};
        in2          <= {b_width{1'bX}};
        count        <= -1;
        ext_product  <= {a_width+b_width{1'bX}};
        ext_complete <= 1'bX;
      end 
   end // ar_register_PROC

  end else  begin : GEN_RM_NE_0

  // Begin sequential assignments
    always @ ( posedge clk ) begin: sr_register_PROC 
      if (rst_n === 1'b0) begin                   // initialize everything asyn reset
        count        <= 0;
        in1          <= 0;
        in2          <= 0;
        ext_product  <= 0;
        ext_complete <= 0;
      end else if (rst_n === 1'b1) begin          // rst_n == 1
        count        <= next_count;
        in1          <= next_in1;
        in2          <= next_in2;
        ext_product  <= next_product;
        ext_complete <= next_complete & start_n;
      end else begin                              // rst_n == X
        in1          <= {a_width{1'bX}};
        in2          <= {b_width{1'bX}};
        count        <= -1;
        ext_product  <= {a_width+b_width{1'bX}};
        ext_complete <= 1'bX;
      end 
   end // ar_register_PROC

  end
endgenerate

  wire corrupt_data;

generate
  if (input_mode == 0) begin : GEN_IM_EQ_0

    localparam [0:0] NO_OUT_REG = (output_mode == 0)? 1'b1 : 1'b0;
    reg [a_width-1:0] ina_hist;
    reg [b_width-1:0] inb_hist;
    wire next_corrupt_data;
    reg  corrupt_data_int;
    wire data_input_activity;
    reg  init_complete;
    wire next_alert1;
    integer change_count;

    assign next_alert1 = next_corrupt_data & rst_n & init_complete &
                                    ~start & ~complete;

    if (rst_mode == 0) begin : GEN_A_RM_EQ_0
      always @ (posedge clk or negedge rst_n) begin : ar_hist_regs_PROC
	if (rst_n === 1'b0) begin
	    ina_hist        <= a;
	    inb_hist        <= b;
	    change_count    <= 0;

	  init_complete   <= 1'b0;
	  corrupt_data_int <= 1'b0;
	end else begin
	  if ( rst_n === 1'b1) begin
	    if ((hold != 1'b1) || (start == 1'b1)) begin
	      ina_hist        <= a;
	      inb_hist        <= b;
	      change_count    <= (start == 1'b1)? 0 :
	                         (next_alert1 == 1'b1)? change_count + 1 : change_count;
	    end

	    init_complete   <= init_complete | start;
	    corrupt_data_int<= next_corrupt_data | (corrupt_data_int & ~start);
	  end else begin
	    ina_hist        <= {a_width{1'bx}};
	    inb_hist        <= {b_width{1'bx}};
	    change_count    <= -1;
	    init_complete   <= 1'bx;
	    corrupt_data_int <= 1'bX;
	  end
	end
      end
    end else begin : GEN_A_RM_NE_0
      always @ (posedge clk) begin : sr_hist_regs_PROC
	if (rst_n === 1'b0) begin
	    ina_hist        <= a;
	    inb_hist        <= b;
	    change_count    <= 0;
	  init_complete   <= 1'b0;
	  corrupt_data_int <= 1'b0;
	end else begin
	  if ( rst_n === 1'b1) begin
	    if ((hold != 1'b1) || (start == 1'b1)) begin
	      ina_hist        <= a;
	      inb_hist        <= b;
	      change_count    <= (start == 1'b1)? 0 :
	                         (next_alert1 == 1'b1)? change_count + 1 : change_count;
	    end

	    init_complete   <= init_complete | start;
	    corrupt_data_int<= next_corrupt_data | (corrupt_data_int & ~start);
	  end else begin
	    ina_hist        <= {a_width{1'bx}};
	    inb_hist        <= {b_width{1'bx}};
	    init_complete    <= 1'bx;
	    corrupt_data_int <= 1'bX;
	    change_count     <= -1;
	  end
	end
      end
    end // GEN_A_RM_NE_0

    assign data_input_activity =  (((a !== ina_hist)?1'b1:1'b0) |
				 ((b !== inb_hist)?1'b1:1'b0)) & rst_n;

    assign next_corrupt_data = (NO_OUT_REG | ~complete) &
                              (data_input_activity & ~start &
					~hold & init_complete);

`ifdef UPF_POWER_AWARE
  `protected
82O2++5,?FFcB-0WB=^+P9N6MO6O_MeEJ[LEVL;,5/TW.b>Z?^D\+)Y(Q(-_H+?E
)SBN?\M5SM/.SGH(^ZF2+B&aWO,6K]:AWbaG4[OIdCB/35RP&\4:?UTdM@SQ<V&>
^cGKEBI_U3NgcE+V:11UbM06D<7<da?&;C4E-FZ>a7>]bVEaYc,<9CN#&gWTZH4[
)[)GMbaIR37(0K=83_G^[SU5M3cU]3B?O_6PaINW9O?,b73V6e[7f+TdQ1DQ8#B.
NDgI1J4_ff/0S>\Tgb(E5g@#e0c6LVUa1e^,8#J_]b:(R0.a]2>K\=B2Y_N?0Af2
RAU,M2U.b:SW)]eD5:2Wed\G6AcR26dfdbCP(IAOO/YRONMNW4:c1A<M1\:D;+Ld
9C1PEQ<MSfXSFV9C?26)f1#@6-e7]JHRMXZ3+R8FYQ:&b[KDVe[_BXY-?(,NKC[>
4.E-U-S=[4JX;)5#?LM@:NTcQ9e1HGb4D+&A-/0)?g0N34Ma(46#.<\W0E7QL>P/
6F;L6=.QNLE<+R<2a:d#4FX(RaN;[#]:DdCZ=P@eK\\[eeU.egL09BU.@^]IQ=\I
XD?[b)gT;4GGBAQ/#f26?QQWTZ;RaKKH=98,?\LaU9_G^R4/,YbKbEKHf[J(F0@U
=8^1O7Y@2Hg;SP>7f,2-KZWIH&<@-\\.G(2Gc#J^LO,W#eY>(cBc#ISL(6dA+=P1
0G&K,B4CLE@Fg+]]eS7A7+F:I@aW[aO=L]3Q?U&L][8B:BZ??K,HdE\<]#173P]L
7W#8c?)d)74EWYBOeJf(#.P]@0VHFdbX7T0(\,?5I>RP2DNbLGRBS11&FFb9R;(:
V_+a_.9,DNMX:2IgCd_gM9d17N>QCE0UG3XH.]13\T.^24RN4Wf5O/S.RT;eUL4:
=9g6JNI@GN^3I&Y/;H+B^:H[VaB_Ie3EF\BeS57U8)d53[?@?6Y&3MAXKYHbTS(=
X4H<4M/2V_O&YO,&>>feTB;8QMU@HI85SV(?]L@6B3CQUM@;TJ)T_PYN\QC<DMd,
\&1P(;B[:9@/[4-^;&H2V>8+;I?FSL-E(-bEK[/_(+^ER)H3\cY[9:(&)G/Z_SW;
,XO47dA/]97ITR/>-@UBT[)5X5\Bb]gGQ4gg7EQFK9a.ANTP=6?081D)1[fAX&Da
@_eIFV>OR5]&[:LfT;dIbR5.?bI90IK=/S=\PB^)S>WXPA##@Z]F#B5W0&MXRGYf
2-D>#^#3G;+E/W5OG(1K58>;N5DA6:/OY);JK4fX/3FG=C^W.aQ(dF(U8#2P4e&I
;08E3SaB[fVR=0==gO[J-/fC4X7=a^9(+@\^K-B^dea=HX4>5FW\H]DD8N._,3\D
VD^/4.TW&a<2aa0?M&XO\:<58G?Wg9I+HGC;@fg.D6A-d61U9D(Q)^>O8-//4Z]^
QAOFbK:P,Ka?2L2g,<dJ0R[,(YVLVWddQYbC5T1,PAe9Y\X>FK_2N;QKb\W9c;[H
COA]+g)16T>EK;a=9G7>80;J,H?5NGH;FT^gH,.GRO2g]+IFN\gaccQ:Y@+/T?G>
F_gbD^_a.T=cJ[Ec4fZPIY#_EF62:+B7?BOS[+&Cg1@bG;e[KOf-+1;([T>382CW
94,[):>B#M/B^TH3Z<?_>DXG&C7bZ=d?A&X491S:)^Y>][XBAgX67-Y#KB45/LSV
#ecX_H\:V5F:?>]6f,[JE&8:cPdFH.XZLgD>FXV0^f92ObK?a:0\aB\a_\YaFR;P
,]Xf;SN00/b/VcQ@AK1)2&N?0O#:6F;H[,dVE4Jc]e7JAb&8EMB>H7Z3CVgPERUQ
,>(@O70[,64BR,WUBV?c2#WIP->8\7e,2/^b1-DZJ,LdNdUYcU+f#Y+9@@_2Z-_^
PE&MHa#W?VOJD5bKB&?=N.1H@g\.U33&c^TTag.^?Bb@RR]T+8+O3TR,KH;#8(1W
7EB_CfU:aG5U0]6[OG^[+ZQ6g25ScINH4P;,IHZB?9f-V^]I#;C+IS=\A78)Bd=5
]6<_W;3/B#^f#JT[Q7d.L]Ff.@7b@T(05-GO#HFRaP;dLbCbK+a>A]\Zb3B3F8^S
#KT,ZHEGHPaHJ\a+:B#?WG[1PRET>e0:+H9\#MWIX7881YdX.;7g^<MXEVd,bK3-
HA>XJ\PJZV:Y.2T-<P+@;C#90N#c913<a6d3U/T6D>G>D8IQXMEEW5-^SN54(]YI
bWcKHg>J7fL#;g)2I/&cT^EI,Tcg1]M-+E4-:S++IY5V#BZ,T8RQK_cf,1g]XCfE
E\c,CD>ABD>B;,UBL8X?Y#DLR(db3N3,N8[F=BfcE@W9(ZX6\&F#,^90P2VZHW/[
@YV@ERY]:1AI^K-USbB<?d)7F^-cF(EN>5:P23Y)XdW7GV7#+;1&\d90M$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert_PROC
      integer updated_count;

      updated_count = change_count;

      if (next_alert1 == 1'b1) begin
        $display("## Warning from %m: DW_mult_seq operand input change near %0d will cause corrupted results if operation is allowed to complete.", $time);
	updated_count = updated_count + 1;
      end

      if (((rst_n & init_complete & ~start & ~complete & next_complete) == 1'b1) &&
          (updated_count > 0)) begin
	$display(" ");
	$display("############################################################");
	$display("############################################################");
	$display("##");
	$display("## Error!! : from %m");
	$display("##");
	$display("##    This instance of DW_mult_seq has encountered %0d change(s)", updated_count);
	$display("##    on operand input(s) after starting the calculation.");
	$display("##    The instance is configured with no input register.");
	$display("##    So, the result of the operation was corrupted.  This");
	$display("##    message is generated at the point of completion of");
	$display("##    the operation (at time %0d), separate warning(s) were", $time );
	$display("##    generated earlier during calculation.");
	$display("##");
	$display("############################################################");
	$display("############################################################");
	$display(" ");
      end
    end
`endif

    assign corrupt_data = corrupt_data_int;

  if (output_mode == 0) begin : GEN_OM_EQ_0
    reg  alert2_issued;
    wire next_alert2;

    assign next_alert2 = next_corrupt_data & rst_n & init_complete &
                                     ~start & complete & ~alert2_issued;

`ifdef UPF_POWER_AWARE
  `protected
P66<U8Y-b9>3?XbFd[gCG+ZW?c0C0\?4b\>9XRAOT/?3GDV4,-^J/)J<G&<<YC@.
IVW]TBKf8+ZNT)/^SS03K6RPaZ<D8dFa+LRLAYCPBW3W37-bDF)_E?dNUcQ[L(;d
EKGN@Q@??Cd56e0G-)?123IM1WJFK-RSP:#PP&eEcE1SPXdJbYAUcfc.82P@egd0
ITZWVPaR;g&1PK__#^;2PKFM-W,X]9Z]90g1##B8Lgb_U:d@WE0:a3U2g=]8=f_\
JEfU:@-YF&\(Se]W9^\\COJF=8EE6I<<ONW/]-7AVE7WK[HN.(TN33];4W0997LI
MS?gD;?gN?Da.dC9JWEYa,J+/&:YbaM@A7;=??0-fT&GOGEW;Qd+T:?R24+0A\?/
0^7beBCLDD2_:48@Lb+ZBB]_OL5-/;&cf()=9f):d7.]9gD1:-4V225^[/M^Z>f5
&3(K?OSd&OPESbgMg(e6Kd3gVXDIS^Z[)FWe73<[e/4>GOY-;YS(2N@NJ1IJ2;SAU$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert2_PROC
      if (next_alert2 == 1'b1) begin
        $display( "## Warning from %m: DW_mult_seq operand input change near %0d causes output to no longer retain result of previous operation.", $time);
      end
    end
`endif

    if (rst_mode == 0) begin : GEN_AI_REG_AR
      always @ (posedge clk or negedge rst_n) begin : ar_alrt2_reg_PROC
        if (rst_n == 1'b0) alert2_issued <= 1'b0;

	  else alert2_issued <= ~start & (alert2_issued | next_alert2);
      end
    end else begin : GEN_AI_REG_SR
      always @ (posedge clk) begin : sr_alrt2_reg_PROC
        if (rst_n == 1'b0) alert2_issued <= 1'b0;

	  else alert2_issued <= ~start & (alert2_issued | next_alert2);
      end
    end

  end  // GEN_OM_EQ_0

  // GEN_IM_EQ_0
  end else begin : GEN_IM_NE_0
    assign corrupt_data = 1'b0;
  end // GEN_IM_NE_0
endgenerate

  assign product      = ((((input_mode==0)&&(output_mode==0)) || (early_start == 1)) && start == 1'b1) ?
			  {a_width+b_width{1'bX}} :
                          (corrupt_data === 1'b0)? ext_product : {a_width+b_width{1'bX}};


 
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 
// synopsys translate_on

endmodule




