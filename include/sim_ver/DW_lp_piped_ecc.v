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
// AUTHOR:    Doug Lee       2/6/09
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: ea4754fd
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Low Power Pipelined Modified Hamming Code Error Correction/Detection Simulation Model 
//
//           This module supports data widths up to 8178 using
//           14 check bits
//
//
//  Parameters:     Valid Values    Description
//  ==========      ============    =============
//  data_width       8 to 8178      default: 8
//                                  Width of 'datain' and 'dataout'
//
//  chk_width         5 to 14       default: 5
//                                  Width of 'chkin', 'chkout', and 'syndout'
//
//   rw_mode           0 or 1       default: 1
//                                  Read or write mode
//                                    0 => read mode
//                                    1 => write mode
//
//   op_iso_mode      0 to 4        default: 0
//                                  Type of operand isolation
//                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
//                                    0 => Follow intent defined by Power Compiler user setting
//                                    1 => no operand isolation
//                                    2 => 'and' gate isolaton
//                                    3 => 'or' gate isolation
//                                    4 => preferred isolation style: 'and' gate
//
//   id_width        1 to 1024      default: 1
//                                  Launch identifier width
//
//   in_reg           0 to 1        default: 0
//                                  Input register control
//                                    0 => no input register
//                                    1 => include input register
//
//   stages          1 to 1022      default: 4
//                                  Number of logic stages in the pipeline
//
//   out_reg          0 to 1        default: 0
//                                  Output register control
//                                    0 => no output register
//                                    1 => include output register
//
//   no_pm            0 to 1        default: 1
//                                  Pipeline management usage
//                                    0 => Use pipeline management
//                                    1 => Do not use pipeline management - launch input
//                                          becomes global register enable to block
//
//   rst_mode         0 to 1        default: 0
//                                  Control asynchronous or synchronous reset 
//                                  behavior of rst_n
//                                    0 => asynchronous reset
//                                    1 => synchronous reset 
//
//
//  Ports        Size    Direction    Description
//  =====        ====    =========    ===========
//  clk          1 bit     Input      Clock Input
//  rst_n        1 bit     Input      Reset Input, Active Low
//
//  datain       M bits    Input      Input data bus
//  chkin        N bits    Input      Input check bits bus
//
//  err_detect   1 bit     Output     Any error flag (active high)
//  err_multiple 1 bit     Output     Multiple bit error flag (active high)
//  dataout      M bits    Output     Output data bus
//  chkout       N bits    Output     Output check bits bus
//  syndout      N bits    Output     Output error syndrome bus
//
//  launch       1 bit     Input      Active High Control input to launch data into pipe
//  launch_id    Q bits    Input      ID tag for operation being launched
//  pipe_full    1 bit     Output     Status Flag indicating no slot for a new launch
//  pipe_ovf     1 bit     Output     Status Flag indicating pipe overflow
//
//  accept_n     1 bit     Input      Flow Control Input, Active Low
//  arrive       1 bit     Output     Product available output 
//  arrive_id    Q bits    Output     ID tag for product that has arrived
//  push_out_n   1 bit     Output     Active Low Output used with FIFO
//  pipe_census  R bits    Output     Output bus indicating the number
//                                   of pipeline register levels currently occupied
//
//     Note: M is the value of "data_width" parameter
//     Note: N is the value of "chk_width" parameter
//     Note: Q is the value of "id_width" parameter
//     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
//
//
//-----------------------------------------------------------------------------
// Modified:
//     LMSU 02/17/15  Updated to eliminate derived internal clock and reset signals
//     RJK  10/07/15  Updated for compatibility with VCS NLP feature
//
////////////////////////////////////////////////////////////////////////////////
module DW_lp_piped_ecc(
        clk,            // Clock input
        rst_n,          // Reset

        datain,         // Input data bus
        chkin,          // Input check bits bus (for read or scrub)

        err_detect,     // Any error flag (active high)
        err_multiple,   // Multiple bit error flag (active high)
        dataout,        // Output data bus
        chkout,         // Output check bits bus
        syndout,        // Output error syndrome bus

        launch,         // Launch data into pipe input
        launch_id,      // ID tag of data launched input
        pipe_full,      // Pipe slots full output (used for flow control)
        pipe_ovf,       // Pipe overflow output

        accept_n,       // Take product input (flow control)
        arrive,         // Data arrival output
        arrive_id,      // ID tag of arrival product output
        push_out_n,     // Active low output used when FIFO follows
        pipe_census     // Pipe stages occupied count output
        );

parameter data_width = 8;  // RANGE 1 to 8178
parameter chk_width = 5;   // RANGE 5 to 14
parameter rw_mode = 1;     // RANGE 0 to 1
parameter op_iso_mode = 0; // RANGE 0 to 4
parameter id_width = 1;    // RANGE 1 to 1024
parameter in_reg = 0;      // RANGE 0 to 1
parameter stages = 4;      // RANGE 1 to 1022
parameter out_reg = 0;     // RANGE 0 to 1
parameter no_pm = 1;       // RANGE 0 to 1
parameter rst_mode = 0;    // RANGE 0 to 1




input                          clk;         // Clock Input
input                          rst_n;       // Reset
input  [data_width-1:0]        datain;        // Data input
input  [chk_width-1:0]         chkin;         // Check bits input

output                         err_detect;    // Error detect output
output                         err_multiple;  // Multiple errors detected output
output [data_width-1:0]        dataout;       // Data output
output [chk_width-1:0]         chkout;        // Check bits output
output [chk_width-1:0]         syndout;       // Syndrome output

input                          launch;      // Launch data into pipe
input  [id_width-1:0]          launch_id;   // ID tag of data launched
output                         pipe_full;   // Pipe slots full (used for flow control)
output                         pipe_ovf;    // Pipe overflow

input                          accept_n;    // Take product (flow control)
output                         arrive;      // Product arrival
output [id_width-1:0]          arrive_id;   // ID tag of arrival product
output                         push_out_n;  // Active low output used when FIFO follows

output [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]       pipe_census; // Pipe Stages Occupied Output

// synopsys translate_off

wire  [data_width-1:0]           O00IlO0I;
wire  [chk_width-1:0]            IOOI1O00;
wire                             O0lI0O1O;
wire  [id_width-1:0]             O10O0O10;
wire                             I1O0O1O1;

wire  [data_width-1:0]           O1110110;
wire  [chk_width-1:0]            OOOl1101;
wire  [data_width-1:0]           O1II11O1;
wire  [data_width-1:0]           OII1OOl0;
wire  [chk_width-1:0]            O01I11IO;
wire  [chk_width-1:0]            I01OO00O;

wire  [data_width-1:0]           O001IOl1;
wire  [chk_width-1:0]            I101OO10;
wire  [data_width-1:0]           I01ll0OO;
wire  [chk_width-1:0]            Ol0I0lO1;

wire  [data_width-1:0]           I10IO1Ol;
wire  [chk_width-1:0]            OI1l0l00;
wire  [chk_width-1:0]            O010010O;
wire                             lO00l00I;
wire                             I0O11O11;

wire  [data_width-1:0]           O0llOO1O;
wire  [chk_width-1:0]            IO1lO0l0;
wire  [chk_width-1:0]            II000OOO;
wire                             I10O110O;
wire                             IO100O1I;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     O00l0I1O;
wire                             OOOOlIO1;
reg   [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     O10l0O0O;

wire                             O010lO10;
wire                             OOO1O1OO;
wire                             I1O001OO;
wire  [id_width-1:0]             IOO11O11;
wire                             OO1lIIO1;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     O00101I1;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          O1O1IlO0;

wire                             l1I101lO;
wire                             OO1IOO00;
reg                              I10l1lO0;
wire                             O0O1011l;
wire  [id_width-1:0]             l0OOl11l;
wire                             I0IOIl1O;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     IIO10010;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          OOO0Ol0O;

wire  [id_width-1:0]             OlI0OIOI;


  assign O00IlO0I     = (datain | (datain ^ datain));
  assign IOOI1O00      = (chkin | (chkin ^ chkin));
  assign O0lI0O1O     = (launch | (launch ^ launch));
  assign O10O0O10  = (launch_id | (launch_id ^ launch_id));
  assign I1O0O1O1   = (accept_n | (accept_n ^ accept_n));



`ifdef UPF_POWER_AWARE
`protected
DB33(::QQ);BVN&1=Ed__X9(=?=aYR;_,@06Rf5#)K>CgK=Q0,1Y2)B?4c^;/YOK
L=0gB@4^:CQ0G-@?=cd]Q4\0G,B)S#NV@?VXYa-?eFK(VPQ1-bb)JT04T2@-SWfC
>PIaP0@4?=BX5P;:-O^O]1(/+Ab8DR8&<?E(/7JA1,E;ZA5-H<-:H3K^dJ.D1>_L
aNAXH?RC6BYI[NO]Q@I[1F[0A?^@(ZT;,7026(NZ80;JbOXDRKPgd,KN3I@@)NVQ
.?A/H4a,Q](F:7ABJ?QJYPKSfJ)gHP9[.Jd#YT9/2F?V,T@Tb@fV6DJS(1>J5Ra#
ICeS3e7SWM/a2Vf<^L;Q8c0@B]SX=V<?5IcU3<CcJQfFN<].C0UA);c1?=f0J;L(
2#DaEYDa15?Gb\.0])?M3T_e1e/FVFV+dEDG5b.0MZ3H=,BA[U=UQb<.IP=4S[K2
9-A+N;VXXT0<Z7ZX=@9.<.e78a=2dd=,c.ecWAT+IH]E+PQ[[QR/O&UE^LA=\.7J
5N50MM1MO23TN]U5IE<Y]HaVI,)Q\f5_H<PN_GB:64H8P==,YPRY7S=.c\T)XU@b
/5L&@3ZX]=,3(4<0=GH.Q7>O?X@DaM>2D@F]SJBFBOX(0LO-^B@T2XU+[XJ(04WN
97Df1-9BfXHe@38[a>BO=(2?:6>V\=,M2f[0])R)JEKcFK>XR1==I6^Q763KF4VH
6VIcJHM.cfC3VE\ZRaRe[[1<=&Y63I@/.eTD?-;R&I2SbFJ3OaFUTc(T9E;8VZW(
degB)@Ld<dQ73fd9<df7&>;<6(f;A.P0#?DH2),9fB[RAdMbg5J8;_<88+M1\A+G
:,MXO9YGA-PT=2R&F\]N,Aedc4g>Vb-cb&0^;C;f0MEC4X53OQN4Y7/<>XZ6TT=D
eN#A@E2]W_RY^)U6J#KQga&&;c3af7W1eF)^6O>Y6W>88YNFW7,A^6;BQ=0JQ+0I
MKa0E>M6RNSO>M>3[+@gBPWCQV/S2T<1\(]-V2RJ1L?98H6-e8b9(9F4FLG8+4aG
3bXT]XS^==&?IM+RIeTf-gT,[Ia>#;eOb3MA6=Y<?43G:<:/W#If11,<<d.e@\3I
[1NMMAa1X.3-a#/O9YK8SQ6NIOaT(N8SbFWLA,Mc(<-4#+^XWV[)=dC&^XI..><>
:S8AKIe<+:O1+YEG<0ZYRQX&aB.DK]\?->B>aCBXJ8CK^;4,OFfDd;Mg=#b]9c#0
@6(WE\&J]6=0JRD_ZZM0XLTP):Z.DcbF=O/64\\MO&W(dGD>U+#=d,fe]BZcDVfO
C_F>J2f)\]fB?.)<N29@g>SNQ8_84=\Z8]9=>8L^#(Z>QK.?;14bPQD)D-g][4<\
?J3Q4NeQ@DV6L;^@<+Z7[SbP)OTG5,U3^0_-dTZ.a@FMNP&;c^E/cb#McK<J>D?d
S-L6HUb>6)_QD0D<bG]1#dNM>V<K5K:D-YTF)\38,4:T6a,BV&(T=B^]F0ccLQNT
ab].1A#?C1T[O+#c]gW0AQ,1J=G9W5>D;W&/>:[XXQ_LgZY?>fR[=<UU?ZgB#/D]
a7RY/\RSa[-/AHB3#T>de\e7aL5+MC+X-eYcL-?b^H4?bS:6L/65:;R106VdNQ?U
V_:8)8=JIQ?Q1QZJH4(PND@O@R^6=GZKR7M]?,eR1g92&C,X&fD9]^WJ=O_JQS)e
HF\[7Fa_g<RGgHK8)OQ@I2U+.&,-@a1-8ddM?T9(L/b4A0XQ8EgLG54b?R[^\^\L
G7V;dR@/dK0^<eA@5GMbB)VZ=+U\JAD<ASDJ[<=(1A\_>?D=MYg;)Bd4TBO<</EH
(GG@cF8K__,F5V[-<-(KZW=[@>/5KPa@0,UCB^[;=d41Of_FBZW&B+c<EI(()ZWJ
6,S&d&&=D6XH+F>Sg;0EKEK5\:>NH2UZIV)PU:K\f6M;EM:S47[=/V5Ke\E2:KD8
+&:7b</PPOYQN9XZKGY/Y-eR^W9,LE()XgA\NUBdXPPdPVEO+6FK>GY&O[QJZ:\8
Xd+IS>D,a5ZJ(.P/MI6,c<@c<5[bGX4&?QRdc1T@d9LKA1BeV?9c\<?_?3-_RFT:
E-fBOKLEWbT_H_R]dTH1F.7g0<UT#9-a.6:582_@;Z3ec)Qd7XcQCXDI8]4L:1U,
cKQaUCP01d_::BR@E#fZ)/@aU,U\L;38@.-W9Q>4\Ig1;6.RI@X_XF#7];JQN9SW
5SBAC&2-C./YH6,D>YVQB?>4I+9H[8UUK(bg;]L-KWV#VDX6K&&@dTE9R.T]+edZ
6H<CQ/J+Oe;C2_ObcGfTFcb3)U;c,b3B?0RRKeKEgg#JcU[,->S<>@IIGZeNQ=Y)
Xb_C&;ZKDf3LSF0&03FMQ\Q[E[dMO36gCMLd039Cd_,=P1732#N&N#V3-WOSU2Fc
Qa<-a_/HDF_FSebT1TRLP6D<B]F;()N-D)#MXT3ZWcW]d+gb2<A\=AdT?,?]YfIS
.B;ZN#gOIJ7cd@0S7be[N]2^FZYY&3U@0>DDXUYIN7;eE77Q,;9Q2Y^XNNaRO[?8
XKI3FEG#I]9dR?34gCY1D\6d#H]\HaEb\TD^K?NH-HgR;_WUC9;dVd?Y:JB3&4^a
_ZQd<YQ(ec=94[Ed\I59QY&QCE6CPUYS:aS<UO><]W)<5@,81.45AOX]>.I=^CVY
5].C/Z-&&P4/6:@f.,&fU(Tf4.[J^f<BYM)[EG/9.;J+f^MKDVD<WIU/<\R(&Jf-
R8WG/a@X<_(;&BH[?V5X[d048?7VP^aRH]0,\/bRb[@^UGL9#@#;^D0=4D]b>b2Z
ZM_<=>UOPNDRJY=2C@QR8U&=75JTJU=3a[W-V>=T-_@3<=;c^QMAd&aMZ]B5&1eS
P8S9fJ&,XB&G(K^D8MbUc?0UfIc>SgG5f@FUHR<4V-[QX#CC4>Wd[U@A^^I@9KNH
@:\K\4KQ.XE,?&(e6c8D-d<OM)>[/IaP;2+cVgC4;1&AJ@II5@APdS(XId+cH]/+
GO.eVb>U?A:2@&1GAK2EE]C/XMX,].KILH8.56bGXPZW2#F/H\b[LaX/8H6_4aJ(
733(4S4YWDYTWT+^EdVA=N&Z@+DZ=700dd^U0\Z9d.@I9DCL;f9/]\4MU;0I3GD)
BFU9@J+3V:NAVV7KJ56NB^AQS=#I+//(dD[1R)XO.aT,f,eS7FAf5@3:E7(.f\Nd
KdEZ+FS5e966a,NCaGRZa)c9?QXG5da)8d;8We3_.?V7>^)a-BCQc+4R+cIV,@1N
Y6+7VG]U4UW8e,D>&P.;de2<<g48:QZTT([PIN4a\1U5d5d1N6WOWQK4.3^)]W],
@@,g6(\BV1f(TETR8[J+>^;XO)0WK0#+Tb#4&X8@JNW<S8E?G>E,&1g>fODR_@;,
NG2KCa_<4T6\&ZUHTX),G[>8eAJR-JJ04@J<(fNESIO<S=Y..gR-^Y,6P#EA3W,R
CbW2W7>S4=9gf3#<=JNB?&X(+d)UV=gV78-_@e9-E-A5[dC,L#+570XL2IIP2&?R
6D9B<20EH>\PN:&f5V0R7B7P+2-YJ&X>VV\.Ng,IBY_2&4U3LH7QD+dCa#5+8Q5F
U)gJdHJB[+_b_IYO?9_Z>CUfEJUI;E6:.6<ECXe/A)ZXgf@6E5(2W6[_ZZ>9TYbC
P2J2QU+^ZgM3+4_5=.I<O)R3#7U=eQBP)<;&H5DOC_-[\>eNYI(WI6MVg]_@=W_e
#M\UAAECd)^;_\X?W1R=aF5Q@)<d#0[23]aA9W^H(SRe3U;5IL<,IM\H[bDFB_C3
b0(1Oc3?H@?[c4++K4)S]5)(@>(/ZQb&_V:N=U9-\S7Jb5V/E-7-fN2@.LPI36e-
OZN0>0bIO52eNN3X>[Z<K=((]W:fW4f,NDWS)SQ2+B+ZfB<@@2\_fN7-X/<Q\=@B
\WR&1\(@(S]D?a_KG3W-[cO^:8ZI&).317Z+7B)3>XS@0MD&W)d+_<DI5DETDN,1
J:^H7g:RV/5)F\g3#L6S5U.MHN5VCe?3gbGJ@c;=J)=LRVV87,LXP16(JJB>8D_>
I_C3UQK>I-(1,)7BgI-4STE(<1<ZTaPZYf<@F,A3/cPR2YcA[3GM:4T><\T)3d)@
C\H,ECQ(\3&b&#K?Y&PEZg-]>9/7JJdJ?F.gZW,bEdL;K9&V5JD#P[Le?4P8[TY9
55ZYS5NM\]-+b<0(M7YBAB&C(10cP5=[A/c1_bF\>:[:5&_07]1FG7,[,BZ];A=3
+I9&)X+YE9W0A+@6C&M^bEJT)=bOda3f:#);MTCTSF7FL?gge?V+::G>?=[@^YCc
&:_[EGdGYDHU/X#<D)GRYEdZHef9(;=9.,ZK7I14LdN)46Z<DX<fUMWTT?BQG2=4
a/Mc3-#D:(0G_cMVIMSBWYQH:?M@ZIGH_LQ#1)24+d6GGA@cG-9,MX<f-<)(5)c3
,TdP);ATPUMHYdTQbINE/I,DXe4Ze:&ZdGV,VPJM6a@MTW60\,HW#IDGKL#]OO2J
OH,TOMHIHeV;,);YJTCefa4,?;K1Tf/c,L2C;0,ZFb39<g,)_IV:5@8&(_,67_8f
a,:#L>B+GB5&gf_D9A4R^/=5bGA]\YWA,Y&T33Ng<LN)A+M5105^U2O5dP+b@WUE
J<&bREIN;cfNPF1g+@D<^+,_@82[\.T\&gW[EX@5@g,,Z;]R)fTSBKQ)OGZ=<Ffd
bJL0/V]ZEANgVGV7M=G:Dc?NQN]PIgCBYQ+D=e,1NW<IGX5[S7\gF-aH#AZ/MW7U
#c7>9PX+T[=[SM#0a]W+YT66=^L,^/<PLa92U-2#^X6V2TSQ7@R8<-.4<_)L/(=9
2^&[.aT=g^EY@UNTLT^5A(EXHb6.c+);\XEM=\WSRN9VH$
`endprotected

`else

 integer OI11IO001, I1011Ol00;
 integer O1O00I001, IlOO01011, IIl1lll10;
 integer lO0IlIOl1, O1I1IO0IO, l1O0O110I, O0l1O10l0;
 integer OIOOl1I00, O0Olll0O0, l1IO10001;
 integer II010O0O1,  lI1O010l1, IOI001111;
 integer O0O1O11OO, O001O1Ol1, OO0O101O0, OlOOIO10I;
 integer lOlIIl001, I11000011, lOO0lO1O0, II1Il0l1l, l11O1O1II;
 integer Ill11O01O [0:(1<<chk_width)-1];
 integer O1111l11O [0:(1<<(chk_width-1))-1];
 reg  [chk_width-1:0] II0O00OIl;
 reg  [data_width-1:0]   IIO0O111I;
  reg [data_width-1:0] O00ll11OO [0:chk_width-1];
`endif

 wire [chk_width-1:0] O000001OO;
 reg  [data_width-1:0] IOO11O1I0;
 reg  [chk_width-1:0] OI1l0OOOI;
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
    lOlIIl001 = OI11IO001 << chk_width;
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

    for (IOI001111=0 ; (IOI001111 < II1Il0l1l) && (lO0IlIOl1 < data_width) ; IOI001111=IOI001111+1) begin
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

        for (OO0O101O0=O0O1O11OO ; (OO0O101O0 < (O0O1O11OO+O0Olll0O0)) && (lO0IlIOl1 < data_width) ; OO0O101O0=OO0O101O0+1) begin
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
        for (OO0O101O0=O0O1O11OO+OIOOl1I00 ; (OO0O101O0 >= O0O1O11OO) && (lO0IlIOl1 < data_width) ; OO0O101O0=OO0O101O0-1) begin
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

    for (OO0O101O0=0 ; OO0O101O0<chk_width ; OO0O101O0=OO0O101O0+1) begin
      IIO0O111I = {data_width{1'b0}};
      for (lO0IlIOl1=0 ; lO0IlIOl1 < data_width ; lO0IlIOl1=lO0IlIOl1+1) begin
        if (O1111l11O[lO0IlIOl1] & (1 << OO0O101O0)) begin
          IIO0O111I[lO0IlIOl1] = 1'b1;
        end
      end
      O00ll11OO[OO0O101O0] = IIO0O111I;
    end

    l11O1O1II = l1IO10001 - 1;

    for (OO0O101O0=0 ; OO0O101O0<chk_width ; OO0O101O0=OO0O101O0+1) begin
      Ill11O01O[OI11IO001<<OO0O101O0] = data_width+OO0O101O0;
    end

    OlOOIO10I = l1IO10001;
  end
`endif
  
  
  always @ (O1110110) begin : DW_IO010IO10
    
    for (I1011Ol00=0 ; I1011Ol00 < chk_width ; I1011Ol00=I1011Ol00+1) begin
      II0O00OIl[I1011Ol00] = ^(O1110110 & O00ll11OO[I1011Ol00]) ^
				((I1011Ol00<2)||(I1011Ol00>3))? 1'b0 : 1'b1;
    end
  end // DW_IO010IO10
  
  assign O000001OO = II0O00OIl ^ OOOl1101;

  always @ (O000001OO) begin : DW_I10l100O1
    if (rw_mode[0] != 1'b1) begin
      if ((^(O000001OO ^ O000001OO) !== 1'b0)) begin
        OI1l0OOOI = {chk_width{1'bx}};
        IOO11O1I0 = {data_width{1'bx}};
        O1OO110OI = 1'bx;
        OO11O110l = 1'bx;
      end else begin
        OI1l0OOOI = {chk_width{1'b0}};
        IOO11O1I0 = {data_width{1'b0}};
        if (O000001OO === {chk_width{1'b0}}) begin
          O1OO110OI = 1'b0;
          OO11O110l = 1'b0;
        end else if (Ill11O01O[O000001OO+OlOOIO10I] == l11O1O1II) begin
          O1OO110OI = 1'b1;
          OO11O110l = 1'b1;
        end else begin
          O1OO110OI = 1'b1;
          OO11O110l = 1'b0;
          if (Ill11O01O[O000001OO+OlOOIO10I] < data_width)
            IOO11O1I0[Ill11O01O[O000001OO+OlOOIO10I]] = 1'b1;
          else
            OI1l0OOOI[Ill11O01O[O000001OO+OlOOIO10I]-data_width] = 1'b1;
        end
      end
    end
  end // DW_I10l100O1

  assign O1110110 = (rw_mode == 1) ? O1II11O1 : OII1OOl0;
  assign OOOl1101  = (rw_mode == 1) ? O01I11IO  : I01OO00O;

  assign O001IOl1 = O1110110;
  assign I101OO10  = II0O00OIl;
reg   [(data_width+chk_width)-1 : 0]     O0110101;
reg   [(data_width+chk_width)-1 : 0]     OI0000O0 [0 : ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))];


generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_in_registers_wr_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        O0110101 <= {(data_width+chk_width){1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OOOOlIO1 === 1'b1)
          O0110101<= {O00IlO0I, IOOI1O00};
        else if (OOOOlIO1 !== 1'b0)
          O0110101 <= ((O0110101 ^ {O00IlO0I, IOOI1O00}) & {(data_width+chk_width){1'bx}}) ^ O0110101;
      end else begin
        O0110101 <= {(data_width+chk_width){1'bx}};
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_in_registers_wr_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        O0110101 <= {(data_width+chk_width){1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OOOOlIO1 === 1'b1)
          O0110101<= {O00IlO0I, IOOI1O00};
        else if (OOOOlIO1 !== 1'b0)
          O0110101 <= ((O0110101 ^ {O00IlO0I, IOOI1O00}) & {(data_width+chk_width){1'bx}}) ^ O0110101;
      end else begin
        O0110101 <= {(data_width+chk_width){1'bx}};
      end
    end
  end
endgenerate


  assign {O1II11O1, O01I11IO} = (in_reg == 0)? {O00IlO0I, IOOI1O00} : O0110101;




generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_wr_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OI0000O0[lO01IO0O] <= {(data_width+chk_width){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O10l0O0O[lO01IO0O] === 1'b1)
            OI0000O0[lO01IO0O] <= (lO01IO0O == 0)? {O001IOl1, I101OO10} : OI0000O0[lO01IO0O-1];
          else if (O10l0O0O[lO01IO0O] !== 1'b0)
            OI0000O0[lO01IO0O] <= ((OI0000O0[lO01IO0O] ^ ((lO01IO0O == 0)? {O001IOl1, I101OO10} : OI0000O0[lO01IO0O-1]))
          		      & {(data_width+chk_width){1'bx}}) ^ OI0000O0[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OI0000O0[lO01IO0O] <= {(data_width+chk_width){1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_wr_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OI0000O0[lO01IO0O] <= {(data_width+chk_width){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O10l0O0O[lO01IO0O] === 1'b1)
            OI0000O0[lO01IO0O] <= (lO01IO0O == 0)? {O001IOl1, I101OO10} : OI0000O0[lO01IO0O-1];
          else if (O10l0O0O[lO01IO0O] !== 1'b0)
            OI0000O0[lO01IO0O] <= ((OI0000O0[lO01IO0O] ^ ((lO01IO0O == 0)? {O001IOl1, I101OO10} : OI0000O0[lO01IO0O-1]))
          		      & {(data_width+chk_width){1'bx}}) ^ OI0000O0[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OI0000O0[lO01IO0O] <= {(data_width+chk_width){1'bx}};
        end
      end
    end
  end
endgenerate

  assign {I01ll0OO, Ol0I0lO1} = (stages+out_reg == 1)? {O001IOl1, I101OO10} : OI0000O0[((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))];


  assign I10IO1Ol      = O1110110 ^ IOO11O1I0;
  assign OI1l0l00       = OOOl1101 ^ OI1l0OOOI;
  assign O010010O      = O000001OO;
  assign lO00l00I   = O1OO110OI;
  assign I0O11O11 = OO11O110l;
reg   [(data_width+chk_width)-1 : 0]     l1l0O01I;
reg   [(data_width+(chk_width*2)+2)-1 : 0]     OIOOl10l [0 : ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))];


generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_in_registers_rd_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        l1l0O01I <= {(data_width+chk_width){1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OOOOlIO1 === 1'b1)
          l1l0O01I<= {O00IlO0I, IOOI1O00};
        else if (OOOOlIO1 !== 1'b0)
          l1l0O01I <= ((l1l0O01I ^ {O00IlO0I, IOOI1O00}) & {(data_width+chk_width){1'bx}}) ^ l1l0O01I;
      end else begin
        l1l0O01I <= {(data_width+chk_width){1'bx}};
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_in_registers_rd_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        l1l0O01I <= {(data_width+chk_width){1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OOOOlIO1 === 1'b1)
          l1l0O01I<= {O00IlO0I, IOOI1O00};
        else if (OOOOlIO1 !== 1'b0)
          l1l0O01I <= ((l1l0O01I ^ {O00IlO0I, IOOI1O00}) & {(data_width+chk_width){1'bx}}) ^ l1l0O01I;
      end else begin
        l1l0O01I <= {(data_width+chk_width){1'bx}};
      end
    end
  end
endgenerate


  assign {OII1OOl0, I01OO00O} = (in_reg == 0)? {O00IlO0I, IOOI1O00} : l1l0O01I;




generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_rd_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OIOOl10l[lO01IO0O] <= {(data_width+(chk_width*2)+2){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O10l0O0O[lO01IO0O] === 1'b1)
            OIOOl10l[lO01IO0O] <= (lO01IO0O == 0)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[lO01IO0O-1];
          else if (O10l0O0O[lO01IO0O] !== 1'b0)
            OIOOl10l[lO01IO0O] <= ((OIOOl10l[lO01IO0O] ^ ((lO01IO0O == 0)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[lO01IO0O-1]))
          		      & {(data_width+(chk_width*2)+2){1'bx}}) ^ OIOOl10l[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OIOOl10l[lO01IO0O] <= {(data_width+(chk_width*2)+2){1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_rd_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OIOOl10l[lO01IO0O] <= {(data_width+(chk_width*2)+2){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O10l0O0O[lO01IO0O] === 1'b1)
            OIOOl10l[lO01IO0O] <= (lO01IO0O == 0)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[lO01IO0O-1];
          else if (O10l0O0O[lO01IO0O] !== 1'b0)
            OIOOl10l[lO01IO0O] <= ((OIOOl10l[lO01IO0O] ^ ((lO01IO0O == 0)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[lO01IO0O-1]))
          		      & {(data_width+(chk_width*2)+2){1'bx}}) ^ OIOOl10l[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OIOOl10l[lO01IO0O] <= {(data_width+(chk_width*2)+2){1'bx}};
        end
      end
    end
  end
endgenerate

  assign {O0llOO1O, IO1lO0l0, II000OOO, I10O110O, IO100O1I} = (stages+out_reg == 1)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))];



reg   [id_width-1 : 0]     lO00O01l [0 : ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];



generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_id
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          lO00O01l[lO01IO0O] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O00l0I1O[lO01IO0O] === 1'b1)
            lO00O01l[lO01IO0O] <= (lO01IO0O == 0)? O10O0O10 : lO00O01l[lO01IO0O-1];
          else if (O00l0I1O[lO01IO0O] !== 1'b0)
            lO00O01l[lO01IO0O] <= ((lO00O01l[lO01IO0O] ^ ((lO01IO0O == 0)? O10O0O10 : lO00O01l[lO01IO0O-1]))
          		      & {id_width{1'bx}}) ^ lO00O01l[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          lO00O01l[lO01IO0O] <= {id_width{1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_id
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          lO00O01l[lO01IO0O] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O00l0I1O[lO01IO0O] === 1'b1)
            lO00O01l[lO01IO0O] <= (lO01IO0O == 0)? O10O0O10 : lO00O01l[lO01IO0O-1];
          else if (O00l0I1O[lO01IO0O] !== 1'b0)
            lO00O01l[lO01IO0O] <= ((lO00O01l[lO01IO0O] ^ ((lO01IO0O == 0)? O10O0O10 : lO00O01l[lO01IO0O-1]))
          		      & {id_width{1'bx}}) ^ lO00O01l[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          lO00O01l[lO01IO0O] <= {id_width{1'bx}};
        end
      end
    end
  end
endgenerate

  assign OlI0OIOI = (in_reg+stages+out_reg == 1)? O10O0O10 : lO00O01l[((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];




generate
  if (rst_mode==0) begin : DW_II0lOI0l
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(rst_n),
                     .init_n(1'b1),
                     .launch(O0lI0O1O),
                     .launch_id(O10O0O10),
                     .accept_n(I1O0O1O1),
                     .arrive(I1O001OO),
                     .arrive_id(IOO11O11),
                     .pipe_en_bus(O00101I1),
                     .pipe_full(O010lO10),
                     .pipe_ovf(OOO1O1OO),
                     .push_out_n(OO1lIIO1),
                     .pipe_census(O1O1IlO0)
                     );
  end else begin : DW_I01OI0I1
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(1'b1),
                     .init_n(rst_n),
                     .launch(O0lI0O1O),
                     .launch_id(O10O0O10),
                     .accept_n(I1O0O1O1),
                     .arrive(I1O001OO),
                     .arrive_id(IOO11O11),
                     .pipe_en_bus(O00101I1),
                     .pipe_full(O010lO10),
                     .pipe_ovf(OOO1O1OO),
                     .push_out_n(OO1lIIO1),
                     .pipe_census(O1O1IlO0)
                     );
  end
endgenerate

assign O0O1011l         = O0lI0O1O;
assign l0OOl11l      = O10O0O10;
assign IIO10010    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b0}};
assign l1I101lO      = I1O0O1O1;
assign OO1IOO00  = l1I101lO && O0O1011l;
assign I0IOIl1O     = ~(~I1O0O1O1 && O0lI0O1O);
assign OOO0Ol0O    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};


assign arrive           = no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? I1O001OO : O0O1011l;
assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? (no_pm ? OlI0OIOI          : IOO11O11  ) : l0OOl11l;
assign O00l0I1O  = ((in_reg+stages+out_reg) > 1) ? (no_pm ? {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){launch}} : O00101I1) : IIO10010;
assign pipe_full        = no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? O010lO10 : l1I101lO;
assign pipe_ovf         = no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OOO1O1OO : I10l1lO0;
assign push_out_n       = no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OO1lIIO1 : I0IOIl1O;
assign pipe_census      = no_pm ? {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}} : ((in_reg+stages+out_reg) > 1) ? O1O1IlO0 : OOO0Ol0O;

assign OOOOlIO1 = O00l0I1O[0];

  always @(O00l0I1O) begin : out_en_bus_in_reg1_PROC
    integer lO01IO0O;

    if  (in_reg == 1) begin
      O10l0O0O[0] = 1'b0;
      for (lO01IO0O=1; lO01IO0O<(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1); lO01IO0O=lO01IO0O+1) begin
        O10l0O0O[lO01IO0O-1] = O00l0I1O[lO01IO0O];
      end
    end else begin
      O10l0O0O = O00l0I1O;
    end
  end


generate
  if (rst_mode==0) begin : DW_O11011I1
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        I10l1lO0     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        I10l1lO0     <= OO1IOO00;
      end else begin
        I10l1lO0     <= 1'bx;
      end
    end
  end else begin : DW_I0O1O01I
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        I10l1lO0     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        I10l1lO0     <= OO1IOO00;
      end else begin
        I10l1lO0     <= 1'bx;
      end
    end
  end
endgenerate


  assign dataout      = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          {data_width{1'bx}} : 
                          (rw_mode==0) ? O0llOO1O: I01ll0OO;

  assign chkout       = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          {chk_width{1'bx}} : 
                          (rw_mode==0) ? IO1lO0l0: Ol0I0lO1;

  assign syndout      = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          {chk_width{1'bx}} : 
                          (rw_mode==0) ? II000OOO: {chk_width{1'b0}};

  assign err_detect   = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          1'bx : 
                          (rw_mode==0) ? I10O110O: 1'b0;

  assign err_multiple = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          1'bx : 
                          (rw_mode==0) ? IO100O1I: 1'b0;

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (data_width < 8) || (data_width > 8178) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 8 to 8178)",
	data_width );
    end
  
    if ( (chk_width < 5) || (chk_width > 14) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter chk_width (legal range: 5 to 14)",
	chk_width );
    end
  
    if ( (rw_mode < 0) || (rw_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rw_mode (legal range: 0 to 1)",
	rw_mode );
    end
  
    if ( (op_iso_mode < 0) || (op_iso_mode > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter op_iso_mode (legal range: 0 to 4)",
	op_iso_mode );
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
