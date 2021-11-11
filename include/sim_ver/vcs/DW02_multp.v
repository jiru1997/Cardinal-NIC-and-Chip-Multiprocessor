////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1998  - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly               November 3, 1998
//
// VERSION:   Verilog Simulation Model for DW02_multp
//
// DesignWare_version: 2febb074
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
//
// ABSTRACT:  Multiplier, partial products
//
//    **** >>>>  NOTE:	This model is architecturally different
//			from the 'wall' implementation of DW02_multp
//			but will generate exactly the same result
//			once the two partial product outputs are
//			added together
//
// MODIFIED:
//
//              Aamir Farooqui 7/11/02
//              Corrected parameter simplied sim model, checking, and X_processing 
//              Alex Tenca  6/3/2011
//              Introduced a new parameter (verif_en) that allows the use of random 
//              CS output values, instead of the fixed CS representation used in 
//              the original model. By "fixed" we mean: the CS output is always the
//              the same for the same input values. By using a randomization process, 
//              the CS output for a given input value will change with time. The CS
//              output takes one of the possible CS representations that correspond 
//              to the product of the input values. For example: 3*2=6 may generate
//              sometimes the output (0101,0001), sometimes (0110,0000), sometimes
//              (1100,1010), etc. These are all valid CS representations of 6.
//              Options for the CS output behavior are (based on verif_en parameter):
//              0 - old behavior (fixed CS representation)
//              1 - partially random CS output. MSB of out0 is always '0'
//                  This behavior is similar to the old behavior, in the sense that
//                  the MSB of the old behavior has a constant bit. It differs from
//                  the old behavior because the other bits are random. The patterns
//                  are such that allow simple sign extension.
//              2 - partially random CS output. MSB of either out0 or out1 always
//                  have a '0'. The patterns allow simple sign extension.
//              3 - fully random CS output
//
//------------------------------------------------------------------------------


module DW02_multp( a, b, tc, out0, out1 );


// parameters
parameter a_width = 8;
parameter b_width = 8;
parameter out_width = 18;
parameter verif_en = 1;

// ports
input [a_width-1 : 0]	a;
input [b_width-1 : 0]	b;
input			tc;
output [out_width-1:0]	out0, out1;


//-----------------------------------------------------------------------------

  
 
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
    
    if (out_width < (a_width+b_width+2)) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter out_width (lower bound: (a_width+b_width+2))",
	out_width );
    end
    
    if ( (verif_en < 0) || (verif_en > 3) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 3)",
	verif_en );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



initial begin : verif_en_warning
  if (verif_en < 3) begin
    $display( "" );
    $display("Warning: from DW02_multp at %m");
    $display("    The simulation coverage of Carry-Save values is not the best when verif_en=%d !\nThe recommended value is 3.",verif_en);
    $display( "" );
  end
end // verif_en_warning   


//-----------------------------------------------------------------------------
// synopsys translate_off

`protected
=Z7;f;@Rb>B=M<-S;LRS)aMQ)0CeKZ6NcCg2-DKWI><]dK/>8fGT7)BWHDgBN/#e
@T/C_e/]<bNB/Q<gR>PCLVI;6b/^d/&MB8)B0e;?0;M?4UF];F()RddDVfMEEXS5
6#6c=VGe8Ie3Tbfe7a]K2>82.;QN3O9\CH8e,S8Fe1-:4MP?SgVQ#YIWb71=9/^C
CF[9\a-Re;J4LO_H&c=5X_g2SXC],?^\N=B_UB,.d77E8B]#[_(BY?UUTYF.72>W
4H5G23YSWg-,247M#[64E698f]\L)SF.PS_(?;6SJ[29ae9gLHX-](LdZH4U>ENJ
-eb(a0g&0BYF?\d]4.0c1DY#1S@SW#D#HM(X(#W4<^:)S;3LDIR-/:1:K22I0H_7
d1e@B?EU^X8]f?O];.:V_dF9dS2T8gG6+1A13f8e<RV#\AX7T0;QQOaT_OC.69D?
H6?LW2BXRWVc^3TSB=d:N/cF/]2&XXNJ4f?><=Zc5c^.TgXVg]b?U<D+b,,S+6DI
W+c?ZE<W/JFb2JJSXC:&[EdS;O)2Vd)ZVK.Y#HLTVFO#7&LcW=79&E.5(M9==9[F
5Te&3J&P,Xb#egF)b/FV<Q_QYFI2Q;HNTb]^I1(W3>?ZM1:TcKMTcHZX=:ZC&.,Y
Ce^.CT:GM4?XZPH[KS_MKUB=A7K1IV8,JAcL6IdV.W^YCBLE/?]Z?UM.J49Ga8eY
V[68=d0-e9?I,H?4\X;TOFR^/Wbg-=2DFB4@c>BHS8e#TDM37aHCU@F.Lf_EUM@#
,)C0gD=T\#T).1Sf>B29-_[=XW75Q1;6+EB^+@A3Vg8IRE-Y0YS(N5\.<TY4&N+_
8]NVO><Q/,A2\)c:?9CU=aBV2.a[V?&YO3XY&0f=_QS>FCC&,D@R\F]AA39OZ\P,
-;/a8M&795-WF?X3.VG7+4-\NAL<eQQ];Q)b]0#0166X),5bd,MI#(\7_+;I+N@R
)fS4Kgd8PHSKB&c&JJKC7-[UW4(>R)6IN^@2IET6T9;>dTBAK#_egdG@:;8-^Gc^
X1U)R^0Sb3>J5=);6-8&)UOJJI0MTR760VYP@,e.=I)<)XV/f82,0LTgU:cQSW;=
fVLd2+)6X&C+ZW8dNIK(21=X4>V=:-R>V[B0<&)K\)b0/Ge/(6)Ld0F?BM.XTgHQ
0?cTI[&&cgaF1gJd5ba^^\#A-1NNXB1W64<D-5NH>MH\DB+-0M#IQdMg63NT;QcY
_LD(1UbG@VDL3\UHNEVA64W/:PJ3Y64_4SRB/W8b+#Ebc9+:AV4B8b2>>]27:LI4
^&c69]A_KFI>I?0]&X@[?CZgYY&&X,=dMIa:R)PIFG5La2<\./0MRLd[6+XT_559
3OG^&(G;-;GV<SESQ8b4I2@?SD;(Q7I@cWbIL_=@c[<-bY^04I^Q:=W(:5\cT:O6
C+K^=O8@;g:Y2X&U/W,2MA\&;C-U87@CXM/=3HZgSLX0M7WFbO1&(-B0G[1<fK8,
28?AK/ccJbDU66/9B7RXR4DcWabSW9XXZ1d(ZQAB5515DV<dM-Qf#)bU:V\CX77]
68[L&??cP=7UJ(V#+HaM+]\P_b4U#L:,P#YXA6L[e@4OU4g=M;<6QcY[GY&BVUOU
+G/L1-S[+Pa&^a3.ceW[9Je6L;C\N5J-1XD6RLSR_3cb&D_B&0df]CK(>[-@4WUN
FDQMU8R]g+.>U5>da;7D2GHPF^>IfZa2L:M9ACgSbZ9:Z+J&e5P#6;UV44=A6.-4
9;QR)3K;Te14UbXN8FWbQ9e^5,KRIUS2K[8PH3G(<daLMc\>IMB(,@[&cG45CEH9
1FN)CEM<,&K>H^?);,6QUCA(;ZOOMNB,AO@Uf@E#XC=gg)\Jd\dIUcAU@a>T8DWD
8?XU8d.)g/XX=2CIF+&-_C;A<LcDI5fBM4YMI_dI-C=+QS@B;R.49]@eC;_bWRHJ
_>4_?M@6e.aRK/f\S\J&-1AJF#fX<7]D\U=N</T>56#DN@YIWW>:(IJ>&)E.V?+7
Ie^-.[/(SSK-78KS9MWcR##K;WI/_dP?+8CV)X:P[+)#a;e-/?<0[QWBZR7,&g6,
;cF.:KdY9AX3EL)cC&/=2?D+E+@I+[Y\E8SKbBWQgUJU_#XMab8;S3M+W,:[&_GZ
CG/W;;c)5RQf6^]RIE_TX:=bC/QNB4:R;.4gTd6>J4G6@BF-KYf^,KX0E3cgKQN3
&b9bZFX>g96;4>N6g.3EL6;/&@^#K=WQbZ,M1A6AbBbFQ.RK++g@.eBZ2<789LY\
HX\51d3>?\N:9IV,U?-Y9.VTGX/JX<8?3U(?AN@BQ+ZRZ4U7]IMI65E1^^Z(f=?-
9NFC9C9UZ;gGI\J;FK=MU/7ZK]g(#=]/Y17S\e^;>O/(K)269:?cN^@Q/&9F]@?f
b.A7fUP>c0ZTUFK8_PS1YfEf]59N7IUWaYLgX0132dNKW^>>5;A;-DQZJD+SWYC]
NY=XV4HPY+\D_XMW3U>Hgge#:=MIST?D[&4OEcW&0b8G2_[DE5&E:=W(3HL)f.\)
W\fdCb_ED/.\T,HBEYJ@1HF,0QWOK[75Q),&RV@/?8J3^1JQ;3&G_2/#BT[bF?cJ
3gH^9@PC;aCL=W.efVdRcM1aTaZG:_7F5;GQNCYKKFA@=45CA#Y_VMP^>N(/b#)F
BP#fA:E]KWC,<c9H=,KU#D@Z<]+8D()g(4E>PZ^2E(A2EW(eHLLaa;=](WC9BNN>
,aZSVYU,K:QH+6#6BRY1gOD[MN?U#D9MN[M=5?(//f-),Zba<.,WTQ)#+XQDe>7-
M:=C>RdLY)X;C^^+])GaW#d<fT<SHL,)[3F?fXLDE/7b-P?N6J]1IJPd2B-.-\=A
;;:0(F9>LDcN]fPTM&.@Q-I<(Tf#(?@DFaJ/]=AIGccI.D>X,YIZIMd8==#I(^7)
>CSe6QAX<@ddZNO&JFYQ,E,>N(R@4NV@M?PF^HB2EaBf/@8C91?HAZW8GB[#f+28
+0BcP=\&3Xb]3=E2\)KAb+Z1OP4MfaOE[=/H)UW1MBU=;C;)GSN:7N@OcJ7UK/\7
]7(Y.<DZB;WAD1_W.(Ae0\;HfceP\NcT:2_5]6T]]_BQAJeD,G.fVJVa-67@:V4M
K.J=HRLC\FYRNMRF@I1=4XQ2MLYXHQ8F0O3fEJ&^E^518+LV<Cb_P01QeaF=YOPI
T\a/=D3+.X<(>R1G/Z[8XY>]B@(gSe[)UCZ);9XTgbEbESPR+ES<a[c2/J1ISGE\
#Xa@AJ=9;ILUFR,H<L3#_B[eWd_XB3C::HL^QaTT#E@?LPBF6,OP6Xa\B#L2_dfP
QSIMT;2HE7HaeAcPc3RM?C[=Dc;:8O1)^b]-SNe9PggR&R-9KW.:AEXQ,CGCD.+;
/KW2_+F2(f<(3^3]P&PPSTSS,(b3#)e)VC<?^_b1PXK-,/66J_7d/+\-JZ0\4(\5
5UgHTY?<K<=ONP;;1Z(D#e4HGZ_?5GJC1DOZMd\6gRWJS?HeG)XZ7\I0TG[6ZD;=
?N(f=)X[MS/^IR]HVOY#O_IWd/O36;b_3,M<K)=FdI.V6?,:DRfZ,A^BZ/K,]_gP
(K1@,@W?AMf\G2TT5[?&-8OFe:6Y0a?KAJ3:L(IKSSJ9L7ZO0.MFZ@.VP2W.W<:H
)&MH-4_aA6<\>24-BWU^<)c38PJdB1I@O]<6<>S(#eF4Ab:6>:g8aa#?N-?Pd.)&
O\G.R]YgJ(T\&M@8cP3QNPQQN;6T^=4Hg?B-46DD8a[H]4GI]?QXC/68Q4.^5BaC
P_d0_G/8598>JOCD.NVTVGb\_<JO^5&8RgLZI5g^_9GWOEI.VB2Z)WIY1S1OS;>^
UdECaeJUKc^C;I3cf31#MdWCa8#Y<Z_b<^5<g]:>LUX(&>/D:B+LA1:W?cb3OT7f
IcPcC&e,6(4[gRaAfUGgM//dSIcAI+JPdJVfF<QS7Y4Y5gX4&JS85M8&&P@3_/5S
0YLG;88\USUe)E7M@3BL;R<9XR-,I->CP.=CA?K=W:?N.MPKXe5J\S0eT:OLVZ):
fDN>]cZ?/VCW70Xe3//R+S-F&2;FR]2cgJZUL9>+PSJe&_=-UCI@\,W[DC7M-+[O
;.-[eA;^R<&ALHW]EOgM/2D#&4N@ASK(,83][]49a:V,-\8KL^Z2Uga7WEO-JN2;
ZBKdYb(<aFU9IDEbM^6Z97=JG#V:?^&BdLY>S;W8@+HG;L\[Z71eE=bd/Yb3OKD_
)D>Y:=Dc@<I0bEOQT)E^DJ1&@OgC>1V^GL)(7,/KS/U2f&>+57I9@(\L6K5_6G(Y
B\-ebA-fbP]Sda9_6<SSHFPY1>BFKL&SY(@.e(dW[BXR(L.;@&>0&W(<aTWTN&QS
7D8c)aKfR+(Z.df#B.9dE#bCQ.5R2Q,)H[A/Z01d>?;-e(CQ]HJ3AH#f_F.@8@MB
?ODG4P8?J0<>J6Oe+3H@4Ja:WfH]g&V_(C;HK7X[:;>c]-&AP7G=Uf<B];]F#CGe
(<Lf&?M6a),F?/\=c+?Q>>QXJFM.M54<6)f/V266.&+]3E+EY,<6K7RTFeY@=a=6
dU-9D])01Z\1#WZV57JQH\^]5S^UDB?Ya<E.WM&L,eD0N?e^.c6c,&.+Q>Y<CKa2
Ua(dWSO>+B&\c5g:d4/YCABQ7ZAP4+WT_dc=97Q[635)NO-RW+gJaOZYLU#6bOc5
8[T?@U(c2BYJH0?Y<\/L#7g)ZDONG3M\N[B.I@1T,)BR.SLP873TF1:]VRd4Dg^0
.7,Mf6)=_;Y88c/G]HOOWEN?53GW58XK)XKU3BG&LA68YIC8cR>e)T^1Ba?2L@,)
D[>E#S(Va1\ZZ#KJF0]RG&CC.0W#N=b<a9)#8.YH@>Q5;T4XN&Q1^=c(_S[E<F4b
01=1dAZWJ[];+,KL1IUd)QKQJ2dK_Hg?5QGR08[(MHBDY,@Qg,U6c0>/YHC?)EU6
Kg#d8(NSKg?6RR\OU]Cg_NZU_F9f=SU(acg0(G7N>E^+QC.Q.]H29@#]2T);:M6b
;[S6A=08>_^:V8[)1<F+T8<I195[^,/[[XN60#JI13=:#&[NbMB1KRN)-5DBJDaH
e_@P6>&Kb7OHBPD#BV2db@,F7SY&1_3/HG@ZR5.ZF1B3C\L#7efP\+0gR?BV/ge:
04.MB?W@)E;_SUfJX;72eg68ac<_g[OZ(3DH#.2@JK;cMHKcPX2HO00gd431QN)S
N.#DW;RRd<RKO2Be[;6g.2@]RD<F>>J_&E<1FI1eV\d@,Qg5;C(P:;)F5[LX#A8]
T5PC/,BRag(B(_G5@/<./F&R)@<K7+X88>>O-a,(QU>LD;:00C75\[PO/](2gefN
\R6:B<Cg:DWVOG2^LJ43c+ES/&T)+KMKdF-g3T5H:]#FUE3Y=52_EW]\]dLUS5RX
(),@fbT2HeTbR.A&8N:JbEPGcM>7=T8#]ge3B>aKM1Z;QF&2e:-^McV?=0_:B>E8
#9<5O3-;?1FKYE1P4Z3/Y\YA?90-_Z7P9.@>T\B=]g4bg>]b&T@?.HZ90JU3dX>V
87bgT:QX)&M)1.#HN1\M3U[X0Obe]@G/PD1eE=ZbaaJJF<K2Eb[gOd:6\#E.McY]
>26HNKJQIZ]acbIBV.]^DG?ZZ[QD/1-N9BQe#=08=b.JeeXOOG5IUB^5>fRUI(F:
_;cIL6PRcbV,5WEDMe=8He7>I^-MQ^3H9a^M)BX9G7B5DKK8:&8FY6+:5L;.PN4?
8D1BE(AMNV.f_7Na0g3ABMS-_2;e8&2JQ&6U8[LDXd>d;96N?[H;b3G+V?->S(Y=
[PVNW]WXVN9/0C3VRH0HWR.+;7EZ7c[8+_>2-#8/#A>VA#,d4e#]E?@/040>V#T1
YZGKQf6;8UcODHH\QJS_5&e4T?aLU.P7KSI0ENJ0g9-FdN<Q^NUb;W,OKdeLYeQ,
dR1.H=B801+<;NfDW?(.AM0K;CH+76Z;^S@D?FCZ0840,S,I=dTCSVb\)5<,U46>
(a+JMAg5@Z_4:_F6)5:.\XXW=)W4RT#+VadWH@4#X&E2&DF@Q5(9SGaJ<2c4:84(
JL8<:aD0_)C>bYVb1YRdUR0D/Z1_XF(/Lb]8#fZ^LQ5#+N8LKYWKBdUd=/#LUI_3
,QA1,bC:<8+[3I_Z5J^3bJ?+RH;3B<1-FUJ6cM(]1ORI;)WcaQEPB]]++VMLH@Xg
D;c5.N4gS8A:6cdYeZIO&CJO1IWcXQ:0=DE#8GWD;H@accX@T-bc_c.>EFb6[0+g
6D)F>>;\M1KI&Z^>S?N9Z<@7H>f4;LIX:MJ5eOd(5#K\P/V2B/C@^LFPQ>14F(6\
8C&ER]?SH4?E2[G-J^U_@#-QZaM8)OQH/0c),3=+\Y>;V8:8?AL]gV4P5IJ<(BHN
#e@L[[T7LacI?A?Z+c=8#33H0Jf@WI.=?-YZL)TBVYY<0&C33NfRDQ_adVW;UDWW
WF^<P?=?K47@K66faGQ</&Z7c,AOZ>^aF[JS[OWDYY_]K=BV(4W2E@Q](TU\#(X6
^f70EA5HaHO[&(,F@0(7/_U_cbU1Rd#?Ed]<CJVTAGf38d78[UVeYNKUC:IJUX&@
58DC_+TTNJT([35QfH0bK-E8>6W2+#QKS2;02a4OOEY]E9c.@V-2_S,e@=:2cYG1
8TX_;Q7@K@#H_=.>9DHF)S09[PSZ_JeNcO>gXaIb6V-+Ff=-4D7[O3D,H;(WN-eI
Q-BXPFB#(eT9S<Id/X2/()Lb1)?_e3<TJW<:\+BTO2gdIg5-?_AYa6C3CSVde>5K
>>dfd8)_YU>9X>55.Za2ZPYIV(e0W9[CIb.[EI2O7_LFJ(&OQKaL,2?+d6M#0Ie.
6&#34_f9b3A]U)JR3;]T[MZg1V22>JKL_F?e#JgC[WF^=K1NA=&PED=(7O:6]LgS
V^^N@EA5gB^/LJ.3C2f2V/TfbWQ5GA</2F;OCF?>).Q:7>JG:@864<NJ_<ICTSUB
5PO2^?(f7A5[VYJ<fGOS^Q#^Y\>de#VCXG/_K)+?dcEd_&agQBY3?^L79QYS^I3Q
:<cg,&8YG#5QX_WHSa3NU6g0IYeH2P9@dE&8WE/@)3TaE,P/0R&P#FGKe^D)5V\P
I71U[G1\f+dJD\T-=4IE0<:eR=[=L=g5)Y1KZS0GF8>aAT70U>[]2FLAQ0:Td#Y2
f+1P0V#G9@>6gK-RWGa2.P8[1GbK1<C1F3MfOZU]V(QaH$
`endprotected


// synopsys translate_on

endmodule
