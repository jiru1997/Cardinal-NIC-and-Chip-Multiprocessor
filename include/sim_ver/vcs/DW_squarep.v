////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1999 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly        5/17/99
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 94879af3
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Integer Squarer, parital products
//
//    **** >>>>  NOTE:	This model is architecturally different
//			from the 'wall' implementation of DW_squarep
//			but will generate exactly the same result
//			once the two partial product outputs are
//			added together
//
// MODIFIED:
//              RPH         10/16/2002
//              Added parameter Chceking and added DC directives
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
//                  are such that allow simple sign extension when tc=1
//              2 - partially random CS output. MSB of either out0 or out1 always
//                  have a '0'. The patterns allow simple sign extension when tc=1.
//              3 - fully random CS output
//
//------------------------------------------------------------------------------
//
module DW_squarep(a, tc, out0, out1);

   parameter width = 8;
   parameter verif_en = 1;

   input [width-1 : 0] a;
   input 	       tc;
   output [2*width-1 : 0] out0, out1;
  // synopsys translate_off
   

   wire  signed [width : 0] a_signed;
   wire  signed [(2*width)-1:0] square;
   wire  signed [(2*width)+1:0] square_ext;
   wire  [(2*width)-1:0]   out0_rnd_cs_l1, out1_rnd_cs_l1;
   wire  [(2*width)-1:0]   out0_rnd_cs_l2, out1_rnd_cs_l2;
   wire  [(2*width)-1:0]   out0_rnd_cs_full, out1_rnd_cs_full;
   wire  [(2*width)-1:0]   out_fixed_cs,out_rnd_cs_l1,out_rnd_cs_l2,out_rnd_cs_full;
   wire                    special_msb_pattern;


  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
     
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
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
     if (verif_en < 3)
       $display("The simulation coverage of CS values is not the best when verif_en=%d !\nThe recommended value is 3.",verif_en);
   end // verif_en_warning

  //-----------------------------------------------------------------------------

`protected
=Z7;f;@Rb>B=M<-S;LRS)aMQ)0CeKZ6NcCg2-DKWI><]dK/>8fGT7)BWHDgBN/#e
@T/C_e/]<bNB/Q<gR>PCLVI;6b/^d/&M4(ZEF)Jg,Z6F01WIW;]TOCYK9=<9#b3b
4_5WM(4)a&#W+99]&gAGZ-c)Y^&5.N6G^5OHcYdA42B&Y6HI#@&<HZ^-=CXO<M#U
KE0.L6(bL.K/TU60Ga@d4;J)TK9IH2XaW05.PQS+5a8eLZJYU:QF22=V6]1:J[dE
_VU/5HQ>S0ZMPUK9cG=[+>C62CNOaHC2?^_bRK[a/E3W_7L1VSM/BId0FeYEbbVB
J47]X((6eG]DfR@)95;1\eW:P5bD@8b<0S;3F900@4K(ZJKc2-MEWAI#QZ>EZgPG
U?d##;eE-dM:C7@634T#Q1=WM)?F>H@39Q=HEM_F:Xd7c4dV_4Uf60BB8E6eO\3;
8JIJ(H]B<Odd;^,AUNLALMF2-GOOH3WMLJTZ:CIe@[CD=?Z^ISU(]-ZS@I@c8TY0
Q(eNI/#1.2>,V?1a2aBH6SV=+WJ2^M^ILEA3/C(BWFa1ARW@XN;:=)d48AgIA_[X
]AO2TKa>^FQ9<QSEPQ;B&4S8dT65BUF.d\LgKRf8SG4BcZa-H/Pg\9bIFR;IfMJ[
cE2@^14d<:aNV-J&]-c^^Z(ALS[U)U?A>eBV1]AQ9g+VIb6MU8U5>T3YS8#f2D?D
@[DQAUN^H>8:PAfY3L=Y542SV6H<aR#c53>_#-BJbRT]U67(7/BWa[5^-XRJe(/D
3@Cc@FQXDZ)78D=RBZSM)A5[^L1#QH/Dg4/[W-DI3HFR=6V40aZ@CSY>QZ4-B_e.
ICeP(.AI?EGUY8=_E.ge[=#cI_(-M?3:)([aRbPgG)c^M2b_1F&VR?9<(Xf8#fFG
2M8(DDK#&WPd>E]M3O\M27\E2N1OW3X=b8dV#7Y:FQPLcg]J5H2c)4Adg=&7_.24
>Q2AcJ(+A,LYFNT2?6(@\+PW7+DTR@D?CaCCP+]HNK4ADJY3L>(9J;JH#KESDF8Y
<K8<SW\E#=VQGF]_3XVW2@+=@63JW54SPJ,=ag6N-W+]CJZf.+7g)PN.,@GFM,E,
0MEJ]>4WNN.I]C6K#&4;3=+_a>>=D?GZ>\(0?Q7^V.I974#GU#Q/^eJg1M2UJZ[O
^fAR):6#7T_JWF47:-)>E@JXC]9T)[CTT\b>(;5YaZWZK1OE)Qg4GUFE8XdPQ/2:
J;YfB]3B@6&M3^g6ODS5Y:.&UL\Lg]Zc8/@eOdEFcTb#)WG+WRK=1/1cIBfN7[7d
U7KWVH,])\fXJ=b^S6L@^-H@bG5H/NE[._]GV]N2ce:^9AAYIf=BLJQ1L?@2LF>A
O/5S5USH;LZX:_R],-_gP_-XYLJ/?.@Sd1&L6MZF5EO290LPZE,V:^>E?EG4;+Mg
O04#.AD&8+CP1P#J#,0A]8UVXF5^6B,@e^2R<0Q[I/6G^\8K19^K;3F^?Tg,=A:Q
L0fA.:&E5>]JI82e#N[3Z..XCT2Y]V4A+&ba6KLY-+LQP:(f/e(\H[G(/ff7-aa\
\We<Yg+A=&=YGTZbT^V;.0A:;;[bc3#IY#ECNZgVd-VPGO(2a+)Fgc\ZR[fU@ee?
fVC#OI/#GbQ1)LY=+b88Rc[d99e5:SV;[\34J)dNG\UF5-92=f&8e\/<B<9TK?8e
8@(HZ=6G&4@<H_L:W#LSC+Q>KV7Y5S(Zc4U4ZfQ)PTZ?A3eFI3,G)E.#]+GB94O0
[eX1,1OJ=c=NHFR.Y/3NCeEZ[=?TQ^?YO^G-?gb[5;-QbC5?#Rc-U<@NAMR#;YX6
8K;7@+NEW^;-b(>2Og9T-W#a]DH2_be-S0O+BC15=TWZeEJ3gLUMJFf1B^T5)CK>
a?R)<O;6W61U8)=#R=[[eX7<>K+f_Y_>VS)dEc\:N7<H_dQb;bbbUSSgJ#GW>8&W
X25C;:O1^8\8;ccEUcGRR]^EY5e^)(1Za^_?2N8fX=ZI2\W81fcge51W:R-F->7R
#?#C\KI4gadPC<_WLBJF9#N,b@eWQ>T08:0BH(Qc5aL[+PF(7L4J+@W,.]-)S1e?
@Pb.J8:O:Xb4.E9UV89[(F@2;XW3\8I+A@NYF?I;bZ4J1RH?K)K22+X2CeAOcDRB
PCJOYEKLW&GB,8?=c^X.K9B^&V#&Q2eEMIK#L</AXW?2E=dPd3G,X&],&G0HL?):
^WNdG;77\W&&IDSe6YFK/8aVO774[;Oa;NLUES00+g?1@7OA^IWgJQI/Ff=-#V(7
=e0X>Ec6YV^7+;bUD==WQ&a>0;FSAQUAFD6Q&=PVH[EKBOV])CJM<b5NRe<R\#1e
FJ5SY=TL9VPV5@Ib\LZ+\&.0Z\M(#S)c+U[\33TD3./[7R+C_Gb0>)EY1E^)gbdI
U9/Z,#)QT)O1d23X&G6FW3E?fC0(M=R8Q)EK7W:_O9c6UUW^U>HBU9E)#8O+-.dc
-)N0Z?SQQ=g;MXRWS?6ZZA1EbeCc&\6#OM0Se>5,,W]fW@c9M1K/\8<ZU7BN:G3S
aQcC?]8D-0YJ?MW)MeZ4d[5-^3C<3-JK^8dU+IHWV1^]7g/1<P:L;QB^5e60VM8a
d,N&7-@#N)TV;eR6C[e6d0WMG7U1CTegI#G0P@Nd>b0g_5Vd>AX9H?=)_<BI?=-R
;SJ]@OBIAN;&aN.A+Q9:D.LLW=46MXP)T=VX]&Qg)YJd?>L?-Uc@J(fZ)FD+QF9A
-?I,0=>TC[]C-C[S0gMg-5N.eSY_CIY.B#gJZ6=-e;<U/30I[f330DM(^AABI^ag
IQ@C5UQa5?]EMAeN=^I(Y3VNSE2OT;EWaJ3Ig8QgDH1eWdONQ^ANSB4<e>T[bg>f
dgW+8FcH^P\B29\L<g5:e^PNbG_3G:\G6eKJ;(BAaB)C&_L-30g?C[7Ya[#X;7\Q
@X)F?9_F5UdT=B#D37f[5-A(#-9NRM2Z6,?]5Q4??SKH+_G:&ZC9EQeNePMBM\-K
CKNKSJ+(RWMO@K:L_bN-:AZ_@&9L.[Wa_#]GVb@/U:TMLZD0b,]>KO50fT-34_Xd
\/@(J<)ZE]#QgW02#Ja\8_Y)I5))&BBKV[ROL-:#ZV=c]GCfgC4BHN]U:OeE=,^M
1,>5ZGCM]XV?ZYb)+,.5.:cR/9<37/OEX86I]NcEd&BHcO;AZ>E<McHF(7g7/A[Y
C>[:-F(aW/X@?]VK0=ZZM8P1@KNV-@d@22X>[IA@^PdE9J.9(_CI2A>@42.Q)YS&
[B9AP-YRV75(6+72DMH#/KST+.=X=WYL@\-KO7eZbY8NZI@Y@G:+3Z4J,#IO+T#4
_Oc)9AOFY8YLe9LZ+D@8QZS5H_e[;PLJ9^U[&CE4(aB<R3]3?=3Q9be3W2FY16fV
f7M2+Q9\7T_;O)6S>NKfIbCbfX81W@6#GObWLY;MNENfYMP>9BVLH-e;=4?XKH8/
S5I7:1GX1;[OLT.LceZ<A7Z:g5DQ8SYD&@Q#;3>A6e@Z_R;Gd1;W7U68^_c[:ZgV
=0_)EdND+4V6N4A24Ga/R//G+)eV:NW[YVc>FdUI#)DM5[34/:X<7OH?EId_LfT[
WX^W&RP>g@G40)LbKX&2)YGM5JA6RQ]#F=RAUGOE.&-LQLRWBGUX>CIfHS.=HQ_H
e,&JLV&@&?C/D0424]S4KMRE1]&E@[JK_6@B@&V/VDU8UVC^TC/0Jg=0UCcG-)BD
XT4?^R1ba[bQG[(EAK;M7b:E+&F<9L6:E;VY+42-b?GFYY\R,de#Ig5;L1PG(dDP
2>Hd>SaVDT(0R00N<DZZ/AQE/T-;F:6BR13P=[9Mc71JWA_9GU4Q;IZ5#,QLK9RA
gR/VDdD7:\8L,Ha=5M:eBI1R)_,-+557H.ZfF^I.(3@E:^XdeYPT9cd?][P&9CEB
2O,56[Z0,V\T\TgfWb3_:+H[]<THJ4&J+?7_?@:FB9N;;]IVa2CF;Q\<1cM)A&MM
;B6f]b:Af,19Fg:O7CL_fBX)f5ed;R)/[=.gSO=..L<J-O2T.5e0\0)<JeEeaB>5
-g8WPUS4eASM-]WHMbfENg19^WSVW[@caOLf3.^Y+_E3XXc,64Oa&Y+EfA.9DN5U
JMMHbB6K,(>fcI>2VP[.WYV@L3D5=6OD6^fAYbBGgO=Z]Y0YN#GL,V=^/YWO]E:#
:d6aU20J.7A-52IPg,PCD;CL#+fUc@Y\QICRK6RMS/X=(aXB;/L>C,/M9[/+PZ8a
8a)D1TbcZS?VMD1?_KKUM9#W>]ga+T:Q1eB@G=NFXLTC60e/E@_b8gWV,P;H=-4R
_6c4PGIAU^^)\>b-ZD<UO;RG5]=@+_WJ4,+<O>&A65D\:PIPGe,#3=.K#>8Z+,_d
&.3OMS6RZQ@+5LF]e2UYUT[-\XZ>B[I&_a1R]51_Ye+2PFfVE?XJ=1YKYZ,^Hb=a
N:3SWBQ3:9e/.aUV&aG<5C/H02<;J;Rd]B9=CE?9P<RTI7db)S\[.7&59M)Xa)8M
):K]]JMH9?B]I;bQ[Q.YKS75:<R?/HI;1P,e>T?FX_TP]U?X,NSgNd_NZ+^HTE94
:?,&f,XgZ]M\YBR,S^?3@g&Ubc(=ZbUdB>-L7=W0-5[AXKB@N&IMLVK,W@BS+PA/
,)/2:O@-cRT6d[T0_bC8:,UALB3@:0CZ,DCMcH-QP^dMb]GB39AKISXCaNd:<:4@
I8E8UKZ=b]SF;:9V+[F=LXT1^BWD(M)UH_#Qf-HQfW&DgH#-fY)#0C<#X>X7I]75
=K)1,:(4OKMTUE>OR(1S)3Wc-c1@2d5E.>8Rc&GHOK4#)YXGD1D7;HACJ]>ZI;@<
4;J[O6g9Kd7O243cG;AU&4cG.<DP8?U_6Ad1_3dWD7C7II=DWa-::N]..b.W@(@1
c/R^Af2T3d<9\<^Z.,_=O_a)7].YB8GV@YUJGe3SOI^6YVc@M:/5@;;ZBP5VDK6(
:E_3L6Z-8&,<K@4C>a:M3\E-9^\M5LY.46+IKI?d=C@VG:(=R=/eNBXUHJ/:B[&P
f@\1?/6/AM/##Q.+f<4I8G6NBcZeZf#CFXZ(MScT>CQC3HN?V=Xe<b)L.bG?P&EL
77+GEFF[-</_^KEQTSZEU;-=<cG@1U(8b\HbBX8aMPP7#FWPE35F?VP:XT_)FRaa
_S)H<^]Z#LD56UX,P#F^T7aL]b7C^IaGBV[K(2fR]I2a<>Y2Be0#;U:#23TYB7@W
_O2T;F1&C[;9Na>(.KcBMT<?B>O09T/CO@Y)db9YTM.O64[^EF9.?fF6E@XR)SU>
bbeIVfWe4^<U#S3PR10UbKQ=)4a7;S5H:6b1<@OcZGK\(4CfUFVPYXM6)DGaZO?T
GD<DEMOcG.KMNZY4]D7,Q7\Tg@8&+7Hb^E0X^f6(X]C;<#FOaTG^0<S+K@AbBW7-
2FPAbXP7UWbJ[3C:]11#(cRGY._d7AM.b-:M9O78AY)/S4@41HRFHX<_G\2F[W\>
6=GNQ(.DNe,CXVW0MD<J1?dKG^;,6NC.f0T#[^0W6SgXQ7#bcFe[gN7W^/>9^#+U
g0-H+IE4,]LEQ@N5BZUY])R//,e+B\UfA9HI\=SCe@e1K-W\=]60F\K68L(8G,eK
XFVaS.=7EQIG/K2.#X\7?eL\>19OMECH3L(aB9/5#SPIIB@5Jb:O@<PX?3+IeWSW
4ac_W^4_N3OOOK4P,65E0@E5^cc3:1D+D]dZ/ef>?KV8\Xf9]+[<Gce&5RH6IDVO
fZUfQEVTX<;.Q-+AE]Q(J,/3JGbgX>J#1>V&>1dF3XHZP6;fYX;V2:;L4KO0f7WY
Q])GE.#R3A0N^cTC8Y;C8S:UZ>&Cb(-UKa1-&5TWKg[06OHdS13fK\+T;70CX)f(
92f/\2ga+VJ7=SU0L8TM=O8b-2&eL[T3GR:&2dc<AAc64=_UVYA>DLb;;&:B>X/@
TLJ&bOF6g,4UOUDQBK?Yf-G-:J/K@+U_<E3+P?Fc@OR&DAcZMObNg6N#QCW[OSBK
^R9PaI\]IS\M:.M-(c:f6bVEK/(\g=9DN(E1[eO]E&8>X#25HWTdU[-UV]&K-0=)
:K(;+K+dZ[SYWQ:B?;(YfL&J[AFf0.de:FTLDI1V2,L<YM3Z)bL=\72N7F+GTBAN
FfW;)ZOZ;7(Ce,/S5+4Og76fg^+e5;_^<;#a(<CBBD?L&AYVaYH(T\4/5Z2ED]@6
AL2Kb.<XB:[#(,aF8RW_e3EPB/b5#7/N=0#A8/-e5:#3+:S>R&\&Bg452YOLOE_X
8V#e)N+A;X#6WRCN5)TGfC/(3/7=1:@=>S+H^RZ6.1gU^c7=JY<(0WV:a]4,7-1/
f)#1\S3OBH2Z6_[;1NeZ(#WaVK<4Hg]e(g:Y[#M-[[UR8+0#c@Q;dBAIbO]WC2EG
_@G&W&5I,&3+d9ALe;Le&f4F]e?9Y:c+IT/6>5g@Z3(cN)T+fS<e5Hf3@3AE-.1[
CdXT5g)/0eRESZ1fAJDe<FRZ/9b,CK[L:&cF=?2]>85\cAKQ^(15b]81f10&Q2J5
:.RSBN#_;A>O6<MSC+Kf.g&F@GMeN3^V38Ya=f[(3)W=SK\+2+WZ_]4\ROD;V].Y
QQJMRY;P4aZQU[gDTW<1/IEVP6He;X2Y&1T_KB5SbGJ#9+:@+7@Q6cX5#gF28a7Z
G8V:C?Nc^(8:IaHJ4_TdaA0Td;@N2f[,<c86O#&8P7<KE[22U/0d]Ge<?GX\Rc33
1f(.IMbJ.gWd07_VTFS,fT_A,<]T,6M2\PQHW9UN)B7KF=;[c<_7f5<KR:CCCQSb
F34eHP0ZUH#VOJ;QL>&7459-2P>1+UB&Z2V?4:;6<:@GdQ9Dd,e[?94Z/V2BIeSN
RW9S7:L=LA8#S(U51?g3eVO&D@B^cK:TY;?>6Sd,MO\)BeZ):M4Z:/ZZ43AId)Ve
R[bZNJR&g+)[JaSA]LJ;XYg\DfR;>J@]]F<L0#;H69JdOe]O&I0PRV]:HTa([5<&
=LOB81)5a8I:43fRD-Ea0,Q92(3)PN6>I9#:6-YBZSDNc=UVT_eG]@g]@f]GB2.K
M<,6/7,/>(^1@cN2S+0C8LF.U\)[@9BaLA)ML4QT7gQ+0:4DG\X90,^gMW_BVY&X
3>TA@+^a.a+TLIdZ;1<d@Q@.MD:D[F.e0WD/Yf09R6=#DL0G<IFf-5].I@/(S=6>
ZQ\8\AdHAA8VZXBV.bM(Z6.PC+K?[X7DKUA2dD8>RHVe<8MHeX3NSYR<R;C_5](T
@D59fJbG4\TA)4(EJZEFN-4g->#+/:2AD/MI9EBdd-[T6(P1K9GG9<=YJVQGZU?)
CB)O4)1XOaPg;Y_S>TG5[CRb,]_LC[-gQJX<U=,<CRM?<3_28O9,3BQ.XcUB?Zcd
4]4g3Q/95cDd13<D=E89aPQF(O,J4:5-/?DceW7&,dCD85LR/+R+b@E33AV#[R2P
X;YD;EaY&A@F&WI71S=1#-c82H<.H\TY>:0P;5I@KO=X-g6ObT\7J?KZNMfJ9.:Y
;NEZC[#Y#G4D0G:31TN4/\,O3\Qe+8@[=.[06BYVS#YXD$
`endprotected


   // synopsys translate_on

endmodule

