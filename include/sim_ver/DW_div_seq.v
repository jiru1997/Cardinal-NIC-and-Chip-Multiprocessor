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
// AUTHOR:    Aamir Farooqui                February 20, 2002
//
// VERSION:   Verilog Simulation Model for DW_div_seq
//
// DesignWare_version: 188f13ad
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//ABSTRACT:  Sequential Divider 
//  Uses modeling functions from DW_Foundation.
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
//             during the first cycle of calculation (related to STAR 9000506285)
// 1/4/12 RJK Change behavior when inputs change during calculation with
//          input_mode = 0 to corrupt output (STAR 9000506285)
// 3/19/08 KYUNG fixed the reset error of the sim model (STAR 9000233070)
// 5/02/08 KYUNG fixed the divide_by_0 error (STAR 9000241241)
// 1/08/09 KYUNG fixed the divide_by_0 error (STAR 9000286268)
//------------------------------------------------------------------------------

module DW_div_seq ( clk, rst_n, hold, start, a,  b, complete, divide_by_0, quotient, remainder);


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
  output [a_width-1 : 0] quotient;
  output [b_width-1 : 0] remainder;
  output divide_by_0;

//-----------------------------------------------------------------------------
// synopsys translate_off

localparam signed [31:0] CYC_CONT = (input_mode==1 & output_mode==1 & early_start==0)? 3 :
                                    (input_mode==early_start & output_mode==0)? 1 : 2;

//------------------------------------------------------------------------------
  // include modeling functions
`include "DW_div_function.inc"
 

//-------------------Integers-----------------------
  integer count;
  integer next_count;
 

//-----------------------------------------------------------------------------
// wire and registers 

  wire [a_width-1:0] a;
  wire [b_width-1:0] b;
  wire [b_width-1:0] in2_c;
  wire [a_width-1:0] quotient;
  wire [a_width-1:0] temp_quotient;
  wire [b_width-1:0] remainder;
  wire [b_width-1:0] temp_remainder;
  wire clk, rst_n;
  wire hold, start;
  wire divide_by_0;
  wire complete;
  wire temp_div_0;
  wire start_n;
  wire start_rst;
  wire int_complete;
  wire hold_n;

  reg [a_width-1:0] next_in1;
  reg [b_width-1:0] next_in2;
  reg [a_width-1:0] in1;
  reg [b_width-1:0] in2;
  reg [b_width-1:0] ext_remainder;
  reg [b_width-1:0] next_remainder;
  reg [a_width-1:0] ext_quotient;
  reg [a_width-1:0] next_quotient;
  reg run_set;
  reg ext_div_0;
  reg next_div_0;
  reg start_r;
  reg ext_complete;
  reg next_complete;
  reg temp_div_0_ff;

  wire [b_width-1:0] b_mux;
  reg [b_width-1:0] b_reg;
  reg pr_state;
  reg start_q;
  reg rst_n_q;
  wire reset_st;

//-----------------------------------------------------------------------------
  
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (a_width < 3) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 3)",
	a_width );
    end
    
    if ( (b_width < 3) || (b_width > a_width) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (legal range: 3 to a_width)",
	b_width );
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
  assign in2_c        =  input_mode == 0 ? in2 : ( int_complete == 1 ? in2 : {b_width{1'b1}});
  assign temp_quotient  = (tc_mode)? DWF_div_tc(in1, in2_c) : DWF_div_uns(in1, in2_c);
  assign temp_remainder = (tc_mode)? DWF_rem_tc(in1, in2_c) : DWF_rem_uns(in1, in2_c);
  assign int_complete = (! start && run_set) || start_rst;
  assign start_rst    = ! start && start_r;

  assign temp_div_0 = (b_mux == 0) ? 1'b1 : 1'b0;

  assign b_mux = (input_mode == 1) ?
                   ((start == 1) ? b : b_reg) :
                   b;

  always @(posedge clk) begin : a1000_PROC
    if (start == 1) begin
      b_reg <= b;
    end 

    start_q <= start;
    rst_n_q <= rst_n;
  end

// Begin combinational next state assignments
  always @ (start or hold or count or a or b or in1 or in2 or
            temp_div_0 or temp_quotient or temp_remainder or
            ext_div_0 or ext_quotient or ext_remainder or ext_complete) begin
    if (start === 1'b1) begin                       // Start operation
      next_in1       = a;
      next_in2       = b;
      next_count     = 0;
      next_complete  = 1'b0;
      next_div_0     = temp_div_0;
      next_quotient  = {a_width{1'bX}};
      next_remainder = {b_width{1'bX}};
    end else if (start === 1'b0) begin              // Normal operation
      if (hold === 1'b0) begin
        if (count >= (num_cyc+CYC_CONT-4)) begin
          next_in1       = in1;
          next_in2       = in2;
          next_count     = count; 
          next_complete  = 1'b1;
          if (run_set == 1) begin
            next_div_0     = temp_div_0;
            next_quotient  = temp_quotient;
            next_remainder = temp_remainder;
          end else begin
            next_div_0     = 0;
            next_quotient  = 0;
            next_remainder = 0;
          end
        end else if (count === -1) begin
          next_in1       = {a_width{1'bX}};
          next_in2       = {b_width{1'bX}};
          next_count     = -1; 
          next_complete  = 1'bX;
          next_div_0     = 1'bX;
          next_quotient  = {a_width{1'bX}};
          next_remainder = {b_width{1'bX}};
        end else begin
          next_in1       = in1;
          next_in2       = in2;
          next_count     = count+1; 
          next_complete  = 1'b0;
          next_div_0     = temp_div_0;
          next_quotient  = {a_width{1'bX}};
          next_remainder = {b_width{1'bX}};
        end
      end else if (hold === 1'b1) begin             // Hold operation
        next_in1       = in1;
        next_in2       = in2;
        next_count     = count; 
        next_complete  = ext_complete;
        next_div_0     = ext_div_0;
        next_quotient  = ext_quotient;
        next_remainder = ext_remainder;
      end else begin                                // hold = X
        next_in1       = {a_width{1'bX}};
        next_in2       = {b_width{1'bX}};
        next_count     = -1;
        next_complete  = 1'bX;
        next_div_0     = 1'bX;
        next_quotient  = {a_width{1'bX}};
        next_remainder = {b_width{1'bX}};
      end
    end else begin                                  // start = X 
      next_in1       = {a_width{1'bX}};
      next_in2       = {b_width{1'bX}};
      next_count     = -1;
      next_complete  = 1'bX;
      next_div_0     = 1'bX;
      next_quotient  = {a_width{1'bX}};
      next_remainder = {b_width{1'bX}};
    end
  end
// end combinational next state assignments
  
generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0

    assign reset_st = ~rst_n | (~start_q & pr_state);

  // Begin sequential assignments   
    always @ ( posedge clk or negedge rst_n ) begin : ar_register_PROC
      if (rst_n === 1'b0) begin
        count           <= 0;
        if(input_mode == 1) begin
          in1           <= 0;
          in2           <= 0;
        end else if (input_mode == 0) begin
          in1           <= a;
          in2           <= b;
        end 
        ext_complete    <= 0;
        ext_div_0       <= 0;
        start_r         <= 0;
        run_set         <= 0;
        pr_state        <= 1;
        ext_quotient    <= 0;
        ext_remainder   <= 0;
        temp_div_0_ff   <= 0;
      end else if (rst_n === 1'b1) begin
        count           <= next_count;
        in1             <= next_in1;
        in2             <= next_in2;
        ext_complete    <= next_complete & start_n;
        ext_div_0       <= next_div_0;
        ext_quotient    <= next_quotient;
        ext_remainder   <= next_remainder;
        start_r         <= start;
        pr_state        <= reset_st;
        run_set         <= 1;
        temp_div_0_ff   <= temp_div_0;
      end else begin                                // If nothing is activated then put 'X'
        count           <= -1;
        in1             <= {a_width{1'bX}};
        in2             <= {b_width{1'bX}};
        ext_complete    <= 1'bX;
        ext_div_0       <= 1'bX;
        ext_quotient    <= {a_width{1'bX}};
        ext_remainder   <= {b_width{1'bX}};
        temp_div_0_ff   <= 1'bX;
      end 
    end                                             // ar_register_PROC

  end else begin : GEN_RM_NE_0

    assign reset_st = ~rst_n_q | (~start_q & pr_state);

  // Begin sequential assignments   
    always @ ( posedge clk ) begin : sr_register_PROC
      if (rst_n === 1'b0) begin
        count           <= 0;
        if(input_mode == 1) begin
          in1           <= 0;
          in2           <= 0;
        end else if (input_mode == 0) begin
          in1           <= a;
          in2           <= b;
        end 
        ext_complete    <= 0;
        ext_div_0       <= 0;
        start_r         <= 0;
        run_set         <= 0;
        pr_state        <= 1;
        ext_quotient    <= 0;
        ext_remainder   <= 0;
        temp_div_0_ff   <= 0;
      end else if (rst_n === 1'b1) begin
        count           <= next_count;
        in1             <= next_in1;
        in2             <= next_in2;
        ext_complete    <= next_complete & start_n;
        ext_div_0       <= next_div_0;
        ext_quotient    <= next_quotient;
        ext_remainder   <= next_remainder;
        start_r         <= start;
        pr_state        <= reset_st;
        run_set         <= 1;
        temp_div_0_ff   <= temp_div_0;
      end else begin                                // If nothing is activated then put 'X'
        count           <= -1;
        in1             <= {a_width{1'bX}};
        in2             <= {b_width{1'bX}};
        ext_complete    <= 1'bX;
        ext_div_0       <= 1'bX;
        ext_quotient    <= {a_width{1'bX}};
        ext_remainder   <= {b_width{1'bX}};
        temp_div_0_ff   <= 1'bX;
      end 
   end // sr_register_PROC

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
RAU,M2U.b:SW)]eD5:2W[dgbDV=VEE#,fBPEG:G&)dA,7M32][3@IEeQ6fOZ[RN4
4/E<Cc?NFd[;\+(7P2\SUdT/L6UPH80?##BOT(gL0bZA\I108GV5]RCb:daIJY8J
8WG,)\b[4IR:^A-[\CeND>:H&CNI]<)60;c_&a?&<F,LQWJO]&f(27)F#0=M&Wa[
),X>RKFaJ6--2fd(]SUa3;Aa2/8:LEWfA8+KCB#45UM;<G)@D/L6G#&>JZU4A#C0
)0WZAJ#NKf6V+\]7J)Q&IQNgB#;&BGb=]\]:=>,\O2P>DcECN,)\/-IO^Lf:^[R7
9XLKZPD1SL^4La,3-L^>H4OB1)B9]R6P.Za>1-)K,.aL#/QGPGA#bC\(<&+M57G5
;^5g_G7],.\Q_:(,7?02\?M@F1:L]:1PRY_KV#4ZR3TX3]2A7H<bI6Ke\GQ6CZ9g
>,fQU;(JG9dWK@eWUSQ[L)ZVH,)>(ZVI]+[&L@Jb#-PEY.S)L7DDJ\;?NbO+QcP5
?9G+NSO,C8J=\R&WeaM>WE0-S,-aV/ISJFeB\g;BN_6GCL27Q3^0.6K_c98<[7FE
MOB&/Pa;72I7:f<5AXL:]\JR]Y>_C?OU)Z(_Wcb9\SRW+;:=/0C:259&)_fL:DX@
=GT)<]&(>Q[YPU;=e;\Mgc2e]&90K24(T+GQZ/O^B1N40M5-LO\1L?b5,,[8dTII
#Y(N.KOJg>-0g>0O67ffHg:c;9EeV2(I]6WbCIHNY;:^.VIM\@+.H(X;?HJU&HR:
W0O.CHg)BQ\=aQXIaY<X@_>FIL?.(Z(Y.OGWA[(]G/g3GMO<IF,<edLDBSR=(N\O
R1P##eDUZD2X2-;VDSeGT6];QRLZ>NgK^38\DD-70Y5#GR/-a7d:<^>PKDC0QG+7
N9G1=YL&aYTV3V/7+dSc9c>.U0.\(;@g&::Q4>c2@29\JE^Fd)N3]P,KSY3+:C>S
1\@JcPC;AHc<W@_N>/4K,H\?QL6cIbL2=MMG_34ce<>[7dSKcG)3BS=02ecX0:W)
UPU7A,WVR\8Qc;VcSEebYBI=+:GdSB./J4SJ7KAC#QUPDe;;E0fG5=I>SZgfE#D0
^KTS-:7>PN?TL87#QfUWbJDHc;g:CR9G@3[+@&69].;Y1Y;T<O_HbOR@E(#O8ET<
MJ2dV#g:6H+?=e8LYgGU9e&@&M)0d@)&U)g5(.@DX<5F:,ZU^XT[;=VX)UeeQcUD
X.]#/F0dPVN6f)BKB:)VZWbU;P)5PdUbfb=W6(6WI[<ST4\0-6(20)AHdBG^J9XY
cG0gcJ#])gYF=4/bEFAY?UC_Ddg?\/BO(Yb[PaRaH/eE>#UTVWFK\B32^)/>V_D:
dW?(,I)U2#IVY\[8>cA23IRN5cH2,TP8.^UF7gPWLOFg#gRbb5[+adJZ3C;G0I+N
4/;O:T?4[,45<\FJ6).T_)[e0;V33T>g#Zd<@M:aCL[^I-.3Z?JP3(N#R6S(D,aP
EZFF2]YV>(OdXY@Y5<9WTCJe+bT=4(ND;28X0SHTVUcYc8EZ.00.W#:U.?=A^GPU
0[.Pb++;HPFRKKAcb?7&LbBTZ3WBa/Q&X6N)^F[599d1[L]TR;RGE>H;T1&W]U+)
e:PdAH\7[f.Kd/CNTO;<,VZ3cf4C=SOegF=gOP,</O2(JG+JVH]CD7@))Y5,983S
0FO#;FTY&50Mc&bTc[,R2Pg?@M4TM.J+;>L^I=O?\&2HH2bOO(RQ.1TX7W227M2e
NU.+Q\fW\2KY0U=UGPZP>Le\65C^U.^5<J2-gWCWBH:Kd67Pf9dFCVefHeNO7CIJ
ScZ;2#/<V,QFM=[(D+8KKB8A#-4N21M[\.S)[NYDCQ@6FB8S/HU6Z^.><,W^F1L-
SEa&,5)RX;U3_HAL<?;5S.Z:8O:ULe&9)S+[=2-3c.&YV7<IQ2S/TIRDV;6E^R)W
Ia24Q4._L4c\L:1GIOJ/;Y5MXRM6/SWE_Z;66](K/F#6DdL_K;U)O)URF1@2ISWe
?0c<)>Y6LV(9TX@8898ZM^E<e2E^3bAIbZ]&KW?W72SRQY=2Q4-[OTURK$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert_PROC
      integer updated_count;

      updated_count = change_count;

      if (next_alert1 == 1'b1) begin
        $display("## Warning from %m: DW_div_seq operand input change near %0d will cause corrupted results if operation is allowed to complete.", $time);
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
	$display("##    This instance of DW_div_seq has encountered %0d change(s)", updated_count);
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
MS?gD;?gN?Da.dC9JWEYf,PAJE((QQ_6O9b(JW5B-01^[]H\E),R;)<e0Z^b_DHR
DY9^2BQX[(&R5Z>6[cg>?^JPd>;HCKgM[5W(g8:BbRZY\acec#U_32,\:DeOLUTO
&.A4Q8,8Z_3V@4U6G78R76YDLT-ZE8IDgAY@GIGY7Y5,K+f+#S5?,PFT\8,gEU/cT$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert2_PROC
      if (next_alert2 == 1'b1) begin
        $display( "## Warning from %m: DW_div_seq operand input change near %0d causes output to no longer retain result of previous operation.", $time);
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
    

  assign quotient     = (reset_st == 1) ? {a_width{1'b0}} :
                        ((((input_mode==0)&&(output_mode==0))||(early_start==1)) & start == 1'b1) ? {a_width{1'bX}} :
                        (corrupt_data !== 1'b0)? {a_width{1'bX}} : ext_quotient;
  assign remainder    = (reset_st == 1) ? {b_width{1'b0}} :
                        ((((input_mode==0)&&(output_mode==0))||(early_start==1)) & start == 1'b1) ? {b_width{1'bX}} :
                        (corrupt_data !== 1'b0)? {b_width{1'bX}} : ext_remainder;
  assign divide_by_0  = (reset_st == 1) ? 1'b0 :
                        (corrupt_data !== 1'b0)? 1'bX :
                        (input_mode == 1 && output_mode == 0 && early_start == 0) ? ext_div_0 :
                        (output_mode == 1 && early_start == 0) ? temp_div_0_ff :
                        temp_div_0;

 
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 
// synopsys translate_on

endmodule
