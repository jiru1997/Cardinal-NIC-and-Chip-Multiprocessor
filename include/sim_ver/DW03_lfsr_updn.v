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
// AUTHOR:    Igor Kurilov       07/09/94 02:08am
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 2250451e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------
//
// ABSTRACT:  LFSR Up/Down Counter
//           Programmable wordlength (width in integer range 1 to 50)
//           positive edge-triggering clock: clk
//           asynchronous reset(active low): reset
//           updn = '1' count up, updn = '0' count down
//           count state : count
//           when reset = '0' , count <= "000...000"
//           counter state 0 to 2**width-2, "111...111" illegal state
//
// MODIFIED:
//
//           07/16/2015  Liming Su   Changed for compatibility with VCS Native
//                                   Low Power
//
//           07/14/94 06:26am
//           GN Feb. 16th, 1996
//           changed dw03 to DW03
//           remove $generic
//           define parameter width=8
//-------------------------------------------------------------------------

module DW03_lfsr_updn
 (updn, cen, clk, reset, count, tercnt);


  parameter width = 8;
  input updn, cen, clk, reset;
  output [width-1 : 0] count;
  output tercnt;

  // synopsys translate_off

  reg shift_right, shift_left, right_xor, left_xor, tc;
  reg [width-1 : 0] q, de, d;

`ifdef UPF_POWER_AWARE
`protected
2c&E_S)Y9AXU;,ZG0]T[X(3/W0#<86@_R^1JD7-JEV;8b.73=Z#T0)N^OSCI9EDS
E^\(<(P5#_eX_9[GC+9Q(C8bG@W58;DKY3R^TAJ;E/2Ya]_4,5=(JGD8.Q@Of>>J
@Ag^35dR3(e.G=T3fK520,7;;\8[B7dH80>AZS7)>=;9CSKUVU\Ce48SO-Dd.W:N
RKb79VO/@L;,Y+0Sb(Z]Z3cc6W_V-d^D6gUZb?CO)LV]b[gRO^LdWHENV<,<WC8_
:f4A_IET^EKaAKPTe]WVODSeg+I4L2,>ADg=7W2+5X6eRQ1R^>:C)FDY:c2gUX]Y
?\.A(@@EOFFQ2J9Xe.Q5\ESd6-T<7M46&(HR]BYCI[KT:eHJE=ALO@RGP.LBT@#G
_5[Ff;XTVgKG+F/M6:H]CeOaX4HeVYaT##Ef[(,Sg4.C:I34CRUdDO+NcH4X3IGY
(>2QW1E/(U/eVG9H?>e-5O?(82Xc4T[c#(B<KSJ\E?_B&?4?Q:HF+_N;f#Yc]e/C
dGCOEH#_]MNH2FQT?1GI3WD[SbWY37VR7g&-;(A3<DNf4FR;,A?OA7\Q>72X?]e\
41_5<&eQQ;f4gO2Nc0/2.=@??]/CH#;d@[B9=B+7\L4Q<^[2aWc;Y59=T(\:XNdP
A#]Z0d.JD<R.S:d^.aaJ/JbaNYEKEFb;>&T8VELc:O&3Y4V<_?eND-@O^>Dd1LAG
>2NHZI>,#)4eBd6b1<UO^(GOP?A3E9d.;9;0YZW7<IM\>[?H-S;-AEEFUOY=dRZX
:E-YdF<TcJ-I3I\);d/?)P93_GbU)=eeQH6)(:5>(5B0&geD?D(T++<D-?6BWNYe
/U:H)]ZKV#eObG^SYFR69;SK54I>_Q+CXF]:G3E#\U:3SV\WWH<,R]g[?7I&DD@_
CDT&U#Q&@c-a=;FID:XO[-<FV2c6#/X;Pa2BZK0VPQOQ.D7KTQ-cJg__L:PS)VLY
#1R3d;/SFFY+U2HeU8)ea,6P5F2.6YO0L?Y&)S3U=1O/_R?B@ZFJNVBA\L;c2K7&
/dB>5P+VB)A4Oa]1&C^1DS^9IY17SWf#]9;OA5[G/R:SBZa>9:7R:(<G7]A5[CL-
>fY?7R<dC@3<OZ8?I0U2Y)Q16V@RScS6O@^C&1TGP+_K-aZdTU&Z&[fJJ(KOHMbZ
R.H5KL<8eV(3C#[(^W@JRD8H3bU9VXJZde-T2N)1>\O,>P3R.#PZ6Lf8WP(@E&(/
8V-JV;0RB(X8YWC0Jb:b#_)deLVN5;C35Y)+.HYB9b,+)aUZYB2;Q?HB3#<-YM5E
@_1MD@D]D-C\IVV\4bBB19/UV[Pa.2_+H0STYR(TF]PRQ4V=17\-a,WF92(1>(>6
geB0\Y/MI?-7O0)XF#B2K6KEgSO2Te+[=&Q>LI&AeGe,2+7L^fV)IZH3S6a7MC.0
N2/bKd_2#]5>STDJNDP+HeS,12,(Rgd]MYF=O7^dG[1&AC>3293;45+9f#/O.01d
H4[&-3=AE60B+@b[>c4CJMH:Pc0IAKD]Ne;f-SgN(Oe)J(@D0X>S7JP=C4FGT#.g
K=6C8QNIVI[;U4ZZ>N^I51,I>e+UWVO2(WE,-,>D_:]1EJHa[\E\\JMAX1&?XNFN
2Gf_G8_:g;V_N;P[Nga2IGd>aR5.eH:]#<ZQ7#7D_[.f7aU&?R3a,IP#ea].[\/M
?BXd#cLe9AH<fg0M#)(YAP_,F1=7ZL\W\;Z-Z0GJ?N+>8=P/ON6QTA=)1A2dE?fc
^ee-D1\O2MH&<bT<AP(G.Uc=:K7:X:UDJ;c(]02\KFXZa+-/P;+FP:#^V3M@NDK&
PQ57I<Jb(FB=>H6SHWU1F,CAO#DGFJ,R@eLFC:<RcDfZG$
`endprotected

`else
  reg [width-1 : 0] pr, pl;
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

  function [width-1 : 0] shl;
    input [width-1 : 0] a;
    input lsb;
    reg [width-1 : 0] b;
    begin
      b = a << 1;
      b[0] = lsb;
      shl = b;
    end
  endfunction

  assign count  = q;
  assign tercnt = tc;

`ifndef UPF_POWER_AWARE
  initial
    begin
    case (width)
      1: pr = 1'b1;
      2,3,4,6,7,15,22: pr = 'b011;
      5,11,21,29,35: pr = 'b0101;
      10,17,20,25,28,31,41: pr = 'b01001;
      9,39: pr = 'b010001;
      23,47: pr = 'b0100001;
      18: pr = 'b010000001;
      49: pr = 'b01000000001;
      36: pr = 'b0100000000001;
      33: pr = 'b010000000000001;
      8,38,43: pr = 'b01100011;
      12: pr = 'b010011001;
      13,45: pr = 'b011011;
      14: pr = 'b01100000000011;
      16: pr = 'b0101101;
      19: pr = 'b01100011;
      24: pr = 'b011011;
      26,27: pr = 'b0110000011;
      30: pr = 'b011000000000000011;
      32,48: pr = 'b011000000000000000000000000011;
      34: pr = 'b01100000000000011;
      37: pr = 'b01010000000101;
      40: pr = 'b01010000000000000000101;
      42: pr = 'b0110000000000000000000011;
      44,50: pr = 'b01100000000000000000000000011;
      46: pr = 'b01100000000000000000011;
      default pr = 'bx;
    endcase
    pl = shr(pr,1'b1);
    end
`endif

  always
    begin: proc_shr
      right_xor = (width == 1) ? ~ q[0] : ^ (q & pr);
      shift_right = ~ right_xor;
      @q;
    end // proc_shr

  always
    begin: proc_shl
      left_xor = (width == 1) ? ~ q[width-1] : ^ (q & pl);
      shift_left = ~ left_xor;
      @q;
    end // proc_shl

  always
    @(updn or cen or q or shift_right or shift_left)
    begin
      de = updn ? shr(q,shift_right) : shl(q,shift_left);
      d = cen ? de : q;
    end


  always @(posedge clk or negedge reset)
    begin
    if (reset === 1'b0)
      q <= {width{1'b0}};

    else
      q <= d;
    end

  always @ (q or updn)
    begin
    if (updn === 1'bx)
      tc = 1'bx;
	  
    else
      begin
      if (updn === 1'b0)
		begin
		if (q === {1'b1, {width-1{1'b0}}})
		  tc = 1'b1;
	     
		else
		  tc = 1'b0;
		end
	     
      else
		begin
		if (q === {{width-1{1'b0}}, 1'b1})
		   tc = 1'b1;
	     
		else
		   tc = 1'b0;
		end
      end
    end

  // synopsys translate_on

endmodule // DW03_lfsr_updn
