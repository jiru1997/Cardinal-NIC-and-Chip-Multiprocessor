////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2008 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Kyung-Nam Han  Jul. 7, 2008
//
// VERSION:   Verilog Simulation Module for DW_sincos
//
// DesignWare_version: e87d215b
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////


// ABSTRACT: Fixed-Point Sine/Cosine Unit
//
//             DW_sincos calculates the fixed-point sine/cosine 
//             function. 
//
//             parameters      valid values (defined in the DW manual)
//             ==========      ============
//             A_width         input,      2 to 34 bits
//             WAVE_width      output,     2 to 34 bits
//             arch            implementation select
//                             0 - area optimized (default)
//                             1 - speed optimized
//             err_range       error range of the result compared to the
//                             true result
//                             1 - 1 ulp error (default)
//                             2 - 2 ulp error
//
//             Input ports     Size & Description
//             ===========     ==================
//             A               A_width bits
//                             Fixed-point Number Input
//             SIN_COS         1 bit
//                             Operator Selector
//                             0 - sine, 1 - cosine
//             WAVE            WAVE_width bits
//                             Fixed-point Number Output
//
// MODIFIED:
//   09/08/08 Kyung-Nam Han
//            Improved QoR when A_width > WAVE_width
//   06/16/10 Kyung-Nam Han (STAR 9000400672)
//            DW_sincos has 2 ulp erros when A_width<=9, err_range=1. 
//            Fixed from D-2010.03-SP3.
//   03/02/15 Kyung-Nam Han (STAR 9000862271, 9000855825)
//            Fixed 1 ulp error and out-range-error when
//            9 <= A_width <= 15 and 14 <= WAVE_width <= 16. 
//----------------------------------------------------------------------
module DW_sincos (
                   A,
                   SIN_COS,
                   WAVE
);

parameter A_width = 24;
parameter WAVE_width = 25;
parameter arch = 0;
parameter err_range = 1;

localparam lO00001O = 1;
localparam O0Ol1101 = (A_width >= 9) && (A_width <= 15) && (WAVE_width >= 14) && (WAVE_width <= 15) && lO00001O;
localparam O11l1lO1 = (A_width >= 9) && (A_width <= 15) && (WAVE_width == 16) && lO00001O;
localparam I00II0OO = (O0Ol1101 || O11l1lO1);
localparam O10001I1 = (O0Ol1101) ? 1 : err_range;



input [A_width - 1:0] A;
input SIN_COS;
output [WAVE_width - 1:0] WAVE;

// synopsys translate_off

localparam IOI1O1O1 = 0;

localparam O10O1001 = 0;
localparam lO110O01 = 0;
localparam l0OO11l1 = 19 - 9;
localparam Ol1OlOO1 = ((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2);
localparam O0Ol0ll1 = l0OO11l1 + ((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))));
localparam O001Il0I = Ol1OlOO1 + 1;

wire [l0OO11l1 - 1:0] Il0Olll0;
wire [((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:0] I11O10O1;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] O11O100O;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] OO1100OI;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] l1OIl011;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] O1010OI0;
wire [((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:0] O100OO1l;
wire [((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:0] l01Ol010;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) == 2) ? 0 : ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 3) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 0 : ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)):0] IO0O011O;
wire [(((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) - 1:0] I0100000;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 0 : ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 3 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)):0] O1011OOO;
wire [((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) - 1:0] OlO01lOO;
wire [((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) - 1:0] l1IOl0O0;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + 2)) - 1:0] OI00I100;
wire [(2 * ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + 2))) - 1:0] lOl00Il0;
wire [(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) - 1:0] O10OOI11;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + 2))) : 1) - 1:0] O1O0lOIO;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1) - 1:0] O11O1001;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) - 1:0] l1OlO0O0;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1) - 1:0] O0O011O1;
wire [((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))) - 1:0] O10O10O1;
wire [(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)) - 1:0] I1000l11;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3)) - 1:0] OI00O010;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1) - 1:0] OllO1OOO;
wire [((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) + ((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))))) - 1:0] O00O01OO;
wire [(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 2) - 1:0] l1l0O1ll;
wire [((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2):0] O1OI0lI0;
wire [((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2):0] O0l0O001;
wire [(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)) - 1:0] I100II10;
wire [(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))) - 1:0] I1llOOlO;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1) - 1:0] OOI00OO0;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) - 1:0] ll0100O0;
wire [((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) + ((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))))) - 1:0] lO01000I;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) + (3 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)))) - 1:0] O00011O0;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) - 1:0] O0lIOO00;
wire [(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) - 1:0] lO11O100;
wire [(((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) - 1:0] O10001lO;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] OllIOOOl;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] O1OlO010;
wire OOOOOOO1;
wire O0OOOI1l;
wire lIlO0l1O;
wire II1OOOI1;
wire O01OI010;
wire Ol0O1O0O;
wire O0Ol0I1O;
wire [WAVE_width - 1:0] O1111Ol0;
wire OlO1l1OO;
wire [(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) - 1:0] lO0O1I0l;
wire [((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 1:0] O11I00II;
wire [(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1):0] OI110IIO;
wire [((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2):0] O0000OlI;
wire [((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2):0] O1I000O1;
wire [Ol1OlOO1 - 1:0] l11011lI;
wire [((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) + (3 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)))) + O10O1001 - 1:0] lI10lIO1;
wire [O0Ol0ll1 - 1 + lO110O01:0] OOOOIO0I;
wire [O001Il0I - 1:0] lOOl0O1l;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] l001OOll;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] I10OII11;
wire [l0OO11l1 - 1:0] l0O01001;
wire [((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) + O10O1001:0] I0I10IlO;
wire [((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) + O10O1001:0] OOO00OI0;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] O10101lO;
wire [((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:0] I10l0OIO;

reg [14 - 1:0] I1OI1110;
reg [21 - 1:0] OOOl0110;
reg [29 - 1:0] O0II010O;
reg [13 - 1:0] l111OlOl;
reg [19 - 1:0] IlI0O01I;
reg [26 - 1:0] OOO011lO;
reg [15 - 1:0] l0011l0O;
reg [22  - 1:0] l1101IO0;
reg [29 - 1:0] O1O1O1l1;
reg [37 - 1:0] OOOI0lO1;
reg [19 - 1:0] OI0I1O1O;
reg [26 - 1:0] ll0IO001;


//-------------------------------------------------------------------------
// Parameter legality check
//-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if ( (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) < 2) || (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) > 34) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) (legal range: 2 to 34)",
	((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) );
    end
    
    if ( (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) < 2) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) > 35) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) (legal range: 2 to 35)",
	((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) );
    end
    
    if ( (arch < 0) || (arch > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch (legal range: 0 to 1)",
	arch );
    end
    
    if ( (err_range < 1) || (err_range > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_range (legal range: 1 to 2)",
	err_range );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

//-------------------------------------------------------------------------

assign I11O10O1 = (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) > A_width + 1) ? {A, {(((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) > A_width + 1) ? ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - A_width - 1 : 1)){1'b0}}} : A[A_width - 1:((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= A_width + 1) ? 0 : A_width - ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)))];


assign OOOOOOO1 = (SIN_COS == 0 && (I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b00 ||
                                  I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b10) ||
                 SIN_COS == 1 && (I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b01 ||
                                  I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b11)) ?
                1'b0 : 1'b1;
assign O0OOOI1l = (SIN_COS == 0 && (I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b00 ||
                                  I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b01) ||
                 SIN_COS == 1 && (I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b00 ||
                                  I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b11)) ?
                1'b0 : 1'b1;

assign O0Ol0I1O = (SIN_COS == 0 && (I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] && (I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 3:0] == 0))) ||
                   (SIN_COS == 1 && (I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2:0] == 0));
assign l01Ol010 = (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? -I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2:0] :
                           {1'b1, {(((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1){1'b0}}} - I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2:0];
assign O100OO1l = (OOOOOOO1) ? l01Ol010 : {1'b0, I11O10O1[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2:0]};
assign O01OI010 = (SIN_COS) ? (O100OO1l[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b10) :
                           (O100OO1l[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1:((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2] == 2'b01);

assign IO0O011O = O100OO1l[((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) == 2) ? 0 : ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 3):((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 0 : ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))];

assign O1011OOO = O100OO1l[((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 0 : ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 3 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)):0];
assign OlO01lOO = (((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? {O1011OOO, 1'b0} : O1011OOO;

assign I0100000 = (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) < 9) ? 
                       {IO0O011O, {(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) < 9) ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) : 1)){1'b0}}} :
                       IO0O011O;
assign l1IOl0O0 = OlO01lOO;

assign OI00I100 = l1IOl0O0[((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) - 1:((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + 2))];
assign lOl00Il0 = OI00I100 * OI00I100;
assign O10OOI11 = lOl00Il0[(2 * ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + 2))) - 1:(2 * ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + 2))) - (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))];

assign O1O0lOIO = O10OOI11 * OI00I100;
assign O11O1001 = O1O0lOIO[((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + 2))) : 1) - 1:((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + 2))) : 1) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)];

assign O0O011O1 = (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? l0011l0O[15 - 1:15 - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1)] : {((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1){1'b0}};
assign I1000l11 = O0O011O1 * O11O1001;
assign OllO1OOO = (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? I1000l11[(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)) - 1:(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1)] : {((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1){1'b0}};

assign l1OlO0O0 = (((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) || (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9)) ? {((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)){1'b0}} :
            (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? l1101IO0[22  - 1:22  - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))] :
            ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) == 6) ? l111OlOl[(((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) == 6) ? (13 - 1) : 0):(((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) == 6) ? (13 - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))) : 0)] :
                                I1OI1110[14 - 1:((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? 0 : 14 - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)))];
assign O10O10O1 = l1OlO0O0 * O10OOI11;
assign OI00O010 = O10O10O1[((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))) - 1:((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)))  ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3))];


generate
if (O0Ol1101) begin : DW_I00I10OO
  assign lO0O1I0l = {(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1){1'b0}};
  assign Il0Olll0 = OI0I1O1O[19 - 1:9];
end
else begin : DW_O1l0O101
  assign Il0Olll0 = {l0OO11l1{1'b0}};
  assign lO0O1I0l = (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? {(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1){1'b0}} :
              (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? O1O1O1l1[29 - 1:29 - (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1)] :
              ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) == 6) ? IlI0O01I[19 - 1:(((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) == 6) ? 19 - (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) : 0)] :
                                 OOOl0110[21 - 1:((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? 0 : 21 - (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1))];
end
endgenerate

assign O00O01OO = lO0O1I0l * l1IOl0O0;
assign l1l0O1ll = O00O01OO[((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) + ((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))))) - 1:((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) + ((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))))) - (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 2)];


generate
if (O0Ol1101) begin : DW_ll1IlI0O
  assign O11I00II = {((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2){1'b0}};
  assign l11011lI = ll0IO001[26 - 1:26 - ((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2)];
end
else begin : DW_l1OO0110
  assign l11011lI = {Ol1OlOO1{1'b0}};
  assign O11I00II = (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? OOOI0lO1[37 - 1:37 - ((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2)] :
              ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) == 6) ? OOO011lO[(((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) == 6) ? (26 - 1) : 0):(((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) == 6) ? (26 - ((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2)) : 0)] :
                                 O0II010O[29 - 1:((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? 0 : 29 - ((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2))];
end
endgenerate

assign O0l0O001 = -OllO1OOO - OI00O010 + l1l0O1ll + O11I00II;

assign lIlO0l1O = (((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? O0l0O001[2] : 1'b0;
assign l001OOll = O0l0O001[((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2):4 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)] + lIlO0l1O;

generate
if (IOI1O1O1 == 1) begin
  assign I10OII11[0] = (l001OOll[((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2]) ? 1'b0 : l001OOll[0];
  assign I10OII11[((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:1] = l001OOll[((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:1];
end
else begin
  assign I10OII11 = l001OOll;
end
endgenerate

assign O1010OI0 = (O0OOOI1l) ? -I10OII11 : I10OII11;

assign I100II10 = O0O011O1 * l1IOl0O0[((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) - 1:((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)];
assign OOI00OO0 = I100II10[(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)) - 1:(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26)  ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 3) : 1) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 3 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2) : 1)];
assign O0lIOO00 = (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 26) ? OOI00OO0 + l1OlO0O0 : l1OlO0O0;


generate
if (O0Ol1101) begin : DW_lOlOOIl0
  assign OI110IIO = {(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) + 1{1'b0}};
  assign O1I000O1 = {((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) + 1{1'b0}};
  assign O0000OlI = {((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) + 1{1'b0}};

  assign l0O01001 = Il0Olll0;
  assign OOO00OI0 = l11011lI;
  assign I0I10IlO = OOO00OI0;
end
else begin : DW_O1I10OI1
  assign OOO00OI0 = {((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) + 1{1'b0}};
  assign I0I10IlO = {((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) + 1{1'b0}};
  assign l0O01001 = {l0OO11l1{1'b0}};

  assign OI110IIO = lO0O1I0l;
  assign O1I000O1 = O11I00II;
  assign O0000OlI = (O1I000O1[((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2)]) ? {((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) + 1{1'b0}} : O1I000O1;
end
endgenerate


assign I1llOOlO = O0lIOO00 * l1IOl0O0[((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) - 1:((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))];
assign ll0100O0 = I1llOOlO[(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))) - 1:(((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2)) + ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) || ((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 1 : ((((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - 2 * (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 2))];
assign lO11O100 = -ll0100O0 + lO0O1I0l;


generate
if (O0Ol1101) begin : DW_IO1IO01O
  assign O00011O0 = {((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) + (3 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)))){1'b0}};
  assign lO01000I = {((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) + ((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))))){1'b0}};

  assign OOOOIO0I = l0O01001 * l1IOl0O0;
  assign lI10lIO1 = OOOOIO0I[O0Ol0ll1 - 1:O0Ol0ll1 - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) + (3 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)))) - O10O1001];
  assign lOOl0O1l = lI10lIO1 + I0I10IlO;
  assign O1OI0lI0 = lOOl0O1l[((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2):0];
end
else begin : DW_OOll1OI1
  assign lI10lIO1 = {((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) + (3 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)))){1'b0}};
  assign OOOOIO0I = {O0Ol0ll1{1'b0}};

  assign lO01000I = lO11O100 * l1IOl0O0;
  assign O00011O0 = lO01000I[((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) + ((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))))) - 1:((((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2) - (1 + (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7)))) + 1) + ((((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? (((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))) + 1) : ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 2 - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7))))) - ((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? 1 : (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - (((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) >= 11 && ((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) <= 24) || (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) == 25 && ((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 2)) ? 6 : 7) + (3 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1))))];
  assign O1OI0lI0 = O00011O0 + O11I00II;
end
endgenerate

generate
if (O0Ol1101) begin : DW_l0II10I1
  assign II1OOOI1 = 1'b0;
end
else begin : DW_OOII010I
  assign II1OOOI1 = (((WAVE_width >= A_width + 1) ? O10001I1 : 1) == 1) ? O1OI0lI0[2] : 1'b0;
end
endgenerate

assign O10101lO = O1OI0lI0[((((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2) + (2 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)) + 2):4 - ((WAVE_width >= A_width + 1) ? O10001I1 : 1)] + II1OOOI1;

generate
if (IOI1O1O1 == 1) begin
  assign I10l0OIO[0] = (O10101lO[((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2]) ? 1'b0 : O10101lO[0];
  assign I10l0OIO[((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:1] = O10101lO[((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:1];
end
else begin
  assign I10l0OIO = O10101lO;
end
endgenerate

assign l1OIl011 = (O0OOOI1l) ? -I10l0OIO : I10l0OIO;

assign O10001lO = {O100OO1l[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1], O0II010O[29 - 1:((((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 9) ? (29 - (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2)) : 0)]};
assign OllIOOOl = (O0Ol0I1O) ? {O0OOOI1l, 1'b1, {(WAVE_width - 2){1'b0}}} :
                 (O0OOOI1l) ? -O10001lO : O10001lO;

assign O11O100O = ((((O0Ol1101) ? 1 : (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 14)) ? 0 : arch) == 0) ? l1OIl011 : O1010OI0;
assign Ol0O1O0O = O01OI010 & O0OOOI1l;
assign OO1100OI = {Ol0O1O0O, (O100OO1l[((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) - 1] | O01OI010), {(((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 2){1'b0}}}; 
assign O1OlO010 = (((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) >= 10 && ((WAVE_width >= A_width + 1) ? (WAVE_width - 1) : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width : WAVE_width + 1)) <= 34) ? 
                  O11O100O | OO1100OI :
                  OllIOOOl;
assign WAVE = (((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) > WAVE_width) ? O1OlO010[((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - 1:((WAVE_width >= A_width + 1) ? WAVE_width : (((WAVE_width == A_width) || (O10001I1 == 1)) ? A_width + 1 : WAVE_width)) - WAVE_width] : O1OlO010;


always @(I0100000) begin : a1000_PROC
  case(I0100000)
    6'b000000: begin
      ll0IO001 = 4608;
      OI0I1O1O = 411520;
    end
    6'b000001: begin
      ll0IO001 = 1651200;
      OI0I1O1O = 411520;
    end
    6'b000010: begin
      ll0IO001 = 3297280;
      OI0I1O1O = 411008;
    end
    6'b000011: begin
      ll0IO001 = 4941312;
      OI0I1O1O = 410240;
    end
    6'b000100: begin
      ll0IO001 = 6582272;
      OI0I1O1O = 409216;
    end
    6'b000101: begin
      ll0IO001 = 8219648;
      OI0I1O1O = 407808;
    end
    6'b000110: begin
      ll0IO001 = 9851392;
      OI0I1O1O = 406528;
    end
    6'b000111: begin
      ll0IO001 = 11477504;
      OI0I1O1O = 404864;
    end
    6'b001000: begin
      ll0IO001 = 13096960;
      OI0I1O1O = 402944;
    end
    6'b001001: begin
      ll0IO001 = 14708224;
      OI0I1O1O = 400640;
    end
    6'b001010: begin
      ll0IO001 = 16311296;
      OI0I1O1O = 398080;
    end
    6'b001011: begin
      ll0IO001 = 17903104;
      OI0I1O1O = 395776;
    end
    6'b001100: begin
      ll0IO001 = 19486208;
      OI0I1O1O = 392576;
    end
    6'b001101: begin
      ll0IO001 = 21056512;
      OI0I1O1O = 389120;
    end
    6'b001110: begin
      ll0IO001 = 22614016;
      OI0I1O1O = 385792;
    end
    6'b001111: begin
      ll0IO001 = 24157184;
      OI0I1O1O = 382464;
    end
    6'b010000: begin
      ll0IO001 = 25685504;
      OI0I1O1O = 378880;
    end
    6'b010001: begin
      ll0IO001 = 27200512;
      OI0I1O1O = 374272;
    end
    6'b010010: begin
      ll0IO001 = 28697600;
      OI0I1O1O = 370304;
    end
    6'b010011: begin
      ll0IO001 = 30178816;
      OI0I1O1O = 365312;
    end
    6'b010100: begin
      ll0IO001 = 31640064;
      OI0I1O1O = 360832;
    end
    6'b010101: begin
      ll0IO001 = 33083392;
      OI0I1O1O = 355840;
    end
    6'b010110: begin
      ll0IO001 = 34506752;
      OI0I1O1O = 350336;
    end
    6'b010111: begin
      ll0IO001 = 35908608;
      OI0I1O1O = 345216;
    end
    6'b011000: begin
      ll0IO001 = 37289472;
      OI0I1O1O = 339584;
    end
    6'b011001: begin
      ll0IO001 = 38647296;
      OI0I1O1O = 333824;
    end
    6'b011010: begin
      ll0IO001 = 39981056;
      OI0I1O1O = 327680;
    end
    6'b011011: begin
      ll0IO001 = 41293824;
      OI0I1O1O = 321280;
    end
    6'b011100: begin
      ll0IO001 = 42579968;
      OI0I1O1O = 314880;
    end
    6'b011101: begin
      ll0IO001 = 43840000;
      OI0I1O1O = 308352;
    end
    6'b011110: begin
      ll0IO001 = 45073920;
      OI0I1O1O = 301568;
    end
    6'b011111: begin
      ll0IO001 = 46280704;
      OI0I1O1O = 294528;
    end
    6'b100000: begin
      ll0IO001 = 47459328;
      OI0I1O1O = 287744;
    end
    6'b100001: begin
      ll0IO001 = 48609280;
      OI0I1O1O = 280448;
    end
    6'b100010: begin
      ll0IO001 = 49730048;
      OI0I1O1O = 273280;
    end
    6'b100011: begin
      ll0IO001 = 50821120;
      OI0I1O1O = 265472;
    end
    6'b100100: begin
      ll0IO001 = 51883520;
      OI0I1O1O = 256896;
    end
    6'b100101: begin
      ll0IO001 = 52911616;
      OI0I1O1O = 249344;
    end
    6'b100110: begin
      ll0IO001 = 53908992;
      OI0I1O1O = 241152;
    end
    6'b100111: begin
      ll0IO001 = 54872576;
      OI0I1O1O = 233216;
    end
    6'b101000: begin
      ll0IO001 = 55805440;
      OI0I1O1O = 224512;
    end
    6'b101001: begin
      ll0IO001 = 56704000;
      OI0I1O1O = 215808;
    end
    6'b101010: begin
      ll0IO001 = 57568256;
      OI0I1O1O = 207232;
    end
    6'b101011: begin
      ll0IO001 = 58397184;
      OI0I1O1O = 198528;
    end
    6'b101100: begin
      ll0IO001 = 59191296;
      OI0I1O1O = 189696;
    end
    6'b101101: begin
      ll0IO001 = 59949568;
      OI0I1O1O = 180864;
    end
    6'b101110: begin
      ll0IO001 = 60672000;
      OI0I1O1O = 171776;
    end
    6'b101111: begin
      ll0IO001 = 61357056;
      OI0I1O1O = 162688;
    end
    6'b110000: begin
      ll0IO001 = 62006784;
      OI0I1O1O = 152960;
    end
    6'b110001: begin
      ll0IO001 = 62618624;
      OI0I1O1O = 143616;
    end
    6'b110010: begin
      ll0IO001 = 63192576;
      OI0I1O1O = 134144;
    end
    6'b110011: begin
      ll0IO001 = 63729664;
      OI0I1O1O = 124160;
    end
    6'b110100: begin
      ll0IO001 = 64225280;
      OI0I1O1O = 115072;
    end
    6'b110101: begin
      ll0IO001 = 64683520;
      OI0I1O1O = 105344;
    end
    6'b110110: begin
      ll0IO001 = 65104384;
      OI0I1O1O = 95232;
    end
    6'b110111: begin
      ll0IO001 = 65484800;
      OI0I1O1O = 85632;
    end
    6'b111000: begin
      ll0IO001 = 65825280;
      OI0I1O1O = 75648;
    end
    6'b111001: begin
      ll0IO001 = 66125824;
      OI0I1O1O = 65536;
    end
    6'b111010: begin
      ll0IO001 = 66389504;
      OI0I1O1O = 55296;
    end
    6'b111011: begin
      ll0IO001 = 66610176;
      OI0I1O1O = 45824;
    end
    6'b111100: begin
      ll0IO001 = 66792960;
      OI0I1O1O = 35200;
    end
    6'b111101: begin
      ll0IO001 = 66933248;
      OI0I1O1O = 25600;
    end
    6'b111110: begin
      ll0IO001 = 67034624;
      OI0I1O1O = 15232;
    end
    6'b111111: begin
      ll0IO001 = 67096576;
      OI0I1O1O = 5120;
    end
  endcase

  case(I0100000)
    6'b000000: begin
      l111OlOl = 62;
      IlI0O01I = 411798;
      OOO011lO = 5;
    end
    6'b000001: begin
      l111OlOl = 185;
      IlI0O01I = 411674;
      OOO011lO = 1646928;
    end
    6'b000010: begin
      l111OlOl = 309;
      IlI0O01I = 411302;
      OOO011lO = 3292870;
    end
    6'b000011: begin
      l111OlOl = 433;
      IlI0O01I = 410682;
      OOO011lO = 4936829;
    end
    6'b000100: begin
      l111OlOl = 556;
      IlI0O01I = 409815;
      OOO011lO = 6577813;
    end
    6'b000101: begin
      l111OlOl = 680;
      IlI0O01I = 408701;
      OOO011lO = 8214836;
    end
    6'b000110: begin
      l111OlOl = 802;
      IlI0O01I = 407340;
      OOO011lO = 9846910;
    end
    6'b000111: begin
      l111OlOl = 924;
      IlI0O01I = 405735;
      OOO011lO = 11473053;
    end
    6'b001000: begin
      l111OlOl = 1046;
      IlI0O01I = 403885;
      OOO011lO = 13092284;
    end
    6'b001001: begin
      l111OlOl = 1167;
      IlI0O01I = 401792;
      OOO011lO = 14703630;
    end
    6'b001010: begin
      l111OlOl = 1287;
      IlI0O01I = 399456;
      OOO011lO = 16306118;
    end
    6'b001011: begin
      l111OlOl = 1407;
      IlI0O01I = 396881;
      OOO011lO = 17898785;
    end
    6'b001100: begin
      l111OlOl = 1526;
      IlI0O01I = 394066;
      OOO011lO = 19480669;
    end
    6'b001101: begin
      l111OlOl = 1643;
      IlI0O01I = 391013;
      OOO011lO = 21050820;
    end
    6'b001110: begin
      l111OlOl = 1760;
      IlI0O01I = 387725;
      OOO011lO = 22608290;
    end
    6'b001111: begin
      l111OlOl = 1876;
      IlI0O01I = 384204;
      OOO011lO = 24152142;
    end
    6'b010000: begin
      l111OlOl = 1990;
      IlI0O01I = 380451;
      OOO011lO = 25681445;
    end
    6'b010001: begin
      l111OlOl = 2104;
      IlI0O01I = 376469;
      OOO011lO = 27195279;
    end
    6'b010010: begin
      l111OlOl = 2216;
      IlI0O01I = 372260;
      OOO011lO = 28692731;
    end
    6'b010011: begin
      l111OlOl = 2327;
      IlI0O01I = 367827;
      OOO011lO = 30172900;
    end
    6'b010100: begin
      l111OlOl = 2436;
      IlI0O01I = 363173;
      OOO011lO = 31634894;
    end
    6'b010101: begin
      l111OlOl = 2544;
      IlI0O01I = 358300;
      OOO011lO = 33077833;
    end
    6'b010110: begin
      l111OlOl = 2650;
      IlI0O01I = 353210;
      OOO011lO = 34500846;
    end
    6'b010111: begin
      l111OlOl = 2755;
      IlI0O01I = 347908;
      OOO011lO = 35903078;
    end
    6'b011000: begin
      l111OlOl = 2858;
      IlI0O01I = 342397;
      OOO011lO = 37283682;
    end
    6'b011001: begin
      l111OlOl = 2960;
      IlI0O01I = 336679;
      OOO011lO = 38641829;
    end
    6'b011010: begin
      l111OlOl = 3059;
      IlI0O01I = 330759;
      OOO011lO = 39976699;
    end
    6'b011011: begin
      l111OlOl = 3157;
      IlI0O01I = 324639;
      OOO011lO = 41287489;
    end
    6'b011100: begin
      l111OlOl = 3253;
      IlI0O01I = 318324;
      OOO011lO = 42573408;
    end
    6'b011101: begin
      l111OlOl = 3347;
      IlI0O01I = 311817;
      OOO011lO = 43833683;
    end
    6'b011110: begin
      l111OlOl = 3439;
      IlI0O01I = 305122;
      OOO011lO = 45067554;
    end
    6'b011111: begin
      l111OlOl = 3529;
      IlI0O01I = 298243;
      OOO011lO = 46274278;
    end
    6'b100000: begin
      l111OlOl = 3616;
      IlI0O01I = 291185;
      OOO011lO = 47453129;
    end
    6'b100001: begin
      l111OlOl = 3702;
      IlI0O01I = 283951;
      OOO011lO = 48603395;
    end
    6'b100010: begin
      l111OlOl = 3785;
      IlI0O01I = 276546;
      OOO011lO = 49724384;
    end
    6'b100011: begin
      l111OlOl = 3866;
      IlI0O01I = 268975;
      OOO011lO = 50815422;
    end
    6'b100100: begin
      l111OlOl = 3945;
      IlI0O01I = 261241;
      OOO011lO = 51875850;
    end
    6'b100101: begin
      l111OlOl = 4021;
      IlI0O01I = 253351;
      OOO011lO = 52905030;
    end
    6'b100110: begin
      l111OlOl = 4095;
      IlI0O01I = 245307;
      OOO011lO = 53902341;
    end
    6'b100111: begin
      l111OlOl = 4166;
      IlI0O01I = 237116;
      OOO011lO = 54867185;
    end
    6'b101000: begin
      l111OlOl = 4235;
      IlI0O01I = 228782;
      OOO011lO = 55798978;
    end
    6'b101001: begin
      l111OlOl = 4302;
      IlI0O01I = 220310;
      OOO011lO = 56697160;
    end
    6'b101010: begin
      l111OlOl = 4365;
      IlI0O01I = 211706;
      OOO011lO = 57561190;
    end
    6'b101011: begin
      l111OlOl = 4426;
      IlI0O01I = 202974;
      OOO011lO = 58390547;
    end
    6'b101100: begin
      l111OlOl = 4485;
      IlI0O01I = 194120;
      OOO011lO = 59184731;
    end
    6'b101101: begin
      l111OlOl = 4541;
      IlI0O01I = 185148;
      OOO011lO = 59943265;
    end
    6'b101110: begin
      l111OlOl = 4594;
      IlI0O01I = 176066;
      OOO011lO = 60665692;
    end
    6'b101111: begin
      l111OlOl = 4644;
      IlI0O01I = 166877;
      OOO011lO = 61351576;
    end
    6'b110000: begin
      l111OlOl = 4691;
      IlI0O01I = 157588;
      OOO011lO = 62000503;
    end
    6'b110001: begin
      l111OlOl = 4736;
      IlI0O01I = 148203;
      OOO011lO = 62612085;
    end
    6'b110010: begin
      l111OlOl = 4778;
      IlI0O01I = 138730;
      OOO011lO = 63185950;
    end
    6'b110011: begin
      l111OlOl = 4817;
      IlI0O01I = 129173;
      OOO011lO = 63721755;
    end
    6'b110100: begin
      l111OlOl = 4853;
      IlI0O01I = 119538;
      OOO011lO = 64219177;
    end
    6'b110101: begin
      l111OlOl = 4886;
      IlI0O01I = 109831;
      OOO011lO = 64677915;
    end
    6'b110110: begin
      l111OlOl = 4916;
      IlI0O01I = 100058;
      OOO011lO = 65097694;
    end
    6'b110111: begin
      l111OlOl = 4943;
      IlI0O01I = 90225;
      OOO011lO = 65478260;
    end
    6'b111000: begin
      l111OlOl = 4967;
      IlI0O01I = 80337;
      OOO011lO = 65819385;
    end
    6'b111001: begin
      l111OlOl = 4989;
      IlI0O01I = 70401;
      OOO011lO = 66120862;
    end
    6'b111010: begin
      l111OlOl = 5007;
      IlI0O01I = 60423;
      OOO011lO = 66382511;
    end
    6'b111011: begin
      l111OlOl = 5022;
      IlI0O01I = 50408;
      OOO011lO = 66604173;
    end
    6'b111100: begin
      l111OlOl = 5034;
      IlI0O01I = 40363;
      OOO011lO = 66785716;
    end
    6'b111101: begin
      l111OlOl = 5043;
      IlI0O01I = 30293;
      OOO011lO = 66927029;
    end
    6'b111110: begin
      l111OlOl = 5049;
      IlI0O01I = 20205;
      OOO011lO = 67028028;
    end
    6'b111111: begin
      l111OlOl = 5052;
      IlI0O01I = 10105;
      OOO011lO = 67088651;
    end
  endcase
    
  case(I0100000)
    7'b0000000: begin
      I1OI1110 = 62;
      OOOl0110 = 1647122;
      O0II010O = 5;
    end
    7'b0000001: begin
      I1OI1110 = 186;
      OOOl0110 = 1646998;
      O0II010O = 6588226;
    end
    7'b0000010: begin
      I1OI1110 = 310;
      OOOl0110 = 1646626;
      O0II010O = 13175466;
    end
    7'b0000011: begin
      I1OI1110 = 433;
      OOOl0110 = 1646006;
      O0II010O = 19760722;
    end
    7'b0000100: begin
      I1OI1110 = 557;
      OOOl0110 = 1645138;
      O0II010O = 26343001;
    end
    7'b0000101: begin
      I1OI1110 = 681;
      OOOl0110 = 1644022;
      O0II010O = 32921314;
    end
    7'b0000110: begin
      I1OI1110 = 805;
      OOOl0110 = 1642659;
      O0II010O = 39494669;
    end
    7'b0000111: begin
      I1OI1110 = 928;
      OOOl0110 = 1641048;
      O0II010O = 46062076;
    end
    7'b0001000: begin
      I1OI1110 = 1052;
      OOOl0110 = 1639191;
      O0II010O = 52622546;
    end
    7'b0001001: begin
      I1OI1110 = 1175;
      OOOl0110 = 1637086;
      O0II010O = 59175091;
    end
    7'b0001010: begin
      I1OI1110 = 1298;
      OOOl0110 = 1634735;
      O0II010O = 65718725;
    end
    7'b0001011: begin
      I1OI1110 = 1421;
      OOOl0110 = 1632138;
      O0II010O = 72252462;
    end
    7'b0001100: begin
      I1OI1110 = 1544;
      OOOl0110 = 1629294;
      O0II010O = 78775318;
    end
    7'b0001101: begin
      I1OI1110 = 1666;
      OOOl0110 = 1626206;
      O0II010O = 85286311;
    end
    7'b0001110: begin
      I1OI1110 = 1788;
      OOOl0110 = 1622873;
      O0II010O = 91784460;
    end
    7'b0001111: begin
      I1OI1110 = 1910;
      OOOl0110 = 1619295;
      O0II010O = 98268786;
    end
    7'b0010000: begin
      I1OI1110 = 2032;
      OOOl0110 = 1615473;
      O0II010O = 104738314;
    end
    7'b0010001: begin
      I1OI1110 = 2153;
      OOOl0110 = 1611408;
      O0II010O = 111192068;
    end
    7'b0010010: begin
      I1OI1110 = 2274;
      OOOl0110 = 1607100;
      O0II010O = 117629077;
    end
    7'b0010011: begin
      I1OI1110 = 2395;
      OOOl0110 = 1602551;
      O0II010O = 124048372;
    end
    7'b0010100: begin
      I1OI1110 = 2515;
      OOOl0110 = 1597760;
      O0II010O = 130448985;
    end
    7'b0010101: begin
      I1OI1110 = 2635;
      OOOl0110 = 1592728;
      O0II010O = 136829954;
    end
    7'b0010110: begin
      I1OI1110 = 2755;
      OOOl0110 = 1587457;
      O0II010O = 143190316;
    end
    7'b0010111: begin
      I1OI1110 = 2874;
      OOOl0110 = 1581946;
      O0II010O = 149529114;
    end
    7'b0011000: begin
      I1OI1110 = 2993;
      OOOl0110 = 1576198;
      O0II010O = 155845394;
    end
    7'b0011001: begin
      I1OI1110 = 3111;
      OOOl0110 = 1570211;
      O0II010O = 162138204;
    end
    7'b0011010: begin
      I1OI1110 = 3229;
      OOOl0110 = 1563989;
      O0II010O = 168406597;
    end
    7'b0011011: begin
      I1OI1110 = 3346;
      OOOl0110 = 1557531;
      O0II010O = 174649628;
    end
    7'b0011100: begin
      I1OI1110 = 3463;
      OOOl0110 = 1550838;
      O0II010O = 180866357;
    end
    7'b0011101: begin
      I1OI1110 = 3579;
      OOOl0110 = 1543912;
      O0II010O = 187055849;
    end
    7'b0011110: begin
      I1OI1110 = 3695;
      OOOl0110 = 1536753;
      O0II010O = 193217171;
    end
    7'b0011111: begin
      I1OI1110 = 3810;
      OOOl0110 = 1529363;
      O0II010O = 199349395;
    end
    7'b0100000: begin
      I1OI1110 = 3924;
      OOOl0110 = 1521742;
      O0II010O = 205451598;
    end
    7'b0100001: begin
      I1OI1110 = 4038;
      OOOl0110 = 1513893;
      O0II010O = 211522861;
    end
    7'b0100010: begin
      I1OI1110 = 4152;
      OOOl0110 = 1505815;
      O0II010O = 217562269;
    end
    7'b0100011: begin
      I1OI1110 = 4264;
      OOOl0110 = 1497511;
      O0II010O = 223568913;
    end
    7'b0100100: begin
      I1OI1110 = 4377;
      OOOl0110 = 1488981;
      O0II010O = 229541888;
    end
    7'b0100101: begin
      I1OI1110 = 4488;
      OOOl0110 = 1480226;
      O0II010O = 235480295;
    end
    7'b0100110: begin
      I1OI1110 = 4599;
      OOOl0110 = 1471249;
      O0II010O = 241383239;
    end
    7'b0100111: begin
      I1OI1110 = 4709;
      OOOl0110 = 1462051;
      O0II010O = 247249833;
    end
    7'b0101000: begin
      I1OI1110 = 4818;
      OOOl0110 = 1452632;
      O0II010O = 253079191;
    end
    7'b0101001: begin
      I1OI1110 = 4927;
      OOOl0110 = 1442994;
      O0II010O = 258870436;
    end
    7'b0101010: begin
      I1OI1110 = 5035;
      OOOl0110 = 1433139;
      O0II010O = 264622697;
    end
    7'b0101011: begin
      I1OI1110 = 5142;
      OOOl0110 = 1423069;
      O0II010O = 270335106;
    end
    7'b0101100: begin
      I1OI1110 = 5248;
      OOOl0110 = 1412784;
      O0II010O = 276006804;
    end
    7'b0101101: begin
      I1OI1110 = 5354;
      OOOl0110 = 1402286;
      O0II010O = 281636936;
    end
    7'b0101110: begin
      I1OI1110 = 5459;
      OOOl0110 = 1391577;
      O0II010O = 287224655;
    end
    7'b0101111: begin
      I1OI1110 = 5563;
      OOOl0110 = 1380658;
      O0II010O = 292769119;
    end
    7'b0110000: begin
      I1OI1110 = 5666;
      OOOl0110 = 1369532;
      O0II010O = 298269493;
    end
    7'b0110001: begin
      I1OI1110 = 5768;
      OOOl0110 = 1358199;
      O0II010O = 303724948;
    end
    7'b0110010: begin
      I1OI1110 = 5869;
      OOOl0110 = 1346662;
      O0II010O = 309134664;
    end
    7'b0110011: begin
      I1OI1110 = 5970;
      OOOl0110 = 1334922;
      O0II010O = 314497825;
    end
    7'b0110100: begin
      I1OI1110 = 6070;
      OOOl0110 = 1322981;
      O0II010O = 319813624;
    end
    7'b0110101: begin
      I1OI1110 = 6168;
      OOOl0110 = 1310840;
      O0II010O = 325081260;
    end
    7'b0110110: begin
      I1OI1110 = 6266;
      OOOl0110 = 1298503;
      O0II010O = 330299941;
    end
    7'b0110111: begin
      I1OI1110 = 6363;
      OOOl0110 = 1285969;
      O0II010O = 335468879;
    end
    7'b0111000: begin
      I1OI1110 = 6459;
      OOOl0110 = 1273242;
      O0II010O = 340587297;
    end
    7'b0111001: begin
      I1OI1110 = 6554;
      OOOl0110 = 1260324;
      O0II010O = 345654423;
    end
    7'b0111010: begin
      I1OI1110 = 6648;
      OOOl0110 = 1247215;
      O0II010O = 350669495;
    end
    7'b0111011: begin
      I1OI1110 = 6741;
      OOOl0110 = 1233919;
      O0II010O = 355631758;
    end
    7'b0111100: begin
      I1OI1110 = 6832;
      OOOl0110 = 1220437;
      O0II010O = 360540464;
    end
    7'b0111101: begin
      I1OI1110 = 6923;
      OOOl0110 = 1206771;
      O0II010O = 365394874;
    end
    7'b0111110: begin
      I1OI1110 = 7013;
      OOOl0110 = 1192923;
      O0II010O = 370194257;
    end
    7'b0111111: begin
      I1OI1110 = 7102;
      OOOl0110 = 1178896;
      O0II010O = 374937890;
    end
    7'b1000000: begin
      I1OI1110 = 7190;
      OOOl0110 = 1164691;
      O0II010O = 379625058;
    end
    7'b1000001: begin
      I1OI1110 = 7276;
      OOOl0110 = 1150311;
      O0II010O = 384255057;
    end
    7'b1000010: begin
      I1OI1110 = 7362;
      OOOl0110 = 1135757;
      O0II010O = 388827188;
    end
    7'b1000011: begin
      I1OI1110 = 7446;
      OOOl0110 = 1121033;
      O0II010O = 393340763;
    end
    7'b1000100: begin
      I1OI1110 = 7529;
      OOOl0110 = 1106139;
      O0II010O = 397795102;
    end
    7'b1000101: begin
      I1OI1110 = 7612;
      OOOl0110 = 1091079;
      O0II010O = 402189535;
    end
    7'b1000110: begin
      I1OI1110 = 7693;
      OOOl0110 = 1075855;
      O0II010O = 406523400;
    end
    7'b1000111: begin
      I1OI1110 = 7772;
      OOOl0110 = 1060469;
      O0II010O = 410796044;
    end
    7'b1001000: begin
      I1OI1110 = 7851;
      OOOl0110 = 1044923;
      O0II010O = 415006823;
    end
    7'b1001001: begin
      I1OI1110 = 7929;
      OOOl0110 = 1029220;
      O0II010O = 419155104;
    end
    7'b1001010: begin
      I1OI1110 = 8005;
      OOOl0110 = 1013361;
      O0II010O = 423240262;
    end
    7'b1001011: begin
      I1OI1110 = 8080;
      OOOl0110 = 997350;
      O0II010O = 427261681;
    end
    7'b1001100: begin
      I1OI1110 = 8154;
      OOOl0110 = 981189;
      O0II010O = 431218756;
    end
    7'b1001101: begin
      I1OI1110 = 8227;
      OOOl0110 = 964880;
      O0II010O = 435110892;
    end
    7'b1001110: begin
      I1OI1110 = 8298;
      OOOl0110 = 948426;
      O0II010O = 438937501;
    end
    7'b1001111: begin
      I1OI1110 = 8368;
      OOOl0110 = 931829;
      O0II010O = 442698008;
    end
    7'b1010000: begin
      I1OI1110 = 8437;
      OOOl0110 = 915092;
      O0II010O = 446391846;
    end
    7'b1010001: begin
      I1OI1110 = 8505;
      OOOl0110 = 898217;
      O0II010O = 450018459;
    end
    7'b1010010: begin
      I1OI1110 = 8571;
      OOOl0110 = 881206;
      O0II010O = 453577301;
    end
    7'b1010011: begin
      I1OI1110 = 8636;
      OOOl0110 = 864063;
      O0II010O = 457067836;
    end
    7'b1010100: begin
      I1OI1110 = 8700;
      OOOl0110 = 846790;
      O0II010O = 460489538;
    end
    7'b1010101: begin
      I1OI1110 = 8762;
      OOOl0110 = 829389;
      O0II010O = 463841892;
    end
    7'b1010110: begin
      I1OI1110 = 8823;
      OOOl0110 = 811863;
      O0II010O = 467124393;
    end
    7'b1010111: begin
      I1OI1110 = 8883;
      OOOl0110 = 794215;
      O0II010O = 470336547;
    end
    7'b1011000: begin
      I1OI1110 = 8942;
      OOOl0110 = 776448;
      O0II010O = 473477871;
    end
    7'b1011001: begin
      I1OI1110 = 8999;
      OOOl0110 = 758563;
      O0II010O = 476547890;
    end
    7'b1011010: begin
      I1OI1110 = 9055;
      OOOl0110 = 740564;
      O0II010O = 479546142;
    end
    7'b1011011: begin
      I1OI1110 = 9109;
      OOOl0110 = 722454;
      O0II010O = 482472177;
    end
    7'b1011100: begin
      I1OI1110 = 9162;
      OOOl0110 = 704235;
      O0II010O = 485325554;
    end
    7'b1011101: begin
      I1OI1110 = 9214;
      OOOl0110 = 685910;
      O0II010O = 488105842;
    end
    7'b1011110: begin
      I1OI1110 = 9264;
      OOOl0110 = 667482;
      O0II010O = 490812623;
    end
    7'b1011111: begin
      I1OI1110 = 9313;
      OOOl0110 = 648953;
      O0II010O = 493445489;
    end
    7'b1100000: begin
      I1OI1110 = 9360;
      OOOl0110 = 630326;
      O0II010O = 496004045;
    end
    7'b1100001: begin
      I1OI1110 = 9406;
      OOOl0110 = 611604;
      O0II010O = 498487904;
    end
    7'b1100010: begin
      I1OI1110 = 9451;
      OOOl0110 = 592791;
      O0II010O = 500896692;
    end
    7'b1100011: begin
      I1OI1110 = 9494;
      OOOl0110 = 573888;
      O0II010O = 503230048;
    end
    7'b1100100: begin
      I1OI1110 = 9536;
      OOOl0110 = 554898;
      O0II010O = 505487619;
    end
    7'b1100101: begin
      I1OI1110 = 9576;
      OOOl0110 = 535825;
      O0II010O = 507669065;
    end
    7'b1100110: begin
      I1OI1110 = 9615;
      OOOl0110 = 516672;
      O0II010O = 509774058;
    end
    7'b1100111: begin
      I1OI1110 = 9653;
      OOOl0110 = 497440;
      O0II010O = 511802281;
    end
    7'b1101000: begin
      I1OI1110 = 9689;
      OOOl0110 = 478134;
      O0II010O = 513753429;
    end
    7'b1101001: begin
      I1OI1110 = 9723;
      OOOl0110 = 458755;
      O0II010O = 515627207;
    end
    7'b1101010: begin
      I1OI1110 = 9756;
      OOOl0110 = 439308;
      O0II010O = 517423334;
    end
    7'b1101011: begin
      I1OI1110 = 9788;
      OOOl0110 = 419794;
      O0II010O = 519141538;
    end
    7'b1101100: begin
      I1OI1110 = 9818;
      OOOl0110 = 400218;
      O0II010O = 520781562;
    end
    7'b1101101: begin
      I1OI1110 = 9847;
      OOOl0110 = 380580;
      O0II010O = 522343158;
    end
    7'b1101110: begin
      I1OI1110 = 9874;
      OOOl0110 = 360886;
      O0II010O = 523826091;
    end
    7'b1101111: begin
      I1OI1110 = 9899;
      OOOl0110 = 341137;
      O0II010O = 525230137;
    end
    7'b1110000: begin
      I1OI1110 = 9924;
      OOOl0110 = 321337;
      O0II010O = 526555086;
    end
    7'b1110001: begin
      I1OI1110 = 9946;
      OOOl0110 = 301489;
      O0II010O = 527800738;
    end
    7'b1110010: begin
      I1OI1110 = 9968;
      OOOl0110 = 281595;
      O0II010O = 528966905;
    end
    7'b1110011: begin
      I1OI1110 = 9987;
      OOOl0110 = 261658;
      O0II010O = 530053411;
    end
    7'b1110100: begin
      I1OI1110 = 10005;
      OOOl0110 = 241682;
      O0II010O = 531060094;
    end
    7'b1110101: begin
      I1OI1110 = 10022;
      OOOl0110 = 221670;
      O0II010O = 531986800;
    end
    7'b1110110: begin
      I1OI1110 = 10037;
      OOOl0110 = 201625;
      O0II010O = 532833392;
    end
    7'b1110111: begin
      I1OI1110 = 10051;
      OOOl0110 = 181549;
      O0II010O = 533599740;
    end
    7'b1111000: begin
      I1OI1110 = 10063;
      OOOl0110 = 161446;
      O0II010O = 534285731;
    end
    7'b1111001: begin
      I1OI1110 = 10074;
      OOOl0110 = 141318;
      O0II010O = 534891260;
    end
    7'b1111010: begin
      I1OI1110 = 10083;
      OOOl0110 = 121169;
      O0II010O = 535416236;
    end
    7'b1111011: begin
      I1OI1110 = 10091;
      OOOl0110 = 101002;
      O0II010O = 535860581;
    end
    7'b1111100: begin
      I1OI1110 = 10097;
      OOOl0110 = 80820;
      O0II010O = 536224227;
    end
    7'b1111101: begin
      I1OI1110 = 10101;
      OOOl0110 = 60625;
      O0II010O = 536507119;
    end
    7'b1111110: begin
      I1OI1110 = 10104;
      OOOl0110 = 40422;
      O0II010O = 536709216;
    end
    7'b1111111: begin
      I1OI1110 = 10106;
      OOOl0110 = 20212;
      O0II010O = 536830486;
    end
  endcase



  case(IO0O011O)
    7'b0000000: begin
      l0011l0O = 15'b101001010101110;
      l1101IO0 = 22'b0000000000000000000000;
      O1O1O1l1 = 29'b11001001000011111101101010100;
      OOOI0lO1 = 37'b0000000000000000000000000000000000000;
    end
    7'b0000001: begin
      l0011l0O = 15'b101001010101011;
      l1101IO0 = 22'b0000000111110000000110;
      O1O1O1l1 = 29'b11001001000010111111101001110;
      OOOI0lO1 = 37'b0000001100100100001110100011111110011;
    end
    7'b0000010: begin
      l0011l0O = 15'b101001010100100;
      l1101IO0 = 22'b0000001111100000000111;
      O1O1O1l1 = 29'b11001001000000000101101000001;
      OOOI0lO1 = 37'b0000011001001000010101010111110111101;
    end
    7'b0000011: begin
      l0011l0O = 15'b101001010011011;
      l1101IO0 = 22'b0000010111001111111111;
      O1O1O1l1 = 29'b11001000111011001111100111011;
      OOOI0lO1 = 37'b0000100101101100001100101011101011001;
    end
    7'b0000100: begin
      l0011l0O = 15'b101001010001110;
      l1101IO0 = 22'b0000011110111111101000;
      O1O1O1l1 = 29'b11001000110100011101101010011;
      OOOI0lO1 = 37'b0000110010001111101100101111100010000;
    end
    7'b0000101: begin
      l0011l0O = 15'b101001001111110;
      l1101IO0 = 22'b0000100110101110111111;
      O1O1O1l1 = 29'b11001000101011101111110101101;
      OOOI0lO1 = 37'b0000111110110010101101110011110011111;
    end
    7'b0000110: begin
      l0011l0O = 15'b101001001101011;
      l1101IO0 = 22'b0000101110011101111101;
      O1O1O1l1 = 29'b11001000100001000110001110001;
      OOOI0lO1 = 37'b0001001011010101001000001001001011001;
    end
    7'b0000111: begin
      l0011l0O = 15'b101001001010101;
      l1101IO0 = 22'b0000110110001100011111;
      O1O1O1l1 = 29'b11001000010100100000111010110;
      OOOI0lO1 = 37'b0001010111110110110100000000101010011;
    end
    7'b0001000: begin
      l0011l0O = 15'b101001000111011;
      l1101IO0 = 22'b0000111101111010011111;
      O1O1O1l1 = 29'b11001000000110000000000011001;
      OOOI0lO1 = 37'b0001100100010111101001101011110000101;
    end
    7'b0001001: begin
      l0011l0O = 15'b101001000011111;
      l1101IO0 = 22'b0001000101100111111001;
      O1O1O1l1 = 29'b11000111110101100011110000001;
      OOOI0lO1 = 37'b0001110000110111100001011100011110011;
    end
    7'b0001010: begin
      l0011l0O = 15'b101000111111111;
      l1101IO0 = 22'b0001001101010100101001;
      O1O1O1l1 = 29'b11000111100011001100001100001;
      OOOI0lO1 = 37'b0001111101010110010011100101011010101;
    end
    7'b0001011: begin
      l0011l0O = 15'b101000111011100;
      l1101IO0 = 22'b0001010101000000101000;
      O1O1O1l1 = 29'b11000111001110111001100010010;
      OOOI0lO1 = 37'b0010001001110011111000011001110110110;
    end
    7'b0001100: begin
      l0011l0O = 15'b101000110110110;
      l1101IO0 = 22'b0001011100101011110011;
      O1O1O1l1 = 29'b11000110111000101011111111000;
      OOOI0lO1 = 37'b0010010110010000001000001101110100011;
    end
    7'b0001101: begin
      l0011l0O = 15'b101000110001101;
      l1101IO0 = 22'b0001100100010110000101;
      O1O1O1l1 = 29'b11000110100000100011110000010;
      OOOI0lO1 = 37'b0010100010101010111011010110001001010;
    end
    7'b0001110: begin
      l0011l0O = 15'b101000101100000;
      l1101IO0 = 22'b0001101011111111011001;
      O1O1O1l1 = 29'b11000110000110100001000100110;
      OOOI0lO1 = 37'b0010101111000100001010001000100100010;
    end
    7'b0001111: begin
      l0011l0O = 15'b101000100110001;
      l1101IO0 = 22'b0001110011100111101010;
      O1O1O1l1 = 29'b11000101101010100100001100101;
      OOOI0lO1 = 37'b0010111011011011101100111011110010011;
    end
    7'b0010000: begin
      l0011l0O = 15'b101000011111110;
      l1101IO0 = 22'b0001111011001110110101;
      O1O1O1l1 = 29'b11000101001100101101011001000;
      OOOI0lO1 = 37'b0011000111110001011100000111100011010;
    end
    7'b0010001: begin
      l0011l0O = 15'b101000011001000;
      l1101IO0 = 22'b0010000010110100110011;
      O1O1O1l1 = 29'b11000100101100111100111100100;
      OOOI0lO1 = 37'b0011010100000101010000000100101101011;
    end
    7'b0010010: begin
      l0011l0O = 15'b101000010001111;
      l1101IO0 = 22'b0010001010011001100000;
      O1O1O1l1 = 29'b11000100001011010011001010100;
      OOOI0lO1 = 37'b0011100000010111000001001101010011111;
    end
    7'b0010011: begin
      l0011l0O = 15'b101000001010011;
      l1101IO0 = 22'b0010010001111100111000;
      O1O1O1l1 = 29'b11000011100111110000011000000;
      OOOI0lO1 = 37'b0011101100100110100111111100101010001;
    end
    7'b0010100: begin
      l0011l0O = 15'b101000000010100;
      l1101IO0 = 22'b0010011001011110110110;
      O1O1O1l1 = 29'b11000011000010010100111010101;
      OOOI0lO1 = 37'b0011111000110011111100101111011001000;
    end
    7'b0010101: begin
      l0011l0O = 15'b100111111010010;
      l1101IO0 = 22'b0010100000111111010101;
      O1O1O1l1 = 29'b11000010011011000001001001110;
      OOOI0lO1 = 37'b0100000100111110111000000011100011011;
    end
    7'b0010110: begin
      l0011l0O = 15'b100111110001101;
      l1101IO0 = 22'b0010101000011110010001;
      O1O1O1l1 = 29'b11000001110001110101011101011;
      OOOI0lO1 = 37'b0100010001000111010010011000101011000;
    end
    7'b0010111: begin
      l0011l0O = 15'b100111101000100;
      l1101IO0 = 22'b0010101111111011100101;
      O1O1O1l1 = 29'b11000001000110110010001111001;
      OOOI0lO1 = 37'b0100011101001101000100001111110100110;
    end
    7'b0011000: begin
      l0011l0O = 15'b100111011111001;
      l1101IO0 = 22'b0010110111010111001101;
      O1O1O1l1 = 29'b11000000011001110111111001011;
      OOOI0lO1 = 37'b0100101001010000000110001011101101010;
    end
    7'b0011001: begin
      l0011l0O = 15'b100111010101010;
      l1101IO0 = 22'b0010111110110001000011;
      O1O1O1l1 = 29'b10111111101011000110110111111;
      OOOI0lO1 = 37'b0100110101010000010000110000101110000;
    end
    7'b0011010: begin
      l0011l0O = 15'b100111001011001;
      l1101IO0 = 22'b0011000110001001000100;
      O1O1O1l1 = 29'b10111110111010011111100111101;
      OOOI0lO1 = 37'b0101000001001101011100100101000001011;
    end
    7'b0011011: begin
      l0011l0O = 15'b100111000000100;
      l1101IO0 = 22'b0011001101011111001010;
      O1O1O1l1 = 29'b10111110001000000010100110011;
      OOOI0lO1 = 37'b0101001101000111100010010000100111100;
    end
    7'b0011100: begin
      l0011l0O = 15'b100110110101101;
      l1101IO0 = 22'b0011010100110011010010;
      O1O1O1l1 = 29'b10111101010011110000010011011;
      OOOI0lO1 = 37'b0101011000111110011010011101011010101;
    end
    7'b0011101: begin
      l0011l0O = 15'b100110101010010;
      l1101IO0 = 22'b0011011100000101010111;
      O1O1O1l1 = 29'b10111100011101101001001111000;
      OOOI0lO1 = 37'b0101100100110001111101110111010011111;
    end
    7'b0011110: begin
      l0011l0O = 15'b100110011110101;
      l1101IO0 = 22'b0011100011010101010011;
      O1O1O1l1 = 29'b10111011100101101101111010011;
      OOOI0lO1 = 37'b0101110000100010000101001100001111100;
    end
    7'b0011111: begin
      l0011l0O = 15'b100110010010101;
      l1101IO0 = 22'b0011101010100011000100;
      O1O1O1l1 = 29'b10111010101011111110111000001;
      OOOI0lO1 = 37'b0101111100001110101001001100010001110;
    end
    7'b0100000: begin
      l0011l0O = 15'b100110000110001;
      l1101IO0 = 22'b0011110001101110100100;
      O1O1O1l1 = 29'b10111001110000011100101011110;
      OOOI0lO1 = 37'b0110000111110111100010101001101010110;
    end
    7'b0100001: begin
      l0011l0O = 15'b100101111001011;
      l1101IO0 = 22'b0011111000110111101111;
      O1O1O1l1 = 29'b10111000110011000111111010010;
      OOOI0lO1 = 37'b0110010011011100101010011000111011101;
    end
    7'b0100010: begin
      l0011l0O = 15'b100101101100010;
      l1101IO0 = 22'b0011111111111110100000;
      O1O1O1l1 = 29'b10110111110100000001001001001;
      OOOI0lO1 = 37'b0110011110111101111001010000111010100;
    end
    7'b0100011: begin
      l0011l0O = 15'b100101011110101;
      l1101IO0 = 22'b0100000111000010110011;
      O1O1O1l1 = 29'b10110110110011001000111111101;
      OOOI0lO1 = 37'b0110101010011011001000001010110110110;
    end
    7'b0100100: begin
      l0011l0O = 15'b100101010000110;
      l1101IO0 = 22'b0100001110000100100100;
      O1O1O1l1 = 29'b10110101110000100000000101100;
      OOOI0lO1 = 37'b0110110101110100010000000010011110000;
    end
    7'b0100101: begin
      l0011l0O = 15'b100101000010100;
      l1101IO0 = 22'b0100010101000011101111;
      O1O1O1l1 = 29'b10110100101100000111000011111;
      OOOI0lO1 = 37'b0111000001001001001001110110000000000;
    end
    7'b0100110: begin
      l0011l0O = 15'b100100110100000;
      l1101IO0 = 22'b0100011100000000001110;
      O1O1O1l1 = 29'b10110011100101111110100101001;
      OOOI0lO1 = 37'b0111001100011001101110100110010011000;
    end
    7'b0100111: begin
      l0011l0O = 15'b100100100101000;
      l1101IO0 = 22'b0100100010111001111111;
      O1O1O1l1 = 29'b10110010011110000111010100011;
      OOOI0lO1 = 37'b0111010111100101110111010110111000010;
    end
    7'b0101000: begin
      l0011l0O = 15'b100100010101101;
      l1101IO0 = 22'b0100101001110000111100;
      O1O1O1l1 = 29'b10110001010100100001111110000;
      OOOI0lO1 = 37'b0111100010101101011101001110000000010;
    end
    7'b0101001: begin
      l0011l0O = 15'b100100000110000;
      l1101IO0 = 22'b0100110000100101000001;
      O1O1O1l1 = 29'b10110000001001001111001111010;
      OOOI0lO1 = 37'b0111101101110000011001010100101110111;
    end
    7'b0101010: begin
      l0011l0O = 15'b100011110110000;
      l1101IO0 = 22'b0100110111010110001010;
      O1O1O1l1 = 29'b10101110111100001111110110111;
      OOOI0lO1 = 37'b0111111000101110100100110110111111011;
    end
    7'b0101011: begin
      l0011l0O = 15'b100011100101101;
      l1101IO0 = 22'b0100111110000100010100;
      O1O1O1l1 = 29'b10101101101101100100100100000;
      OOOI0lO1 = 37'b1000000011100111111001000011101001011;
    end
    7'b0101100: begin
      l0011l0O = 15'b100011010101000;
      l1101IO0 = 22'b0101000100101111011001;
      O1O1O1l1 = 29'b10101100011101001110000111100;
      OOOI0lO1 = 37'b1000001110011100001111001100100100010;
    end
    7'b0101101: begin
      l0011l0O = 15'b100011000100000;
      l1101IO0 = 22'b0101001011010111010110;
      O1O1O1l1 = 29'b10101011001011001101010010101;
      OOOI0lO1 = 37'b1000011001001011100000100110101011101;
    end
    7'b0101110: begin
      l0011l0O = 15'b100010110010101;
      l1101IO0 = 22'b0101010001111100000110;
      O1O1O1l1 = 29'b10101001110111100010111000001;
      OOOI0lO1 = 37'b1000100011110101100110101010000011010;
    end
    7'b0101111: begin
      l0011l0O = 15'b100010100000111;
      l1101IO0 = 22'b0101011000011101100110;
      O1O1O1l1 = 29'b10101000100010001111101011110;
      OOOI0lO1 = 37'b1000101110011010011010110001111011110;
    end
    7'b0110000: begin
      l0011l0O = 15'b100010001110111;
      l1101IO0 = 22'b0101011110111011110001;
      O1O1O1l1 = 29'b10100111001011010100100001110;
      OOOI0lO1 = 37'b1000111000111001110110011100110101101;
    end
    7'b0110001: begin
      l0011l0O = 15'b100001111100100;
      l1101IO0 = 22'b0101100101010110100101;
      O1O1O1l1 = 29'b10100101110010110010010000001;
      OOOI0lO1 = 37'b1001000011010011110011001100100110011;
    end
    7'b0110010: begin
      l0011l0O = 15'b100001101001110;
      l1101IO0 = 22'b0101101011101101111011;
      O1O1O1l1 = 29'b10100100011000101001101101010;
      OOOI0lO1 = 37'b1001001101101000001010100110011011100;
    end
    7'b0110011: begin
      l0011l0O = 15'b100001010110110;
      l1101IO0 = 22'b0101110010000001110001;
      O1O1O1l1 = 29'b10100010111100111011110000110;
      OOOI0lO1 = 37'b1001010111110110110110010010111111010;
    end
    7'b0110100: begin
      l0011l0O = 15'b100001000011011;
      l1101IO0 = 22'b0101111000010010000011;
      O1O1O1l1 = 29'b10100001011111101001010011010;
      OOOI0lO1 = 37'b1001100001111111101111111110011100000;
    end
    7'b0110101: begin
      l0011l0O = 15'b100000101111110;
      l1101IO0 = 22'b0101111110011110101101;
      O1O1O1l1 = 29'b10100000000000110011001110011;
      OOOI0lO1 = 37'b1001101100000010110001011000100000101;
    end
    7'b0110110: begin
      l0011l0O = 15'b100000011011110;
      l1101IO0 = 22'b0110000100100111101011;
      O1O1O1l1 = 29'b10011110100000011010011100100;
      OOOI0lO1 = 37'b1001110101111111110100010100100011111;
    end
    7'b0110111: begin
      l0011l0O = 15'b100000000111100;
      l1101IO0 = 22'b0110001010101100111001;
      O1O1O1l1 = 29'b10011100111110011111111001001;
      OOOI0lO1 = 37'b1001111111110110110010101001101000100;
    end
    7'b0111000: begin
      l0011l0O = 15'b011111110010111;
      l1101IO0 = 22'b0110010000101110010100;
      O1O1O1l1 = 29'b10011011011011000100100000100;
      OOOI0lO1 = 37'b1010001001100111100110010010100001000;
    end
    7'b0111001: begin
      l0011l0O = 15'b011111011110000;
      l1101IO0 = 22'b0110010110101011111000;
      O1O1O1l1 = 29'b10011001110110001001010000010;
      OOOI0lO1 = 37'b1010010011010010001001001101110011010;
    end
    7'b0111010: begin
      l0011l0O = 15'b011111001000110;
      l1101IO0 = 22'b0110011100100101100001;
      O1O1O1l1 = 29'b10011000001111101111000110100;
      OOOI0lO1 = 37'b1010011100110110010101011101111100011;
    end
    7'b0111011: begin
      l0011l0O = 15'b011110110011010;
      l1101IO0 = 22'b0110100010011011001011;
      O1O1O1l1 = 29'b10010110100111110111000010010;
      OOOI0lO1 = 37'b1010100110010100000101001001010100010;
    end
    7'b0111100: begin
      l0011l0O = 15'b011110011101100;
      l1101IO0 = 22'b0110101000001100110011;
      O1O1O1l1 = 29'b10010100111110100010000011111;
      OOOI0lO1 = 37'b1010101111101011010010011010010001100;
    end
    7'b0111101: begin
      l0011l0O = 15'b011110000111011;
      l1101IO0 = 22'b0110101101111010010101;
      O1O1O1l1 = 29'b10010011010011110001001100001;
      OOOI0lO1 = 37'b1010111000111011110111011111001100100;
    end
    7'b0111110: begin
      l0011l0O = 15'b011101110001000;
      l1101IO0 = 22'b0110110011100011101111;
      O1O1O1l1 = 29'b10010001100111100101011101000;
      OOOI0lO1 = 37'b1011000010000101101110101010100011100;
    end
    7'b0111111: begin
      l0011l0O = 15'b011101011010010;
      l1101IO0 = 22'b0110111001001000111011;
      O1O1O1l1 = 29'b10001111111001111111111001000;
      OOOI0lO1 = 37'b1011001011001000110010010010111101111;
    end
    7'b1000000: begin
      l0011l0O = 15'b011101000011011;
      l1101IO0 = 22'b0110111110101001111000;
      O1O1O1l1 = 29'b10001110001011000001100100000;
      OOOI0lO1 = 37'b1011010100000100111100110011001111110;
    end
    7'b1000001: begin
      l0011l0O = 15'b011100101100001;
      l1101IO0 = 22'b0111000100000110100001;
      O1O1O1l1 = 29'b10001100011010101011100010011;
      OOOI0lO1 = 37'b1011011100111010001000101010011101001;
    end
    7'b1000010: begin
      l0011l0O = 15'b011100010100101;
      l1101IO0 = 22'b0111001001011110110011;
      O1O1O1l1 = 29'b10001010101000111110111001010;
      OOOI0lO1 = 37'b1011100101101000010000011011111101111;
    end
    7'b1000011: begin
      l0011l0O = 15'b011011111100110;
      l1101IO0 = 22'b0111001110110010101011;
      O1O1O1l1 = 29'b10001000110101111100101111000;
      OOOI0lO1 = 37'b1011101110001111001110101111100000010;
    end
    7'b1000100: begin
      l0011l0O = 15'b011011100100110;
      l1101IO0 = 22'b0111010100000010000101;
      O1O1O1l1 = 29'b10000111000001100110001010011;
      OOOI0lO1 = 37'b1011110110101110111110010001001101001;
    end
    7'b1000101: begin
      l0011l0O = 15'b011011001100011;
      l1101IO0 = 22'b0111011001001100111111;
      O1O1O1l1 = 29'b10000101001011111100010011011;
      OOOI0lO1 = 37'b1011111111000111011001110001101010110;
    end
    7'b1000110: begin
      l0011l0O = 15'b011010110011111;
      l1101IO0 = 22'b0111011110010011010101;
      O1O1O1l1 = 29'b10000011010101000000010010011;
      OOOI0lO1 = 37'b1100000111011000011100000101111111110;
    end
    7'b1000111: begin
      l0011l0O = 15'b011010011011000;
      l1101IO0 = 22'b0111100011010101000011;
      O1O1O1l1 = 29'b10000001011100110011010000110;
      OOOI0lO1 = 37'b1100001111100010000000000111110111001;
    end
    7'b1001000: begin
      l0011l0O = 15'b011010000001111;
      l1101IO0 = 22'b0111101000010010001000;
      O1O1O1l1 = 29'b01111111100011010110011000111;
      OOOI0lO1 = 37'b1100010111100100000000110101100010100;
    end
    7'b1001001: begin
      l0011l0O = 15'b011001101000100;
      l1101IO0 = 22'b0111101101001010100000;
      O1O1O1l1 = 29'b01111101101000101010110101011;
      OOOI0lO1 = 37'b1100011111011110011001010001111101110;
    end
    7'b1001010: begin
      l0011l0O = 15'b011001001110111;
      l1101IO0 = 22'b0111110001111110000111;
      O1O1O1l1 = 29'b01111011101100110001110010000;
      OOOI0lO1 = 37'b1100100111010001000100100100110010001;
    end
    7'b1001011: begin
      l0011l0O = 15'b011000110101001;
      l1101IO0 = 22'b0111110110101100111011;
      O1O1O1l1 = 29'b01111001101111101100011011010;
      OOOI0lO1 = 37'b1100101110111011111101111010011000111;
    end
    7'b1001100: begin
      l0011l0O = 15'b011000011011000;
      l1101IO0 = 22'b0111111011010110111001;
      O1O1O1l1 = 29'b01110111110001011011111110011;
      OOOI0lO1 = 37'b1100110110011111000000100011111110010;
    end
    7'b1001101: begin
      l0011l0O = 15'b011000000000110;
      l1101IO0 = 22'b0111111111111011111110;
      O1O1O1l1 = 29'b01110101110010000001101001000;
      OOOI0lO1 = 37'b1100111101111010000111110111100101000;
    end
    7'b1001110: begin
      l0011l0O = 15'b010111100110001;
      l1101IO0 = 22'b1000000100011100000111;
      O1O1O1l1 = 29'b01110011110001011110101001111;
      OOOI0lO1 = 37'b1101000101001101001111010000001000101;
    end
    7'b1001111: begin
      l0011l0O = 15'b010111001011011;
      l1101IO0 = 22'b1000001000110111010010;
      O1O1O1l1 = 29'b01110001101111110100010000011;
      OOOI0lO1 = 37'b1101001100011000010010001101100000010;
    end
    7'b1010000: begin
      l0011l0O = 15'b010110110000011;
      l1101IO0 = 22'b1000001101001101011011;
      O1O1O1l1 = 29'b01101111101101000011101100010;
      OOOI0lO1 = 37'b1101010011011011001100010100100001101;
    end
    7'b1010001: begin
      l0011l0O = 15'b010110010101001;
      l1101IO0 = 22'b1000010001011110100001;
      O1O1O1l1 = 29'b01101101101001001110001110011;
      OOOI0lO1 = 37'b1101011010010101111001001111000100000;
    end
    7'b1010010: begin
      l0011l0O = 15'b010101111001110;
      l1101IO0 = 22'b1000010101101010100000;
      O1O1O1l1 = 29'b01101011100100010101000111111;
      OOOI0lO1 = 37'b1101100001001000010100101100000010100;
    end
    7'b1010011: begin
      l0011l0O = 15'b010101011110001;
      l1101IO0 = 22'b1000011001110001010101;
      O1O1O1l1 = 29'b01101001011110011001101010111;
      OOOI0lO1 = 37'b1101100111110010011010011111011110100;
    end
    7'b1010100: begin
      l0011l0O = 15'b010101000010010;
      l1101IO0 = 22'b1000011101110010111111;
      O1O1O1l1 = 29'b01100111010111011101001001111;
      OOOI0lO1 = 37'b1101101110010100000110100010100011000;
    end
    7'b1010101: begin
      l0011l0O = 15'b010100100110001;
      l1101IO0 = 22'b1000100001101111011011;
      O1O1O1l1 = 29'b01100101001111100000111000010;
      OOOI0lO1 = 37'b1101110100101101010100110011100110100;
    end
    7'b1010110: begin
      l0011l0O = 15'b010100001001111;
      l1101IO0 = 22'b1000100101100110100110;
      O1O1O1l1 = 29'b01100011000110100110001001111;
      OOOI0lO1 = 37'b1101111010111110000001010110001101110;
    end
    7'b1010111: begin
      l0011l0O = 15'b010011101101100;
      l1101IO0 = 22'b1000101001011000011110;
      O1O1O1l1 = 29'b01100000111100101110010011000;
      OOOI0lO1 = 37'b1110000001000110001000010011001110001;
    end
    7'b1011000: begin
      l0011l0O = 15'b010011010000111;
      l1101IO0 = 22'b1000101101000101000001;
      O1O1O1l1 = 29'b01011110110001111010101000110;
      OOOI0lO1 = 37'b1110000111000101100101111000101111111;
    end
    7'b1011001: begin
      l0011l0O = 15'b010010110100000;
      l1101IO0 = 22'b1000110000101100001100;
      O1O1O1l1 = 29'b01011100100110001100100000111;
      OOOI0lO1 = 37'b1110001100111100010110011010010000111;
    end
    7'b1011010: begin
      l0011l0O = 15'b010010010111000;
      l1101IO0 = 22'b1000110100001101111101;
      O1O1O1l1 = 29'b01011010011001100101010001100;
      OOOI0lO1 = 37'b1110010010101010010110010000100110011;
    end
    7'b1011011: begin
      l0011l0O = 15'b010001111001111;
      l1101IO0 = 22'b1000110111101010010010;
      O1O1O1l1 = 29'b01011000001100000110010001010;
      OOOI0lO1 = 37'b1110011000001111100001111001111111100;
    end
    7'b1011100: begin
      l0011l0O = 15'b010001011100100;
      l1101IO0 = 22'b1000111011000001001001;
      O1O1O1l1 = 29'b01010101111101110000110111100;
      OOOI0lO1 = 37'b1110011101101011110101111010000111011;
    end
    7'b1011101: begin
      l0011l0O = 15'b010000111111000;
      l1101IO0 = 22'b1000111110010010100000;
      O1O1O1l1 = 29'b01010011101110100110011100000;
      OOOI0lO1 = 37'b1110100010111111001110111010000111101;
    end
    7'b1011110: begin
      l0011l0O = 15'b010000100001010;
      l1101IO0 = 22'b1001000001011110010101;
      O1O1O1l1 = 29'b01010001011110101000010111001;
      OOOI0lO1 = 37'b1110101000001001101001101000101001100;
    end
    7'b1011111: begin
      l0011l0O = 15'b010000000011100;
      l1101IO0 = 22'b1001000100100100100101;
      O1O1O1l1 = 29'b01001111001101111000000001101;
      OOOI0lO1 = 37'b1110101101001011000010111001111001000;
    end
    7'b1100000: begin
      l0011l0O = 15'b001111100101100;
      l1101IO0 = 22'b1001000111100101001111;
      O1O1O1l1 = 29'b01001100111100010110110100111;
      OOOI0lO1 = 37'b1110110010000011010111100111100110001;
    end
    7'b1100001: begin
      l0011l0O = 15'b001111000111010;
      l1101IO0 = 22'b1001001010100000010010;
      O1O1O1l1 = 29'b01001010101010000110001010100;
      OOOI0lO1 = 37'b1110110110110010100100110001000110111;
    end
    7'b1100010: begin
      l0011l0O = 15'b001110101001000;
      l1101IO0 = 22'b1001001101010101101010;
      O1O1O1l1 = 29'b01001000010111000111011100111;
      OOOI0lO1 = 37'b1110111011011000100111011011011001011;
    end
    7'b1100011: begin
      l0011l0O = 15'b001110001010101;
      l1101IO0 = 22'b1001010000000101010111;
      O1O1O1l1 = 29'b01000110000011011100000110100;
      OOOI0lO1 = 37'b1110111111110101011100110001000101100;
    end
    7'b1100100: begin
      l0011l0O = 15'b001101101100000;
      l1101IO0 = 22'b1001010010101111010111;
      O1O1O1l1 = 29'b01000011101111000101100010100;
      OOOI0lO1 = 37'b1111000100001001000010000010011110101;
    end
    7'b1100101: begin
      l0011l0O = 15'b001101001101010;
      l1101IO0 = 22'b1001010101010011101000;
      O1O1O1l1 = 29'b01000001011010000101001100100;
      OOOI0lO1 = 37'b1111001000010011010100100101100101010;
    end
    7'b1100110: begin
      l0011l0O = 15'b001100101110100;
      l1101IO0 = 22'b1001010111110010001000;
      O1O1O1l1 = 29'b00111111000100011100100000011;
      OOOI0lO1 = 37'b1111001100010100010001110110001000111;
    end
    7'b1100111: begin
      l0011l0O = 15'b001100001111100;
      l1101IO0 = 22'b1001011010001010110111;
      O1O1O1l1 = 29'b00111100101110001100111010011;
      OOOI0lO1 = 37'b1111010000001011110111010101101001011;
    end
    7'b1101000: begin
      l0011l0O = 15'b001011110000100;
      l1101IO0 = 22'b1001011100011101110010;
      O1O1O1l1 = 29'b00111010010111010111110111010;
      OOOI0lO1 = 37'b1111010011111010000010101011011000101;
    end
    7'b1101001: begin
      l0011l0O = 15'b001011010001010;
      l1101IO0 = 22'b1001011110101010111000;
      O1O1O1l1 = 29'b00110111111111111110110011111;
      OOOI0lO1 = 37'b1111010111011110110001100100011011110;
    end
    7'b1101010: begin
      l0011l0O = 15'b001010110010000;
      l1101IO0 = 22'b1001100000110010001000;
      O1O1O1l1 = 29'b00110101101000000011001101111;
      OOOI0lO1 = 37'b1111011010111010000001110011101100111;
    end
    7'b1101011: begin
      l0011l0O = 15'b001010010010101;
      l1101IO0 = 22'b1001100010110011100000;
      O1O1O1l1 = 29'b00110011001111100110100010110;
      OOOI0lO1 = 37'b1111011110001011110001010001111100011;
    end
    7'b1101100: begin
      l0011l0O = 15'b001001110011001;
      l1101IO0 = 22'b1001100100101111000000;
      O1O1O1l1 = 29'b00110000110110101010010000101;
      OOOI0lO1 = 37'b1111100001010011111101111101110010001;
    end
    7'b1101101: begin
      l0011l0O = 15'b001001010011100;
      l1101IO0 = 22'b1001100110100100100101;
      O1O1O1l1 = 29'b00101110011101001111110101111;
      OOOI0lO1 = 37'b1111100100010010100101111011101110101;
    end
    7'b1101110: begin
      l0011l0O = 15'b001000110011110;
      l1101IO0 = 22'b1001101000010100010000;
      O1O1O1l1 = 29'b00101100000011011000110001001;
      OOOI0lO1 = 37'b1111100111000111100111010110001100011;
    end
    7'b1101111: begin
      l0011l0O = 15'b001000010100000;
      l1101IO0 = 22'b1001101001111101111110;
      O1O1O1l1 = 29'b00101001101001000110100001010;
      OOOI0lO1 = 37'b1111101001110011000000011101100001010;
    end
    7'b1110000: begin
      l0011l0O = 15'b000111110100001;
      l1101IO0 = 22'b1001101011100001101111;
      O1O1O1l1 = 29'b00100111001110011010100101011;
      OOOI0lO1 = 37'b1111101100010100101111100111111110110;
    end
    7'b1110001: begin
      l0011l0O = 15'b000111010100010;
      l1101IO0 = 22'b1001101100111111100011;
      O1O1O1l1 = 29'b00100100110011010110011101000;
      OOOI0lO1 = 37'b1111101110101100110011010001110100000;
    end
    7'b1110010: begin
      l0011l0O = 15'b000110110100010;
      l1101IO0 = 22'b1001101110010111010111;
      O1O1O1l1 = 29'b00100010010111111011100111110;
      OOOI0lO1 = 37'b1111110000111011001001111101001110000;
    end
    7'b1110011: begin
      l0011l0O = 15'b000110010100010;
      l1101IO0 = 22'b1001101111101001001011;
      O1O1O1l1 = 29'b00011111111100001011100101100;
      OOOI0lO1 = 37'b1111110010111111110010010010011001000;
    end
    7'b1110100: begin
      l0011l0O = 15'b000101110100001;
      l1101IO0 = 22'b1001110000110100111110;
      O1O1O1l1 = 29'b00011101100000000111110110010;
      OOOI0lO1 = 37'b1111110100111010101010111111100000111;
    end
    7'b1110101: begin
      l0011l0O = 15'b000101010011111;
      l1101IO0 = 22'b1001110001111010110000;
      O1O1O1l1 = 29'b00011011000011110001111010011;
      OOOI0lO1 = 37'b1111110110101011110010111000110010100;
    end
    7'b1110110: begin
      l0011l0O = 15'b000100110011110;
      l1101IO0 = 22'b1001110010111010100000;
      O1O1O1l1 = 29'b00011000100111001011010010010;
      OOOI0lO1 = 37'b1111111000010011001000111000011100000;
    end
    7'b1110111: begin
      l0011l0O = 15'b000100010011011;
      l1101IO0 = 22'b1001110011110100001101;
      O1O1O1l1 = 29'b00010110001010010101011110100;
      OOOI0lO1 = 37'b1111111001110000101011111110101101100;
    end
    7'b1111000: begin
      l0011l0O = 15'b000011110011001;
      l1101IO0 = 22'b1001110100100111110111;
      O1O1O1l1 = 29'b00010011101101010001111111111;
      OOOI0lO1 = 37'b1111111011000100011011010001111010000;
    end
    7'b1111001: begin
      l0011l0O = 15'b000011010010110;
      l1101IO0 = 22'b1001110101010101011101;
      O1O1O1l1 = 29'b00010001010000000010010111010;
      OOOI0lO1 = 37'b1111111100001110010101111110010111100;
    end
    7'b1111010: begin
      l0011l0O = 15'b000010110010011;
      l1101IO0 = 22'b1001110101111100111111;
      O1O1O1l1 = 29'b00001110110010101000000101100;
      OOOI0lO1 = 37'b1111111101001110011011010110100000000;
    end
    7'b1111011: begin
      l0011l0O = 15'b000010010010000;
      l1101IO0 = 22'b1001110110011110011101;
      O1O1O1l1 = 29'b00001100010101000100101100000;
      OOOI0lO1 = 37'b1111111110000100101010110010110001101;
    end
    7'b1111100: begin
      l0011l0O = 15'b000001110001100;
      l1101IO0 = 22'b1001110110111001110101;
      O1O1O1l1 = 29'b00001001110111011001101011101;
      OOOI0lO1 = 37'b1111111110110001000011110001101111000;
    end
    7'b1111101: begin
      l0011l0O = 15'b000001010001001;
      l1101IO0 = 22'b1001110111001111001000;
      O1O1O1l1 = 29'b00000111011001101000100101111;
      OOOI0lO1 = 37'b1111111111010011100101110111111111101;
    end
    7'b1111110: begin
      l0011l0O = 15'b000000110000101;
      l1101IO0 = 22'b1001110111011110010110;
      O1O1O1l1 = 29'b00000100111011110010111011111;
      OOOI0lO1 = 37'b1111111111101100010000110000010000011;
    end
    7'b1111111: begin
      l0011l0O = 15'b000000010000001;
      l1101IO0 = 22'b1001110111100111011111;
      O1O1O1l1 = 29'b00000010011101111010001111001;
      OOOI0lO1 = 37'b1111111111111011000100001011010011010;
    end
  endcase

end

// synopsys translate_on

endmodule
