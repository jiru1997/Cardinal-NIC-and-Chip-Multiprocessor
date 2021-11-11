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
// VERSION:   Verilog Simulation Model for DW_sqrt_seq
//
// DesignWare_version: a4969e34
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
//ABSTRACT:  Sequential Square Root 
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
//             during the first cycle of calculation (related to STAR 9000506330)
// 1/5/12 RJK Change behavior when input changes during calculation with
//          input_mode = 0 to corrupt output (STAR 9000506330)
//
//------------------------------------------------------------------------------

module DW_sqrt_seq ( clk, rst_n, hold, start, a, complete, root);


// parameters 

  parameter  width       = 6; 
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
  input [width-1:0] a;

  output complete;
  output [(width+1)/2-1:0] root;

//-----------------------------------------------------------------------------
// synopsys translate_off

//------------------------------------------------------------------------------
localparam signed [31:0] CYC_CONT = (input_mode==1 & output_mode==1 & early_start==0)? 3 :
                                    (input_mode==early_start & output_mode==0)? 1 : 2;

//------------------------------------------------------------------------------
  // include modeling functions
`include "DW_sqrt_function.inc"
 
//-------------------Integers-----------------------
  integer count;
  integer next_count;
 

//-----------------------------------------------------------------------------
// wire and registers 

  wire clk, rst_n;
  wire hold, start;
  wire [width-1:0] a;
  wire complete;
  wire [(width+1)/2-1:0] root;

  wire [(width+1)/2-1:0] temp_root;
  reg [(width+1)/2-1:0] ext_root;
  reg [(width+1)/2-1:0] next_root;
 
  reg [width-1:0]   in1;
  reg [width-1:0]   next_in1;

  wire start_n;
  wire hold_n;
  reg ext_complete;
  reg next_complete;
 


//-----------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 6) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 6)",
	width );
    end
    
    if ( (num_cyc < 3) || (num_cyc > (width+1)/2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_cyc (legal range: 3 to (width+1)/2)",
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
  assign temp_root    = (tc_mode)? DWF_sqrt_tc (in1): DWF_sqrt_uns (in1); 

// Begin combinational next state assignments
  always @ (start or hold or a or count or in1 or temp_root or ext_root or ext_complete) begin : a1000_PROC
    if (start === 1'b1) begin                   // Start operation
      next_in1      = a;
      next_count    = 0;
      next_complete = 1'b0;
      next_root     = {(width+1)/2{1'bX}};
    end else if (start === 1'b0) begin          // Normal operation
      if (hold===1'b0) begin
        if (count >= (num_cyc+CYC_CONT-4)) begin
          next_in1      = in1;
          next_count    = count; 
          next_complete = 1'b1;
          next_root     = temp_root;
        end else if (count === -1) begin
          next_in1      = {width{1'bX}};
          next_count    = -1; 
          next_complete = 1'bX;
          next_root     = {(width+1)/2{1'bX}};
        end else begin
          next_in1      = in1;
          next_count    = count+1; 
          next_complete = 1'b0;
          next_root     = {(width+1)/2{1'bX}} ;
        end
      end else if (hold === 1'b1) begin         // Hold operation
        next_in1      = in1;
        next_count    = count; 
        next_complete = ext_complete;
        next_root     = ext_root;
      end else begin                            // hold == X
        next_in1      = {width{1'bX}};
        next_count    = -1;
        next_complete = 1'bX;
        next_root     = {(width+1)/2{1'bX}};
      end
    end else begin                              // start == X
      next_in1      = {width{1'bX}};
      next_count    = -1;
      next_complete = 1'bX;
      next_root     = {(width+1)/2{1'bX}};
    end
  end
// end combinational next state assignments

generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0

  // Begin sequential assignments   
    always @ ( posedge clk or negedge rst_n ) begin: ar_register_PROC
      if (rst_n === 1'b0) begin                 // initialize everything asyn reset
        count        <= 0;
        in1          <= 0;
        ext_root     <= 0;
        ext_complete <= 0;
      end else if (rst_n === 1'b1) begin        // rst_n == 1
        count        <= next_count;
        in1          <= next_in1;
        ext_root     <= next_root;
        ext_complete <= next_complete & start_n;
      end else begin                            // rst_n == X
        count        <= -1;
        in1          <= {width{1'bX}};
        ext_root     <= {(width+1)/2{1'bX}};
        ext_complete <= 1'bX;
      end 
   end // ar_register_PROC

  end else begin : GEN_RM_NE_0

  // Begin sequential assignments   
    always @ ( posedge clk ) begin: sr_register_PROC 
      if (rst_n === 1'b0) begin                 // initialize everything syn reset
        count        <= 0;
        in1          <= 0;
        ext_root     <= 0;
        ext_complete <= 0;
      end else if (rst_n === 1'b1) begin        // rst_n == 1
        count        <= next_count;
        in1          <= next_in1;
        ext_root     <= next_root;
        ext_complete <= next_complete & start_n;
      end else begin                            // rst_n == X
        count        <= -1;
        in1          <= {width{1'bX}};
        ext_root     <= {(width+1)/2{1'bX}};
        ext_complete <= 1'bX;
      end 
    end // sr_register_PROC

  end
endgenerate

  wire corrupt_data;

generate
  if (input_mode == 0) begin : GEN_IM_EQ_0

    localparam [0:0] NO_OUT_REG = (output_mode == 0)? 1'b1 : 1'b0;
    reg [width-1:0] ina_hist;
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
	    change_count    <= 0;

	  init_complete   <= 1'b0;
	  corrupt_data_int <= 1'b0;
	end else begin
	  if ( rst_n === 1'b1) begin
	    if ((hold != 1'b1) || (start == 1'b1)) begin
	      ina_hist        <= a;
	      change_count    <= (start == 1'b1)? 0 :
	                         (next_alert1 == 1'b1)? change_count + 1 : change_count;
	    end

	    init_complete   <= init_complete | start;
	    corrupt_data_int<= next_corrupt_data | (corrupt_data_int & ~start);
	  end else begin
	    ina_hist        <= {width{1'bx}};
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
	    change_count    <= 0;
	  init_complete   <= 1'b0;
	  corrupt_data_int <= 1'b0;
	end else begin
	  if ( rst_n === 1'b1) begin
	    if ((hold != 1'b1) || (start == 1'b1)) begin
	      ina_hist        <= a;
	      change_count    <= (start == 1'b1)? 0 :
	                         (next_alert1 == 1'b1)? change_count + 1 : change_count;
	    end

	    init_complete   <= init_complete | start;
	    corrupt_data_int<= next_corrupt_data | (corrupt_data_int & ~start);
	  end else begin
	    ina_hist        <= {width{1'bx}};
	    init_complete    <= 1'bx;
	    corrupt_data_int <= 1'bX;
	    change_count     <= -1;
	  end
	end
      end
    end // GEN_A_RM_NE_0

    assign data_input_activity =  ((a !== ina_hist)?1'b1:1'b0) & rst_n;

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
RAU,M2U.b:SW)]eD5:2WYd&fT>[L.2(;:b(K6+0LPa47^\GHIX>BQgJFbf9UR#&C
3#6/.DSZ(FG:3D>(A\UFW>XdDCIMg^3+c7P_\5D^5]1C2g)B1@^+>O5aV4gH=:5Z
Be>53CC;W,DP[.FKOgX9)JB.UdS(eSS>RaX:BP56LR5HeGE.A9/\0;Y7?(XC6V@(
Z/bS<R=&a:Se,/(b96bCZJLG@NV?S(>H,<P#0LU_=FcbT2.FgU(&).(ZU.aLdRb=
I?IS:1>+a/H)9N2?5a-@2R@5<EJ-U?:PP.CB9&W,7&I;QbfAJQ^&1F9fD5(FP/()
:(U-^74/_?4G1XIJ@8W9N0dKM,aI8B6BS6S@ELSJY#g.5?\]@C/+#:VKB8^(L+\H
fB=?^d\#^3F^5@Z04T#a]W;L((/OZA3O\>B<d5A52fY[V@0U^\(7=2F)+O1EX/I]
BW.K@5c?&b@\DP5bNELI92IV[W=X7X)cTEbQO;82P9[)Z&,OP8GLf\8#B7,N@Z#-
=;cO/fX=9=aU#SOTZ2E^R,JWMc?EVSaV(IEW_;?T3\X(aVLTV/E52S68I#Za7ea;
d>D?g6]=C8W^J=<CJB[QGR&(C6N]I4945356/T_7(V_<<T<b,K^-7Z7]Q1S42PaP
BC,B&NIM]Q@aU]C=4N:(49,&e@I6U9ggH.T,];?P]T-^<)7d&)S>\aeNMWO1-8Qf
Q.QJT_bddM0]SH6b=U@:cK2_U<^,G5LaA&P=Q@4A=7,H7V5(0HT/REfe7<8:Id+M
,fV8(34RaLIS+1eF+YaR(dPOIW3I9V\g/Pe7D.@@f-<<CY.dNE-P\,V./J3IWJUV
V<K>[DOKV]P1;IHX5W3KbEMV=2_O,:F7Ig/=(N@^UKG#3Ha:9TDC@MCF@YRS(TAN
4YMZ&5WXBVI4_C.-VJ,SIfAG<DZZd=Wd(N,(?ZbYO<2:T[(GaZOC@77<45U3S^9I
HY#,ZF(R1\#G_2AX1NM@J>S=&WHK-1BaZ)[,g7WOa:03<B/gY7/HPB.f11ZBBC^A
2aKT74#D<LYL/WOTe=+/_2+A1+LeW,f65.:UYbPV]cT4M:OECF7D@d@D+]SK[6W#
;A(C\dB<@O9dO(WES@EHH7?E9M?;,&)g+Q[Q12<J;P[\)^TeD0dd;#90TKV:K<_a
9_HS@X:W^Q[ZcKB0E,Dc91Oe3Aa&;81QU.J^[Lc0YGF:TcFEN-@IJe/bPM;A^+00
aXV6W7O)gBIW>LW^W1NQSd]FU1MA/@WcdUg=M=Z^)c^R[JbbgE80:W1>73QU>M/9
\)c;gPRJ3IW:HEa\>OG>a==cF0V9b_ED117EU>ST+G>+EcQ:G3O>UaB[/YIJ0c&g
+(NX6d\bZ@5U1c+B;gJ.>VPKd7Qd/f95a]Y-7b;98HM&Y34R[+\S[EYG:8C)+U)J
E,S=6(-PZU/BV6A>P;OZ2_,9<Qe_P-Q+_?0Q2aJ+\#5NBH6aHWa?#@04^Ed0#La9
R2BC.M?ZdNT<GSKDPLRNd5OQMd-^#@#TgW>6Jd,IcV<]e889[/I(>(I8G1@QTCR,
c#_KO-gQT_>-D+)R,Y=bdH>0E922?M34@LRSf?@/HNPN>;B]bgVVJ6JcFg3QJM7&
G)[D??<fLXEZT102/M53-eL0S)H+Q1KA+;Hbd_9b(1[4SHY?1?TE8XXM3Id9C]N8
W+)R1g7d3Ga7EYBbA?]28QK59.E5&S6X=)WWG,3?,:70U=XKB8BRdL,dW2)4>R-H
6W)#+9\)f#L&(GF?Y0\K43[)Y7DMgWF/PO#[+&dYbc76V:7Edd,)9R(FW@I4;QXK
HXa0\Xb7R;7&C@K[/]SOGMSc:&aW[?NN>Taf>3.KdeGKHadAYM5_Q>POWWZ::8b;
eb+YA63TO36R-=bS]U.+dD1,.2N>7d;>/QJP\P@\:WV-P.6QMAHDLJ0O-X66P-X4
(g/VOU(E3J=3RDX359,<YK:ga]O:.e>)fWbW6HQYTLH(gBad>0WJ>;4--IM-UR=8
_<9eN;NW&1G2=cFUg;,M50Y.T)<1b20K[PE0C##684F,ISP(>RGb.R4-M$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert_PROC
      integer updated_count;

      updated_count = change_count;

      if (next_alert1 == 1'b1) begin
        $display("## Warning from %m: DW_sqrt_seq operand input change near %0d will cause corrupted results if operation is allowed to complete.", $time);
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
	$display("##    This instance of DW_sqrt_seq has encountered %0d change(s)", updated_count);
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
MS?gD;?gN?Da.dC9JWEYd,dO6B.g2#OK+9259\N4_UZG^:_LF2JI?Zb\/+>57aYX
JfONL0#b3&XUG^++:39;<220);\RM4R>BP)Na]cLgWSHU)6F1g<3?e59AT:C.(de
0\MH#Se0)CGL1c&:1T,;6FeJ&1=4P]0A.d2>I+SMgH7>GBbD98B5#+Bad7:#af0eU$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert2_PROC
      if (next_alert2 == 1'b1) begin
        $display( "## Warning from %m: DW_sqrt_seq operand input change near %0d causes output to no longer retain result of previous operation.", $time);
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

  assign root         = ((((input_mode==0)&&(output_mode==0))||(early_start==1)) & start == 1'b1) ?
			     {(width+1)/2{1'bX}} :
                             (corrupt_data === 1'b0)? ext_root : {(width+1)/2{1'bX}} ;

 
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 
// synopsys translate_on

endmodule




