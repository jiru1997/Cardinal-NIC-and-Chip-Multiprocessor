/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP5-5
// Date      : Sat Oct  2 11:32:49 2021
/////////////////////////////////////////////////////////////


module DW_div_inst_DW_div_6 ( a, b, quotient, remainder, divide_by_0 );
  input [7:0] a;
  input [7:0] b;
  output [7:0] quotient;
  output [7:0] remainder;
  output divide_by_0;
  wire   PartRem_7__1_, PartRem_6__2_, PartRem_6__1_, PartRem_5__3_,
         PartRem_5__2_, PartRem_5__1_, PartRem_4__4_, PartRem_4__3_,
         PartRem_4__2_, PartRem_4__1_, PartRem_3__5_, PartRem_3__4_,
         PartRem_3__3_, PartRem_3__2_, PartRem_3__1_, PartRem_2__6_,
         PartRem_2__5_, PartRem_2__4_, PartRem_2__3_, PartRem_2__2_,
         PartRem_2__1_, PartRem_1__7_, PartRem_1__6_, PartRem_1__5_,
         PartRem_1__4_, PartRem_1__3_, PartRem_1__2_, PartRem_1__1_,
         CryTmp_6__2_, CryTmp_5__3_, CryTmp_5__2_, CryTmp_4__4_, CryTmp_4__3_,
         CryTmp_4__2_, CryTmp_3__5_, CryTmp_3__4_, CryTmp_3__3_, CryTmp_3__2_,
         CryTmp_2__6_, CryTmp_2__5_, CryTmp_2__4_, CryTmp_2__3_, CryTmp_2__2_,
         CryTmp_1__7_, CryTmp_1__6_, CryTmp_1__5_, CryTmp_1__4_, CryTmp_1__3_,
         CryTmp_1__2_, CryTmp_0__7_, CryTmp_0__6_, CryTmp_0__5_, CryTmp_0__4_,
         CryTmp_0__3_, CryTmp_0__2_, SumTmp_7__0_, SumTmp_6__1_, SumTmp_6__0_,
         SumTmp_5__2_, SumTmp_5__1_, SumTmp_5__0_, SumTmp_4__3_, SumTmp_4__2_,
         SumTmp_4__1_, SumTmp_4__0_, SumTmp_3__4_, SumTmp_3__3_, SumTmp_3__2_,
         SumTmp_3__1_, SumTmp_3__0_, SumTmp_2__5_, SumTmp_2__4_, SumTmp_2__3_,
         SumTmp_2__2_, SumTmp_2__1_, SumTmp_2__0_, SumTmp_1__6_, SumTmp_1__5_,
         SumTmp_1__4_, SumTmp_1__3_, SumTmp_1__2_, SumTmp_1__1_, SumTmp_1__0_,
         SumTmp_0__7_, SumTmp_0__6_, SumTmp_0__5_, SumTmp_0__4_, SumTmp_0__3_,
         SumTmp_0__2_, SumTmp_0__1_, SumTmp_0__0_, n1, n2, n3, n4, n5, n6, n10,
         n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38,
         n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52,
         n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66,
         n67, n68;
  wire   [7:0] BInv;

  FAX1 u_fa_PartRem_0_0_1 ( .A(PartRem_1__1_), .B(BInv[1]), .C(n13), .YC(
        CryTmp_0__2_), .YS(SumTmp_0__1_) );
  FAX1 u_fa_PartRem_0_0_2 ( .A(PartRem_1__2_), .B(BInv[2]), .C(CryTmp_0__2_), 
        .YC(CryTmp_0__3_), .YS(SumTmp_0__2_) );
  FAX1 u_fa_PartRem_0_0_3 ( .A(PartRem_1__3_), .B(BInv[3]), .C(CryTmp_0__3_), 
        .YC(CryTmp_0__4_), .YS(SumTmp_0__3_) );
  FAX1 u_fa_PartRem_0_0_4 ( .A(PartRem_1__4_), .B(BInv[4]), .C(CryTmp_0__4_), 
        .YC(CryTmp_0__5_), .YS(SumTmp_0__4_) );
  FAX1 u_fa_PartRem_0_0_5 ( .A(PartRem_1__5_), .B(BInv[5]), .C(CryTmp_0__5_), 
        .YC(CryTmp_0__6_), .YS(SumTmp_0__5_) );
  FAX1 u_fa_PartRem_0_0_6 ( .A(PartRem_1__6_), .B(BInv[6]), .C(CryTmp_0__6_), 
        .YC(CryTmp_0__7_), .YS(SumTmp_0__6_) );
  FAX1 u_fa_PartRem_0_0_7 ( .A(PartRem_1__7_), .B(BInv[7]), .C(CryTmp_0__7_), 
        .YC(quotient[0]), .YS(SumTmp_0__7_) );
  FAX1 u_fa_PartRem_0_1_1 ( .A(PartRem_2__1_), .B(BInv[1]), .C(n12), .YC(
        CryTmp_1__2_), .YS(SumTmp_1__1_) );
  FAX1 u_fa_PartRem_0_1_2 ( .A(PartRem_2__2_), .B(BInv[2]), .C(CryTmp_1__2_), 
        .YC(CryTmp_1__3_), .YS(SumTmp_1__2_) );
  FAX1 u_fa_PartRem_0_1_3 ( .A(PartRem_2__3_), .B(BInv[3]), .C(CryTmp_1__3_), 
        .YC(CryTmp_1__4_), .YS(SumTmp_1__3_) );
  FAX1 u_fa_PartRem_0_1_4 ( .A(PartRem_2__4_), .B(BInv[4]), .C(CryTmp_1__4_), 
        .YC(CryTmp_1__5_), .YS(SumTmp_1__4_) );
  FAX1 u_fa_PartRem_0_1_5 ( .A(PartRem_2__5_), .B(BInv[5]), .C(CryTmp_1__5_), 
        .YC(CryTmp_1__6_), .YS(SumTmp_1__5_) );
  FAX1 u_fa_PartRem_0_1_6 ( .A(PartRem_2__6_), .B(BInv[6]), .C(CryTmp_1__6_), 
        .YC(CryTmp_1__7_), .YS(SumTmp_1__6_) );
  FAX1 u_fa_PartRem_0_2_1 ( .A(PartRem_3__1_), .B(BInv[1]), .C(n15), .YC(
        CryTmp_2__2_), .YS(SumTmp_2__1_) );
  FAX1 u_fa_PartRem_0_2_2 ( .A(PartRem_3__2_), .B(BInv[2]), .C(CryTmp_2__2_), 
        .YC(CryTmp_2__3_), .YS(SumTmp_2__2_) );
  FAX1 u_fa_PartRem_0_2_3 ( .A(PartRem_3__3_), .B(BInv[3]), .C(CryTmp_2__3_), 
        .YC(CryTmp_2__4_), .YS(SumTmp_2__3_) );
  FAX1 u_fa_PartRem_0_2_4 ( .A(PartRem_3__4_), .B(BInv[4]), .C(CryTmp_2__4_), 
        .YC(CryTmp_2__5_), .YS(SumTmp_2__4_) );
  FAX1 u_fa_PartRem_0_2_5 ( .A(PartRem_3__5_), .B(BInv[5]), .C(CryTmp_2__5_), 
        .YC(CryTmp_2__6_), .YS(SumTmp_2__5_) );
  FAX1 u_fa_PartRem_0_3_1 ( .A(PartRem_4__1_), .B(BInv[1]), .C(n14), .YC(
        CryTmp_3__2_), .YS(SumTmp_3__1_) );
  FAX1 u_fa_PartRem_0_3_2 ( .A(PartRem_4__2_), .B(BInv[2]), .C(CryTmp_3__2_), 
        .YC(CryTmp_3__3_), .YS(SumTmp_3__2_) );
  FAX1 u_fa_PartRem_0_3_3 ( .A(PartRem_4__3_), .B(BInv[3]), .C(CryTmp_3__3_), 
        .YC(CryTmp_3__4_), .YS(SumTmp_3__3_) );
  FAX1 u_fa_PartRem_0_3_4 ( .A(PartRem_4__4_), .B(BInv[4]), .C(CryTmp_3__4_), 
        .YC(CryTmp_3__5_), .YS(SumTmp_3__4_) );
  FAX1 u_fa_PartRem_0_4_1 ( .A(PartRem_5__1_), .B(BInv[1]), .C(n11), .YC(
        CryTmp_4__2_), .YS(SumTmp_4__1_) );
  FAX1 u_fa_PartRem_0_4_2 ( .A(PartRem_5__2_), .B(BInv[2]), .C(CryTmp_4__2_), 
        .YC(CryTmp_4__3_), .YS(SumTmp_4__2_) );
  FAX1 u_fa_PartRem_0_4_3 ( .A(PartRem_5__3_), .B(BInv[3]), .C(CryTmp_4__3_), 
        .YC(CryTmp_4__4_), .YS(SumTmp_4__3_) );
  FAX1 u_fa_PartRem_0_5_1 ( .A(PartRem_6__1_), .B(BInv[1]), .C(n10), .YC(
        CryTmp_5__2_), .YS(SumTmp_5__1_) );
  FAX1 u_fa_PartRem_0_5_2 ( .A(PartRem_6__2_), .B(BInv[2]), .C(CryTmp_5__2_), 
        .YC(CryTmp_5__3_), .YS(SumTmp_5__2_) );
  FAX1 u_fa_PartRem_0_6_1 ( .A(PartRem_7__1_), .B(BInv[1]), .C(n16), .YC(
        CryTmp_6__2_), .YS(SumTmp_6__1_) );
  OR2X1 U2 ( .A(b[3]), .B(n5), .Y(n57) );
  AND2X1 U3 ( .A(n4), .B(CryTmp_3__5_), .Y(quotient[3]) );
  AND2X1 U4 ( .A(n6), .B(n62), .Y(n58) );
  BUFX2 U5 ( .A(n54), .Y(n1) );
  BUFX2 U6 ( .A(n48), .Y(n2) );
  OR2X1 U7 ( .A(b[2]), .B(b[1]), .Y(n49) );
  INVX1 U8 ( .A(n49), .Y(n3) );
  OR2X1 U9 ( .A(a[7]), .B(BInv[0]), .Y(n17) );
  OR2X1 U10 ( .A(b[5]), .B(n65), .Y(n64) );
  INVX1 U11 ( .A(n64), .Y(n4) );
  INVX1 U12 ( .A(n58), .Y(n5) );
  OR2X1 U13 ( .A(b[5]), .B(b[4]), .Y(n61) );
  INVX1 U14 ( .A(n61), .Y(n6) );
  INVX1 U15 ( .A(n33), .Y(PartRem_6__1_) );
  INVX1 U16 ( .A(n35), .Y(PartRem_5__1_) );
  INVX1 U17 ( .A(n40), .Y(PartRem_3__1_) );
  INVX1 U18 ( .A(n43), .Y(PartRem_2__1_) );
  INVX1 U19 ( .A(n29), .Y(PartRem_1__1_) );
  INVX1 U20 ( .A(n37), .Y(PartRem_4__1_) );
  INVX1 U21 ( .A(n32), .Y(PartRem_7__1_) );
  INVX1 U22 ( .A(SumTmp_4__3_), .Y(n46) );
  INVX1 U23 ( .A(SumTmp_2__3_), .Y(n55) );
  INVX1 U24 ( .A(SumTmp_2__5_), .Y(n45) );
  AND2X1 U25 ( .A(CryTmp_2__6_), .B(n62), .Y(quotient[2]) );
  INVX1 U26 ( .A(SumTmp_6__1_), .Y(n47) );
  INVX1 U27 ( .A(SumTmp_5__1_), .Y(n53) );
  INVX1 U28 ( .A(SumTmp_4__1_), .Y(n56) );
  INVX1 U29 ( .A(SumTmp_3__1_), .Y(n60) );
  INVX1 U30 ( .A(SumTmp_2__1_), .Y(n63) );
  INVX1 U31 ( .A(SumTmp_3__3_), .Y(n52) );
  INVX1 U32 ( .A(SumTmp_1__1_), .Y(n66) );
  INVX1 U33 ( .A(SumTmp_1__3_), .Y(n59) );
  INVX1 U34 ( .A(SumTmp_1__5_), .Y(n51) );
  INVX1 U35 ( .A(n36), .Y(PartRem_4__3_) );
  INVX1 U36 ( .A(n39), .Y(PartRem_3__3_) );
  INVX1 U37 ( .A(n42), .Y(PartRem_2__3_) );
  INVX1 U38 ( .A(n25), .Y(PartRem_1__3_) );
  INVX1 U39 ( .A(n41), .Y(PartRem_2__5_) );
  INVX1 U40 ( .A(n21), .Y(PartRem_1__5_) );
  INVX1 U41 ( .A(n18), .Y(remainder[7]) );
  AND2X1 U42 ( .A(CryTmp_4__4_), .B(n58), .Y(quotient[4]) );
  INVX1 U43 ( .A(PartRem_1__2_), .Y(n27) );
  INVX1 U44 ( .A(SumTmp_0__2_), .Y(n28) );
  INVX1 U45 ( .A(SumTmp_0__1_), .Y(n30) );
  INVX1 U46 ( .A(SumTmp_0__3_), .Y(n26) );
  INVX1 U47 ( .A(PartRem_1__4_), .Y(n23) );
  INVX1 U48 ( .A(SumTmp_0__4_), .Y(n24) );
  INVX1 U49 ( .A(SumTmp_0__5_), .Y(n22) );
  INVX1 U50 ( .A(PartRem_1__6_), .Y(n19) );
  INVX1 U51 ( .A(SumTmp_0__6_), .Y(n20) );
  INVX1 U52 ( .A(n44), .Y(PartRem_1__7_) );
  AND2X1 U53 ( .A(CryTmp_5__3_), .B(n50), .Y(quotient[5]) );
  INVX1 U54 ( .A(n1), .Y(quotient[6]) );
  INVX1 U55 ( .A(n34), .Y(PartRem_5__3_) );
  INVX1 U56 ( .A(n38), .Y(PartRem_3__5_) );
  INVX1 U57 ( .A(n65), .Y(n62) );
  INVX1 U58 ( .A(b[1]), .Y(BInv[1]) );
  INVX1 U59 ( .A(b[7]), .Y(BInv[7]) );
  INVX1 U60 ( .A(b[2]), .Y(BInv[2]) );
  INVX1 U61 ( .A(b[0]), .Y(BInv[0]) );
  OR2X1 U62 ( .A(a[5]), .B(BInv[0]), .Y(n10) );
  OR2X1 U63 ( .A(a[4]), .B(BInv[0]), .Y(n11) );
  OR2X1 U64 ( .A(a[1]), .B(BInv[0]), .Y(n12) );
  OR2X1 U65 ( .A(a[0]), .B(BInv[0]), .Y(n13) );
  OR2X1 U66 ( .A(a[3]), .B(BInv[0]), .Y(n14) );
  OR2X1 U67 ( .A(a[2]), .B(BInv[0]), .Y(n15) );
  OR2X1 U68 ( .A(a[6]), .B(BInv[0]), .Y(n16) );
  INVX1 U69 ( .A(n2), .Y(quotient[7]) );
  INVX1 U70 ( .A(n31), .Y(remainder[0]) );
  OR2X1 U71 ( .A(b[7]), .B(b[6]), .Y(n65) );
  INVX1 U72 ( .A(n57), .Y(n50) );
  INVX1 U73 ( .A(n67), .Y(quotient[1]) );
  OR2X1 U74 ( .A(b[7]), .B(n68), .Y(n67) );
  INVX1 U75 ( .A(CryTmp_1__7_), .Y(n68) );
  INVX1 U76 ( .A(b[3]), .Y(BInv[3]) );
  INVX1 U77 ( .A(b[4]), .Y(BInv[4]) );
  INVX1 U78 ( .A(b[5]), .Y(BInv[5]) );
  INVX1 U79 ( .A(b[6]), .Y(BInv[6]) );
  XNOR2X1 U80 ( .A(BInv[0]), .B(a[0]), .Y(SumTmp_0__0_) );
  XNOR2X1 U81 ( .A(BInv[0]), .B(a[1]), .Y(SumTmp_1__0_) );
  XNOR2X1 U82 ( .A(BInv[0]), .B(a[2]), .Y(SumTmp_2__0_) );
  XNOR2X1 U83 ( .A(BInv[0]), .B(a[3]), .Y(SumTmp_3__0_) );
  XNOR2X1 U84 ( .A(BInv[0]), .B(a[4]), .Y(SumTmp_4__0_) );
  XNOR2X1 U85 ( .A(BInv[0]), .B(a[5]), .Y(SumTmp_5__0_) );
  XNOR2X1 U86 ( .A(BInv[0]), .B(a[6]), .Y(SumTmp_6__0_) );
  XNOR2X1 U87 ( .A(BInv[0]), .B(a[7]), .Y(SumTmp_7__0_) );
  MUX2X1 U88 ( .B(PartRem_1__7_), .A(SumTmp_0__7_), .S(quotient[0]), .Y(n18)
         );
  MUX2X1 U89 ( .B(n19), .A(n20), .S(quotient[0]), .Y(remainder[6]) );
  MUX2X1 U90 ( .B(n21), .A(n22), .S(quotient[0]), .Y(remainder[5]) );
  MUX2X1 U91 ( .B(n23), .A(n24), .S(quotient[0]), .Y(remainder[4]) );
  MUX2X1 U92 ( .B(n25), .A(n26), .S(quotient[0]), .Y(remainder[3]) );
  MUX2X1 U93 ( .B(n27), .A(n28), .S(quotient[0]), .Y(remainder[2]) );
  MUX2X1 U94 ( .B(n29), .A(n30), .S(quotient[0]), .Y(remainder[1]) );
  MUX2X1 U95 ( .B(a[0]), .A(SumTmp_0__0_), .S(quotient[0]), .Y(n31) );
  MUX2X1 U96 ( .B(PartRem_2__6_), .A(SumTmp_1__6_), .S(quotient[1]), .Y(n44)
         );
  MUX2X1 U97 ( .B(n38), .A(n45), .S(quotient[2]), .Y(PartRem_2__6_) );
  MUX2X1 U98 ( .B(PartRem_4__4_), .A(SumTmp_3__4_), .S(quotient[3]), .Y(n38)
         );
  MUX2X1 U99 ( .B(n34), .A(n46), .S(quotient[4]), .Y(PartRem_4__4_) );
  MUX2X1 U100 ( .B(PartRem_6__2_), .A(SumTmp_5__2_), .S(quotient[5]), .Y(n34)
         );
  MUX2X1 U101 ( .B(n32), .A(n47), .S(quotient[6]), .Y(PartRem_6__2_) );
  MUX2X1 U102 ( .B(a[7]), .A(SumTmp_7__0_), .S(quotient[7]), .Y(n32) );
  NAND3X1 U103 ( .A(n17), .B(n3), .C(n50), .Y(n48) );
  MUX2X1 U104 ( .B(n41), .A(n51), .S(quotient[1]), .Y(PartRem_1__6_) );
  MUX2X1 U105 ( .B(PartRem_3__4_), .A(SumTmp_2__4_), .S(quotient[2]), .Y(n41)
         );
  MUX2X1 U106 ( .B(n36), .A(n52), .S(quotient[3]), .Y(PartRem_3__4_) );
  MUX2X1 U107 ( .B(PartRem_5__2_), .A(SumTmp_4__2_), .S(quotient[4]), .Y(n36)
         );
  MUX2X1 U108 ( .B(n33), .A(n53), .S(quotient[5]), .Y(PartRem_5__2_) );
  MUX2X1 U109 ( .B(a[6]), .A(SumTmp_6__0_), .S(quotient[6]), .Y(n33) );
  NAND3X1 U110 ( .A(n50), .B(BInv[2]), .C(CryTmp_6__2_), .Y(n54) );
  MUX2X1 U111 ( .B(PartRem_2__4_), .A(SumTmp_1__4_), .S(quotient[1]), .Y(n21)
         );
  MUX2X1 U112 ( .B(n39), .A(n55), .S(quotient[2]), .Y(PartRem_2__4_) );
  MUX2X1 U113 ( .B(PartRem_4__2_), .A(SumTmp_3__2_), .S(quotient[3]), .Y(n39)
         );
  MUX2X1 U114 ( .B(n35), .A(n56), .S(quotient[4]), .Y(PartRem_4__2_) );
  MUX2X1 U115 ( .B(a[5]), .A(SumTmp_5__0_), .S(quotient[5]), .Y(n35) );
  MUX2X1 U116 ( .B(n42), .A(n59), .S(quotient[1]), .Y(PartRem_1__4_) );
  MUX2X1 U117 ( .B(PartRem_3__2_), .A(SumTmp_2__2_), .S(quotient[2]), .Y(n42)
         );
  MUX2X1 U118 ( .B(n37), .A(n60), .S(quotient[3]), .Y(PartRem_3__2_) );
  MUX2X1 U119 ( .B(a[4]), .A(SumTmp_4__0_), .S(quotient[4]), .Y(n37) );
  MUX2X1 U120 ( .B(PartRem_2__2_), .A(SumTmp_1__2_), .S(quotient[1]), .Y(n25)
         );
  MUX2X1 U121 ( .B(n40), .A(n63), .S(quotient[2]), .Y(PartRem_2__2_) );
  MUX2X1 U122 ( .B(a[3]), .A(SumTmp_3__0_), .S(quotient[3]), .Y(n40) );
  MUX2X1 U123 ( .B(n43), .A(n66), .S(quotient[1]), .Y(PartRem_1__2_) );
  MUX2X1 U124 ( .B(a[2]), .A(SumTmp_2__0_), .S(quotient[2]), .Y(n43) );
  MUX2X1 U125 ( .B(a[1]), .A(SumTmp_1__0_), .S(quotient[1]), .Y(n29) );
endmodule


module DW_div_inst ( di_A, di_B, quotient_b, remainder_b );
  input [7:0] di_A;
  input [7:0] di_B;
  output [7:0] quotient_b;
  output [7:0] remainder_b;


  DW_div_inst_DW_div_6 DW_div_1 ( .a(di_A), .b(di_B), .quotient(quotient_b), 
        .remainder(remainder_b) );
endmodule

