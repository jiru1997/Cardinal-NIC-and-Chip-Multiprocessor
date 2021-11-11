////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2001 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly    Aug. 7, 2001
//
// VERSION:   Verilog Simulation Model for DW_ecc
//
// DesignWare_version: 92af6f98
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Error Detection & Correction
//
//      Parameters:
//           width       - data size (8 <= "width" <= 8178)
//           chkbits     - number of checkbits (5 <= "chkbits" <= 10)
//           synd_sel    - controls checkbit correction vs syndrome
//                           emission selection when gen input is not
//                           active (0 => correct check bits
//                           1 => pass syndrome to chkout)
//
//      Ports:
//           gen         - generate versus check mode control input
//                           (1 => generate check bits from datain
//                           0 => check validity of check bits on chkin
//                           with respect to data on datain and indicate
//                           the presence of errors on err_detect & err_multpl)
//           correct_n   - control signal indicating whether or not to correct
//           datain      - input data
//           chkin       - input check bits
//           err_detect  - flag indicating occurance of error
//           err_multpl  - flag indicating multibit (i.e. uncorrectable) error
//           dataout     - output data
//           chkout      - output check bits
//
//-----------------------------------------------------------------------------
// MODIFIED:
//
//  10/7/15 RJK  Updated for compatibility with VCS NLP feature
//-----------------------------------------------------------------------------

module DW_ecc(gen, correct_n, datain, chkin,
		err_detect, err_multpl, dataout, chkout);

parameter width = 32;
parameter chkbits = 7;
parameter synd_sel = 0;

input gen;	// checkbit generation control input (active high)
input correct_n;// correct error control input (active low)
input [width-1:0] datain;   // data input bus (generating, checking & correcting)
input [chkbits-1:0] chkin;  // checkbit input bus (checking & correcting)

output err_detect;	// error detection output flag (active high)
output err_multpl;	// multiple bit error detection output (active high)
output [width-1:0] dataout;	// data output bus (generating, checking & correcting)
output [chkbits-1:0] chkout;	// checkbit output bus (generating & scrubbing)

// synopsys translate_off
`ifdef UPF_POWER_AWARE
`protected
>b3><Eaf:7eVKF]6##NWe#g0N6R+E_IP)D:+._c)Q>LRdB]<E:_K-)=Z<.5@^\.>
K=G]cM[F8LRC94#VeLN7#0e#.Y6be5)D0;(eR?#7Y;JG2WH5JC#ZQBOBYR3I?G2K
Jb]90H-dcJ^9ZG/A^I(II(+K4NYZg:U:LU&SK/ZW\?d;A7fBYK=e&9-<)VD[OEPL
_NbT/>S=;K<eA6e?BD[)eMS-/3J\&NdeB[GX=@;MULQCMNSC&>7)=6)[S:4/U/3:
OA,+\T_1)CD&NfH2&e)-IKT3<:W4Qc\/fZgaXabN-?UE6NC,;2G^F,X_Ne)9X620
92f2:;g+N]=&2^beAV<O^:FD0FFBc\^CGP,Z6QF3B?BCcA=d._K)7YWZA?V6<9>>
&M/2@\_NC\_B<#^BfFDTW)9S8e>TVT>L043d04B-\3U99N[LJF.9>\;MNX]G>&Wf
-TC_dbY\?T)H(TO\AA)O-.B(01,8_5C865b[^DA-</S:X0>N>)/G]2N97ZW/&6JO
RR>^)b/]&Z5:C3@&KBQH<M-7UfI7Z<EK8^E.\\M[>+XbFM[SZ^#,[<Y.1Ng@NLb2
,&L@Bg0b@3SM#(8]@ER3T2\O]7EQDf;ISR,JZZ&R?Ze;TQ)HT44Y_J,@SQ-750aA
a#[fDM::(f](9f+TSIQVe21Og3a]g5.\g?,+UK[A1Z.T+]Q@(\Y6U9>JM+-[G2W:
-VV[?\<Q)b-L7bN4>3QHO,&d3@.:aQSeF2e5GO&\34bP?-2-Y7ABOgb=/1X=<O-c
CKN<I,QgZ-=Fd+[.GHOX@g=+EF(&OZ[d,7:&bVccRE2#:G(;G)Q2&AV[9P=-R0b]
Ia?,5TLgW&\5J\)YJRa[YdAF::K^R:3^VL=X3VF,)V,0dW.GE]IB^d;1>Jg9(7.R
EIP^J[_S8Q<LY5SdW5O6V((]fHTO#4\\CLba+C/Eg[\PS5_G_MACU@,aOTe[Ee+N
]-F,,-_c>P=fa>Z2SaJZPaW/3IWSYb47K]VC^IS;O4-[13[8PM/PUYQGd8?55A7S
,3=OEE97#<ac7a15WXOQd84HZ5?(VLDB<P@Rd][5)(S[UNJM;R7K?H[W:(U\,J56
_EgI30F1.OP3Ia.]+Z?Y,0&QdNY,J:d1KLT,g\IcC\1E?CHCOS/3cGS(64BP5_H6
56\B:d2X#A\#)0d?bW2)W3#V+)9RF71IZB#W7;P6;<1=+cC)0G[LFe,FA^C?U8).
&HXS]b5\_ZJB]OcF&&F,6EAV76bg&U#G>H:gJD^KaKG/c&VD+K)M3:-RA_f)N9(O
?NbW_M7.W#,LE3gL>UT)Z,;2]KZ\D_##eV?4-P(?Wb;;RJ&aIZfgDS)BBB=H1T],
1;H)34)M95FaUTM4J)@/1G\]7I:9VU+aYE()dCbf0A,VJ)CEMT,/<F\#IRK7]37/
3AMQg1a<JX]=VHcO94ZgRG1MA/,[&OZ(L0e\7#YYJ,#>5ec5H;N.78WA&DJOVP]+
?QPef15IcR=:KO9:=FW/C7#A1ADab<TV0+e70APQ^a:(/T]FIg/&bWJ\X/34K@fW
?V_8)Eb(=R->]OOWf--fV/TPW0eQ\;\I)ZUVGSD](WZ1\8+HA-C:&AEVZ/THbc_@
MW/:1[;Y;/_W)(R<_P/.WNX[RIJ:6b6N0.A([eN]IA(,N^Z2CIHBBQ<6TZ8:?KU[
5NE/K]&^IQ51Yc\=\.5=8]NYa#/&I8]/c)7HMf5#CaZQ+TPEJK(Q6:<[ZBAbP[Uf
+TeFU[Kf0Y\AC;+[c\)fc1=R:E].DS)+@@?5QENeFZBYAN80fN^gX0<[#4O?:MC.
930d#:9S:6LYg#c+dBG4&9C\84:PQ\cJbHZ[7bYIO6bU.^\9M1GE9FX0ccM.AZ6&
V(T\]Oaa[FF?eNZNDZJU7eWCB(g6:bd?Vf]aW3CM+]C+O-\O;^bX0B47IcaBP=,I
GNC1>cdC,b#cI/EdOKOO])ReS_?LROcR_B9T^+^&89WLgdH)4L8gg84<^78#-;6E
>I3/H;CS/B^^c#_bPGfG_#CK6<f+2BHF&;=J4/bFeg/6+X8=//:]IENTNfR?_O<P
[MZ#2JRa>>1T@30YT@3GYgPa-LTOV&+8^804^D?TdaJ:\)L];.0Aaa1e\QA>bY[A
_I/)V/4;&c#0\=WFDL;K?eGdO9=F^=1S0;[c?HEP7Z+R7O^IBI_bOg:;[NY.=<,X
I7;7+ZPHcJbMIR)ee7E<7<5;Q61SGRJ_/O3V\J4U]30>8^g\/Uf=+#e1b:01VVJ3
=e.2)A_OS8:G[]>M5Hf>bR5X]Z)//K&a(S>5#Cd&_7YUBD.;1ID9T9]GZADF:/@A
aP:,SSH\?AF95\?C[U27&0eD2<VF<g.Q:7C0H+.#EAX+MLeG/&2<@JgV].3EHD:^
>?EUQ7e6IaMWEPEW)V[8BBZ6>5/dXa[V=XK7Z&P&8P)U15_K/94b#44Gd7O>69:<
&_+^S]_+7g@E85#BD_#@GX345fb0EI08R0a[UcFU>JJC]_H&OKA,3f^2a#5M-0;]
UA]LP91>=MI)cR<g#R7F-_^O13a&Q+PF-\H+feSH3Z7-F>AR+YF]7LNc=1SCKBW6
acEJc9Ug>:dRR>KgT-];d?D_QJV@^_VHB6B_)e;\7/24;JAPcdgfaJ4]/I/(.5Ed
?AB\XAg):cdX87)dQ4a<NQOX-QP0eU4Sc8>-S[^>Y+DdZbM2,fE1;AIZGL#PH01)
Q7\fRfOaIO.LMb-ZZ/3OEDQe@>S@L_WQ.Z;^A&R_WN=?&2JVNc)O=PNDc/:PLHW^
3g-BRIb:X>AEOdbKZY^f+;O3;<.2g\DVXBS4CRAQbFeG::e@I?V6ee/NcSRXcTL8
N@I3#TKMFF4[bafNKNZS.&P)^]c)&DT+0O):5^\gGaLYEDaHE,@)f<T-],-XC\V/
+R=G^RN#&U?(YVfPT,O+WL\\VVQOc=ZMH?LcH+d]DZ>Rac4@b\Ub;RE-@V&ID&<)
EAA>fD9/#(OE+c)+f1BQ18>.DDC8,<bSc\aQYTN)Q&]-Lb<D69>RV]FXYXdgA3J,
,NA;K.VcLJe8a]>AV&29(f9TRg&?#PB4#FcdD8SLG>CDgU..C9^)D1?^Z7TUfD-J
7TQBWWWX+7Q/5ERX2Q7aXI#NB-QZ\=1JSEgFBUb&YIX9R0Oc:G@_QRQ<VXO1(a,7
):U1)(+f1[WS><6.-D0806ba=YVGN?AEX6;FRY/dLd3=ANG:B=9([AX]Y0--(([J
D2XS?e?\5=[FXd@1=QG5AQCBd;@GEP0e9IC22[PV]9)>T);F8YPe=,DSZD#Oa-5/
@])MTfGaQNd:2?M>GUeR2@J^dO6a-)EIaVI\a)4W(^_Pg;^>IFGf2[1M\LJ^0HA[
.?B.HcS&IUfVN+,.TdUf?PQM3O+8;3;\DTT^e(b/>dQT7VX(2F\L:#=-\S3/N7C&
a/fCN7:_D+=#5IcKKUT.5DS(356cc(6CC_/J8ZTP(+&RdN4E7SFeXWV).Tc63OI0
])/b73Y@<9X#&8J<)9])Z50;56]SAKYA\R:2K6+J85+\@aBD4E\_7-De>]L^<H=N
S#KGc0SZEF3A3:_=J=f8VWI8b6c#Q^X]U(VY>^-fWD-9I5a?aR]8<NS,<+8&=([-
b70^-#8A>V<bd]4)OeR>.b[49ZU+UP70QG5VCR@]S6,PA-a[G)FV\aaQ#7e4XUAK
4:F_876PHUZ(:G:W)FX\.NS\=OaPO[^KK9\.96O1bOaOK9F5:>fESfg,B&I7M>,=
_1H8D>(_E)GOZ35N;Y@FW<PfYRJ:QH&_&&dDfHEMT/=\MWKbWHF8YS.bEJ;2@/AT
[K#.Q,?[Id;b2d/4(fLK=a0)g_fH219[c0.g8;0&#8=TU0=Q]5B@@,8/=0;4S\>O
T+>H5&1>(2BKVD0T/+9@6DTS=V37E5S#)S+340cMG,]gUH2YYRD0:.HC(_LY3G;O
KK_eG\[7J>ac+QEK8L@&,YSA;UV=b_8Ae8><Z)GH,8H,I),W&<Q,;F..KSNE9&TF
5Z:QN7JG8R[<W/8?T<e):J9WRIA_;be_cS]7d)&^AXZ.3L)a\_+X.P/P46]e(VR#
8;<6DTQZ+JTfeNS;=-+e2&6cGRf4_Lb?Q)^(;=J[H7KIYeJ:;a3V^?M(^.c<6FJ/
fJ#+?Dc9WOd<_+11@^g)g)aG5J(_[75UMcCf?f8(W;PCQ8M?>+_R<]+Pagb<&)8c
P-f_G1Ke:7c.BSKg,;N(3b\@K7bbcOO/-^;UA?/@:0]Ga:B)UN#&&1[V1D/NLHAZ
\9-+I2EMdASKfKe<,c+<I^E#b0AFDgKYbFQ#W@_d;_H5.QL>Sd]3+OV7>aV>d_#A
Q#a52Q42WG^@A_VHCLBg6NL0G6;,/fJSOaF>ZPB/>R/]]fc>8O<#U4S?QPBcFR#]
:VG<0=@d4[OgZ2UN=[BTWBL2AS6MTT1?,;La[L,-BSQS<3[b#bHD6:_^T^49^c36
1dNPD\:?D/^+S:NHBJ?1+HCP8]#W-E7_8dUf5-G+5Ud>C,V]\SJUZX9B&4A6(,VW
J74S5f7MRZ:;T=47>P<1\[D[0;PdDIK.c,DaP,(]07\@_AD],eJM5KU&GfGQS@NV
1Md,4f#[X6eU3/XUD1:_](Dg7[Y1B?NK1MU8c0+:C8DSK(.;K4bSDO8(\U6CgWg0
X5&4K-(A@J/Sd]W>2)T>2g3FXC+[N[?SISBDCKLJCC.SF$
`endprotected

`else

 integer OI11IO001, I1011Ol00;
 integer O1O00I001, IlOO01011, IIl1lll10;
 integer lO0IlIOl1, O1I1IO0IO, l1O0O110I, O0l1O10l0;
 integer OIOOl1I00, O0Olll0O0, l1IO10001;
 integer II010O0O1,  lI1O010l1, IOI001111;
 integer O0O1O11OO, O001O1Ol1, OO0O101O0, OlOOIO10I;
 integer lOlIIl001, I11000011, lOO0lO1O0, II1Il0l1l, l11O1O1II;
 integer Ill11O01O [0:(1<<chkbits)-1];
 integer O1111l11O [0:(1<<(chkbits-1))-1];
 reg  [chkbits-1:0] II0O00OIl;
 reg  [width-1:0]   IIO0O111I;
  reg [width-1:0] O00ll11OO [0:chkbits-1];
`endif

 wire [chkbits-1:0] O000001OO;
 reg  [width-1:0] IOO11O1I0;
 reg  [chkbits-1:0] OI1l0OOOI;
 reg  O1OO110OI, OO11O110l;

  function [30:0] OI100OI00;
  
    input [30:0] O01I10010;
    input [30:0] I1011Ol00;
    
    if (O01I10010) begin
      if (I1011Ol00 < 1) OI100OI00 = 1;
      else if (I1011Ol00 > 5) OI100OI00 = 1;
      else OI100OI00 = 0;
    end else begin
      if (I1011Ol00 < 1) OI100OI00 = 5;
      else if (I1011Ol00 < 3) OI100OI00 = 1;
      else OI100OI00 = 0;
    end
  endfunction


  function [30:0] OI10l11ll;
  
    input [30:0] l1Il10O1l;
    
    integer O0O1O1101, lO1lOOlI0;
    begin
      
      lO1lOOlI0 = l1Il10O1l;
      O0O1O1101 = 0;
      
      while (lO1lOOlI0 != 0) begin
        if (lO1lOOlI0 & 1)
          O0O1O1101 = O0O1O1101 + 1;
      
        lO1lOOlI0 = lO1lOOlI0 >> 1;
      end
      
      OI10l11ll = O0O1O1101;
    end
  endfunction
  

`ifndef UPF_POWER_AWARE
  initial begin
    
    OI11IO001 = 1;
    O001O1Ol1 = 5;
    lOlIIl001 = OI11IO001 << chkbits;
    l1O0O110I = 2;
    lOO0lO1O0 = lOlIIl001 >> O001O1Ol1;
    O0Olll0O0 = l1O0O110I << 4;

    for (OO0O101O0=0 ; OO0O101O0 < lOlIIl001 ; OO0O101O0=OO0O101O0+1) begin
      Ill11O01O[OO0O101O0]=-1;
    end

    II1Il0l1l = lOO0lO1O0 * l1O0O110I;
    lO0IlIOl1 = 0;
    I11000011 = O001O1Ol1 + Ill11O01O[0];
    OIOOl1I00 = O0Olll0O0 + Ill11O01O[1];

    for (IOI001111=0 ; (IOI001111 < II1Il0l1l) && (lO0IlIOl1 < width) ; IOI001111=IOI001111+1) begin
      O1O00I001 = IOI001111 / l1O0O110I;

      if ((IOI001111 < 4) || ((IOI001111 > 8) && (IOI001111 >= (II1Il0l1l-(l1O0O110I*l1O0O110I)))))
        O1O00I001 = O1O00I001 ^ 1;

      if (^IOI001111 ^ 1)
        O1O00I001 = lOO0lO1O0-OI11IO001-O1O00I001;

      if (lOO0lO1O0 == OI11IO001)
        O1O00I001 = 0;

      O1I1IO0IO = 0;
      O0O1O11OO = O1O00I001 << O001O1Ol1;

      if (IOI001111 < lOO0lO1O0) begin
        II010O0O1 = 0;
        if (lOO0lO1O0 > OI11IO001)
          II010O0O1 = IOI001111 % 2;

          O0l1O10l0 = OI100OI00(II010O0O1,0);

        for (OO0O101O0=O0O1O11OO ; (OO0O101O0 < (O0O1O11OO+O0Olll0O0)) && (lO0IlIOl1 < width) ; OO0O101O0=OO0O101O0+1) begin
          lI1O010l1 = OI10l11ll(OO0O101O0);
          if (lI1O010l1 % 2) begin
            if (O0l1O10l0 <= 0) begin
              if (lI1O010l1 > 1) begin
                Ill11O01O[OO0O101O0] = ((O1I1IO0IO < 2) && (II010O0O1 == 0))?
            			    lO0IlIOl1 ^ 1 : lO0IlIOl1;
                O1111l11O[ ((O1I1IO0IO < 2) && (II010O0O1 == 0))? lO0IlIOl1 ^ 1 : lO0IlIOl1 ] =
            			    OO0O101O0;
                lO0IlIOl1 = lO0IlIOl1 + 1;
              end

              O1I1IO0IO = O1I1IO0IO + 1;

              if (O1I1IO0IO < 8) begin
                O0l1O10l0 = OI100OI00(II010O0O1,O1I1IO0IO);

              end else begin
                OO0O101O0 = O0O1O11OO+O0Olll0O0;
              end
            end else begin

              O0l1O10l0 = O0l1O10l0 - 1;
            end
          end
        end

      end else begin
        for (OO0O101O0=O0O1O11OO+OIOOl1I00 ; (OO0O101O0 >= O0O1O11OO) && (lO0IlIOl1 < width) ; OO0O101O0=OO0O101O0-1) begin
          lI1O010l1 = OI10l11ll(OO0O101O0);

          if (lI1O010l1 %2) begin
            if ((lI1O010l1>1) && (Ill11O01O[OO0O101O0] < 0)) begin
              Ill11O01O[OO0O101O0] = lO0IlIOl1;
              O1111l11O[lO0IlIOl1] = OO0O101O0;
              lO0IlIOl1 = lO0IlIOl1 + 1;
            end
          end
        end
      end
    end

    l1IO10001 = OI11IO001 - 1;

    for (OO0O101O0=0 ; OO0O101O0<chkbits ; OO0O101O0=OO0O101O0+1) begin
      IIO0O111I = {width{1'b0}};
      for (lO0IlIOl1=0 ; lO0IlIOl1 < width ; lO0IlIOl1=lO0IlIOl1+1) begin
        if (O1111l11O[lO0IlIOl1] & (1 << OO0O101O0)) begin
          IIO0O111I[lO0IlIOl1] = 1'b1;
        end
      end
      O00ll11OO[OO0O101O0] = IIO0O111I;
    end

    l11O1O1II = l1IO10001 - 1;

    for (OO0O101O0=0 ; OO0O101O0<chkbits ; OO0O101O0=OO0O101O0+1) begin
      Ill11O01O[OI11IO001<<OO0O101O0] = width+OO0O101O0;
    end

    OlOOIO10I = l1IO10001;
  end
`endif
  
  
  always @ (datain) begin : DW_IO010IO10
    
    for (I1011Ol00=0 ; I1011Ol00 < chkbits ; I1011Ol00=I1011Ol00+1) begin
      II0O00OIl[I1011Ol00] = ^(datain & O00ll11OO[I1011Ol00]) ^
				((I1011Ol00<2)||(I1011Ol00>3))? 1'b0 : 1'b1;
    end
  end // DW_IO010IO10
  
  assign O000001OO = II0O00OIl ^ chkin;

  always @ (O000001OO or gen) begin : DW_I10l100O1
    if (gen != 1'b1) begin
      if ((^(O000001OO ^ O000001OO) !== 1'b0)) begin
        OI1l0OOOI = {chkbits{1'bx}};
        IOO11O1I0 = {width{1'bx}};
        O1OO110OI = 1'bx;
        OO11O110l = 1'bx;
      end else begin
        OI1l0OOOI = {chkbits{1'b0}};
        IOO11O1I0 = {width{1'b0}};
        if (O000001OO === {chkbits{1'b0}}) begin
          O1OO110OI = 1'b0;
          OO11O110l = 1'b0;
        end else if (Ill11O01O[O000001OO+OlOOIO10I] == l11O1O1II) begin
          O1OO110OI = 1'b1;
          OO11O110l = 1'b1;
        end else begin
          O1OO110OI = 1'b1;
          OO11O110l = 1'b0;
          if (Ill11O01O[O000001OO+OlOOIO10I] < width)
            IOO11O1I0[Ill11O01O[O000001OO+OlOOIO10I]] = 1'b1;
          else
            OI1l0OOOI[Ill11O01O[O000001OO+OlOOIO10I]-width] = 1'b1;
        end
      end
    end
  end // DW_I10l100O1

  assign err_detect = (gen === 1'b1)? 1'b0 : ((gen === 1'b0)? O1OO110OI : 1'bx);
  assign err_multpl = (gen === 1'b1)? 1'b0 : ((gen === 1'b0)? OO11O110l : 1'bx);

  assign chkout = (gen === 1'b1)? II0O00OIl :
  		  ((gen ===1'b0) && (synd_sel == 1))? O000001OO :
		  ((gen === 1'b0) && (correct_n === 1'b1))? (chkin | (chkin ^ chkin)) :
		  ((gen === 1'b0) && (correct_n === 1'b0))? chkin ^ OI1l0OOOI :
		  {chkbits{1'bx}};

  assign dataout = ((gen === 1'b1) || (correct_n === 1'b1))? (datain | (datain ^ datain)) :
  		  ((gen ===1'b0) && (correct_n === 1'b0))? datain ^ IOO11O1I0 :
		  {width{1'bx}};
  
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if ( (width < 8) || (width > 8178) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 8 to 8178)",
	width );
    end
    
    if ( (chkbits < 5) || (chkbits > 14) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter chkbits (legal range: 5 to 14)",
	chkbits );
    end
    
    if ( (synd_sel < 0) || (synd_sel > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter synd_sel (legal range: 0 to 1)",
	synd_sel );
    end
    
    if ( width > ((1<<(chkbits-1))-chkbits) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination (chkbits value too low for specified width)" );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  
// synopsys translate_on
endmodule
