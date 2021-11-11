////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2000  - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly        07/28/2000
//
// VERSION:   Verilog Simulation Model for DW02_tree
//
// DesignWare_version: 68f640b1
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Wallace Tree Summer with Carry Save output
//
// MODIFIED:
//            Aamir Farooqui 7/11/02
//            Corrected parameter checking, simplied sim model, and X_processing
//
//            Alex Tenca  6/20/2011
//            Introduced a new parameter (verif_en) that allows the use of random 
//            CS output values, instead of the fixed CS representation used in 
//            the original model. By "fixed" we mean: the CS output is always the
//            the same for the same input values. By using a randomization process,
//            the CS output for a given input value will change with time. The CS
//            output takes one of the possible CS representations that correspond
//            to the binary output of the DW02_tree. For example: for binary (0110)
//            sometimes the output is (0101,0001), sometimes (0110,0000), sometimes
//            (1100,1010), etc. These are all valid CS representations of 6.
//            Options for the CS output behavior are (based on verif_en parameter):
//              0 - old behavior (fixed CS representation)
//              1 - fully random CS output
//
//------------------------------------------------------------------------------
//

module DW02_tree( INPUT, OUT0, OUT1 );

// parameters
parameter num_inputs = 8;
parameter input_width = 8;
parameter verif_en = 1;


//-----------------------------------------------------------------------------
// ports
input [num_inputs*input_width-1 : 0]	INPUT;
output [input_width-1:0]		OUT0, OUT1;

//-----------------------------------------------------------------------------
// synopsys translate_off
reg    [input_width-1:0]		OII0OOOI, O001l0I0;
wire   [input_width-1:0]                out0_rnd_cs_full, out1_rnd_cs_full;
wire   [input_width-1:0]                out_fixed_cs,out_rnd_cs_full;

//-----------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (num_inputs < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_inputs (lower bound: 1)",
	num_inputs );
    end
    
    if (input_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter input_width (lower bound: 1)",
	input_width );
    end
    
    if ( (verif_en < 0) || (verif_en > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 1)",
	verif_en );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


initial begin : verif_en_warning
  if (verif_en < 1)
    $display("The simulation coverage of CS values is not the best when verif_en=%d !\nThe recommended value is 1.",verif_en);
end // verif_en_warning

//-----------------------------------------------------------------------------


`protected
=Z7;f;@Rb>B=M<-S;LRS)aMQ)0CeKZ6NcCg2-DKWI><]dK/>8fGT7)BWHDgBN/#e
@T/C_e/]<bNB/Q<gR>PCLVI;6b/^d/&M6.G)aI<YN8+dBP;d:HSZB.aR,?<YIM5)
1UMZM?:P&BHd>dU-/:,8B-9ce)9A#cVR\8,]>92[,[9\VBAdaU&-.Y&@9MR4bIc7
_&5Uf4=ObbLeFeMaGX(ZU(S)8E5I3cUMVB5I#_eH_2>_X&T,.OR().5?SH_fV1fI
bZF)1(;DZVBfNLFYIXHeUQCcJ3(3BV@T66WLSG#)8))RQX;d.8g)BB:G(#Q]T@K5
P97WIR;Fc)L7.)NNMT?LQ-D]OD5e+g1f?,11Z[QJOTQ&&V>#_D&M^D3B/RY970BA
G)cXV(>Zg3Ib\XdIC2TMH&=5P#gGDXefLYP216;;]Q?>^_L#?.KX4<9:AC1)B=^5
<W_>9/J#=YeWV^5>1Pa6JULDMZO@4=BP;GI+-Ha(A306R;C,:R/a(9FS<XN+b6BP
?c;X[K/2Xg7_[4N4L[^(KOe4g8#cMHcV3)K4Q3H5,MQT<PdaA2/5_9VXg\J?]TZV
<ENU0RZ]Bca<]59gO8LI-\WMW^Z=)+0FO96E+4(eOJ?9_7U&Y^0S?R:KJQa.g)e1
V4ISg&1L>E=(=eVV\V5cT6E(8Ed_551W\?ZdRaVA^71Q+B/(WF)&X&gL@OZT&6U0
C<c>LfRNIYa)()E#^]W/+S7(:-+d9)ACSN3--;)N[W0bYVTQJ]1@&E=&.])a+RNI
[59SR6?8EN#FM@)+NeYL@=W/Ad:Vc05aU>RKJ(JMEQ.K&Y;&5U?WIfA0M@Qa<1e8
=5QX_F>4/S[D9&a\Y8g_]L(6L/03PK0+Y@cO-:9TA=eEO?/g0.S/X&YCPL.VGgb3
+Kg.:3=B_[[g#<A,O3=AHH.-2_5>FL+JEF,]b_V/DC:SD[O)FP[&CW>,AZE-BMA]
NYV.4gM#JKQYB)Q2R5S-U&[OTY5X>EgbMY-1@@-b\SB^L3Qd9^6=RN#<GALD,2WW
]XT70)<KSIFfaJRZ8)CPbWIS[-7\(6[@E1H#_YM69X>CXCG_aGM_CJ95W7UQR#:<
dWN?,L9TL()Qfed8ad\SXQc2O@9KZVaI/>[))b;XUY@L_;N/JI<9Ka2@ggNF0I,1
#,V#<B59UO^MZ3A^[\Jdf[A3.gOAR[?>4]_H8_=PN@3MgM=[c(NHf&MJd5=3AMWM
Oc>56.?bRPdAU^b<@(N32BcZ_L8UCOF+JQ_4a+aQT6&.,3<EX2MT?c@Q]-9+NeSS
DER\DSH4O=MONQXVbPK[8ID>eT^DXaCYW7+[#)>Y9AG2gQ)B6JE=@:UIe]&32b_+
H:(L((b0M@O16T;4/fUFAFdH^@?5/Y<IfMEP[+W.T#_F:ZBU/0g<RWcbI[GUg\#4
H2f/X4:Kaf;b)-g6/I^X<L;&d0d_6Nd_]>WQ:MBRTb?H[f>=@TcN1X/\;#.fQDXT
eN9[@O^@.2=(APOG;>gaE\ReV3Pd@:5J0<?>G5A.&(V^M/R8-_;0U=;@P>T<M(^_
O].D/WF&JT]Ua=\9Q3e2OBLN6:J=#_\Gd?:5,d\IXL6bc^\05AE;X#@19P8]/<^X
CEPL.HBg>?LGR(^9IL@C/G,7(WFS/)FUf@_?L^J/_B@YYDL2G()ec&6WgJ;_ATSc
f/.Wd#+Z1FC,/M]P_K\BMa?55-@QebN7]&^\WS_97ZFTZ<0JCSMg@E;RegA.Oc<7
<^-;/Uf&VJ.LTF^0\[XR=73U.A/Vd8(gWN.RE?2^<BTQAU=UbP=6dX,Z1B.D?-57
.[68M1),(5b^Gd+KZ_C\2fG9SW6&[HaVS\PZ;T_O=IC7)@<&eNOf]gPNFF]P(b4[
G+)&GT-6E7.A8E^ES?@=#N4[T@T:1DFJ5F.4<QL^]1X59NL8HQBAA;2e&YP:adUB
P[8C38KL;7FZSfF7Y7>LRSGg-D4RcXaH>#_9P@:#f]&&=O?MH6.49-A^R5-<[-H\
OWGMQ3g9Z7\04:3,#ZP&:I==N0aBD&^1HN5:]f?,[JJ,&ESRWD7CD-fY4Xe&+ZCP
M9?@#6?bCEg/J3acW3L3<R:S[WVQ.,[E<VV^Ic3ZZ3ZTQ6eBPJD/5=O)(3>4f/XF
9833gM1K\33Ff7,MbDY0XD?Q=O;1(-eNN6H6A)a=.2AK6C=APE2c[_S@2>P(<+T[
V8VYX23dfQVV]&(?OQN7VL/BS;gUQSI7UDD=TcNZ6HROd0RK@Y>UX(78Z9)G[H9;
g+f<cBPE,J&/-3T:QEOA^3VfC4b1(c&NRG^A2ONgA)UDCDW4V&X2OM/D3bD1.\V(
>f7R_bEX^,,eU]\R5?6gcKIA7Y[CJfY)V7RBUXMIQGDAIQ#N5=JVJg5-G+B+Y?Ld
#MFU-:_N>CYeP7;G,T.ZSa[.9<6J[4XHP/B&8;Xe#b,VP<WL-QUOgD:OFEfAc-b&
9HUM7KIBaY#N9KU\5g-\9^HS&gSS\0C#/XNgN,TW/3SD-e[8ID+VV8?@5/(8b?:c
F@@-J(/Xg6R6GRL@J)N779_FK>,2#E<\VJS3ANME8>e1e]_\U]/E7OccgQbB7D/Y
@T.:S##.Ae6HF@7WS?.>fA5P\[;97a=d_ZBab=N@RKc&6DU@5DZ0WZ1b;4^+f:Tc
?d>GRODNY4g+G(gI\#1@;Z:B>F([IDITNRI1Y#WfdQDd.FJTQ,:Ta9INOH^B3<(C
Z3.,0Y(YY3e#R-1Q31^1<7OMV^g5ae)g[N:M?W,SUC;g9M2fX^,VZ&DaR8d^Q70N
.,W(D(aO<(H,M;^YXVbXPX+^;3P\XO7dB:ZfHK.Uf;V6?cXNfS#c8YFOI(GTKPH6
9E-dN>_HT7-AOd/Gd&eYg,61FYSZ<DI;F+&#NJW22cK>ERECJ.YCJHd]-0#0Q8M(
]@&@;Ic>GPfYAHd]XOYdIaDR3-7S4c_dJ@+fE>YP\^0\1E)\dDfa&1O]#A6:Le5G
HV3G85=]VE_<F:bZ8K]W,B;+NB?XgCe=;HT0=)S+;U0Pe3\#c97-DQ,?fO#KNVFD
)/R&M)0aZQ^aS/U.:\R.@B7[Qf?ODKIe,FFe8]L-<Y1DS31>e./,F;[#Sa@MG5&)
Q,S;^TK/Y7(1bfQcab02J&K1)N[]+d2bcD@SG])(=^C653aWb)ffUL4_H77eGBIa
BLQ8@.fL1@.DZ=FZ+SM#fcR,VG2H^a53)G\4S+E7JbFTLM^6#_gEgD\-.dAa_#BA
f6cZO95ggJ>cJ9ZZ<W2SQU?#^S(S=JLH\2E(^9UY.C/;:279M[\X?YN^2W3D68BW
+a812g?.@;[a]fXa&#/F0g,_)]3K?,D^6LKK:I?AeS,>S;JI+^H0-Z^Va72XU-(1
:O_=QRW(Z.2KWV8b,=N7:Y#/U7GLe2];ZRU/c-O>a#b07e(fO]b?gGY)gRG9A/b+
YGg7TdId[MD?I)LZ@c+VT<b0AdDC@\:\QNF71M1YQ?LfDB]@BIbPCJ#cd42G)9U5
>Z1GG<^NW^2_52#,+@L3gd/)c.cQ9;=1(40RTe0Lg;c_g2@)=Z#:V)#=.5OUZ<[W
:@2aDfL;_P^PCPKT^GNABd04;\K0JQB+GQ,\59FE&;Va[D>656=WL\c=eZJ/41J(
1bE]EbF-Pd8L>9FeFcb][Z&QfF.F2N#<[0.b0eZ.d+TZQ=dU(d8Be/(:-(=PE+fX
W3)aM?)gD</3HQUVAU#F\YA&-(O_cDS/;\fKQ@>@KYL.1TZ_aSKW<TL:CWB+e#>9
5<[T1aN7Z#gV=MBYO^>516/37.EWN9>G[;KQI,X]WZ0K<fT:A3#^U^55O,?>eP=_
,(>[7;Ed>42P.[f,Lb#0d>/VWO+@C(;1;>X2W;,(QS/=cS)7SRb5H9c^4^24SJ4L
XbW2WSJR+N248YIRbE:,5\0d(NgJ1g3NXJGWg>TV)>c=F$
`endprotected


// synopsys translate_on

endmodule
