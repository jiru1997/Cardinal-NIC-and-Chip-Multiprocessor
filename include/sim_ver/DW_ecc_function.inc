////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2012 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly,  Nov. 22, 2012
//
// VERSION:   Verilog Check-bit Calculation Function
//
// DesignWare_version: 2835186a
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// NOTE: THIS FUNCTION IS NOT FOR SYNTHESIS. It is provided for use in
//       initializing ECC check bits for memories at time zero of simu-
//       lations (such as in an initial block with 'for' loops).
//
//
// Function: DWF_ecc_gen_chkbits
//
//     Calculates the check bits to be used with the data passed (based on
//     the data width and check bit width arguments passed) that are directly
//     compatible with the logic of the DW_ecc design with parameter values
//     that match the same data and check bit width values.
//
// Arguments:
//     width : number of data bits to calculate check bits from (integer)
//     chkbits : number of check bits to be generated (integer)
//     data_in : data bits to be used to calculate check bits from (vector
//               of size `DW_ecc_func_max_width)
//
// Returns:
//     16-bit value with the specified number of check bits in the low
//     order bits.
//
//
// The Verilog macro, DW_ecc_func_max_width should be set to a value that
// is equal to or greater than the largest value of the width argument passed
// to DWF_ecc_gen_chkbits.  Its default setting (if not defined before the
// DWF_ecc_function.inc file is included) is 2048 but the DW_ecc design can
// support widths up to 8178.  This macro can also be used in the design
// that includes it to size the vector that is passed as the data_in argument
// of the function call (to avoid lint issues).
//
// The DW_ecc_gen_chkbits function always returns a 16-bit value, no matter
// how many check bits are specified with the chkbits argument.
//
////////////////////////////////////////////////////////////////////////////////

`ifndef DW_ecc_func_max_width
`define DW_ecc_func_max_width 2048
`endif


  function [15:0] DWF_ecc_gen_chkbits;
    input integer width;
    input integer chkbits;
    input [`DW_ecc_func_max_width-1:0] data_in;

// synopsys translate_off
integer O0O1O1101, lO1lOOlI0; integer OI11IO001, I1011Ol00; integer O1O00I001, IlOO01011, IIl1lll10; integer lO0IlIOl1, O1I1IO0IO, l1O0O110I, O0l1O10l0;
integer OIOOl1I00, O0Olll0O0, l1IO10001; integer II010O0O1, lI1O010l1, IOI001111; integer O0O1O11OO, O001O1Ol1, OO0O101O0, OlOOIO10I; integer lOlIIl001,
I11000011, lOO0lO1O0, II1Il0l1l, l11O1O1II; integer Ill11O01O [0:(1<<16)-1]; integer O1111l11O [0:(1<<(15))-1]; reg [15:0] II0O00OIl; reg
[`DW_ecc_func_max_width-1:0] IIO0O111I; reg [width-1:0] O00ll11OO [0:chkbits-1]; begin OI11IO001 = 1; O001O1Ol1 = 5; lOlIIl001 = OI11IO001 << chkbits; l1O0O110I
= 2; lOO0lO1O0 = lOlIIl001 >> O001O1Ol1; O0Olll0O0 = l1O0O110I << 4; for (OO0O101O0=0 ; OO0O101O0 < lOlIIl001 ; OO0O101O0=OO0O101O0+1) begin
Ill11O01O[OO0O101O0]=-1; end II1Il0l1l = lOO0lO1O0 * l1O0O110I; lO0IlIOl1 = 0; I11000011 = O001O1Ol1 + Ill11O01O[0]; OIOOl1I00 = O0Olll0O0 + Ill11O01O[1]; for
(IOI001111=0 ; (IOI001111 < II1Il0l1l) && (lO0IlIOl1 < width) ; IOI001111=IOI001111+1) begin O1O00I001 = IOI001111 / l1O0O110I; if ((IOI001111 < 4) ||
((IOI001111 > 8) && (IOI001111 >= (II1Il0l1l-(l1O0O110I*l1O0O110I))))) O1O00I001 = O1O00I001 ^ 1; if (^IOI001111 ^ 1) O1O00I001 = lOO0lO1O0-OI11IO001-O1O00I001;
if (lOO0lO1O0 == OI11IO001) O1O00I001 = 0; O1I1IO0IO = 0; O0O1O11OO = O1O00I001 << O001O1Ol1; if (IOI001111 < lOO0lO1O0) begin II010O0O1 = 0; if (lOO0lO1O0 >
OI11IO001) II010O0O1 = IOI001111 % 2; if (II010O0O1) begin if (0 < 1) O0l1O10l0 = 1; else if (0 > 5) O0l1O10l0 = 1; else O0l1O10l0 = 0; end else begin if (0 <
1) O0l1O10l0 = 5; else if (0 < 3) O0l1O10l0 = 1; else O0l1O10l0 = 0; end for (OO0O101O0=O0O1O11OO ; (OO0O101O0 < (O0O1O11OO+O0Olll0O0)) && (lO0IlIOl1 < width) ;
OO0O101O0=OO0O101O0+1) begin lO1lOOlI0 = OO0O101O0; O0O1O1101 = 0; while (lO1lOOlI0 != 0) begin if (lO1lOOlI0 & 1) O0O1O1101 = O0O1O1101 + 1; lO1lOOlI0 =
lO1lOOlI0 >> 1; end lI1O010l1 = O0O1O1101; if (lI1O010l1 % 2) begin if (O0l1O10l0 <= 0) begin if (lI1O010l1 > 1) begin Ill11O01O[OO0O101O0] = ((O1I1IO0IO < 2)
&& (II010O0O1 == 0))? lO0IlIOl1 ^ 1 : lO0IlIOl1; O1111l11O[ ((O1I1IO0IO < 2) && (II010O0O1 == 0))? lO0IlIOl1 ^ 1 : lO0IlIOl1 ] = OO0O101O0; lO0IlIOl1 =
lO0IlIOl1 + 1; end O1I1IO0IO = O1I1IO0IO + 1; if (O1I1IO0IO < 8) begin if (II010O0O1) begin if (O1I1IO0IO < 1) O0l1O10l0 = 1; else if (O1I1IO0IO > 5) O0l1O10l0
= 1; else O0l1O10l0 = 0; end else begin if (O1I1IO0IO < 1) O0l1O10l0 = 5; else if (O1I1IO0IO < 3) O0l1O10l0 = 1; else O0l1O10l0 = 0; end end else begin
OO0O101O0 = O0O1O11OO+O0Olll0O0; end end else begin O0l1O10l0 = O0l1O10l0 - 1; end end end end else begin for (OO0O101O0=O0O1O11OO+OIOOl1I00 ; (OO0O101O0 >=
O0O1O11OO) && (lO0IlIOl1 < width) ; OO0O101O0=OO0O101O0-1) begin lO1lOOlI0 = OO0O101O0; O0O1O1101 = 0; while (lO1lOOlI0 != 0) begin if (lO1lOOlI0 & 1) O0O1O1101
= O0O1O1101 + 1; lO1lOOlI0 = lO1lOOlI0 >> 1; end lI1O010l1 = O0O1O1101; if (lI1O010l1 %2) begin if ((lI1O010l1>1) && (Ill11O01O[OO0O101O0] < 0)) begin
Ill11O01O[OO0O101O0] = lO0IlIOl1; O1111l11O[lO0IlIOl1] = OO0O101O0; lO0IlIOl1 = lO0IlIOl1 + 1; end end end end end l1IO10001 = OI11IO001 - 1; for (OO0O101O0=0 ;
OO0O101O0<chkbits ; OO0O101O0=OO0O101O0+1) begin IIO0O111I = {`DW_ecc_func_max_width{1'b0}}; for (lO0IlIOl1=0 ; lO0IlIOl1 < width ; lO0IlIOl1=lO0IlIOl1+1) begin
if (O1111l11O[lO0IlIOl1] & (1 << OO0O101O0)) begin IIO0O111I[lO0IlIOl1] = 1'b1; end end O00ll11OO[OO0O101O0] = IIO0O111I; end l11O1O1II = l1IO10001 - 1; for
(OO0O101O0=0 ; OO0O101O0<chkbits ; OO0O101O0=OO0O101O0+1) begin Ill11O01O[OI11IO001<<OO0O101O0] = width+OO0O101O0; end OlOOIO10I = l1IO10001; for (OO0O101O0=0 ;
OO0O101O0 < chkbits ; OO0O101O0=OO0O101O0+1) begin DWF_ecc_gen_chkbits[OO0O101O0] = ^(data_in & O00ll11OO[OO0O101O0]) ^ ((OO0O101O0<2)||(OO0O101O0>3))? 1'b0 :
1'b1; end    end
// synopsys translate_on
  endfunction
