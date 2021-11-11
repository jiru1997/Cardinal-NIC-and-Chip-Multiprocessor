////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1994 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Igor Kurilov       07/07/94 03:06am
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 46889a93
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  LFSR Counter with Dynamic Count-to Flag
//           Programmable wordlength (width in integer range 1 to 50)
//           positive edge-triggering clock: clk
//           asynchronous reset(active low): reset
//           count state : count
//           when reset = '0' , count <= "000...000"
//           counter state 0 to 2**width-2, "111...111" illegal state
//
// MODIFIED:
//
//           RJK Jun. 16th, 2015
//           changed for compatibility with VCS Native Low Power
//
//           GN  Feb. 16th, 1996
//           changed dw03 to DW03
//           remove $generic and $end_generic
//           defined parameter width = 8
//------------------------------------------------------------------------------

module DW03_lfsr_dcnto
 (data, count_to, load, cen, clk, reset, count, tercnt);

  parameter width = 8 ;
  input [width-1 : 0] data;
  input [width-1 : 0] count_to;
  input load, cen, clk, reset;
  output [width-1 : 0] count;
  output tercnt;

  // synopsys translate_off

  reg right_xor, shift_right, tc;
  reg [width-1 : 0] q, de, d;

`ifdef UPF_POWER_AWARE
`protected
82O2++5,?FFcB-0WB=^+P9N6MO6O_MeEJ[LEVL;,5/TW.b>Z?^D\+)Y(Q(-_H+?E
QWTO864/,S[Be#A,W1D3/,+[eZ8MUc^F:b&,>BL+aDgF43OH(]gW2@<\\#5P(X73
QR^0bCQ/H(0RLMCZXb)K]UO4)(\.a?:4C72E[WSI;(dQ=4GCGSA&23A/[C(COeK^
LL\5YT]Jeb]RXBLX(6YbTWEGc&?GWZ,-Q92A0.5O94/_(T^8P7++X#g1d_CgQ/RQ
5K[./ee(5#/\^B=VAQ\CL_7=0fN1XJ4(./ODCIP:ERKD\cOF^fgV?S>GNK>W;16=
Z,KZG0Z6,PE\I8X/7-eH)\\GBN7b504:e,61APTC1Ia.ARP,76POe<A;\[5@M.RQ
[Od5eFV/36OLa/H;Y&#dBeNAg>)UM^b6Y9]&(_[]N7=CEaOHZ42cZ_/aIDVXC2g&
bQ#[CN+=[K6g,J9[)HWSF9&MEWB@+8)B1(20b:)?)(3L-HFM&-b+?80QW\?EI@5G
1-CKBb=e<4?<61cQGbSGB;U-WHNCSVgLW7P[Y0<F1eDK2[MA+P1,1URTYF8e9;9P
/?HMB8[eQ/GHGV#Xc[d6_fQ7=7LQ6XXQN<a,X0c3)?2EU^3RaM4P=0=_4S;EV84\
+\S8:[T76a3+2Lb+C^NECDLVBa:(+DCGR#)::3WMT2;29KQ1b50a4Ob<e5W-@L#d
R5b>d4G8P3aAEC:Z^?d8d,O&.00APCS\EI8c0=bH+d.3&CS+/d4>VM=PN+.Ga7e-
e&P5Sc(Gd=E#FL>aWJ=@>>=XT5]SR\HD,)P9W\bI/;Fa=\1G6,FM@QMa1N6Id9>&
=IQdF>Q7+eeUaSc;2T14;;#We/@ECP)9[[R@#:I8,9D]PCG\2X8d+=1@c-[GEDF4
:c59-LH1_F,0,^FFdU<eH[[MaTE_4QB4M3Z9,H3P3R^HW]MWVU4@.gMLIG@K3LEd
7^O2&YAC5DV3DR-GELXQ@6fJU3V2/&3LHVLW&)WDZQJ7Db<)(OF/Z_eANN,cc3BL
;:\aB3VZSMbE:O=&X6T<\G@[DcR=-e86P/@c4\I/K[I]aa\<E)[>+YY&cRbb:e67
8W;CUKJ.3^4gVR7JS@(=H8#-KNf]1fC2^P<7VG,C)#Yb=,aITegP(-YX]\?2@-aC
WTIR[?CV/0(MC^J931^/BI\-)#HO_9ZL]0g(CW),c-6g.-]C27YRY/LHO3W_UXWb
.24.&&.,U06##LSYfdRAFNCAVN^QB&gCc6<)4VXYJS]?d5ABFK]P40A.O[=V?08J
K+W)D)X-<(\PXKC6V(O;H@<f2E9bPS_(S6g#16gU+@Z0-HN5@PJcJS7DF0<O44>O
_Cd2[0I-5NdU^/\#U>JSFIN\XT,76RB[9-U=Z5EMbGJ,eOGS/<aYaH0YN.ANGWHF
?TK4\A#P)g745_QSW3-GeXGC<e2NU0c0#P.?40OJHcb04HfcTgTf=,QZceOEU<#E
W1CT5)1<BENT(J+3-,)[9aD>),Y8DGSV_fT8-QT1A.#YA6C5^90YO:gT^_0d9AL6
)Yf9.Ng6K^M2EdAee)##dN:2LSEJ0gJI)5(&U)#A@9C7M0.U+1FG0L^VP4aL##3(
W2P+fAH3JXRcMZWJAJAa#LJC2.9@JAUA0K8@fJ&.Y<3f(2TAWR<:b31X+>^,7QNV
YE,;UDE=&JTdeIJf&PBSJgY]86W>8\(#aW\-(0^0M;M2]Q^3OJ;^32L1DUDN=T[U
A>+aS_1JM3/agR1Z,T)6JO-C228_UJ+f0e_@#)-ULU-FH\1&(:d@[2-D-_.gCMW(
g\?a9e3TV,3Ad^dLA3R]V7eP77.[aH6@:$
`endprotected

`else
  reg [width-1 : 0] p;
`endif

  function [width-1 : 0] shr;
    input [width-1 : 0] a;
    input msb;
    reg [width-1 : 0] b;
    begin
      b = a >> 1;
      b[width-1] = msb;
      shr = b;
    end
  endfunction

  assign count = q;
  assign tercnt = tc;

`ifndef UPF_POWER_AWARE
  initial
    begin
    case (width)
      1: p = 1'b1;
      2,3,4,6,7,15,22: p = 'b011;
      5,11,21,29,35: p = 'b0101;
      10,17,20,25,28,31,41: p = 'b01001;
      9,39: p = 'b010001;
      23,47: p = 'b0100001;
      18: p = 'b010000001;
      49: p = 'b01000000001;
      36: p = 'b0100000000001;
      33: p = 'b010000000000001;
      8,38,43: p = 'b01100011;
      12: p = 'b010011001;
      13,45: p = 'b011011;
      14: p = 'b01100000000011;
      16: p = 'b0101101;
      19: p = 'b01100011;
      24: p = 'b011011;
      26,27: p = 'b0110000011;
      30: p = 'b011000000000000011;
      32,48: p = 'b011000000000000000000000000011;
      34: p = 'b01100000000000011;
      37: p = 'b01010000000101;
      40: p = 'b01010000000000000000101;
      42: p = 'b0110000000000000000000011;
      44,50: p = 'b01100000000000000000000000011;
      46: p = 'b01100000000000000000011;
      default p = 'bx;
    endcase
    end
`endif

  always
    begin: proc_shr
      right_xor = (width == 1) ? ~ q[0] : ^ (q & p);
      shift_right = ~ right_xor;
      @q;
    end // proc_shr

  always
    @(load or cen or shift_right or q or data)
    begin
      de = load ? shr(q,shift_right) : data;
      d = cen ? de : q;
    end

  always @(posedge clk or negedge reset) 
    begin
      if (reset === 1'b0) 
        begin 
          q <= 0;
	end
      else 
	begin
          q <= d;
	end
    end

  always @(count_to or q) tc = count_to == q;

  //---------------------------------------------------------------------------
  // Parameter legality check
  //---------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if ( (width < 1) || (width > 50) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 50)",
	width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  // synopsys translate_on

endmodule // DW03_lfsr_dcnto
