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
// AUTHOR:    "Bruce Dean May 25 2006"     
//
// VERSION:   "Simulation verilog"
//
// DesignWare_version: 09d81b79
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
//
//  ABSTRACT:  
//
//             Parameters:     Valid Values
//             ==========      ============
//             width           1 to 1024      8
//             clk_ratio       2 to 1024      2
//             reg_data_s      0 to 1         1
//             reg_data_d      0 to 1         1
//             tst_mode        0 to 2         0
//
//
//             Input Ports:    Size    Description
//             ===========     ====    ===========
//             clk_s            1        Source clock
//             rst_s_n          1        Source domain asynch. reset (active low)
//             init_s_n         1        Source domain synch. reset (active low)
//             send_s           1        Source domain send request input
//             data_s           width    Source domain send data input
//             clk_d            1        Destination clock
//             rst_d_n          1        Destination domain asynch. reset (active low)
//             init_d_n         1        Destination domain synch. reset (active low)
//             test             1        Scan test mode select input
//
//
//             Output Ports    Size    Description
//             ============    ====    ===========
//             data_d          width    Destination domain data output
//             data_avail_d    1        Destination domain data update output
//
//
//
//
//
//  MODIFIED:
//
//  10/01/15 RJK  Updated for compatible with VCS NLP flow
//

`ifdef UPF_POWER_AWARE
`protected
>b3><Eaf:7eVKF]6##NWe#g0N6R+E_IP)D:+._c)Q>LRdB]<E:_K-)=Z<.5@^\.>
CX-SKc:LJO(f=Xf)JeWb))F1g:W\a2?=CV?aG2FA?d\:?8EGVWdT\FaLCQRS.cNR
SYCPBb&GRUcTG.T>)D=VbNEW5dBKX^0>T,:</5LB5:7N-F^7Zbd=N7#M&[]4-]7b
-YAM950MHH+eG-DJNW@A+?ZdF-MBaEY3fVb)HdTG41f_,d1HO4>GI\Nc0/R?[aW9
^7PDMW^2Q7UU-<I0e-g#\=Q^geB[7IVI_8PS6[cD=R_Ua_1HHO]@5MHLe_NIV103
gJ;>fNL;[#5eeQ)B00XEe+9\Y(J8.MVZ=F\?ZGWfbKb>CSgJ.G1_W1)de9^S/f)-
OeT+_A[gOfNcM9a=>-M<f2FE[,O\H.cMZOP,=NY/_W2(33;,0\#:Q,?(+Yc&@LFE
<6c^EI;Q\[U=;-MQSTZ:02=TOZ;Y5/b]Y;eFSY^9G^1.^<)Wg53E[/ZA<X_C@)6X
3>@2?3b32CYS_b3@K4=1?41:W>RO[If^0?T?#O^G2LHCXBBMSY--ZU?E-gO\R2]G
4;A+;/O2+S6a//ZX<9RcYOB8?RCP;O4M;S/\+O7/D,0-5UE[3dZL+::fdYVVeY5L
:ORBRGOP\<)fF>e;d0=)]>S-WGFM[2^3L1/@3O+,g+)O8c?7V_=T[L=0>YL->OPD
817GAFD/I?C2&@ZOHN2be)?QSF4[Q=bI6d;XIU1^K]RQ0IQa4U1/4C)LZ#_43A5I
LR9YE@84.0A<PRA>bEX_Df[BdMXD3,Lc#NE=?F-5P+PLW(.P>=HB6a^X(O-_&(DN
QFF]Z8Fa(R-0VN_7Qb<INJ;-cd/J2ZH?Da^5)E=ae[LI#]+>g38gF-15^;3FT4B8
SP98:Mg)/X47Wf;N]A,[,Q?V1:QM+U9=6^T)gKXdFWWIN;1B/R]T[b</E^[\G<D+
JQ+#^)94\0aW8,;F/a4APD2b:TYCc.JN8\QM/Na(RgUOa<:^c)>B/@I=BdO^GKf]
I)cX[.U;QfDe;SIFEBLKJ(-OZ(7a]M1\Y>G(M8E0&=e5;2@7@^_QV;&@>0NPe^5X
ZAZ>D8:^ZW;[[7]EBT><H/+3U/1>gJc.dV6R#O=RJSEYZ;2MVNFNF26]R66g&Qgg
;X6JO3.ITg\PSI^I9[C,86a4);E0S_4;_Ub;O(c76.V@XCgdXE,2(deP2^S]4(R-
+/)2Ie)<O(X\N=T^EQ3GdQ+N-SC3@X4a][@RO0IT7<U#dR9aN(QOI(QKG>JPIdML
Y\14MJ##^]O_0?@UEe\cM&:,60\N@Q\Q44K?fKDI>//c/BS0L)Ha(9GC3((0DW4P
H[7FVa1V+[?1\]?.6[)D^66<9-Kd(YBGA+/9PXY,HBXW9S&1e0_P)U5&L;U^/a49
Vf]bT36>D[^#8I1cC(>8U\-??<:IGS=>^Z@Ve,77[#/YQ4@R.J-a(:0K2TJC@Eb=
#1)36[LBQe:EH/f1O&/KA7d^>/7?)([+KfG=;13RZeZ^)J=BOAW+E-_UW\&d2_5@
3J.;5PdfYY]5V.e5NS[,-dET6CEK_f8,AMH7g0)W0DfZ@E1AedSF@f1M[f5\^11M
]dK(Z_J;d\8=P0.KA_6H]>fN:Q\K;6Tg\92J;NX0GI9.O71MB2<a:THCg-XRV0XG
8_FA?@7Sbd8CJXN93SYHc>UA-DI,(I?Ta_I/J]Lg[aU^,JeQ_Ee;31:4,1@W:),Z
SXN)0\NcV&4ZKae5^]JQQP8>f::cd<6946B5?\7b?@5\DMF#:E?1F3L@F<X7fg1b
:Pad5):EH2e2bY[BIS+/JR,Va4C5A&APKT+F0EMGDAP7A0IXaa(b\?e(?a#5GDJ@
7O[.##/AF[LTV)V9V.UB&@aG=BaO6>X&BTKfV<96S4E?EC5L0P5YeZa;EV_Zf=:H
7\ZW.BFY67T(BZ;),8/Ld,\2EMBE+YN#OW3_a0173-4P4/[ZTb0;5?e:17,1K@^G
2<#<e[RT8)H5b^X8VL-ND;/R8RI<^<ec))RUNK:=/0<OP[9[]5Ia8FQ:aCO?d1&e
9D6_Z\Xc7\aXI>8P],Z3,R2\)]4=Z,]E1SO\c396CKKYgdCGJE2-)f<3UBE2ZJ+N
BECSaO;,RH2(a)UNg4,-,WHOZQ2GTg;-SBQ##Me_/E2bf98&.R-+5I[4#/<KF(L;
eBQ[HTSML)IJ?gE(O<1LB8XR(_&FS5XUfRN\+8^UR7F?]N?-PV9;WP1?+7)@TB?g
>=._E_07ZT1@@JJ+]?2;OX<[4PJ5W?I4H1e.MA,-C17&1+9^V&g138XX,(eRb0U9
<&BVeJX.&G(NHcQ]MXF(O_MJ?DZU#GFDLUUSK+Rg20DSbb;R3f)B+N#I]d@eQ1TO
)2&E0JCH;WKLfgL>7N+YB=T3b1OGfX;@@^+3JC?DJAL]A.5JCRJ#]CfA>;e6?9#^
7+TL#gdI,(3PW272ZX7>MeF,-ZW(2-L)=)H3&NP0<:Z4=Z<&K>]MMAA<?]4e?[Xb
e^SN:B=S_d.@#TZ9A]C\R(6BKfC#4N+^,b[,G1a;&.<9a&:3VVO>&.b<5#P#V^3>
4BZHKG..]Z6.PT[^>U^H=a^MOQUT#1Sdg]=JUUaL#\8dTfKR(fC=N8+62,,&^O42
[G>8?\6[&O,6?Q4e[da=0bQB>-00@9RAcM(G>(K2X=M6Hc5@4.[46WC;>HLD1;\f
<CJ9F<[RI_>@U,QBf]DMN:)a99KAWY54GK+>C>.C>T[\#>PEdX2e@NaEM]+M0&0E
b5XFZB5-XYA:Y.@@JAJ3NY@a#(/JPW-2@WJf<Q5W>J?@9.ZcB:YcT[V[&2dLM6bI
)8#.SAV/Ce>S.9\g47@:S;TOdW:0@/_RT=BML-fbAa>?D#fWFcWSW6V,):58CH5,
6\8Tc@@D>aeB0^fI[9DKL9^9)B@HbS<U59FdNV-;3T.CKJfgY>847b=KLCaB<[2&
PS#f=<>d?:5.PXT2QeC4&JS9QY..P=YdV>d@Vc/(/CC4K#I-4++[.)<N-P5I#g<9
FDU_9,&]W#aDYE5CD[8&&bg[Y1RaH9;E\6WA9&)XTX@1<C:e.d(Y=,JD?HW&C9cc
[&cb9O72/S.^TD]IQ>>_^@_Y94M8E+.a;f#83EAHOcS0<5^5V6fXBL^>)g-JGE#=
_0HST(SQf_[PKK(JF_eE\#J1@U?/GI=6_DIZ:X3<=WLLYef8G.g++O.[ed7;V]:a
b9fJ.gEc:=Z29bH&-)=a,+M_3JJJ_PPLfE)=@_NUFR_C0Ia8GWc5f(YGa4a:f:c#
6NR:.eae7+E?^Ad6=]:QS-8\#95d:&]J+cbHR&)0I1XJ.Ja.b)K^V_<1Bee/;UIe
/UYUdB;\MB[(8J4DIW3/W13GcMeUeGEFQCa7HA,0R]L5(d3R5>XT&7;gDD&U8=;U
DHN)X\Y&[)8>:2-a>5Z8NMdJ(I=4YYc9K5G(ER9f\40:d3>0OWJf#fM=)-92GQM4
2.Lb).-dMb@=#SLWK?+03J[eMa_RL/5@^CBI5>X^)-_EN15]?)-@3WdcU7Z21#a1
2S^;S;Q>P=.FV9M<X_bPT>5Y_,]+P1,3NR2##P?6b9X=aWHDCQ)4E3CE2.C6L#V9
W&eE\C[I38L?/MHM;#^6^MN6>UM=@fW5Yd^91WKQWHWXQ5B<RR8e\AC48),--FY9
^-f+cFDZM<5aY_e)7(QHVF(_(YBIE5IfKg)c6?5EcNLTgXU+_(geK0Y#Q1D(^.5Y
9[G2+MW9eL=a0QM;MYN4>(]1Rb7HgL)RLc0-7UW&X[YC@Yc&-CHW+[_1MXPVOQe?
5NfIR?F1g48a\N=WeIA2P=bD)KQ&7O8a2E;4;0f4]^ccU\-AB6H^U_3aGHYU34_(
&7gH[TQF^Ud1G]D&EAX;d:,0#Qf-,T7c1V:=5628W]KaGZM3bBZO4QE(E3RG0cD(
ZdJJP>6B7:O]H7(5XaM/b=6W&LM-QM5;VP9#I9Y\R2JOBc_D9XaBdCV@<g_>Lg:J
7[G+]CU@G3[I:E+/_E;f0?eF@f&e-[X5,RSCOR#\.c(^E\_LO)D\52O-bG\>P9@2
T2,eF4NS4gb\KNd;.._7W(XB\\T4XNb[V&M&T_Yf\MI4,::&S>@SU(PPA962FQ&[
N0_\#-O-#T;H0CW#TG9#D&dZ20_.0Z]d:)2VdQY+-7UBR\C/b(UF=A6=P1<;Z7>&
DI-eDJbLJ4?Y[2K\3^0bS8Z,YYDGIYY^4L#^60PO98[+-B/4N/IBSGWP7>6<0QPD
KWfC;S&M(Vafbea>bcCD<)MQC;d\SH[@>1&=eK2N68bXR(Je^@CSSXYRB#-^KXZ)
=G@G^JWC:64NW=J;5USYf4K\+]^9Oa\@,ZM^cJW=e4ZLS#@F_c#:c/:NOZ<>@LSe
]/>:QED/b<Q[O-f8O/\9;FX<WYN6a[YN[:9[B/>.f:;Ff=Wa@G#V?f3V.9FBT;RM
7]D??P_^L:7c+08dWg#I#b/AF3XN2]ETKE<MGgR(&4>g.I&\M?3HUTJ@cT#;YW-D
L;NMB4-T?PKD:T0N+/BBHG,,D78Z4J/YX?Id5EUFJF0#KWd4C6B<CS.GXL0B_LQb
?A@AR/-_VC)-E,2DB[JE5=7>K;.#;5eGSX6/L4LXBN<Z4O0+-#]0Z^ZA;&J(J_c3
b(Ve2Y>IU7C#+1,d958HU1KI>DAU41e=5gQDUa-)3ZN>#6]bEfOT\.QWa)GDLDN5
/-XEbET[OJ(@.:99cK\NT8e3(H80AYCS[]@Pg9-Q.Y>)U=QX).EZN&\^88U)OeYB
(Q#UDZT7FbLK]PL;EWVF0@H44&1:2L2.Q39VdJ\WWbA>&fADND]8I>[Q/GZ<G0<&
1NdJTUR@>)XFA2@X<D>Y(EM4_/H82]#EE[R)<N1&KNSXc1b27b-IR2+7ZDWMT4T\
Y^;cO97FP;/(CM081e.IcWV6dLYQb4Wd#)7cPDV,<,@;<A(Qd8I0GITDU._?9/:&
:Y,_f/bA=>dc3>_aJ6N&gL]8\3NV,2P\2OU8N/[:aC.EOe\2T#JZ_SP62c:@C1<[
/L(a89PQ7.W&4Y,@8\>1?f9#1<3e1N==)]0g>QN,:?)-W=e6;ZW5V7f9a#M6KI]-
=.U8fHebC1YaY<Z#NN9D/HYTJa35VE-GQR\I9=MXf<;Hf\;I]&:K_:+AB;Dc;T,d
P=>&S/+9S]@O6=@O@_FNd7U#H6&/R08LGa.KRQ#:0S)NEgZMgP4g&9=QQ6GP.768
a3\G=ZaR0c.:c)We-FQ5\92DSaB+RX;)0WWaE9Ng^:+:2#?_=K8RaOH=[3T=b.4C
@(IMQ&6>KPYN@c_ISQWIMKXLTdJA:^MI<72gdWb5,\CC>DE00#Y<ISQKZBT(>99.
gacO,]K=b&N.IS#AX=UM&ZCf@\9IBT,bYCJ35+]+EEX=C3-&<<a>I?MHE5)\.a8]
[MeM\W/[&_7HYS>9ReefHD(Y@0S99N@EFfU>g2R><;JTHN=31Y,>Ic.9R_E84XXb
QPQeN)ZeNQXC)V.c/N;74)\Ve49)A/QX4ECb0Z]?)W?\K<C7fDGRA7IK4(MZ,(PA
3Q30T9a<3BKd9(\^#L\ZfFN8Q:M3YHS.+:<7:4.,8;T^^PGEa+e37KML^P3ZS6TN
Tb)36--F-PV^M>P8^<7LR0VJ-GTc^HW/KcHONc/=Id]SN+.3J+(92^R7.^)gG;:-
XgB<W]ZY-6]]QKPGZH&=F(A:Y41V/4RC5>WQ@)EaQc(@9T7gIaOJ42Ob87?DP65H
:QOEf)d:Bg5N>6QM\T06._D^UJ=aY>b:RP00=M#Ob5@.HIB_>bI[Q>c3bFR-6gOG
[QSER).0K72;GDG=_UPV]&_N-,0aPS9,##23d13T\H>2Gc1FR0R&#Z\2A&#^(B2,
JTBAb_aE3ZM@BGGZD:]3+&7R32AeV[bFC[,O1X_e@3JPg#PV<.SLUVB:<7:;W#?Z
[O@#=OVK)9a0#ZJGQ+5=D_3DJYUN(A_[a:.dePI@4\Fb9F,/Z]C)(>0KU[?V-.GC
3<0c5Y?8(T[\M<W[_YB#gD)C>/aZZ]#58S-cE)ecdA0I7=:R,W5[;\&01])(;HMf
ZeGIW^?ZaVV?U/D]D36d_cOSA#fW5VMQY<R.I1eTP#W7H6=g,[0R:-S+-56J,W]P
6HZC7AfCK7E2QKe,-HCffe56@>8CWK(,^NfTS(R=2\UWI4A2UFHg(3\719LW@3_4
OQbGfPV64_0c;K<[M<c&S<D3S;8Re7P6?XEB(Y=@+B723M6Y>,F7D;1Z7&:1<0FG
FB)1Ffdg^#,M1Q</&/+=.8I:UfAH2<2N\S]I0Dg7dJf0^\#HdXeg8,b4M+.cODbC
-FF7T]^,8F6<7b\U5ZeP7\:c6&RBKQ&[.0(3F4TS;3[=1_7W+SXZbO:>>J+29K#e
>g;(3OgJQ2\RM/0&M3&G1HMASN79Z..\7+S)DId7K>9ICb(O6cWeL1+c#BN>X53J
7;F&C2O\U(&VC(YOHB[]EHbS,NY?KZbL?R>SE2g3@5aVTXd?#@eKLG.GX2R>UE18
?_==c8YdLA/&<UH8RA+ZH:aXf^d3M(aE?b08]Q<;g]>6<e0PI<g8P:SDe)-9aPEE
3RWM._B&FI?FR]\_,(f:K7[NE/IKf?R)EVGR_0HP57XMgCFbPAeX:-gAQ?BW#HbK
=.1XeG6ZC86YUPFSdFIf.8Y_UbGG91F90[aH6Q@E&:S2#Y?IO2c+HY/1\>CO<d]#
gU)-9#Cb@aIIJ)^W4@LQ0e;KE(fc+4:<+#,^=#cOcGaG_6,>&?U]@c2(BO3J_WfJ
Q\2,.CP\)L5,;\3/)[I2S/[.:V3)a@bGI@UKga2-D5(Q/G-dSQ/[Q).BGCMKYUC1
+aW1]L1V>G/28ML@O65CXd):0J5)W(<M>42?>#EHd1<YfS9S()3fVeS(KZ@_AgR8
0bR[YWYY\a[dH1JZa1A@(.WgF=@b7f,JOW.1a29,DF.ZbV5^MG)0bDMZ+[5OBY?Q
YUICJdF;S/=HV\3aRdbD-]S=7)dc&;_aS6K]-[Y1HeR\^,&G023FF5<K)06_bgB5
IVCWC9OZ_T[Be(35S00XN]b-@)2+OCa/,18fP)O6N\/0.501K;CdZ:N#Re8fDSU8
7dCO,geG>eVg],6dgO7/f>HUE7U>cA>T?_1/OSVAR32_\]d=(JIBOHT,\gAJ>]FJ
UU;U>#F-.WHg@<R)XNc[ScA@6WD.3-A]^g/>[S79?@Gg-;Q\AKRY8+X1&Ed_<\;=
32N_P;WZY/OOeeO_W(6+,CP9-LN)0g5J@X04HJW)1.NJFVBZ8>BZU;GD[6eI?[e=
QV-DedSa\b8#c)_>]LQ),eW1.X@QUC#[X_d#7fJS5]KL3ZSFF:]Mg)+ET@73@T0Z
^A.Q-C;/?5PU;eBDHf^TD)YdWPeSfSI0fM/?V^ANQ(IIAS\dN?K@&M(MU9ff>=Hd
Y-7_W_JeLS/F:G,V6Xg2FMP7f21]^2Vc2\W-[4VB1?BQ:P?R))257C_@W9CK]d(&
-G13P#VX?&0eS1d(,g/D:01=>fO3;,D\0-QMBBGFW/1HMH3&U=F#P0aQ)E,,bOR0
MDLWa]]LQWFeF(AG88)V0gEE:=U&O[T?g/a,0NI.KdgbH=OU#Od(Q1F4bV;MdZfH
4H?Bf/<H./S[B768W[9LG=.ORQ3L\>>(YB#_@_.R/=(^8[@[WYZC+<]XYT;?f-VC
C0Q]0e[Db2BWUU)]8TST;?]2<+SAGZTZ3.:>6O&^V.:?gE[CX8SS/8(?ZM)(@RA2
KY\de(bCXN2?PZ#F;Fa/VR\_H[T5[T:);+c2R<><^INTQ.1BL9>D\O7G>9Le>c#7
NHa&A@OBU4/\@SQM5[)J:BIVN7MZ(?fK54]UFF>=Z)</e(6)cGY6-bdN_.JMRN?,
RGE(5b9-0ST8WX;;GNDTJ:5J9eKT3UR)VE3Ed^aS+B(7\C+JcV7._P]&UNR0_\7b
f/)KB.-QWWb+>32dJ&B,O3^#f6KM62gB,O=2LWa@NYOT\4+;)Z8^C5.=3?^Y4Y>c
1-HcNHUA=0-T[EM/Yfc\Q2M#?L>AU?N9Pe8FTZfcMbGO0Uc4Jff_5R8N2UfgA-<_
fa)O>EEPaDd#6=_L23TLVT6,-WB1KL5CK8+g2<a^9U60/T)AI:aZN7]HCfO#Rf[S
]8Cd2H-<Q>>B3NU\IGN=GN_,8UD&U2cZX89g#?UFc3\KG/4=3GSYT2E1Q/5EU-,X
AFJb^A=Z&Z2YD1\O,&@F1BcXQ27&1b81A.LaW13MTB9AJ,RFQ\5HUcZT,#H5^H.V
B,.(F=1DC#XCOac\I-P:T+fPB4MP/UH\RJ#P:#X^0B_Y6SM74LG/:T\P@:9E0Pb+
]aVb0c?/PBTA&D/E\+QUQZgBgU3T/6GV/aTK@1beY0_NYXP<P\]aX\:[?fG1=0JW
dMFV@6Acfd(N+]5fT,LAdIGDd[]M&b=GbZA)5,\aYWc=@4XW5:51ZZ8-La^.M0W3
EdMe:WP;#)S&](?_#/83KFdL(^caV004f/XgR8O4T5#_GB+Qa-4MTLaJ^FA4)g[e
NC2]b\>0_5;+;Y4_d+.c1+4JRX#-D&SDa^?C2)/,3?+E(PMJVNH99NOdOJA?OGP8
6ZI7H,455.^b]0cDTceKcge;?K,[;.Oa70E+b6DCRgF4fM1)3f28gTH3/Q56aPOL
+_#G_VUHM@TI71UPe4f/P.@9DeE2L9,58H\DCW5[G)YJ)DaJDO0V#@fXT/HZMg&g
)e+NWESX&dYV[\(fcW;MD]F]Z0=-4\[#+U8B>1H(__^\5PUJW]c0JX>cY<geZD#)
T\Xe\@R[L9/7gC?c(U0f_QU]8NOKAF#J8O=VAI\#9ecN_dT41<&=LQK>Y6cfQJP/
I6K:0Vb+;HbDJJ3c-P#CN).fD8)AV4E_9S+FSLE#eM[Gf<A.9;+J7(X.(,R/0fZ,
67gHP2&D1cPdT<QBIg>W6(^RPF<D_EIP^@]HMO<?9&.-]+I0ALB<403L>,]^98^-
^WXLN7T[@8(P&f3dUC/_U6eY6>KbJa_AC;e6#TA5BV2#JGIH0#33HeS1LR74aLG5
7eZM&,N-f?MII(0IKB;L/<cT=JYD,X,b8AU)<4XA_9,?-a>KLMTT;\48Ee#5e>WG
0(T#&QE2/QZ(Ub95f-g1_,1.6.MSAC[XbD.^#7>W.eN6eLQ5K)FXM/G_ZH&&P(TM
[,O.Yb1YR]cMOS@fW1UD(;3?@\QSL\_WC0U8Ie_#GLECR-RFQgg3FVWKa2^c@M-C
OTOc)^FV&B3fL?EHTZMY03=G>&DVAD2<Y;d+GKUY6g4UAY5f[1+4T4a+7X_#e:Se
9+Y6;R@bT&XgENZ0@Qg>Q6S],F#MHX6M)Y>B<OHe.>1,D2L&QX]9b,0a4#IaUV7S
:=cfI+D1aP&>X_.]-fJ)L7<B[G?#T7J)HBB,9]E:?D.VQP)a0g[HJ[G#8cO#:4[U
>8J>>&fMCUbI>F[3M05:/-e&g9G_-3=J9;d(5^e?7a04RfKB/5)aDMg]=e44JJTE
[0O_5KM0gGM1(K/W5;+@^@&]P2UcA#>QP:+8@c892-B=LDPBK]EPLJTE>D;1g0H-
gQQ>D;M>[UT77<JV:(ea)-D-UQHeAUZ+.X4PG7?)?9>RXb4_D=F3>/D_IQRW#]IN
#b;P?Q+/5C^_85[gUJ>@?bP_:&JH1M4e/d4A]F&9H,KZAJJB48^7S8S];GG1g0T@
[Y08:H0Y;eUT4c+AaX?c;(XB;4\e6#=1:?W)EVXc.1RU6<c]g2c\(+N8P47<AfeG
S9@J_9IXbEd8-a/cU?K3AXf=3X.3>?cY,/QODJ0;MWAW5HVc,dEcg+Q.(bN^R;E&
Y1(T^BFBSB8;A<O]eI(L7V-\RMFNb/7IaOKM(:]YXCG6Z=YI(>VNeD&AB;(aYf/C
H\)Y_7NOQMD@78+Z3I,7-)@c@YMC,N-?2J57b;^/;YG:E@+bWK,@FEP9ML\.&Vc1
TKbg.&QPC.+9-AVDYWQP0UU=e8<C\?SZ?,C3PS8&]fWHg7cHXf4F>8SDVa1b7I;U
6bF;IF=LdTSEP\b8OU/7(.:d/XGDKHT]@_Y.3J6OTAa?=NAFO2B>8X/-RFJ9=#H6
:S,D<C?5gSPL=5]M@SUX_QN,VK88aID<^F<\<+b+1G]_YR@dW9RFU(YKISdY+H08
A9dP,/L&/I?)&aIC^#+c;V,MEAb2OKP77@]QB/,ZTcNW^48XH.Q9c5dR<@B-+R_E
P5DH-R#-e_M^:DeX\<(8^e6(Y=O\+Icc+B1^8>^4RF(>TC>EAc4WC(#[:b^D)c6?
)F^PT3(aG)T#29.W/YK;,OL^><CR)L<#)P#+<),4gcK<GVYFcLHI[.Td:>1Fe.MS
Ce>]@/OL3TCb3e,.P&]b4]S+H/-cW2<T2fQL89ZKNY+D-A>W]Kc+:M:IZB(?D>VV
?A+e>GBe7]f;(]#(KQWc^J0IN6-G9[+20+XKZ@Vg]c[;Y\LEOAfC_GLKb(?1F[Nf
Tf/8Q#cA<[)NPgK+XY==V)P]KCN[VQ3NC>JO+/(TT0/^_H[,Xc2SR\TAR;#8V0(B
KgOF(\5aD#)W6@CM@HOP@QMd8543g\K;P+2CZH73d,-M0(d[cI.bXdRBZQ&=)NE^
>1)2:K(eAcc8Tfb7?ME5W?NA_fYbKLDNUX<-Cf<I&>f)ELb-AN08XS-UUEHX37<H
U2Ta7RK;YG.+6R,g1TNWQ(G341A=<>A?<5Pa/3Z(R7>3g4df5B#);7_ZLE@OV;GF
bIO50@bbdP:[JLbF2Hf+6&)3#6#0F=-/E8?CTE\&SK4G=-E6.<\#fSAJ2eJfbCgS
fc<IKgf>2T5b^^B8SaM0aTBcf83HUZAYfb,gV,2[9<3#^0a_9:<5WZ2O=E#>UgA6
V>4e;B6PI+[:3?X)8eDC=T\43&dJ\[-EH13((Q5#Y6QO(-VWPdH]4(?52PgP+U4GV$
`endprotected

`else

module DW_data_qsync_hl(
	clk_s,
	rst_s_n,
	init_s_n,
	send_s,
	data_s,
	clk_d,
	rst_d_n,
	init_d_n,
	data_avail_d,
	data_d,
	test
	);

  parameter width = 8;
  parameter clk_ratio = 2;
  parameter tst_mode = 0;

  input  clk_s;
  input  rst_s_n;
  input  init_s_n;
  input  send_s;
  input  [width-1:0] data_s;

  input  clk_d;
  input  rst_d_n;
  input  init_d_n;
  output data_avail_d ;
  output [width-1:0] data_d;

  input  test;
// synopsys translate_off
integer reset ;//        [4 : 0];// :="00001";
integer idle ;//         [4 : 0];// :="00010";
integer update_a ;//     [4 : 0];// :="00100";
integer update_b ;//     [4 : 0];// :="01000";
integer update_hold;//   [4 : 0];// :="10000";

reg    [width-1 : 0]  data_s_reg ; 
wire   [width-1 : 0]  data_s_mux ; 
reg    [4 : 0]  send_state ; 
reg    [4 : 0]  next_state ; 
reg     tmg_ref_data   ;
reg     tmg_ref_reg    ;
wire    tmg_ref_mux    ;
reg     tmg_ref_neg    ;
reg     tmg_ref_pos    ;
reg     tmg_ref_xi     ;
wire    tmg_ref_xo     ;
wire    tmg_ref_fb     ;
wire    tmg_ref_cc;
wire    tmg_ref_ccm;
reg     tmg_ref_l;
reg     data_s_l;
wire    data_avl_out   ;
reg     data_avail_r   ;
reg     data_avail_s   ;
wire    data_s_snd_en  ;
wire    data_s_reg_en  ;
reg    [width-1 : 0]  data_s_snd;
reg     send_s_en      ;
wire    data_m_sel     ;
wire    tmg_ref_fben   ;
reg     data_a_reg;
 
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (width < 1) || (width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 1024)",
	width );
    end
  
    if ( (clk_ratio < 2) || (clk_ratio > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter clk_ratio (legal range: 2 to 1024)",
	clk_ratio );
    end
  
    if ( (tst_mode < 0) || (tst_mode > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tst_mode (legal range: 0 to 2)",
	tst_mode );
    end

    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  initial begin
    reset       <= 5'b00000;
    idle        <= 5'b00001;
    update_a    <= 5'b00010;
    update_b    <= 5'b00100;
    update_hold <= 5'b01000;
  end
  always @ ( clk_s or rst_s_n) begin : SRC_DM_SEQ_PROC
    if  (rst_s_n === 0) begin  
      data_s_reg   <= 0;
      data_s_snd   <= 0;
      send_state   <= 0;
      data_avail_r <= 0;
      tmg_ref_xi   <= 0;
      tmg_ref_reg  <= 0;
      tmg_ref_pos  <= 0;
      tmg_ref_neg  <= 0;
      data_a_reg   <= 0;
    end else if  (rst_s_n === 1) begin   
      if(clk_s === 1)  begin
        if ( init_s_n === 0) begin  
          data_s_reg   <= 0;
          data_s_snd   <= 0;
          send_state   <= 0;
          data_avail_r <= 0;
          tmg_ref_xi   <= 0;
          tmg_ref_reg  <= 0;
          tmg_ref_pos  <= 0;
          tmg_ref_neg  <= 0;
          data_a_reg   <= 0;
        end else if ( init_s_n === 1)   begin 
	  if(data_s_reg_en === 1)
            data_s_reg   <= data_s;
          if(data_s_snd_en === 1)
            data_s_snd   <= data_s_mux;
          send_state   <= next_state;
	  data_avail_r <= data_avl_out;
          tmg_ref_xi   <= tmg_ref_xo;
          tmg_ref_reg  <= tmg_ref_mux;
          tmg_ref_pos  <= tmg_ref_ccm;
          data_a_reg   <= data_avl_out;
        end else begin
          send_state   <= {width{1'bx}};
          data_s_reg   <= {width{1'bx}};
          data_s_snd   <= {width{1'bx}};
          data_avail_r <= 1'bx;
          tmg_ref_xi   <= 1'bx;
          tmg_ref_reg  <= 1'bx;
          tmg_ref_pos  <= 1'bx;
          tmg_ref_neg  <= 1'bx;
          data_a_reg   <= 1'bx;
	end
      end else if(clk_s === 0)  begin
        if ( init_s_n === 0)  
          tmg_ref_neg  <= 0;
        else if ( init_s_n === 1)   
          tmg_ref_neg  <= tmg_ref_ccm;
        else
          tmg_ref_neg  <= 1'bx;
      end else begin
        send_state   <= {width{1'bx}};
        data_s_reg   <= {width{1'bx}};
        data_s_snd   <= {width{1'bx}};
	data_avail_r <= 1'bx;
        tmg_ref_xi   <= 1'bx;
        tmg_ref_reg  <= 1'bx;
        tmg_ref_pos  <= 1'bx;
        tmg_ref_neg  <= 1'bx;
        data_a_reg   <= 1'bx;
      end
    end else begin
      send_state   <= {width{1'bx}};
      data_s_reg   <= {width{1'bx}};
      data_s_snd   <= {width{1'bx}};
      data_avail_r <= 1'bx;
      tmg_ref_xi   <= 1'bx;
      tmg_ref_reg  <= 1'bx;
      tmg_ref_pos  <= 1'bx;
      tmg_ref_neg  <= 1'bx;
      data_a_reg   <= 1'bx;
    end 
  end  

  always @ ( clk_d or rst_d_n) begin : DST_DM_POS_SEQ_PROC
    if (rst_d_n === 0 ) 
      tmg_ref_data <= 0;
    else if (rst_d_n === 1 ) begin  
      if(clk_d === 0)  begin
	tmg_ref_data <= tmg_ref_data;
      end else if(clk_d === 1) 
        if (init_d_n === 0 ) 
          tmg_ref_data <= 0;
        else if (init_d_n === 1 )
	  if(data_avail_r)  
            tmg_ref_data <= !  tmg_ref_data ;
	  else
	    tmg_ref_data <= tmg_ref_data;
	else
          tmg_ref_data <= 1'bx;
      else
        tmg_ref_data <= 1'bx;
    end else
      tmg_ref_data <= 1'bx;
  end
  
// latch is intentionally infered
// leda S_4C_R off
// leda DFT_021 off
  always @ (clk_s or tmg_ref_cc) begin : frwd_hold_latch_PROC
    if (clk_s == 1'b1) 
      tmg_ref_l <= tmg_ref_cc;
  end // frwd_hold_latch_PROC;
// leda DFT_021 on
// leda S_4C_R on

   always @ (send_state or send_s or tmg_ref_fb or clk_s ) begin : SRC_DM_COMB_PROC
    case (send_state) 
      reset : 
	next_state =  idle;
      idle : 
        if (send_s === 1) 
	  next_state =  update_a;
        else
	  next_state =  idle;
      update_a : 
        if(send_s === 1) 
	  next_state =  update_b;
        else
	  next_state =  update_hold;
      update_b : 
        if(tmg_ref_fb === 1 & send_s === 0) 
	  next_state =  update_hold;
        else
	  next_state =  update_b;
      update_hold : 
        if(send_s === 1 & tmg_ref_fb === 0) 
	  next_state =  update_b;
        else if(send_s === 1 & tmg_ref_fb === 1) 
	  next_state =  update_hold;
        else if(send_s === 0 & tmg_ref_fb ===1) 
	  next_state =  idle;
        else
	  next_state =  update_hold;
      default : next_state = reset;
    endcase
  end 
  assign data_avl_out   = next_state[1] | next_state[2] | next_state[3];
  assign tmg_ref_xo     = tmg_ref_reg ^  tmg_ref_mux;
  assign tmg_ref_fb     = tmg_ref_xo;//not (tmg_ref_xi | tmg_ref_xo) when clk_ratio = 3 else tmg_ref_xo;
  assign tmg_ref_mux    = clk_ratio === 2 ? tmg_ref_neg  : tmg_ref_pos ;
  assign tmg_ref_fben   = next_state[1] | next_state[2] | next_state[3];
  assign data_s_mux     = (data_m_sel === 1) ? data_s : data_s_reg;
  assign data_m_sel     = (send_state[0]  | (send_state[3] & data_s_snd_en)) ;
  assign data_s_reg_en  = (send_state[2] | (send_state[3] & !  tmg_ref_fb)) & send_s;
  assign data_s_snd_en  = (send_state[0] & send_s) | (send_state[2] & tmg_ref_fb) |
                          (send_state[3] & tmg_ref_fb & send_s);
  assign data_d         = data_s_snd;
  assign data_avail_d   = data_a_reg;
  assign tmg_ref_cc     = tmg_ref_data;
  assign tmg_ref_ccm    = ((clk_ratio > 2) & (test == 1'b1)) ?  tmg_ref_l: tmg_ref_cc;
  // synopsys translate_on
endmodule
`endif
