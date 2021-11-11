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
// AUTHOR:    Alexandre Tenca, October 2006
//
// VERSION:   Verilog Simulation Model for DW_fp_dp3
//
// DesignWare_version: e30a732a
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT: Floating-point Three-term Dot-product
//           Computes the sum of products of FP numbers. For this component,
//           three products are considered. Given the FP inputs a, b, c, d, e
//           and f, it computes the FP output z = a*b + c*d + e*f. 
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
//              sig_width       significand f,  2 to 253 bits
//              exp_width       exponent e,     3 to 31 bits
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
//              rnd             3 bits
//                              rounding mode
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number result that corresponds
//                              to a*b+c*d+e*f
//              status          byte
//                              info about FP results
//
// MODIFIED:
//         11/09/07: AFT - Includes modifications to deal with the sign of zeros
//                   according to specification regarding the addition. (A-SP1)
//         04/07/08 - AFT : included a new parameter (arch_type) to control
//                   the use of alternative architecture with IFP blocks
//         04/21/08 - AFT : fixed some cases when the infinity status bit 
//                    should be set with invalid bit (ieee_compliance = 0)
//           1/2009 - AFT - extended the coverage of arch_type to include the
//                    case when ieee_compliance = 1
//           4/2012 - AFT - sign of zero when all the products are zero is not 
//                    properly set when ieee_compliance=0 and rnd=3
//
//-------------------------------------------------------------------------------
module DW_fp_dp3 (a, b, c, d, e, f, rnd, z, status);
parameter sig_width=23;
parameter exp_width=8;
parameter ieee_compliance=0;                    
parameter arch_type=0;

// declaration of inputs and outputs
input  [sig_width+exp_width:0] a,b,c,d,e,f;
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




function [4-1:0] OI101IO0;

  input [2:0] l1OII0l0;
  input [0:0] Oll0O0O0;
  input [0:0] O1I1OOOl,O0000l0O,OIO1I10O;


  begin
  OI101IO0[0] = 0;
  OI101IO0[1] = O0000l0O|OIO1I10O;
  OI101IO0[2] = 0;
  OI101IO0[3] = 0;
  if ($time > 0)
  case (l1OII0l0)
    3'b000:
    begin
      OI101IO0[0] = O0000l0O&(O1I1OOOl|OIO1I10O);
      OI101IO0[2] = 1;
      OI101IO0[3] = 0;
    end
    3'b001:
    begin
      OI101IO0[0] = 0;
      OI101IO0[2] = 0;
      OI101IO0[3] = 0;
    end
    3'b010:
    begin
      OI101IO0[0] = ~Oll0O0O0 & (O0000l0O|OIO1I10O);
      OI101IO0[2] = ~Oll0O0O0;
      OI101IO0[3] = ~Oll0O0O0;
    end
    3'b011:
    begin
      OI101IO0[0] = Oll0O0O0 & (O0000l0O|OIO1I10O);
      OI101IO0[2] = Oll0O0O0;
      OI101IO0[3] = Oll0O0O0;
    end
    3'b100:
    begin
      OI101IO0[0] = O0000l0O;
      OI101IO0[2] = 1;
      OI101IO0[3] = 0;
    end
    3'b101:
    begin
      OI101IO0[0] = O0000l0O|OIO1I10O;
      OI101IO0[2] = 1;
      OI101IO0[3] = 1;
    end
    default:
      $display("Error! illegal rounding mode.\n");
  endcase
  end

endfunction


// definitions used in the code


reg [8    -1:0] OIOO0Il0;
reg [(exp_width + sig_width):0] O1I1O1II;
reg O10O0O01,I0000OlI,OIO1I10O,I1I010Ol,I10O1l00,O100O1O1,O111II00,I110l0O1;
reg [exp_width-1:0] l11O10O1,l0IO00OO,OIl11l11,lO0IIIl1,OO1I01Il,l110001O; 
reg [sig_width-1:0] O111lO00,OOO110l0,OOl0lO0I,OllI0I00,OO1lI100,IO00IO1O;
reg [sig_width:0] I10I1101,O01O0O01,I011IIO1,Ol1I1I10,IO1I0II1,IOOIOOO1;
reg I1lOI000,l01O0I00,IOO10O10,O11l0101,Ill0lIII,I01l0ll0;
reg lII1l0O0,I01I1O10,Ol0OIl01,OOl0I01I,l1l101l1,I011O1O1;
reg O000O1lI,I00OO11l,IOO0O00I,I1I00O1I,O0OO1O11,OI011II1;
reg O1l100O0,Ol01000O,Ol11lO0O,OO011O10,OlO0OIO0,OOl0OI0l;
reg [2*sig_width+1:0] O01l0IIl, OII01I10,l11I110l;
reg [(2*(sig_width+1)+1+(sig_width+5)):0] OIl1IIl0, ll1IIOll;
reg [(2*(sig_width+1)+1+(sig_width+5)):0] l101O0I1;
reg [exp_width:0] OO0l1OOO, lI11OO01,l0I0lIOl;
reg IO01OOO1, O1O0llI1, ll0Il11O;
reg [exp_width-1:0] O00ll0l1;
reg [exp_width-1:0] I1OOOO01;
reg [exp_width+1:0] Ol1O00ll;                     // biggest exponent
reg [exp_width:0] ll0OO0lO,O1OOII1O;
reg [exp_width:0] lO10lI00,OOIO0000,l1Ol01I0;    // Exponents.
reg [exp_width:0] IOIOOlOO;
reg [(2*(sig_width+1)+1+(sig_width+5)):0] O0I10110,l00OO00O,I1O1l111;   // Mantissa vectors
reg [(2*(sig_width+1)+1+(sig_width+5)):0] OO0OlO0l;
reg I1lI1IOO,OIOO1OI0,O0O000ll;           // signs
reg OO11IlIl;
reg [(2*(sig_width+1)+1+(sig_width+5)):0] O00O00lO, l01OIO1I;
reg [(2*(sig_width+1)+1+(sig_width+5))+1:0] lI011O0I,l0O01OII;
reg [(2*(sig_width+1)+1+(sig_width+5))+1:0] l11101IO;        // Internal adder output
reg I10000OO;
reg O1IO111I;
reg [(2*(sig_width+1)+1+(sig_width+5)):0] l1110O1O;                   // Mantissa vector
reg [4-1:0] IO1OIO0O;             // The values returned by OI101IO0 function.
reg [(exp_width + sig_width + 1)-1:0] OO1O1lO1;                 // NaN FP number
reg [(exp_width + sig_width + 1)-1:0] IO001OOO;               // plus infinity
reg [(exp_width + sig_width + 1)-1:0] O0I110O0;                // negative infinity
reg [(exp_width + sig_width + 1)-1:0] IOOO1l10;              // plus zero
reg [(exp_width + sig_width + 1)-1:0] I11I10OO;               // negative zero
reg O001lI00, I1I01OI1, OOO0O000;
reg I0l1I11l, O0O00I1I, OOO0OI11;
reg OOI1OI11, lIO0OlI1, l01O1OI0;
reg IO1OI101, O1I00111, I01O00O0, IOOI00O1, l1O10O11, OO00OOl1;
reg IO0Il1I0;

//---------------------------------------------------------------
// The following portion of the code describes DW_fp_dp2 when
// arch_type = 1
//---------------------------------------------------------------


wire [sig_width+exp_width : 0] O1l11O01;
wire [7 : 0] O0l0OO10;

wire [sig_width+2+exp_width+6:0] llI00I11;
wire [sig_width+2+exp_width+6:0] O0O0O01O;
wire [sig_width+2+exp_width+6:0] lO0lII11; 
wire [sig_width+2+exp_width+6:0] O01OO010;
wire [sig_width+2+exp_width+6:0] l0l01101;
wire [sig_width+2+exp_width+6:0] O100l11O;
wire [2*(sig_width+2+1)+exp_width+1+6:0] II00010O; // partial products
wire [2*(sig_width+2+1)+exp_width+1+6:0] O1OO1Il0; 
wire [2*(sig_width+2+1)+1+exp_width+1+1+6:0] O11OO010; 
wire [2*(sig_width+2+1)+1+exp_width+1+1+6:0] O0OI0011; // result of p1+p2
wire [2*(sig_width+2+1)+1+1+exp_width+1+1+1+6:0] OO1IO1ll; // result of p1+p2+p3



  // Instances of DW_fp_ifp_conv  -- format converters
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U1 ( .a(a), .z(llI00I11) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U2 ( .a(b), .z(O0O0O01O) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U3 ( .a(c), .z(lO0lII11) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U4 ( .a(d), .z(O01OO010) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U5 ( .a(e), .z(l0l01101) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U6 ( .a(f), .z(O100l11O) );
  // Instances of DW_ifp_mult
    DW_ifp_mult #(sig_width+2, exp_width, 2*(sig_width+2+1), exp_width+1)
	  U7 ( .a(llI00I11), .b(O0O0O01O), .z(II00010O) );
    DW_ifp_mult #(sig_width+2, exp_width, 2*(sig_width+2+1), exp_width+1)
	  U8 ( .a(lO0lII11), .b(O01OO010), .z(O1OO1Il0) );
    DW_ifp_mult #(sig_width+2, exp_width, 2*(sig_width+2+1)+1, exp_width+1+1)
	  U9 ( .a(l0l01101), .b(O100l11O), .z(O11OO010) );
   // Instances of DW_ifp_addsub
    DW_ifp_addsub #(2*(sig_width+2+1), exp_width+1, 2*(sig_width+2+1)+1, exp_width+1+1, ieee_compliance)
	  U10 ( .a(II00010O), .b(O1OO1Il0), .op(1'b0), .rnd(rnd),
               .z(O0OI0011) );
    DW_ifp_addsub #(2*(sig_width+2+1)+1, exp_width+1+1, 2*(sig_width+2+1)+1+1, exp_width+1+1+1, ieee_compliance)
	  U11 ( .a(O0OI0011), .b(O11OO010), .op(1'b0), .rnd(rnd),
               .z(OO1IO1ll) );
  // Instance of DW_ifp_fp_conv  -- format converter
    DW_ifp_fp_conv #(2*(sig_width+2+1)+1+1, exp_width+1+1+1, sig_width, exp_width, ieee_compliance)
          U12 ( .a(OO1IO1ll), .rnd(rnd), .z(O1l11O01), .status(O0l0OO10) );

//-------------------------------------------------------------------
// The following code is used to describe the DW_fp_dp2 component
// when arch_type = 0
//-------------------------------------------------------------------
always @(a or b or c or d or e or f or rnd)
begin
  // setup special values
  I1OOOO01 = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
  O00ll0l1 = 1;
  OO1O1lO1 = {1'b0,{exp_width{1'b1}},{sig_width{1'b0}}};
  // mantissa of NaN is 1 when ieee_compliance = 1
  OO1O1lO1[0] = ieee_compliance; 
  IO001OOO = {1'b0,I1OOOO01,{sig_width{1'b0}}};
  O0I110O0 = {1'b1,I1OOOO01,{sig_width{1'b0}}};
  IOOO1l10 = 0;
  I11I10OO = {1'b1,{sig_width+exp_width{1'b0}}};
  OIOO0Il0 = 0;

  // extract exponent and significand from inputs
  l11O10O1 = a[((exp_width + sig_width) - 1):sig_width];
  l0IO00OO = b[((exp_width + sig_width) - 1):sig_width];
  OIl11l11 = c[((exp_width + sig_width) - 1):sig_width];
  lO0IIIl1 = d[((exp_width + sig_width) - 1):sig_width];
  OO1I01Il = e[((exp_width + sig_width) - 1):sig_width];
  l110001O = f[((exp_width + sig_width) - 1):sig_width];
  O111lO00 = a[(sig_width - 1):0];
  OOO110l0 = b[(sig_width - 1):0];
  OOl0lO0I = c[(sig_width - 1):0];
  OllI0I00 = d[(sig_width - 1):0];
  OO1lI100 = e[(sig_width - 1):0];
  IO00IO1O = f[(sig_width - 1):0];
  I1lOI000 = a[(exp_width + sig_width)];
  l01O0I00 = b[(exp_width + sig_width)];
  IOO10O10 = c[(exp_width + sig_width)];
  O11l0101 = d[(exp_width + sig_width)];
  Ill0lIII = e[(exp_width + sig_width)];
  I01l0ll0 = f[(exp_width + sig_width)];

  // determine special input values and perform adjustments in internal
  // mantissa values
  lII1l0O0 = ((l11O10O1 === 0) && ((O111lO00 === 0) || (ieee_compliance === 0)));
  I01I1O10 = ((l0IO00OO === 0) && ((OOO110l0 === 0) || (ieee_compliance === 0)));
  Ol0OIl01 = ((OIl11l11 === 0) && ((OOl0lO0I === 0) || (ieee_compliance === 0)));
  OOl0I01I = ((lO0IIIl1 === 0) && ((OllI0I00 === 0) || (ieee_compliance === 0)));
  l1l101l1 = ((OO1I01Il === 0) && ((OO1lI100 === 0) || (ieee_compliance === 0)));
  I011O1O1 = ((l110001O === 0) && ((IO00IO1O === 0) || (ieee_compliance === 0)));
  O111lO00 = (lII1l0O0)?0:O111lO00;
  OOO110l0 = (I01I1O10)?0:OOO110l0;
  OOl0lO0I = (Ol0OIl01)?0:OOl0lO0I;
  OllI0I00 = (OOl0I01I)?0:OllI0I00;
  OO1lI100 = (l1l101l1)?0:OO1lI100;
  IO00IO1O = (I011O1O1)?0:IO00IO1O;
  // detect infinity inputs
  O000O1lI = ((l11O10O1 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((O111lO00 === 0)||(ieee_compliance === 0)));
  I00OO11l = ((l0IO00OO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((OOO110l0 === 0)||(ieee_compliance === 0)));
  IOO0O00I = ((OIl11l11 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((OOl0lO0I === 0)||(ieee_compliance === 0)));
  I1I00O1I = ((lO0IIIl1 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((OllI0I00 === 0)||(ieee_compliance === 0)));
  O0OO1O11 = ((OO1I01Il === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((OO1lI100 === 0)||(ieee_compliance === 0)));
  OI011II1 = ((l110001O === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&((IO00IO1O === 0)||(ieee_compliance === 0)));
  O111lO00 = (O000O1lI)?0:O111lO00;
  OOO110l0 = (I00OO11l)?0:OOO110l0;
  OOl0lO0I = (IOO0O00I)?0:OOl0lO0I;
  OllI0I00 = (I1I00O1I)?0:OllI0I00;
  OO1lI100 = (O0OO1O11)?0:OO1lI100;
  IO00IO1O = (OI011II1)?0:IO00IO1O;
  // detect nan inputs
  O1l100O0 = ((l11O10O1 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(O111lO00 !== 0)&&(ieee_compliance === 1));
  Ol01000O = ((l0IO00OO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(OOO110l0 !== 0)&&(ieee_compliance === 1));
  Ol11lO0O = ((OIl11l11 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(OOl0lO0I !== 0)&&(ieee_compliance === 1));
  OO011O10 = ((lO0IIIl1 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(OllI0I00 !== 0)&&(ieee_compliance === 1));
  OlO0OIO0 = ((OO1I01Il === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(OO1lI100 !== 0)&&(ieee_compliance === 1));
  OOl0OI0l = ((l110001O === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}))&&(IO00IO1O !== 0)&&(ieee_compliance === 1));

  if ((l11O10O1 === 0) && (O111lO00 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      I10I1101 = {1'b0,O111lO00};
      IO1OI101 = 1;
      l11O10O1[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (l11O10O1 === 0) 
        I10I1101 = 0;
      else
        I10I1101 = {1'b1,O111lO00};
      IO1OI101 = 0;      
    end
  if ((l0IO00OO === 0) && (OOO110l0 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      O01O0O01 = {1'b0,OOO110l0};
      O1I00111 = 1;
      l0IO00OO[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (l0IO00OO === 0) 
        O01O0O01 = 0;
      else
        O01O0O01 = {1'b1,OOO110l0};
      O1I00111 = 0;      
    end
  if ((OIl11l11 === 0) && (OOl0lO0I != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      I011IIO1 = {1'b0,OOl0lO0I};
      I01O00O0 = 1;
      OIl11l11[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (OIl11l11 === 0) 
        I011IIO1 = 0;
      else
        I011IIO1 = {1'b1,OOl0lO0I};
      I01O00O0 = 0;      
    end
  if ((lO0IIIl1 === 0) && (OllI0I00 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      Ol1I1I10 = {1'b0,OllI0I00};
      IOOI00O1 = 1;
      lO0IIIl1[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (lO0IIIl1 === 0) 
        Ol1I1I10 = 0;
      else
        Ol1I1I10 = {1'b1,OllI0I00};
      IOOI00O1 = 0;      
    end
  if ((OO1I01Il === 0) && (OO1lI100 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      IO1I0II1 = {1'b0,OO1lI100};
      l1O10O11 = 1;
      OO1I01Il[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (OO1I01Il === 0) 
        IO1I0II1 = 0;
      else
        IO1I0II1 = {1'b1,OO1lI100};
      l1O10O11 = 0;      
    end
  if ((l110001O === 0) && (IO00IO1O != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      IOOIOOO1 = {1'b0,IO00IO1O};
      OO00OOl1 = 1;
      l110001O[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (l110001O === 0) 
        IOOIOOO1 = 0;
      else
        IOOIOOO1 = {1'b1,IO00IO1O};
      OO00OOl1 = 0;      
    end

  if (l11O10O1 === 0 || l0IO00OO === 0)
    OO0l1OOO = 0;
  else
    OO0l1OOO = {1'b0,l11O10O1} + {1'b0,l0IO00OO};
  if (OIl11l11 === 0 || lO0IIIl1 === 0)
    lI11OO01 = 0;
  else
    lI11OO01 = {1'b0,OIl11l11} + {1'b0,lO0IIIl1};
  if (OO1I01Il === 0 || l110001O === 0)
    l0I0lIOl = 0;
  else
    l0I0lIOl = {1'b0,OO1I01Il} + {1'b0,l110001O};
  
  OOI1OI11 = (lII1l0O0 | I01I1O10);
  lIO0OlI1 = (Ol0OIl01 | OOl0I01I);
  l01O1OI0 = (l1l101l1 | I011O1O1);

  // Identify and treat special input values

  // Rule 1.
  if (O1l100O0 || Ol01000O || Ol11lO0O || OO011O10 || OlO0OIO0 || OOl0OI0l)
    begin
      // one of the inputs is a NAN       --> the output must be an NAN
      O1I1O1II = OO1O1lO1;
      OIOO0Il0[2] = 1;
    end

  else if (((O000O1lI && I01I1O10) ||  // a=inf and b=0
	    (I00OO11l && lII1l0O0) ||  // b=inf and a=0
	    (IOO0O00I && OOl0I01I) ||  // c=inf and d=0
	    (I1I00O1I && Ol0OIl01) ||  // d=inf and c=0
	    (O0OO1O11 && I011O1O1) ||  // e=inf and f=0
	    (OI011II1 && l1l101l1)) )  // f=inf and e=0
    begin
      O1I1O1II = OO1O1lO1;
      OIOO0Il0[2] = 1;
      OIOO0Il0[1] = (ieee_compliance == 0);
    end


  // Zero inputs 
  else if (OOI1OI11 & lIO0OlI1 & l01O1OI0)
    begin
      IO01OOO1 = (I1lOI000 ^ l01O0I00);
      O1O0llI1 = (IOO10O10 ^ O11l0101);
      ll0Il11O = (Ill0lIII ^ I01l0ll0);
      if (IO01OOO1 == O1O0llI1 && O1O0llI1 === ll0Il11O && ieee_compliance==1)
        O1I1O1II = {IO01OOO1,{sig_width+exp_width{1'b0}}};
      else
        O1I1O1II = (rnd == 3)?I11I10OO:IOOO1l10;
      OIOO0Il0[0] = 1;
    end
  
  else                                          
    begin 
    // generate the product terms
    O01l0IIl = (I10I1101 * O01O0O01);
    OII01I10 = (I011IIO1 * Ol1I1I10);
    l11I110l = (IO1I0II1 * IOOIOOO1);
    OIl1IIl0 = {2'b0,O01l0IIl,{(sig_width+5){1'b0}}};
    ll1IIOll = {2'b0,OII01I10,{(sig_width+5){1'b0}}};
    l101O0I1 = {2'b0,l11I110l,{(sig_width+5){1'b0}}};

    IO01OOO1 = (I1lOI000 ^ l01O0I00);
    O1O0llI1 = (IOO10O10 ^ O11l0101);
    ll0Il11O = (Ill0lIII ^ I01l0ll0);

    // the following variables are used to keep track of invalid operations
    I0l1I11l = ((O000O1lI & I01I1O10) | (I00OO11l & lII1l0O0));
    O0O00I1I = ((IOO0O00I & OOl0I01I) | (I1I00O1I & Ol0OIl01));
    OOO0OI11 = ((O0OO1O11 & I011O1O1) | (OI011II1 & l1l101l1));
    IO0Il1I0 = I0l1I11l | O0O00I1I | OOO0OI11;
    OOI1OI11 = (lII1l0O0 | I01I1O10) & ~I0l1I11l;
    lIO0OlI1 = (Ol0OIl01 | OOl0I01I) & ~O0O00I1I;
    l01O1OI0 = (l1l101l1 | I011O1O1) & ~OOO0OI11;
   
    if (IO0Il1I0 || (OOI1OI11 & lIO0OlI1 & l01O1OI0))
      begin
        if (IO0Il1I0)
          begin
            OIOO0Il0[2] = 1;
            OIOO0Il0[1] = (ieee_compliance == 0);
            O1I1O1II = OO1O1lO1;                  // NaN
          end
        else
          begin
            O1I1O1II = 0;
            OIOO0Il0[0] = 1;
          end      
      end
    else

      begin // valid operations 
      while ( (OIl1IIl0[(2*(sig_width+1)+1+(sig_width+5))-2] === 0) && (|OO0l1OOO !== 0) )
        begin
          OO0l1OOO = OO0l1OOO - 1;
          OIl1IIl0 = OIl1IIl0 << 1;
        end
      while ( (ll1IIOll[(2*(sig_width+1)+1+(sig_width+5))-2] === 0) && (|lI11OO01 !== 0) )
        begin
          lI11OO01 = lI11OO01 - 1;
          ll1IIOll = ll1IIOll << 1;
        end
      while ( (l101O0I1[(2*(sig_width+1)+1+(sig_width+5))-2] === 0) && (|l0I0lIOl !== 0) )
        begin
          l0I0lIOl = l0I0lIOl - 1;
          l101O0I1 = l101O0I1 << 1;
        end
 
      O001lI00 = 0;
      I1I01OI1 = 0;
      OOO0O000 = 0;
      if (O000O1lI || I00OO11l)
        O001lI00 = 1;
      if (IOO0O00I || I1I00O1I)
        I1I01OI1 = 1;
      if (O0OO1O11 || OI011II1)
        OOO0O000 = 1;
      if (O001lI00 === 1 || I1I01OI1 === 1 || OOO0O000 === 1)
        begin
          OIOO0Il0[1] = 1;
          OIOO0Il0[5] = ~(O000O1lI | I00OO11l | IOO0O00I | I1I00O1I |
                                          O0OO1O11 | OI011II1);
          OIOO0Il0[4] = ~(O000O1lI | I00OO11l | IOO0O00I | I1I00O1I |
                                          O0OO1O11 | OI011II1);
          O1I1O1II = IO001OOO;
          O1I1O1II[(exp_width + sig_width)] = O001lI00 & IO01OOO1 | I1I01OI1 & O1O0llI1 |
                             OOO0O000 & ll0Il11O;
          // Watch out for Inf-Inf !
          if ( (O001lI00 === 1 && I1I01OI1 === 1 && IO01OOO1 !== O1O0llI1)|| 
               (O001lI00 === 1 && OOO0O000 === 1 && IO01OOO1 !== ll0Il11O)|| 
               (I1I01OI1 === 1 && OOO0O000 === 1 && O1O0llI1 !== ll0Il11O) )
            begin
              OIOO0Il0[2] = 1;
              OIOO0Il0[1] = (ieee_compliance == 0);
              OIOO0Il0[4] = 0;
              OIOO0Il0[5] = 0;
              O1I1O1II = OO1O1lO1;                  // NaN
            end
        end

      else
        begin
          if ({IO01OOO1,OO0l1OOO,OIl1IIl0} == 
              {~O1O0llI1,lI11OO01,ll1IIOll})
             begin
               OO0l1OOO = 0;
               OIl1IIl0 = 0;
               lI11OO01 = 0;
               ll1IIOll = 0;
             end
          if ({IO01OOO1,OO0l1OOO,OIl1IIl0} == 
              {~ll0Il11O,l0I0lIOl,l101O0I1})
             begin
               OO0l1OOO = 0;
               OIl1IIl0 = 0;
               l0I0lIOl = 0;
               l101O0I1 = 0;
             end
          if ({O1O0llI1,lI11OO01,ll1IIOll} == 
              {~ll0Il11O,l0I0lIOl,l101O0I1})
             begin
               lI11OO01 = 0;
               ll1IIOll = 0;
               l0I0lIOl = 0;
               l101O0I1 = 0;
             end

          O10O0O01 = 0;
          if ({lI11OO01,ll1IIOll} < {l0I0lIOl,l101O0I1})
            O10O0O01 = 1;
          if (O10O0O01 === 1)
            begin
              IOIOOlOO = l0I0lIOl;
              OO0OlO0l = l101O0I1;
              OO11IlIl = ll0Il11O;
              l1Ol01I0 = lI11OO01;
              I1O1l111 = ll1IIOll;
              O0O000ll = O1O0llI1;
            end
          else
            begin
              IOIOOlOO = lI11OO01;
              OO0OlO0l = ll1IIOll;
              OO11IlIl = O1O0llI1;
              l1Ol01I0 = l0I0lIOl;
              I1O1l111 = l101O0I1;
              O0O000ll = ll0Il11O;
            end
          I0000OlI = 0;
          if  ({OO0l1OOO,OIl1IIl0} < {IOIOOlOO,OO0OlO0l})
            I0000OlI = 1;
          if (I0000OlI === 1) 
            begin   
              lO10lI00 = IOIOOlOO;
              O0I10110 = OO0OlO0l;
              I1lI1IOO = OO11IlIl;
              OOIO0000 = OO0l1OOO;
              l00OO00O = OIl1IIl0;
              OIOO1OI0 = IO01OOO1;
            end   
          else
            begin
              lO10lI00 = OO0l1OOO;
              O0I10110 = OIl1IIl0;
              I1lI1IOO = IO01OOO1;
              OOIO0000 = IOIOOlOO;
              l00OO00O = OO0OlO0l;
              OIOO1OI0 = OO11IlIl;
            end

          I1I010Ol = 0;
          ll0OO0lO = lO10lI00 - OOIO0000;
          O00O00lO = l00OO00O;
          while ( (|O00O00lO !== 0) && (|ll0OO0lO !== 0) )
            begin
              I1I010Ol = O00O00lO[0] | I1I010Ol;
              O00O00lO = O00O00lO >> 1;
              ll0OO0lO = ll0OO0lO - 1;
            end
          O00O00lO[0] = O00O00lO[0] | I1I010Ol;
          I1I010Ol = O00O00lO[0];
          I10O1l00 = 0;
          O1OOII1O = lO10lI00 - l1Ol01I0;
          l01OIO1I = I1O1l111;
          while ( (|l01OIO1I !== 0) && (|O1OOII1O !== 0) )
            begin
              I10O1l00 = l01OIO1I[0] | I10O1l00;
              l01OIO1I = l01OIO1I >> 1;
              O1OOII1O = O1OOII1O - 1;
            end
          l01OIO1I[0] = l01OIO1I[0] | I10O1l00;
          I10O1l00 = l01OIO1I[0];

          if (I1I010Ol && I10O1l00)
            if ({OOIO0000,l00OO00O} < {l1Ol01I0,I1O1l111})
              O00O00lO[0] = 0;
            else
              l01OIO1I[0] = 0;

          if (I1lI1IOO !== OIOO1OI0) 
            lI011O0I = ~{1'b0,O00O00lO} + 1;
          else
            lI011O0I = {1'b0,O00O00lO};
          if (I1lI1IOO !== O0O000ll)
            l0O01OII = ~{1'b0,l01OIO1I} + 1;
          else
            l0O01OII = {1'b0,l01OIO1I};
            
          l11101IO = {1'b0,O0I10110} + lI011O0I + l0O01OII;
  
          I10000OO = l11101IO[(2*(sig_width+1)+1+(sig_width+5))+1];      
          if (I10000OO === 1) 
            l1110O1O = ~l11101IO[(2*(sig_width+1)+1+(sig_width+5)):0] + 1;
          else
            l1110O1O = l11101IO[(2*(sig_width+1)+1+(sig_width+5)):0];
          O1IO111I = (l11101IO !== 0)?I10000OO ^ I1lI1IOO:0;
  
          Ol1O00ll = {1'b0, lO10lI00};

          O100O1O1 = 0;
          if (l1110O1O[(2*(sig_width+1)+1+(sig_width+5))] === 1)
            begin
              Ol1O00ll = Ol1O00ll + 1;
              O100O1O1 = l1110O1O[0];
              l1110O1O = l1110O1O >> 1;
              l1110O1O[0] = l1110O1O[0] | O100O1O1;
            end
          if (l1110O1O[(2*(sig_width+1)+1+(sig_width+5))-1] === 1)
            begin
              Ol1O00ll = Ol1O00ll + 1;
              O100O1O1 = l1110O1O[0];
              l1110O1O = l1110O1O >> 1;
              l1110O1O[0] = l1110O1O[0] | O100O1O1;
            end
          if (l1110O1O[(2*(sig_width+1)+1+(sig_width+5))-2] === 1)
            begin
              Ol1O00ll = Ol1O00ll + 1;
              O100O1O1 = l1110O1O[0];
              l1110O1O = l1110O1O >> 1;
              l1110O1O[0] = l1110O1O[0] | O100O1O1;
            end

          // Normalize the Mantissa for leading zero case.
            while ( (l1110O1O[(2*(sig_width+1)+1+(sig_width+5))-3] === 0) && (Ol1O00ll > (({exp_width{1'b1}}>>1)+1)) )
              begin
                Ol1O00ll = Ol1O00ll - 1;
                l1110O1O = l1110O1O << 1;
              end
  
          // This right shift operation is done for denormal values only
            while ( (l1110O1O !== 0) && (Ol1O00ll <= (({exp_width{1'b1}}>>1))) )
              begin
                Ol1O00ll = Ol1O00ll + 1;
                O100O1O1 = l1110O1O[0] | O100O1O1;
                l1110O1O = l1110O1O >> 1;
              end

          // Round l1110O1O according to the rounding mode (rnd).
            O111II00 = l1110O1O[((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)];
            I110l0O1 = l1110O1O[(((2*(sig_width+1)+1+(sig_width+5))-3-sig_width) - 1)];
            OIO1I10O = |l1110O1O[(((2*(sig_width+1)+1+(sig_width+5))-3-sig_width) - 1)-1:0] | I1I010Ol | I10O1l00 | O100O1O1;
            IO1OIO0O = OI101IO0(rnd, O1IO111I, O111II00, I110l0O1, OIO1I10O);
            if (IO1OIO0O[0] === 1) l1110O1O = l1110O1O + (1<<((2*(sig_width+1)+1+(sig_width+5))-3-sig_width));
            // Normalize the Mantissa for overflow case after rounding.
            if ( (l1110O1O[(2*(sig_width+1)+1+(sig_width+5))-2] === 1) )
              begin
                Ol1O00ll = Ol1O00ll + 1;
                l1110O1O = l1110O1O >> 1;
              end

          // test if the output of the rounding unit is still not normalized
            if (l1110O1O[(2*(sig_width+1)+1+(sig_width+5)):(2*(sig_width+1)+1+(sig_width+5))-3] === 0 || Ol1O00ll <= ({exp_width{1'b1}}>>1))
              if (ieee_compliance == 1) 
                begin
                  O1I1O1II = {O1IO111I,{exp_width{1'b0}}, l1110O1O[((2*(sig_width+1)+1+(sig_width+5))-4):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)]};
                  OIOO0Il0[5] = IO1OIO0O[1];
                  OIOO0Il0[3] = IO1OIO0O[1] | 
                                                (l1110O1O[(2*(sig_width+1)+1+(sig_width+5)):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)] != 0);
                  if (l1110O1O[((2*(sig_width+1)+1+(sig_width+5))-4):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)] == 0) 
                    begin
                      OIOO0Il0[0] = 1; 
                      if (~IO1OIO0O[1])
                        begin
                          if (rnd === 3)
                            O1I1O1II[(exp_width + sig_width)] = 1;
                          else
                            O1I1O1II[(exp_width + sig_width)] = 0;
                        end
                    end
                end
              else // when denormal is not used --> becomes zero or minFP
                begin
                  OIOO0Il0[5] = IO1OIO0O[1] | 
                                                (l1110O1O[(2*(sig_width+1)+1+(sig_width+5)):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)] != 0);
                  OIOO0Il0[3] = IO1OIO0O[1] | 
                                                (l1110O1O[(2*(sig_width+1)+1+(sig_width+5)):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)] != 0);
                  if (((rnd == 2 & ~O1IO111I) | 
                       (rnd == 3 & O1IO111I) | 
                       (rnd == 5)) & (l1110O1O[(2*(sig_width+1)+1+(sig_width+5)):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)] != 0))
                    begin  // minnorm
                      O1I1O1II = {O1IO111I,{exp_width-1{1'b0}},{1'b1},{sig_width{1'b0}}};
                      OIOO0Il0[0] = 0;
                    end
                  else
                    begin  // zero
                      OIOO0Il0[0] = 1;
                      if (OIOO0Il0[5])
                        O1I1O1II = {O1IO111I,{exp_width{1'b0}}, {sig_width{1'b0}}};
                      else
                        // result is an exact zero -- use simple rule
                        begin
                          O1I1O1II = 0;
                          if (rnd === 3)
                            O1I1O1II[(exp_width + sig_width)] = 1;
                          else
                            O1I1O1II[(exp_width + sig_width)] = 0;
                        end
                    end
                end
            else
              begin
                if (Ol1O00ll >= ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})+({exp_width{1'b1}}>>1))
                  begin
                    OIOO0Il0[4] = 1;
                    OIOO0Il0[5] = 1;
                    if(IO1OIO0O[2] === 1)
                      begin
                        // Infinity
                        l1110O1O[((2*(sig_width+1)+1+(sig_width+5))-4):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)] = 0;
                        Ol1O00ll = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
                        OIOO0Il0[1] = 1;
                      end
                    else
                      begin
                        // MaxNorm
                        Ol1O00ll = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}) - 1;
                        l1110O1O[((2*(sig_width+1)+1+(sig_width+5))-4):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)] = -1;
                      end
                  end
                else
                  Ol1O00ll = Ol1O00ll - ({exp_width{1'b1}}>>1);
                OIOO0Il0[5] = OIOO0Il0[5] | 
                                              IO1OIO0O[1];
                // Reconstruct the floating point format.
                O1I1O1II = {O1IO111I,Ol1O00ll[exp_width-1:0],l1110O1O[((2*(sig_width+1)+1+(sig_width+5))-4):((2*(sig_width+1)+1+(sig_width+5))-3-sig_width)]};
              end //  result is normal value 
        end  // addition of products
    end  // valid operations
  end  // normal inputs
end

assign status = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(d ^ d) !== 1'b0) || (^(e ^ e) !== 1'b0) || (^(f ^ f) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? {8'bx} : ((arch_type === 1)?O0l0OO10:OIOO0Il0);
assign z = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(d ^ d) !== 1'b0) || (^(e ^ e) !== 1'b0) || (^(f ^ f) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? {sig_width+exp_width+1{1'bx}} : ((arch_type === 1)?O1l11O01:O1I1O1II);

 // synopsys translate_on

endmodule

