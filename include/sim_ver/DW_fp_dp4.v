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
// AUTHOR:    Alexandre Tenca, November 2006
//
// VERSION:   Verilog Simulation Model for DW_fp_dp4
//
// DesignWare_version: a175767f
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point Four-term Dot-product
//           Computes the sum of products of FP numbers. For this component,
//           four products are considered. Given the FP inputs a, b, c, d, e
//           f, g and h, it computes the FP output z = a*b + c*d + e*f + g*h. 
//           The format of the FP numbers is defined by the number of bits 
//           in the significand (sig_width) and the number of bits in the 
//           exponent (exp_width).
//           The total number of bits in the FP number is sig_width+exp_width+1
//           since the sign bit takes the place of the MS bits in the significand
//           which is always 1 (unless the number is a denormal; a condition 
//           that can be detected testing the exponent value).
//           The output is a FP number and status flags with information about
//           special number representations and exceptions. Rounding mode may 
//           also be defined by an input port.
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand,  2 to 253 bits
//              exp_width       exponent,     3 to 31 bits
//              ieee_compliance 0 or 1 (default 1)
//              arch_type       0 or 1 (default 0)
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              b               (sig_width + exp_width) + 1-bits
//                              Floating-point Number Input
//              c               (sig_width + exp_width) + 1-bits
//                              Floating-point Number Input
//              d               (sig_width + exp_width) + 1-bits
//                              Floating-point Number Input
//              e               (sig_width + exp_width) + 1-bits
//                              Floating-point Number Input
//              f               (sig_width + exp_width) + 1-bits
//                              Floating-point Number Input
//              g               (sig_width + exp_width) + 1-bits
//                              Floating-point Number Input
//              h               (sig_width + exp_width) + 1-bits
//                              Floating-point Number Input
//              rnd             3 bits
//                              rounding mode
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number result that corresponds
//                              to a*b+c*d+e*f+g*h
//              status          byte
//                              info about FP results
//
// MODIFIED:
//         11/09/07: AFT - Includes modifications to deal with the sign of zeros
//                   according to specification regarding the addition of zeros. 
//                   (A-SP1)
//           11/12/07 - AFT - fixed other problems related to the cancellation of
//                    of products and internal detection of infinities
//           04/25/08 - AFT - included a new parameter (arch_type) to control
//                   the use of alternative architecture with IFP blocks
//           01/2009 - AFT - expanded the use of parameters to accept 
//                     ieee_compliance=1 when arch_type=1
//           07/2009 - AFT - fixed the O0l10OOI bit cancellation procedure to follow 
//                     the same rules defined for the sum4 component (see comments
//                     in the code)
//           09/2010 - AFT - fix corner cases when only 1 bit of the signficant is
//                     kept during alignment.
//           10/2011 - AFT - fixed the cancellation of O0l10OOI bits when there are 
//                     partially out of range products after alignment.
//           04/2012 - AFT - fixed problem described in star 9000532273 
//                     Sticky bit is being shifted during normalization, and 
//                     causing rounding error. 
//           07/2012 - AFT - slightly changed the description of the rules used
//                     to cancel stk bits when POR or COR products happen. No change
//                     in functionality.
//
//-------------------------------------------------------------------------------
module DW_fp_dp4 (a, b, c, d, e, f, g, h, rnd, z, status);
parameter sig_width=23;
parameter exp_width=8;
parameter ieee_compliance=0;                    
parameter arch_type=0;

// declaration of inputs and outputs
input  [sig_width+exp_width:0] a,b,c,d,e,f,g,h;
input  [2:0] rnd;
output [sig_width+exp_width:0] z;
output [7:0] status;

// synopsys translate_off

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (sig_width < 2) || (sig_width > 253) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to 253)",
	sig_width );
    end
  
    if ( (exp_width < 3) || (exp_width > 31) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_width (legal range: 3 to 31)",
	exp_width );
    end
  
    if ( (ieee_compliance < 0) || (ieee_compliance > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ieee_compliance (legal range: 0 to 1)",
	ieee_compliance );
    end
  
    if ( (arch_type < 0) || (arch_type > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch_type (legal range: 0 to 1)",
	arch_type );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



function [4-1:0] Ol1l110O;

  input [2:0] ll1IOIlO;
  input [0:0] I000OO0O;
  input [0:0] IO1IO0l1,OO100IO0,O0l10OOI;


  begin
  Ol1l110O[0] = 0;
  Ol1l110O[1] = OO100IO0|O0l10OOI;
  Ol1l110O[2] = 0;
  Ol1l110O[3] = 0;
  if ($time > 0)
  case (ll1IOIlO)
    3'b000:
    begin
      Ol1l110O[0] = OO100IO0&(IO1IO0l1|O0l10OOI);
      Ol1l110O[2] = 1;
      Ol1l110O[3] = 0;
    end
    3'b001:
    begin
      Ol1l110O[0] = 0;
      Ol1l110O[2] = 0;
      Ol1l110O[3] = 0;
    end
    3'b010:
    begin
      Ol1l110O[0] = ~I000OO0O & (OO100IO0|O0l10OOI);
      Ol1l110O[2] = ~I000OO0O;
      Ol1l110O[3] = ~I000OO0O;
    end
    3'b011:
    begin
      Ol1l110O[0] = I000OO0O & (OO100IO0|O0l10OOI);
      Ol1l110O[2] = I000OO0O;
      Ol1l110O[3] = I000OO0O;
    end
    3'b100:
    begin
      Ol1l110O[0] = OO100IO0;
      Ol1l110O[2] = 1;
      Ol1l110O[3] = 0;
    end
    3'b101:
    begin
      Ol1l110O[0] = OO100IO0|O0l10OOI;
      Ol1l110O[2] = 1;
      Ol1l110O[3] = 1;
    end
    default:
      $display("Error! illegal rounding mode.\n");
  endcase
  end

endfunction


// definitions used in the code


`define DW_lIO011OO (sig_width*4+5)
`define DW_l11l1llI (((`DW_lIO011OO>16)?((`DW_lIO011OO>64)?((`DW_lIO011OO>128)?8:7):((`DW_lIO011OO>32)?6:5)):((`DW_lIO011OO>4)?((`DW_lIO011OO>8)?4:3):((`DW_lIO011OO>2)?2:1))))
`define DW_Il1II1Il (6*sig_width+5+3)
`define DW_OO10OOO1 0
reg [8    -1:0] l0Ol0OOI;
reg [(exp_width + sig_width):0] OIl1001l;
reg lO0OOOIl,l1O100I0,OIO0I111,O01l0OI0,O0l10OOI,OIlOO101,l01010ll,OO1llIO1,IOIO101I,Il110l11,Il001001;
reg [exp_width-1:0] OII0OO00,I0IO1I0I,II11O1l1,O111O1l0,O0I11lO1,I0OllO01,lI10O00l,lOOO1O10; 
reg [sig_width-1:0] I0OOOO0I,O11l1Il0,l1010OI1,Olll0I0I,l110IO01,l0011Ol0,O1I01l1O,OOIllOOl;
reg [sig_width:0] OlI00101,O0O01OO1,IlOl0O1O,I00001l0,l00l0l10,l0l10l0l,l010l000,OO1O01OI;
reg I0O1O10l,lIO0OIO1,O0I1O0OO,I0101O0I,lI0O1O11,lOllOlI1,O0O10OIl,O1101IlO;
reg O01l0I11,OOO1IO01,OOl000IO,O0I0l100,lOIOI11I,OOl0lll1,lll1O1I1,OlO101Ol;
reg II10OOO1,l0l0IIOI,l000O1O1,O111l1ll,I0OIO0II,I00O0l01,l1I11O1O,O00O10O0;
reg IIOO00Ol,IOlI1111,lI01111O,llIO1OO1,O0IOIOOO,l0O0001O,OI0OOO0I,O1I10IO1;
reg [2*sig_width+1:0] l0OOO1l1,I1OlI0Ol,OlOIOIO0,l10IIIO0;
reg [(`DW_Il1II1Il-2):0] I1llOI11, I011O0l1;
reg [(`DW_Il1II1Il-2):0] O0IOlI0O, OIOl00O1;
reg [exp_width+1:0] O11O101I, O0Ol1l1l,II10l0O0,O00I1lOO;
reg I11010I0, O11O0IO1, llII1II1, l0OIOl1I;
reg [exp_width-1:0] lOII1O0l;
reg [exp_width-1:0] lO11O011;
reg [exp_width+1:0] I0I0110O;                     // biggest exponent
reg [exp_width+1:0] O0I0lO1O,OOI1O00O,O1OlO001;
reg [exp_width+1:0] O1O0lOOO,O011O1I0,OlI1O0O0;          // Exponents.
reg [exp_width+1:0] OI0Ol0OO,OI1000I0,Il10l0OO;
reg [exp_width+1:0] O0111O11,O1O00OII;
reg OI01lO00,l10O100O,O1l100OO;                 // Signs     
reg l10OlIl0,O11l0O0O,OOIIOO0O; 
reg OII1I001,II101lI0;
reg [(`DW_Il1II1Il-2):0] llOIOl1I,lO0ll1O1,O11lO00O;   // Mantissa vectors
reg [(`DW_Il1II1Il-2):0] OO1101OO,l0010OO1;
reg [(`DW_Il1II1Il-2):0] I01O1OI1,OO011IO0,II01l1O1; 
`define DW_llO101OO ((`DW_Il1II1Il-2)+1)
reg [(`DW_Il1II1Il-2):0] I1O11lIO, l0O111OO;
reg [(`DW_Il1II1Il-2):0] O1l0O100;
reg [(`DW_Il1II1Il-2)+1:0] O111111l,OO10Il01,l0IOIO11, IOOO1I01;
reg [(`DW_Il1II1Il-2)+1:0] II1lO1lO;        // Internal adder output
reg IO1110IO;
reg I10OIO1I;
reg [(`DW_Il1II1Il-2):0] OIOOl1OI;                   // Mantissa vector
reg [4-1:0] l1000O1I;             // The values returned by Ol1l110O function.
reg [(exp_width + sig_width + 1)-1:0] IIOO1OI0;                 // NaN FP number
reg [(exp_width + sig_width + 1)-1:0] OI11lO10;               // plus infinity
reg [(exp_width + sig_width + 1)-1:0] OI0110lO;                // negative infinity
reg [(exp_width + sig_width + 1)-1:0] OIl01l1O;              // plus zero
reg [(exp_width + sig_width + 1)-1:0] IO1O011I;               // negative zero
reg Ol10000O, IOI00O10, OOIO0lO0, I1000OO1;
reg l1OOO0O1, lO01101O, IO0OO10I, OO00O1OO;
reg O1l10l01, l1O100O0, OO1II1I1, O0Ol01I1;
reg OIO11IOO, I1O0lOII, O00OOl01, O01II1lI; 
reg O00I0Ol1, O1l000I0, OO0O1111, lOO000II;
reg IO1O0000;
reg I00l100l;
reg l0IlO0O1, OlOl1OO0;
reg O11IOO1I, OlOII011;

//---------------------------------------------------------------
// The following portion of the code describes DW_fp_dp2 when
// arch_type = 1
//---------------------------------------------------------------


wire [sig_width+exp_width : 0] OO0IOOll;
wire [7 : 0] O10O0I1O;

wire [sig_width+2+exp_width+6:0] OI0IOI00;
wire [sig_width+2+exp_width+6:0] OOO1IlI0;
wire [sig_width+2+exp_width+6:0] l10OOO00; 
wire [sig_width+2+exp_width+6:0] I0OOII0O;
wire [sig_width+2+exp_width+6:0] ll11O1l0;
wire [sig_width+2+exp_width+6:0] Ol01Ol0I;
wire [sig_width+2+exp_width+6:0] IO0OI0ll;
wire [sig_width+2+exp_width+6:0] O101OI11;
wire [2*(sig_width+2+1)+exp_width+1+6:0] O10Ol000; // partial products
wire [2*(sig_width+2+1)+exp_width+1+6:0] l100OO1I;
wire [2*(sig_width+2+1)+exp_width+1+6:0] l1Ol001l; 
wire [2*(sig_width+2+1)+exp_width+1+6:0] IO0111Ol;
wire [2*(sig_width+2+1)+1+exp_width+1+1+6:0] llOI0000; // result of p1+p2
wire [2*(sig_width+2+1)+1+exp_width+1+1+6:0] OIOOl1O1; // result of p3+p4   
wire [2*(sig_width+2+1)+1+1+exp_width+1+1+1+6:0] O11OlO0I; // result of padd1+padd2



  // Instances of DW_fp_ifp_conv  -- format converters
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U1 ( .a(a), .z(OI0IOI00) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U2 ( .a(b), .z(OOO1IlI0) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U3 ( .a(c), .z(l10OOO00) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U4 ( .a(d), .z(I0OOII0O) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U5 ( .a(e), .z(ll11O1l0) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U6 ( .a(f), .z(Ol01Ol0I) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U7 ( .a(g), .z(IO0OI0ll) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U8 ( .a(h), .z(O101OI11) );
  // Instances of DW_ifp_mult
    DW_ifp_mult #(sig_width+2, exp_width, 2*(sig_width+2+1), exp_width+1)
	  U9  ( .a(OI0IOI00), .b(OOO1IlI0), .z(O10Ol000) );
    DW_ifp_mult #(sig_width+2, exp_width, 2*(sig_width+2+1), exp_width+1)
	  U10 ( .a(l10OOO00), .b(I0OOII0O), .z(l100OO1I) );
    DW_ifp_mult #(sig_width+2, exp_width, 2*(sig_width+2+1), exp_width+1)
	  U11 ( .a(ll11O1l0), .b(Ol01Ol0I), .z(l1Ol001l) );
    DW_ifp_mult #(sig_width+2, exp_width, 2*(sig_width+2+1), exp_width+1)
	  U12 ( .a(IO0OI0ll), .b(O101OI11), .z(IO0111Ol) );
   // Instances of DW_ifp_addsub
    DW_ifp_addsub #(2*(sig_width+2+1), exp_width+1, 2*(sig_width+2+1)+1, exp_width+1+1, ieee_compliance)
	  U13 ( .a(O10Ol000), .b(l100OO1I), .op(1'b0), .rnd(rnd),
               .z(llOI0000) );
    DW_ifp_addsub #(2*(sig_width+2+1), exp_width+1, 2*(sig_width+2+1)+1, exp_width+1+1, ieee_compliance)
	  U14 ( .a(l1Ol001l), .b(IO0111Ol), .op(1'b0), .rnd(rnd),
               .z(OIOOl1O1) );
    DW_ifp_addsub #(2*(sig_width+2+1)+1, exp_width+1+1, 2*(sig_width+2+1)+1+1, exp_width+1+1+1, ieee_compliance)
	  U15 ( .a(llOI0000), .b(OIOOl1O1), .op(1'b0), .rnd(rnd),
               .z(O11OlO0I) );
  // Instance of DW_ifp_fp_conv  -- format converter
    DW_ifp_fp_conv #(2*(sig_width+2+1)+1+1, exp_width+1+1+1, sig_width, exp_width, ieee_compliance)
          U16 ( .a(O11OlO0I), .rnd(rnd), .z(OO0IOOll), .status(O10O0I1O) );

//-------------------------------------------------------------------
// The following code is used to describe the DW_fp_dp2 component
// when arch_type = 0
//-------------------------------------------------------------------
always @(a or b or c or d or e or f or g or h or rnd)
begin
  // setup special values
  lO11O011 = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
  lOII1O0l = 1;
  IIOO1OI0 = {1'b0,{exp_width{1'b1}},{sig_width{1'b0}}};
  // mantissa of NaN is 1 when ieee_compliance = 1
  IIOO1OI0[0] = ieee_compliance; 
  OI11lO10 = {1'b0,lO11O011,{sig_width{1'b0}}};
  OI0110lO = {1'b1,lO11O011,{sig_width{1'b0}}};
  OIl01l1O = 0;
  IO1O011I = {1'b1,{sig_width+exp_width{1'b0}}};
  l0Ol0OOI = 0;

  // extract exponent and significand from inputs
  OII0OO00 = a[((exp_width + sig_width) - 1):sig_width];
  I0IO1I0I = b[((exp_width + sig_width) - 1):sig_width];
  II11O1l1 = c[((exp_width + sig_width) - 1):sig_width];
  O111O1l0 = d[((exp_width + sig_width) - 1):sig_width];
  O0I11lO1 = e[((exp_width + sig_width) - 1):sig_width];
  I0OllO01 = f[((exp_width + sig_width) - 1):sig_width];
  lI10O00l = g[((exp_width + sig_width) - 1):sig_width];
  lOOO1O10 = h[((exp_width + sig_width) - 1):sig_width];
  I0OOOO0I = a[(sig_width - 1):0];
  O11l1Il0 = b[(sig_width - 1):0];
  l1010OI1 = c[(sig_width - 1):0];
  Olll0I0I = d[(sig_width - 1):0];
  l110IO01 = e[(sig_width - 1):0];
  l0011Ol0 = f[(sig_width - 1):0];
  O1I01l1O = g[(sig_width - 1):0];
  OOIllOOl = h[(sig_width - 1):0];
  I0O1O10l = a[(exp_width + sig_width)];
  lIO0OIO1 = b[(exp_width + sig_width)];
  O0I1O0OO = c[(exp_width + sig_width)];
  I0101O0I = d[(exp_width + sig_width)];
  lI0O1O11 = e[(exp_width + sig_width)];
  lOllOlI1 = f[(exp_width + sig_width)];
  O0O10OIl = g[(exp_width + sig_width)];
  O1101IlO = h[(exp_width + sig_width)];

  // determine special input values and perform adjustments in internal
  // mantissa values
  O01l0I11 = ((OII0OO00 === 0) && ((I0OOOO0I === 0) || (ieee_compliance === 0)));
  OOO1IO01 = ((I0IO1I0I === 0) && ((O11l1Il0 === 0) || (ieee_compliance === 0)));
  OOl000IO = ((II11O1l1 === 0) && ((l1010OI1 === 0) || (ieee_compliance === 0)));
  O0I0l100 = ((O111O1l0 === 0) && ((Olll0I0I === 0) || (ieee_compliance === 0)));
  lOIOI11I = ((O0I11lO1 === 0) && ((l110IO01 === 0) || (ieee_compliance === 0)));
  OOl0lll1 = ((I0OllO01 === 0) && ((l0011Ol0 === 0) || (ieee_compliance === 0)));
  lll1O1I1 = ((lI10O00l === 0) && ((O1I01l1O === 0) || (ieee_compliance === 0)));
  OlO101Ol = ((lOOO1O10 === 0) && ((OOIllOOl === 0) || (ieee_compliance === 0)));
  I0OOOO0I = (O01l0I11)?0:I0OOOO0I;
  O11l1Il0 = (OOO1IO01)?0:O11l1Il0;
  l1010OI1 = (OOl000IO)?0:l1010OI1;
  Olll0I0I = (O0I0l100)?0:Olll0I0I;
  l110IO01 = (lOIOI11I)?0:l110IO01;
  l0011Ol0 = (OOl0lll1)?0:l0011Ol0;
  O1I01l1O = (lll1O1I1)?0:O1I01l1O;
  OOIllOOl = (OlO101Ol)?0:OOIllOOl;
  // detect infinity inputs
  II10OOO1 = ((OII0OO00 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((I0OOOO0I === 0)||(ieee_compliance === 0)));
  l0l0IIOI = ((I0IO1I0I === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((O11l1Il0 === 0)||(ieee_compliance === 0)));
  l000O1O1 = ((II11O1l1 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((l1010OI1 === 0)||(ieee_compliance === 0)));
  O111l1ll = ((O111O1l0 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((Olll0I0I === 0)||(ieee_compliance === 0)));
  I0OIO0II = ((O0I11lO1 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((l110IO01 === 0)||(ieee_compliance === 0)));
  I00O0l01 = ((I0OllO01 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((l0011Ol0 === 0)||(ieee_compliance === 0)));
  l1I11O1O = ((lI10O00l === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((O1I01l1O === 0)||(ieee_compliance === 0)));
  O00O10O0 = ((lOOO1O10 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((OOIllOOl === 0)||(ieee_compliance === 0)));
  I0OOOO0I = (II10OOO1)?0:I0OOOO0I;
  O11l1Il0 = (l0l0IIOI)?0:O11l1Il0;
  l1010OI1 = (l000O1O1)?0:l1010OI1;
  Olll0I0I = (O111l1ll)?0:Olll0I0I;
  l110IO01 = (I0OIO0II)?0:l110IO01;
  l0011Ol0 = (I00O0l01)?0:l0011Ol0;
  O1I01l1O = (l1I11O1O)?0:O1I01l1O;
  OOIllOOl = (O00O10O0)?0:OOIllOOl;
  // detect nan inputs
  IIOO00Ol = ((OII0OO00 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(I0OOOO0I !== 0)&&(ieee_compliance === 1));
  IOlI1111 = ((I0IO1I0I === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(O11l1Il0 !== 0)&&(ieee_compliance === 1));
  lI01111O = ((II11O1l1 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(l1010OI1 !== 0)&&(ieee_compliance === 1));
  llIO1OO1 = ((O111O1l0 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(Olll0I0I !== 0)&&(ieee_compliance === 1));
  O0IOIOOO = ((O0I11lO1 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(l110IO01 !== 0)&&(ieee_compliance === 1));
  l0O0001O = ((I0OllO01 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(l0011Ol0 !== 0)&&(ieee_compliance === 1));
  OI0OOO0I = ((lI10O00l === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(O1I01l1O !== 0)&&(ieee_compliance === 1));
  O1I10IO1 = ((lOOO1O10 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(OOIllOOl !== 0)&&(ieee_compliance === 1));

  // build mantissas
  // Detect the denormal input case
  if ((OII0OO00 === 0) && (I0OOOO0I != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      OlI00101 = {1'b0,I0OOOO0I};
      OIO11IOO = 1;
      OII0OO00[0] = 1;                // set exponent of denormal to minimum
    end
  else
    begin
      // Mantissa for normal number
      if (OII0OO00 === 0) 
        OlI00101 = 0;
      else
        OlI00101 = {1'b1,I0OOOO0I};
      OIO11IOO = 0;      
    end
  if ((I0IO1I0I === 0) && (O11l1Il0 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      O0O01OO1 = {1'b0,O11l1Il0};
      I1O0lOII = 1;
      I0IO1I0I[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (I0IO1I0I === 0) 
        O0O01OO1 = 0;
      else
        O0O01OO1 = {1'b1,O11l1Il0};
      I1O0lOII = 0;      
    end
  if ((II11O1l1 === 0) && (l1010OI1 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      IlOl0O1O = {1'b0,l1010OI1};
      O00OOl01 = 1;
      II11O1l1[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (II11O1l1 === 0) 
        IlOl0O1O = 0;
      else
        IlOl0O1O = {1'b1,l1010OI1};
      O00OOl01 = 0;      
    end
  if ((O111O1l0 === 0) && (Olll0I0I != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      I00001l0 = {1'b0,Olll0I0I};
      O01II1lI = 1;
      O111O1l0[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (O111O1l0 === 0) 
        I00001l0 = 0;
      else
        I00001l0 = {1'b1,Olll0I0I};
      O01II1lI = 0;      
    end
  if ((O0I11lO1 === 0) && (l110IO01 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      l00l0l10 = {1'b0,l110IO01};
      O00I0Ol1 = 1;
      O0I11lO1[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (O0I11lO1 === 0) 
        l00l0l10 = 0;
      else
        l00l0l10 = {1'b1,l110IO01};
      O00I0Ol1 = 0;      
    end
  if ((I0OllO01 === 0) && (l0011Ol0 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      l0l10l0l = {1'b0,l0011Ol0};
      O1l000I0 = 1;
      I0OllO01[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (I0OllO01 === 0) 
        l0l10l0l = 0;
      else
        l0l10l0l = {1'b1,l0011Ol0};
      O1l000I0 = 0;      
    end
  if ((lI10O00l === 0) && (O1I01l1O != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      l010l000 = {1'b0,O1I01l1O};
      OO0O1111 = 1;
      lI10O00l[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (lI10O00l === 0) 
        l010l000 = 0;
      else
        l010l000 = {1'b1,O1I01l1O};
      OO0O1111 = 0;      
    end
  if ((lOOO1O10 === 0) && (OOIllOOl != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      OO1O01OI = {1'b0,OOIllOOl};
      lOO000II = 1;
      lOOO1O10[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (lOOO1O10 === 0) 
        OO1O01OI = 0;
      else
        OO1O01OI = {1'b1,OOIllOOl};
      lOO000II = 0;      
    end
  // calculate the internal exponents
  if (OII0OO00 === 0 || I0IO1I0I === 0)
    O11O101I = 0;
  else
    O11O101I = {2'b00,OII0OO00} + {2'b00,I0IO1I0I};
  if (II11O1l1 === 0 || O111O1l0 === 0)
    O0Ol1l1l = 0;
  else
    O0Ol1l1l = {2'b00,II11O1l1} + {2'b00,O111O1l0};
  if (O0I11lO1 === 0 || I0OllO01 === 0)
    II10l0O0 = 0;
  else
    II10l0O0 = {2'b00,O0I11lO1} + {2'b00,I0OllO01};
  if (lI10O00l === 0 || lOOO1O10 === 0)
    O00I1lOO = 0;
  else
    O00I1lOO = {2'b00,lI10O00l} + {2'b00,lOOO1O10};

  O1l10l01 = (O01l0I11 | OOO1IO01);
  l1O100O0 = (OOl000IO | O0I0l100);
  OO1II1I1 = (lOIOI11I | OOl0lll1);
  O0Ol01I1 = (lll1O1I1 | OlO101Ol);
  
  // Identify and treat special input values

  // Rule 1.
  if (IIOO00Ol || IOlI1111 || lI01111O || llIO1OO1 || O0IOIOOO || l0O0001O || OI0OOO0I || O1I10IO1)
    begin // gets here only when ieee_compliance = 1
      // one of the inputs is a NAN       --> the output must be an NAN
      OIl1001l = IIOO1OI0;
      l0Ol0OOI[2] = 1;
      l0Ol0OOI[1] = (ieee_compliance == 0);
    end

  //
  // Infinity Inputs
  // Rule 2.1
  //
  else if ((II10OOO1 && OOO1IO01) ||  // a=inf and b=0
	   (l0l0IIOI && O01l0I11) ||  // b=inf and a=0
	   (l000O1O1 && O0I0l100) ||  // c=inf and d=0
	   (O111l1ll && OOl000IO) ||  // d=inf and c=0
	   (I0OIO0II && OOl0lll1) ||  // e=inf and f=0
	   (I00O0l01 && lOIOI11I) ||  // f=inf and e=0
	   (l1I11O1O && OlO101Ol) ||  // g=inf and h=0
	   (O00O10O0 && lll1O1I1))    // h=inf and g=0
    begin
      OIl1001l = IIOO1OI0;
      l0Ol0OOI[2] = 1;
      l0Ol0OOI[1] = (ieee_compliance == 0);
    end

  // Leave the decision about 2.2 and 3 for after the multiplication is done

  // Zero inputs 
  else if (O1l10l01 & l1O100O0 & OO1II1I1 & O0Ol01I1 & (ieee_compliance == 1))
    begin
      I11010I0 = (I0O1O10l ^ lIO0OIO1);
      O11O0IO1 = (O0I1O0OO ^ I0101O0I);
      llII1II1 = (lI0O1O11 ^ lOllOlI1);
      l0OIOl1I = (O0O10OIl ^ O1101IlO);
      if (I11010I0 == O11O0IO1 & O11O0IO1 === llII1II1 & llII1II1 === l0OIOl1I)
        OIl1001l = {I11010I0,{sig_width+exp_width{1'b0}}};
      else
        OIl1001l = (rnd == 3)?IO1O011I:OIl01l1O;
      l0Ol0OOI[0] = 1;
    end
  
  //
  // Normal Inputs
  //
  else                                          
    begin 
    // generate the product terms
    l0OOO1l1 = (OlI00101 * O0O01OO1);
    I1OlI0Ol = (IlOl0O1O * I00001l0);
    OlOIOIO0 = (l00l0l10 * l0l10l0l);
    l10IIIO0 = (l010l000 * OO1O01OI);
    I1llOI11 = {2'b0,l0OOO1l1,{(`DW_Il1II1Il-2*sig_width-5){1'b0}}};
    I011O0l1 = {2'b0,I1OlI0Ol,{(`DW_Il1II1Il-2*sig_width-5){1'b0}}};
    O0IOlI0O = {2'b0,OlOIOIO0,{(`DW_Il1II1Il-2*sig_width-5){1'b0}}};
    OIOl00O1 = {2'b0,l10IIIO0,{(`DW_Il1II1Il-2*sig_width-5){1'b0}}};

    I11010I0 = (I0O1O10l ^ lIO0OIO1);
    O11O0IO1 = (O0I1O0OO ^ I0101O0I);
    llII1II1 = (lI0O1O11 ^ lOllOlI1);
    l0OIOl1I = (O0O10OIl ^ O1101IlO);

    // the following variables are used to keep track of invalid operations
    l1OOO0O1 = ((II10OOO1 & OOO1IO01) | (l0l0IIOI & O01l0I11)) & (ieee_compliance == 1);
    lO01101O = ((l000O1O1 & O0I0l100) | (O111l1ll & OOl000IO)) & (ieee_compliance == 1);
    IO0OO10I = ((I0OIO0II & OOl0lll1) | (I00O0l01 & lOIOI11I)) & (ieee_compliance == 1);
    OO00O1OO = ((l1I11O1O & OlO101Ol) | (O00O10O0 & lll1O1I1)) & (ieee_compliance == 1);
    IO1O0000 = l1OOO0O1 | lO01101O | IO0OO10I | OO00O1OO;

    if (IO1O0000)
      begin
        l0Ol0OOI[2] = 1;
        OIl1001l = IIOO1OI0;                  // NaN
        l0Ol0OOI[1] = (ieee_compliance == 0);
      end
    else

      begin // valid operations 
      // Takes care of Rule 2.2
      // Normalize the intermediate mantissas of partial prods.
      while ( (I1llOI11[(`DW_Il1II1Il-2)-2] === 0) && (|O11O101I !== 0) )
        begin
          O11O101I = O11O101I - 1;
          I1llOI11 = I1llOI11 << 1;
        end
      while ( (I011O0l1[(`DW_Il1II1Il-2)-2] === 0) && (|O0Ol1l1l !== 0) )
        begin
          O0Ol1l1l = O0Ol1l1l - 1;
          I011O0l1 = I011O0l1 << 1;
        end
      while ( (O0IOlI0O[(`DW_Il1II1Il-2)-2] === 0) && (|II10l0O0 !== 0) )
        begin
          II10l0O0 = II10l0O0 - 1;
          O0IOlI0O = O0IOlI0O << 1;
        end
      while ( (OIOl00O1[(`DW_Il1II1Il-2)-2] === 0) && (|O00I1lOO !== 0) )
        begin
          O00I1lOO = O00I1lOO - 1;
          OIOl00O1 = OIOl00O1 << 1;
        end
 

      Ol10000O = 0;
      IOI00O10 = 0;
      OOIO0lO0 = 0;
      I1000OO1 = 0;
      if (II10OOO1 || l0l0IIOI)
        Ol10000O = 1;
      if (l000O1O1 || O111l1ll)
        IOI00O10 = 1;
      if (I0OIO0II || I00O0l01)
        OOIO0lO0 = 1;
      if (l1I11O1O || O00O10O0)
        I1000OO1 = 1;
      I00l100l = II10OOO1 | l0l0IIOI | l000O1O1 | O111l1ll | 
                       I0OIO0II | I00O0l01 | l1I11O1O | O00O10O0;
      if (Ol10000O === 1 || IOI00O10 === 1 || OOIO0lO0 === 1 || I1000OO1 === 1)
        begin
          l0Ol0OOI[1] = 1;
          l0Ol0OOI[4] = ~I00l100l;
          l0Ol0OOI[5] = l0Ol0OOI[4];
          OIl1001l = OI11lO10;
          OIl1001l[(exp_width + sig_width)] = (Ol10000O & I11010I0) | (IOI00O10 & O11O0IO1) |
                             (OOIO0lO0 & llII1II1) | (I1000OO1 & l0OIOl1I);
          // Watch out for Inf-Inf !
          if ( (Ol10000O === 1 && IOI00O10 === 1 && I11010I0 !== O11O0IO1) ||
               (Ol10000O === 1 && OOIO0lO0 === 1 && I11010I0 !== llII1II1) ||
               (Ol10000O === 1 && I1000OO1 === 1 && I11010I0 !== l0OIOl1I) ||
               (IOI00O10 === 1 && OOIO0lO0 === 1 && O11O0IO1 !== llII1II1) ||
               (IOI00O10 === 1 && I1000OO1 === 1 && O11O0IO1 !== l0OIOl1I) ||
               (OOIO0lO0 === 1 && I1000OO1 === 1 && llII1II1 !== l0OIOl1I) )
            begin
              l0Ol0OOI[2] = 1;
              l0Ol0OOI[4] = 0;
              l0Ol0OOI[5] = 0;
              OIl1001l = IIOO1OI0;                  // NaN
              l0Ol0OOI[1] = (ieee_compliance == 0);
            end
        end
      else
        begin
          // continue with addition of products
          if ({I11010I0,O11O101I,I1llOI11} == 
              {~O11O0IO1,O0Ol1l1l,I011O0l1})
             begin
               O11O101I = 0;
               I1llOI11 = 0;
               O0Ol1l1l = 0;
               I011O0l1 = 0;
             end
          if ({I11010I0,O11O101I,I1llOI11} == 
              {~llII1II1,II10l0O0,O0IOlI0O})
             begin
               O11O101I = 0;
               I1llOI11 = 0;
               II10l0O0 = 0;
               O0IOlI0O = 0;
             end
          if ({I11010I0,O11O101I,I1llOI11} == 
              {~l0OIOl1I,O00I1lOO,OIOl00O1})
             begin
               O11O101I = 0;
               I1llOI11 = 0;
               O00I1lOO = 0;
               OIOl00O1 = 0;
             end
          if ({O11O0IO1,O0Ol1l1l,I011O0l1} == 
              {~llII1II1,II10l0O0,O0IOlI0O})
             begin
               O0Ol1l1l = 0;
               I011O0l1 = 0;
               II10l0O0 = 0;
               O0IOlI0O = 0;
             end
          if ({O11O0IO1,O0Ol1l1l,I011O0l1} == 
              {~l0OIOl1I,O00I1lOO,OIOl00O1})
             begin
               O0Ol1l1l = 0;
               I011O0l1 = 0;
               O00I1lOO = 0;
               OIOl00O1 = 0;
             end
          if ({llII1II1,II10l0O0,O0IOlI0O} == 
              {~l0OIOl1I,O00I1lOO,OIOl00O1})
             begin
               II10l0O0 = 0;
               O0IOlI0O = 0;
               O00I1lOO = 0;
               OIOl00O1 = 0;
             end

          // compute the signal that defines the large and small FP values
          lO0OOOIl = 0;
          if ({O11O101I,I1llOI11} < {O0Ol1l1l,I011O0l1})
            lO0OOOIl = 1;
          if (lO0OOOIl == 1)
            begin
              O011O1I0 = O0Ol1l1l;
              lO0ll1O1 = I011O0l1;
              l10O100O = O11O0IO1;
              OI1000I0 = O11O101I;
              OO011IO0 = I1llOI11;
              O11l0O0O = I11010I0;
            end
          else
            begin
              O011O1I0 = O11O101I;
              lO0ll1O1 = I1llOI11;
              l10O100O = I11010I0;
              OI1000I0 = O0Ol1l1l;
              OO011IO0 = I011O0l1;
              O11l0O0O = O11O0IO1;
            end
          l1O100I0 = 0;
          if ({II10l0O0,O0IOlI0O} < {O00I1lOO,OIOl00O1}) 
            l1O100I0 = 1;
          if (l1O100I0 == 1) 
            begin
              OlI1O0O0 = O00I1lOO;
              O11lO00O = OIOl00O1;
              O1l100OO = l0OIOl1I;
              Il10l0OO = II10l0O0;
              II01l1O1 = O0IOlI0O;
              OOIIOO0O = llII1II1;
            end
          else
            begin
              OlI1O0O0 = II10l0O0;
              O11lO00O = O0IOlI0O;
              O1l100OO = llII1II1;
              Il10l0OO = O00I1lOO;
              II01l1O1 = OIOl00O1;
              OOIIOO0O = l0OIOl1I;
            end
          OIO0I111 = 0;
          if ({O011O1I0,lO0ll1O1} < {OlI1O0O0,O11lO00O}) 
            OIO0I111 = 1;
          if (OIO0I111 == 1) 
            begin
              O1O0lOOO = OlI1O0O0;
              llOIOl1I = O11lO00O;
              OI01lO00 = O1l100OO;
              O0111O11 = O011O1I0;
              OO1101OO = lO0ll1O1;
              OII1I001 = l10O100O;
            end
          else
            begin
              O1O0lOOO = O011O1I0;
              llOIOl1I = lO0ll1O1;
              OI01lO00 = l10O100O;
              O0111O11 = OlI1O0O0;
              OO1101OO = O11lO00O;
              OII1I001 = O1l100OO;
            end
          O01l0OI0 = 0;
          if ({OI1000I0,OO011IO0} < {Il10l0OO,II01l1O1}) 
            O01l0OI0 = 1;
          if (O01l0OI0 == 1) 
            begin
              O1O00OII = Il10l0OO;
              l0010OO1 = II01l1O1;
              II101lI0 = OOIIOO0O;
              OI0Ol0OO = OI1000I0;
              I01O1OI1 = OO011IO0;
              l10OlIl0 = O11l0O0O;
            end
          else
            begin
              O1O00OII = OI1000I0;
              l0010OO1 = OO011IO0;
              II101lI0 = O11l0O0O;
              OI0Ol0OO = Il10l0OO;
              I01O1OI1 = II01l1O1;
              l10OlIl0 = OOIIOO0O;
            end

          // Shift right by E_Diff the Small number: M_Small.
          I1O11lIO = OO1101OO;
          if (`DW_OO10OOO1 > 0)
            begin
              OIlOO101 = |OO1101OO[`DW_OO10OOO1:0];
              I1O11lIO[`DW_OO10OOO1:0] = 0;
            end
          else
            OIlOO101 = 0; 
          O0I0lO1O = O1O0lOOO - O0111O11;
          while ( (|I1O11lIO[`DW_llO101OO-1:`DW_OO10OOO1+1] !== 0) && (|O0I0lO1O !== 0) && (O0I0lO1O[exp_width+1] == 1'b0))
            begin
              I1O11lIO[`DW_llO101OO-1:`DW_OO10OOO1] = I1O11lIO[`DW_llO101OO-1:`DW_OO10OOO1] >> 1;
              OIlOO101 = I1O11lIO[`DW_OO10OOO1] | OIlOO101;
              O0I0lO1O = O0I0lO1O - 1;
            end
          O11IOO1I = ~|I1O11lIO[`DW_llO101OO-1:`DW_OO10OOO1+1];
          l0IlO0O1 = |I1O11lIO[`DW_llO101OO-1:`DW_OO10OOO1+1] & OIlOO101;
          I1O11lIO[`DW_OO10OOO1] = OIlOO101;
          l0O111OO = l0010OO1;
          if (`DW_OO10OOO1 > 0)
            begin
              l01010ll = |l0010OO1[`DW_OO10OOO1:0];
              l0O111OO[`DW_OO10OOO1:0] = 0;
            end
          else
            l01010ll = 0;
          OOI1O00O = O1O0lOOO - O1O00OII;
          while ( (|l0O111OO[`DW_llO101OO-1:`DW_OO10OOO1+1] !== 0) && (|OOI1O00O !== 0) && (OOI1O00O[exp_width+1] == 1'b0))
            begin
              l0O111OO[`DW_llO101OO-1:`DW_OO10OOO1] = l0O111OO[`DW_llO101OO-1:`DW_OO10OOO1] >> 1;
              l01010ll = l0O111OO[`DW_OO10OOO1] | l01010ll;
              OOI1O00O = OOI1O00O - 1;
            end
          OlOII011 = ~|l0O111OO[`DW_llO101OO-1:`DW_OO10OOO1+1];
          OlOl1OO0 = |l0O111OO[`DW_llO101OO-1:`DW_OO10OOO1+1] & l01010ll;
          l0O111OO[`DW_OO10OOO1] = l01010ll;
          O1l0O100 = I01O1OI1;
          if (`DW_OO10OOO1 > 0)
            begin
              OO1llIO1 = |I01O1OI1[`DW_OO10OOO1:0];
              O1l0O100[`DW_OO10OOO1:0] = 0;
            end
          else
            OO1llIO1 = 0;
          O1OlO001 = O1O0lOOO - OI0Ol0OO;
          while ( (|O1l0O100[`DW_llO101OO-1:`DW_OO10OOO1+1] !== 0) && (|O1OlO001 !== 0) && (O1OlO001[exp_width+1] == 1'b0))
            begin
              O1l0O100[`DW_llO101OO-1:`DW_OO10OOO1] = O1l0O100[`DW_llO101OO-1:`DW_OO10OOO1] >> 1;
              OO1llIO1 = O1l0O100[`DW_OO10OOO1] | OO1llIO1;
              O1OlO001 = O1OlO001 - 1;
            end
          O1l0O100[`DW_OO10OOO1] = OO1llIO1;

          if (l0IlO0O1 | OlOl1OO0) 
	    begin
              O1l0O100[`DW_OO10OOO1] = 0;
              if (l0IlO0O1 & OlOl1OO0) 
                begin
                  if ({O0111O11,OO1101OO} < {O1O00OII,l0010OO1})
                    I1O11lIO[`DW_OO10OOO1] = 0;
                  else
                    l0O111OO[`DW_OO10OOO1] = 0;
                end
            end
          else
            begin
              if ((OIlOO101 & O11IOO1I) | (l01010ll & OlOII011)) 
                begin
                  O1l0O100[`DW_OO10OOO1] = 0;
                  if ((OIlOO101 & O11IOO1I) & (l01010ll & OlOII011)) 
                    begin  
  	              if ({O0111O11,OO1101OO} < {O1O00OII,l0010OO1})
                        I1O11lIO[`DW_OO10OOO1] = 0;
                      else
                        l0O111OO[`DW_OO10OOO1] = 0;
                    end
                end
            end         
            
          // Compute internal addition result
          // We are going to change the sign of the smaller products
          // when their sign is different from the large product
          O111111l = {1'b0,llOIOl1I};
          if (OI01lO00 !== OII1I001) 
            OO10Il01 = ~{1'b0,I1O11lIO} + 1;
          else
            OO10Il01 = {1'b0,I1O11lIO};
          if (OI01lO00 !== II101lI0)
            l0IOIO11 = ~{1'b0,l0O111OO} + 1;
          else
            l0IOIO11 = {1'b0,l0O111OO};
          if (OI01lO00 !== l10OlIl0)
            IOOO1I01 = ~{1'b0,O1l0O100} + 1;
          else
            IOOO1I01 = {1'b0,O1l0O100};
            
          II1lO1lO = O111111l + OO10Il01 + 
                         l0IOIO11 + IOOO1I01;
  
          // Processing after addition
          IO1110IO = II1lO1lO[(`DW_Il1II1Il-2)+1];      
          if (IO1110IO === 1) 
            OIOOl1OI = ~II1lO1lO[(`DW_Il1II1Il-2):0] + 1;
          else
            OIOOl1OI = II1lO1lO[(`DW_Il1II1Il-2):0];
          OIOOl1OI[0] = 1'b0; // eliminates the stick bit from OIOOl1OI
          I10OIO1I = (II1lO1lO !== 0)?IO1110IO ^ OI01lO00:0;
  
          if (OIOOl1OI[(`DW_Il1II1Il-2):sig_width+5] === 0 && OO1llIO1 == 1'b1) 
            begin
              OIOOl1OI = I01O1OI1;
              I10OIO1I = (OIOOl1OI === 0)?0:l10OlIl0;
              I0I0110O = OI0Ol0OO;
              OO1llIO1 = 0;
            end
          else
            I0I0110O = O1O0lOOO;

          // Normalize the Mantissa for computation overflow case.
          IOIO101I = 0;
          if (OIOOl1OI[(`DW_Il1II1Il-2)] === 1)
            begin
              I0I0110O = I0I0110O + 1;
              IOIO101I = OIOOl1OI[`DW_OO10OOO1];
              OIOOl1OI = OIOOl1OI >> 1;
              OIOOl1OI[`DW_OO10OOO1] = OIOOl1OI[`DW_OO10OOO1] | IOIO101I;
            end
          if (OIOOl1OI[(`DW_Il1II1Il-2)-1] === 1)
            begin
              I0I0110O = I0I0110O + 1;
              IOIO101I = OIOOl1OI[`DW_OO10OOO1];
              OIOOl1OI = OIOOl1OI >> 1;
              OIOOl1OI[`DW_OO10OOO1] = OIOOl1OI[`DW_OO10OOO1] | IOIO101I;
            end
          if (OIOOl1OI[(`DW_Il1II1Il-2)-2] === 1)
            begin
              I0I0110O = I0I0110O + 1;
              IOIO101I = OIOOl1OI[`DW_OO10OOO1];
              OIOOl1OI = OIOOl1OI >> 1;
              OIOOl1OI[`DW_OO10OOO1] = OIOOl1OI[`DW_OO10OOO1] | IOIO101I;
            end

          // Normalize the Mantissa for leading zero case.
            while ( (OIOOl1OI[(`DW_Il1II1Il-2)-3] === 0) && (I0I0110O > (({exp_width{1'b1}}>>1))) )
              begin
                I0I0110O = I0I0110O - 1;
                OIOOl1OI = OIOOl1OI << 1;
              end
          // This right shift operation is done for denormal values only
            while ( (OIOOl1OI !== 0) && (I0I0110O <= (({exp_width{1'b1}}>>1))) && 
                    (ieee_compliance == 1) )
              begin
                I0I0110O = I0I0110O + 1;
                IOIO101I = OIOOl1OI[`DW_OO10OOO1] | IOIO101I;
                OIOOl1OI = OIOOl1OI >> 1;
              end
 
          // Round OIOOl1OI according to the rounding mode (rnd).
            Il110l11 = OIOOl1OI[((`DW_Il1II1Il-2)-3-sig_width)];
            Il001001 = OIOOl1OI[(((`DW_Il1II1Il-2)-3-sig_width) - 1)];
            O0l10OOI = |OIOOl1OI[(((`DW_Il1II1Il-2)-3-sig_width) - 1)-1:0] | OIlOO101 | l01010ll | OO1llIO1 | IOIO101I;
            l1000O1I = Ol1l110O(rnd, I10OIO1I, Il110l11, Il001001, O0l10OOI);
            if (l1000O1I[0] === 1) OIOOl1OI = OIOOl1OI + (1<<((`DW_Il1II1Il-2)-3-sig_width));
            // Normalize the Mantissa for overflow case after rounding.
            if ( (OIOOl1OI[(`DW_Il1II1Il-2)-2] === 1) )
              begin
                I0I0110O = I0I0110O + 1;
                OIOOl1OI = OIOOl1OI >> 1;
              end

          // test if the output of the rounding unit is still not normalized
            if (OIOOl1OI[(`DW_Il1II1Il-2):(`DW_Il1II1Il-2)-3] === 0 || I0I0110O <= ({exp_width{1'b1}}>>1))
              if (ieee_compliance == 1) 
                begin
                  OIl1001l = {I10OIO1I,{exp_width{1'b0}}, OIOOl1OI[((`DW_Il1II1Il-2)-4):((`DW_Il1II1Il-2)-3-sig_width)]};
                  l0Ol0OOI[5] = l1000O1I[1];
                  l0Ol0OOI[3] = l1000O1I[1] | 
                                                (OIOOl1OI[(`DW_Il1II1Il-2):((`DW_Il1II1Il-2)-3-sig_width)] != 0);
                  if (OIOOl1OI[((`DW_Il1II1Il-2)-4):((`DW_Il1II1Il-2)-3-sig_width)] == 0) 
                    begin
                      l0Ol0OOI[0] = 1; 
                      if (~l1000O1I[1])
                        begin
                          if (rnd == 3)
                            OIl1001l[(exp_width + sig_width)] = 1;
                          else
                            OIl1001l[(exp_width + sig_width)] = 0;
                        end
                    end
                end
              else // when denormal is not used --> becomes zero or minFP
                begin
                  l0Ol0OOI[5] = l1000O1I[1] | 
                                                (OIOOl1OI[(`DW_Il1II1Il-2):((`DW_Il1II1Il-2)-3-sig_width)] != 0);
                  l0Ol0OOI[3] = l0Ol0OOI[5];
                  if (((rnd == 2 & ~I10OIO1I) | 
                       (rnd == 3 & I10OIO1I) | 
                       (rnd == 5)) & (OIOOl1OI[(`DW_Il1II1Il-2):((`DW_Il1II1Il-2)-3-sig_width)] != 0))
                    begin // minnorm
                      OIl1001l = {I10OIO1I,{exp_width-1{1'b0}},{1'b1},{sig_width{1'b0}}};
                      l0Ol0OOI[0] = 0;
                    end
                  else
                    begin // zero
                      l0Ol0OOI[0] = 1;
                      if (l0Ol0OOI[5])
                        OIl1001l = {I10OIO1I,{exp_width{1'b0}}, {sig_width{1'b0}}};
                      else
                        // result is an exact zero -- use simple rule
                        begin
                          OIl1001l = 0;
                          if (rnd === 3)
                            OIl1001l[(exp_width + sig_width)] = 1;
                          else
                            OIl1001l[(exp_width + sig_width)] = 0;
                        end
                    end
                end
            else
              begin
                //
                // Huge
                //
                if (I0I0110O >= ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})+({exp_width{1'b1}}>>1))
                  begin
                    l0Ol0OOI[4] = 1;
                    l0Ol0OOI[5] = 1;
                    if(l1000O1I[2] === 1)
                      begin
                        // Infinity
                        OIOOl1OI[((`DW_Il1II1Il-2)-4):((`DW_Il1II1Il-2)-3-sig_width)] = 0;
                        I0I0110O = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
                        l0Ol0OOI[1] = 1;
                      end
                    else
                      begin
                        // MaxNorm
                        I0I0110O = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}) - 1;
                        OIOOl1OI[((`DW_Il1II1Il-2)-4):((`DW_Il1II1Il-2)-3-sig_width)] = -1;
                      end
                  end
                else
                  I0I0110O = I0I0110O - ({exp_width{1'b1}}>>1);
                //
                // Normal  (continued)
                //
                l0Ol0OOI[5] = l0Ol0OOI[5] | 
                                              l1000O1I[1];
                // Reconstruct the floating point format.
                OIl1001l = {I10OIO1I,I0I0110O[exp_width-1:0],OIOOl1OI[((`DW_Il1II1Il-2)-4):((`DW_Il1II1Il-2)-3-sig_width)]};
              end //  result is normal value 
        end  // addition of products
    end  // valid operations
  end  // normal inputs
end

assign status = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(d ^ d) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? {8'bx} : ((arch_type === 1)?O10O0I1O:l0Ol0OOI);
assign z = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(d ^ d) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? {sig_width+exp_width+1{1'bx}} : ((arch_type === 1)?OO0IOOll:OIl1001l);

 // synopsys translate_on

endmodule

