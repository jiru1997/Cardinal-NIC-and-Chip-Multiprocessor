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
// AUTHOR:    Alexandre Tenca, September 2006
//
// VERSION:   Verilog Simulation Model for DW_fp_dp2
//
// DesignWare_version: c2b8c493
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point two-term Dot-product
//           Computes the sum of products of FP numbers. For this component,
//           two products are considered. Given the FP inputs a, b, c, and d,
//           it computes the FP output z = a*b + c*d. 
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
//              sig_width       significand size,  2 to 253 bits
//              exp_width       exponent size,     3 to 31 bits
//              ieee_compliance 0 or 1 (default 0)
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
//              rnd             3 bits
//                              rounding mode
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number result that corresponds
//                              to a*b+c*d
//              status          byte
//                              info about FP results
//
// MODIFIED:
//         10/4/06 - includes rounding for denormal values
//          5/1/07 - fixes the manipulation of sign of zero
//         11/9/07 - More fixes of sign of zeros and code cleanup (A-SP1)
//         04/07/08 - AFT : included a new parameter (arch_type) to control
//                   the use of alternative architecture with IFP blocks
//         01/2009 - AFT - fix the cases when tiny=1 and MinNorm=1 for some
//                   combination of the inputs and rounding modes.
//         12/2008 - Fixed tiny bit for the case of sub-norm before rounding
//         12/2008 - Allowed the use of denormals when arch_type=1
//
//-------------------------------------------------------------------------------
module DW_fp_dp2 (a, b, c, d, rnd, z, status);
parameter sig_width=23;             // RANGE 2 to 253 bits
parameter exp_width=8;              // RANGE 3 to 31 bits     
parameter ieee_compliance=0;        // RANGE 0 or 1                  
parameter arch_type=0;              // RANGE 0 or 1           

// declaration of inputs and outputs
input  [sig_width+exp_width:0] a,b,c,d;
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




function [4-1:0] OO0Ol01O;

  input [2:0] IlIO100I;
  input [0:0] ll000OIO;
  input [0:0] OI0l1I0O,I11O1O10,Ol101l00;


  begin
  OO0Ol01O[0] = 0;
  OO0Ol01O[1] = I11O1O10|Ol101l00;
  OO0Ol01O[2] = 0;
  OO0Ol01O[3] = 0;
  if ($time > 0)
  case (IlIO100I)
    3'b000:
    begin
      OO0Ol01O[0] = I11O1O10&(OI0l1I0O|Ol101l00);
      OO0Ol01O[2] = 1;
      OO0Ol01O[3] = 0;
    end
    3'b001:
    begin
      OO0Ol01O[0] = 0;
      OO0Ol01O[2] = 0;
      OO0Ol01O[3] = 0;
    end
    3'b010:
    begin
      OO0Ol01O[0] = ~ll000OIO & (I11O1O10|Ol101l00);
      OO0Ol01O[2] = ~ll000OIO;
      OO0Ol01O[3] = ~ll000OIO;
    end
    3'b011:
    begin
      OO0Ol01O[0] = ll000OIO & (I11O1O10|Ol101l00);
      OO0Ol01O[2] = ll000OIO;
      OO0Ol01O[3] = ll000OIO;
    end
    3'b100:
    begin
      OO0Ol01O[0] = I11O1O10;
      OO0Ol01O[2] = 1;
      OO0Ol01O[3] = 0;
    end
    3'b101:
    begin
      OO0Ol01O[0] = I11O1O10|Ol101l00;
      OO0Ol01O[2] = 1;
      OO0Ol01O[3] = 1;
    end
    default:
      $display("Error! illegal rounding mode.\n");
  endcase
  end

endfunction


// definitions used in the code


reg [8    -1:0] lOOO0IO1;
reg [(exp_width + sig_width):0] OOOlO11O;
reg I010l1OO,I0IOlI0I,Ol101l00,l10OO111,IO1lI10l,OO0I1lI1,O0I01000;
reg [exp_width-1:0] O101O0IO,llOOO1OO,OII10I11,O0ll10O0; 
reg [sig_width-1:0] I1OOO001,l000OOOl,ll01l00O,lll00O1O;
reg [sig_width:0] l11O000O,I1111l1l,l0l0O01l,O1111I11;
reg lO100lO1,O0100000,OOlI1O01,IO001011;
reg OlO11100,lOIO1l0l,O0I1OlI0,I0I0O1Ol;
reg [2*sig_width+1:0] O110Ol1O, ll01Ol11;
reg [(2*sig_width+2+2):0] O1OIO01l, ll1lIIl1;
reg [exp_width+1:0] lOIO11O0, Ol1OOI0O;
reg OO111IOO, llOl1O11;
reg [exp_width-1:0] I0I1O100;
reg [exp_width-1:0] OI11lOIl;
reg [exp_width+1:0] I1lOOO10;                     // biggest exponent
reg [exp_width:0] Ol0O1l10,lI111l0O,l101011O;       // Exponents.
reg [(2*sig_width+2+2):0] IOl11I1I,O0I0l01l;       // Mantissa vectors
reg l1OllIl0,IIII1OOO;                     // signs
reg [(2*sig_width+2+2):0] l1OO0O0I;
reg [(2*sig_width+2+2):0] O00011OI;          // Internal adder output
reg [(2*sig_width+2+2):0] IO1Ol100;                   // Mantissa vector
reg [4-1:0] I1OOII00;             // The values returned by OO0Ol01O function.
reg [(exp_width + sig_width + 1)-1:0] O0l011lO;                 // NaN FP number
reg [(exp_width + sig_width + 1)-1:0] OlIO1OI0;               // plus infinity
reg [(exp_width + sig_width + 1)-1:0] O1OI0O1I;                // negative infinity
reg [(exp_width + sig_width + 1)-1:0] IlI0OOO1;               // plus zero
reg [(exp_width + sig_width + 1)-1:0] O1O111OI;                // negative zero
reg II1O1l1I, lO100IlO;
reg O100II10, O1lIO10O;
reg l0l101O0, II10IIO0, IO1lIO11, l00OO001;
reg l0l011O1, I1011O01, O01llI11, IO100O11;

//---------------------------------------------------------------
// The following portion of the code describes DW_fp_dp2 when
// arch_type = 1
//---------------------------------------------------------------


wire [sig_width+exp_width : 0] O1Il1000;
wire [7 : 0] O00ll1lO;

wire [sig_width+2+exp_width+6:0] I0O0OIO1;
wire [sig_width+2+exp_width+6:0] OIlI1OOI;
wire [sig_width+2+exp_width+6:0] lIO1I1lO; 
wire [sig_width+2+exp_width+6:0] l1O10O11;
wire [(sig_width+2+6)+exp_width+1+6:0] l1I0O0OO, IO0OOOIO; // partial products
wire [(sig_width+2+6)+1+exp_width+1+1+6:0] I1Ol10O0; // result of p1+p2



  // Instances of DW_fp_ifp_conv  -- format converters
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U1 ( .a(a), .z(I0O0OIO1) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U2 ( .a(b), .z(OIlI1OOI) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U3 ( .a(c), .z(lIO1I1lO) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U4 ( .a(d), .z(l1O10O11) );
  // Instances of DW_ifp_mult
    DW_ifp_mult #(sig_width+2, exp_width, (sig_width+2+6), exp_width+1)
	  U5 ( .a(I0O0OIO1), .b(OIlI1OOI), .z(l1I0O0OO) );
    DW_ifp_mult #(sig_width+2, exp_width, (sig_width+2+6), exp_width+1)
	  U6 ( .a(lIO1I1lO), .b(l1O10O11), .z(IO0OOOIO) );
  // Instances of DW_ifp_addsub
    DW_ifp_addsub #((sig_width+2+6), exp_width+1, (sig_width+2+6)+1, exp_width+1+1, ieee_compliance)
	  U7 ( .a(l1I0O0OO), .b(IO0OOOIO), .op(1'b0), .rnd(rnd),
               .z(I1Ol10O0) );
  // Instance of DW_ifp_fp_conv  -- format converter
    DW_ifp_fp_conv #((sig_width+2+6)+1, exp_width+1+1, sig_width, exp_width, ieee_compliance)
          U8 ( .a(I1Ol10O0), .rnd(rnd), .z(O1Il1000), .status(O00ll1lO) );

//-------------------------------------------------------------------
// The following code is used to describe the DW_fp_dp2 component
// when arch_type = 0
//-------------------------------------------------------------------
always @(a or b or c or d or rnd)
begin
  // setup special values
  OI11lOIl = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
  I0I1O100 = 1;
  O0l011lO = {1'b0,{exp_width{1'b1}},{sig_width{1'b0}}};
  // mantissa of NaN is 1 when ieee_compliance = 1
  O0l011lO[0] = ieee_compliance; 
  OlIO1OI0 = {1'b0,OI11lOIl,{sig_width{1'b0}}};
  O1OI0O1I = {1'b1,OI11lOIl,{sig_width{1'b0}}};
  IlI0OOO1 = 0;
  O1O111OI = {1'b1,{sig_width+exp_width{1'b0}}};
  lOOO0IO1 = 0;

  // extract exponent and significand from inputs
  O101O0IO = a[((exp_width + sig_width) - 1):sig_width];
  llOOO1OO = b[((exp_width + sig_width) - 1):sig_width];
  OII10I11 = c[((exp_width + sig_width) - 1):sig_width];
  O0ll10O0 = d[((exp_width + sig_width) - 1):sig_width];
  I1OOO001 = a[(sig_width - 1):0];
  l000OOOl = b[(sig_width - 1):0];
  ll01l00O = c[(sig_width - 1):0];
  lll00O1O = d[(sig_width - 1):0];
  lO100lO1 = a[(exp_width + sig_width)];
  O0100000 = b[(exp_width + sig_width)];
  OOlI1O01 = c[(exp_width + sig_width)];
  IO001011 = d[(exp_width + sig_width)];
  I0IOlI0I = (lO100lO1 ^ O0100000) ^ (OOlI1O01 ^ IO001011);

  // build mantissas
  if ((O101O0IO === 0) && (I1OOO001 != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      l11O000O = {1'b0,I1OOO001};
      l0l101O0 = 1;
      O101O0IO[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (O101O0IO === 0) 
        l11O000O = 0;
      else
        l11O000O = {1'b1,I1OOO001};
      l0l101O0 = 0;      
    end
  if ((llOOO1OO === 0) && (l000OOOl != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      I1111l1l = {1'b0,l000OOOl};
      II10IIO0 = 1;
      llOOO1OO[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (llOOO1OO === 0) 
        I1111l1l = 0;
      else
        I1111l1l = {1'b1,l000OOOl};
      II10IIO0 = 0;      
    end
  if ((OII10I11 === 0) && (ll01l00O != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      l0l0O01l = {1'b0,ll01l00O};
      IO1lIO11 = 1;
      OII10I11[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (OII10I11 === 0) 
        l0l0O01l = 0;
      else
        l0l0O01l = {1'b1,ll01l00O};
      IO1lIO11 = 0;      
    end
  if ((O0ll10O0 === 0) && (lll00O1O != 0) && (ieee_compliance === 1)) 
    begin
      // Mantissa of denormal value
      O1111I11 = {1'b0,lll00O1O};
      l00OO001 = 1;
      O0ll10O0[0] = 1;
    end
  else
    begin
      // Mantissa for normal number
      if (O0ll10O0 === 0) 
        O1111I11 = 0;
      else
        O1111I11 = {1'b1,lll00O1O};
      l00OO001 = 0;      
    end

  OlO11100 = ((O101O0IO === 0) && ((I1OOO001 === 0) || (ieee_compliance === 0)));
  lOIO1l0l = ((llOOO1OO === 0) && ((l000OOOl === 0) || (ieee_compliance === 0)));
  O0I1OlI0 = ((OII10I11 === 0) && ((ll01l00O === 0) || (ieee_compliance === 0)));
  I0I0O1Ol = ((O0ll10O0 === 0) && ((lll00O1O === 0) || (ieee_compliance === 0)));
  l0l011O1 = ((O101O0IO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((I1OOO001 === 0) || (ieee_compliance === 0)));
  I1011O01 = ((llOOO1OO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((l000OOOl === 0) || (ieee_compliance === 0)));
  O01llI11 = ((OII10I11 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((ll01l00O === 0) || (ieee_compliance === 0)));
  IO100O11 = ((O0ll10O0 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((lll00O1O === 0) || (ieee_compliance === 0)));
  
  if (O101O0IO === 0 || llOOO1OO === 0)
    lOIO11O0 = 0;
  else
    lOIO11O0 = {2'b0,O101O0IO} + {2'b0,llOOO1OO};
  if (OII10I11 === 0 || O0ll10O0 === 0)
    Ol1OOI0O = 0;
  else
    Ol1OOI0O = {2'b0,OII10I11} + {2'b0,O0ll10O0};

  // zero products
  O100II10 = OlO11100 | lOIO1l0l;
  O1lIO10O = O0I1OlI0 | I0I0O1Ol;

  // Identify and treat special input values

  // NAN inputs (Rule 1.)
  if ((O101O0IO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (I1OOO001 != 0) && (ieee_compliance === 1)) 
    begin
      // one of the inputs is a NAN       --> the output must be an NAN
      OOOlO11O = O0l011lO;
      lOOO0IO1[2] = 1;
    end
  else if ((llOOO1OO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (l000OOOl != 0) && (ieee_compliance === 1))
    begin
      OOOlO11O = O0l011lO;
      lOOO0IO1[2] = 1;
    end
  else if ((OII10I11 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (ll01l00O != 0) && (ieee_compliance === 1)) 
    begin
      OOOlO11O = O0l011lO;
      lOOO0IO1[2] = 1;
    end
  else if ((O0ll10O0 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (lll00O1O != 0) && (ieee_compliance === 1)) 
    begin
      OOOlO11O = O0l011lO;
      lOOO0IO1[2] = 1;
    end

  else if ((l0l011O1 && lOIO1l0l) ||  // a=inf and b=0
           (I1011O01 && OlO11100) ||  // b=inf and a=0
           (O01llI11 && I0I0O1Ol) ||  // c=inf and d=0
           (IO100O11 && O0I1OlI0) )   // d=inf and c=0
    begin
      OOOlO11O = O0l011lO;
      lOOO0IO1[2] = 1;
      lOOO0IO1[1] = (ieee_compliance == 0);
    end

  // 
  //  Zero inputs
  else if (O100II10 & O1lIO10O)
    begin
      OO111IOO = (lO100lO1 ^ O0100000);
      llOl1O11 = (OOlI1O01 ^ IO001011);
      if (OO111IOO == llOl1O11)
        OOOlO11O = {OO111IOO,{sig_width+exp_width{1'b0}}};
      else
        OOOlO11O = (rnd == 3)?O1O111OI:IlI0OOO1;
      lOOO0IO1[0] = 1;
    end
  
  //
  // Normal Inputs
  //
  else                                          
    begin
    // generate the product terms
    O110Ol1O = (l11O000O * I1111l1l);
    ll01Ol11 = (l0l0O01l * O1111I11);
    O1OIO01l = {1'b0,O110Ol1O,2'b0};
    ll1lIIl1 = {1'b0,ll01Ol11,2'b0};
    OO111IOO = (lO100lO1 ^ O0100000);
    llOl1O11 = (OOlI1O01 ^ IO001011);

    II1O1l1I = 0;
    lO100IlO = 0;
    if (l0l011O1||I1011O01)
      II1O1l1I = 1;
    if (O01llI11||IO100O11) 
      lO100IlO = 1;
    if (II1O1l1I === 1 || lO100IlO === 1)
      begin
        lOOO0IO1[1] = 1;
        lOOO0IO1[4] = ~(l0l011O1|I1011O01|O01llI11|IO100O11);
        lOOO0IO1[5] =  ~(l0l011O1|I1011O01|O01llI11|IO100O11);
        OOOlO11O = OlIO1OI0;
        OOOlO11O[(exp_width + sig_width)] = (II1O1l1I === 1)?OO111IOO:llOl1O11;
        // Watch out for Inf-Inf !
        if ( (II1O1l1I === 1) && (lO100IlO === 1) && (I0IOlI0I === 1) )
          begin
            lOOO0IO1[2] = 1;
            lOOO0IO1[4] = 0;
            lOOO0IO1[5] = 0;
            OOOlO11O = O0l011lO;                  // NaN
            if (ieee_compliance === 1)
              lOOO0IO1[1] = 0;
          end
      end
    else
      begin
        while ( (O1OIO01l[(2*sig_width+2+2)-1] === 0) && (lOIO11O0 > 0) )
          begin
            lOIO11O0 = lOIO11O0 - 1;
            O1OIO01l = O1OIO01l << 1;
          end
        while ( (ll1lIIl1[(2*sig_width+2+2)-1] === 0) && (Ol1OOI0O > 0) )
          begin
            Ol1OOI0O = Ol1OOI0O - 1;
            ll1lIIl1 = ll1lIIl1 << 1;
          end

        // compute the signal that defines the large and small FP value
        I010l1OO = 0;
        if ({lOIO11O0,O1OIO01l} < {Ol1OOI0O,ll1lIIl1})
          I010l1OO = 1;
        if (I010l1OO === 1)
          begin
            Ol0O1l10 = Ol1OOI0O;
            IOl11I1I = ll1lIIl1;
            l1OllIl0 = llOl1O11;
            lI111l0O = lOIO11O0;
            O0I0l01l = O1OIO01l;
            IIII1OOO = OO111IOO;
          end
        else
          begin
            Ol0O1l10 = lOIO11O0;
            IOl11I1I = O1OIO01l;
            l1OllIl0 = OO111IOO;
            lI111l0O = Ol1OOI0O;
            O0I0l01l = ll1lIIl1;
            IIII1OOO = llOl1O11;
          end

        // Shift right by l101011O the Small number: O0I0l01l.
        l10OO111 = 0;
        l101011O = Ol0O1l10 - lI111l0O;
        l1OO0O0I = O0I0l01l;
        while ( (l1OO0O0I != 0) && (l101011O > 0) )
          begin
            l10OO111 = l1OO0O0I[0] | l10OO111;
            l1OO0O0I = l1OO0O0I >> 1;
            l101011O = l101011O - 1;
          end
        l1OO0O0I[0] = l1OO0O0I[0] | l10OO111;

        // Compute internal addition result: a +/- b
        if (I0IOlI0I === 0) O00011OI = IOl11I1I + l1OO0O0I;
        else O00011OI = IOl11I1I - l1OO0O0I;

        IO1Ol100 = O00011OI;
        // ----------------------------------------------------------
        //  Processing after addition
        // -----------------------------------------------------------
        I1lOOO10 = {1'b0, Ol0O1l10};
        //
        // Normal case after the computation.
        //
            // Normalize the Mantissa for computation overflow case.
            IO1lI10l = 0;
            if (IO1Ol100[(2*sig_width+2+2)] === 1)
              begin
                I1lOOO10 = I1lOOO10 + 1;
                IO1lI10l = IO1Ol100[0];
                IO1Ol100 = IO1Ol100 >> 1;
                IO1Ol100[0] = IO1Ol100[0] | IO1lI10l;
              end
          if (IO1Ol100[(2*sig_width+2+2)-1] === 1)
              begin
                I1lOOO10 = I1lOOO10 + 1;
                IO1lI10l = IO1Ol100[0];
                IO1Ol100 = IO1Ol100 >> 1;
                IO1Ol100[0] = IO1Ol100[0] | IO1lI10l;
              end

            // Normalize the Mantissa for leading zero case.
            if ( (I1lOOO10 > (({exp_width{1'b1}}>>1))) )
              begin
                while ( (IO1Ol100[(2*sig_width+2+2)-2] === 0) && (I1lOOO10 > (({exp_width{1'b1}}>>1))) )
                  begin
                    I1lOOO10 = I1lOOO10 - 1;
                    IO1Ol100 = IO1Ol100 << 1;
                  end
              end
            if ( ($unsigned(I1lOOO10) <= (({exp_width{1'b1}}>>1))) )
              begin
                while ( (IO1Ol100 !== 0) && ($unsigned(I1lOOO10) <= (({exp_width{1'b1}}>>1))) )
                  begin
                    I1lOOO10 = I1lOOO10 + 1;
                    IO1lI10l = IO1Ol100[0] | IO1lI10l;
                    IO1Ol100 = IO1Ol100 >> 1;
                  end
              end

            // Round IO1Ol100 according to the rounding mode (rnd).
            OO0I1lI1 = IO1Ol100[(2*sig_width+2-sig_width-2+2)];
            O0I01000 = IO1Ol100[((2*sig_width+2-sig_width-2+2) - 1)];
            Ol101l00 = |IO1Ol100[((2*sig_width+2-sig_width-2+2) - 1)-1:0] | l10OO111 | IO1lI10l;
            I1OOII00 = OO0Ol01O(rnd, l1OllIl0, OO0I1lI1, O0I01000, Ol101l00);
            if (I1OOII00[0] === 1) IO1Ol100 = IO1Ol100 + (1<<(2*sig_width+2-sig_width-2+2));
            // Normalize the Mantissa for overflow case after rounding.
            if ( (IO1Ol100[(2*sig_width+2+2)-1] === 1) )
              begin
                I1lOOO10 = I1lOOO10 + 1;
                IO1Ol100 = IO1Ol100 >> 1;
              end

            // test if the output of the rounding unit is still not normalized
            if (IO1Ol100[(2*sig_width+2+2):(2*sig_width+2+2)-2] === 0 || $unsigned(I1lOOO10) <= ({exp_width{1'b1}}>>1))
              if (ieee_compliance == 1) 
                begin
                  OOOlO11O = {l1OllIl0,{exp_width{1'b0}}, IO1Ol100[(2*sig_width+2+2)-3:(2*sig_width+2-sig_width-2+2)]};
                  lOOO0IO1[5] = I1OOII00[1];
                  lOOO0IO1[3] = I1OOII00[1] | 
                                                (IO1Ol100[(2*sig_width+2+2):(2*sig_width+2-sig_width-2+2)] != 0);
                  if (IO1Ol100[(2*sig_width+2+2)-3:(2*sig_width+2-sig_width-2+2)] == 0) 
                    begin
                      lOOO0IO1[0] = 1; 
	              if (~I1OOII00[1])
                        begin
                          if (rnd === 3)
                            OOOlO11O[(exp_width + sig_width)] = 1;
                          else
                            OOOlO11O[(exp_width + sig_width)] = 0;
                        end
                    end
                end
              else // when denormal is not used --> becomes zero or minFP
                begin
                  lOOO0IO1[5] = I1OOII00[1] | 
                                                (IO1Ol100[(2*sig_width+2+2):(2*sig_width+2-sig_width-2+2)] != 0);
                  if (((rnd == 2 & ~l1OllIl0) | 
                       (rnd == 3 & l1OllIl0) | 
                       (rnd == 5)) & (IO1Ol100[(2*sig_width+2+2):(2*sig_width+2-sig_width-2+2)] != 0))
                    begin  // minnorm
                      OOOlO11O = {l1OllIl0,{exp_width-1{1'b0}},{1'b1},{sig_width{1'b0}}};
                      lOOO0IO1[0] = 1'b0;
                      lOOO0IO1[3] = 1'b0;
                    end
                  else
                    begin  // zero
                      lOOO0IO1[0] = 1'b1;
                      lOOO0IO1[3] = lOOO0IO1[5];
                      if (lOOO0IO1[5])
                        OOOlO11O = {l1OllIl0,{exp_width{1'b0}}, {sig_width{1'b0}}};
                      else
                        // result is an exact zero -- use simple rule to set the sign
                        begin
                          OOOlO11O = 0;
                          if (rnd === 3)
                            OOOlO11O[(exp_width + sig_width)] = 1;
                          else
                            OOOlO11O[(exp_width + sig_width)] = 0;
                        end
                    end
                end
            else
              begin
                //
                // Huge
                //
                if (I1lOOO10 >= ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})+({exp_width{1'b1}}>>1))
                  begin
                    lOOO0IO1[5] = 1;
                    if(I1OOII00[2] === 1)
                      begin
                        // Infinity
                        IO1Ol100[(2*sig_width+2+2)-3:(2*sig_width+2-sig_width-2+2)] = 0;
                        I1lOOO10 = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
                        lOOO0IO1[1] = 1;
                        lOOO0IO1[4] = 1;
                     end
                    else
                      begin
                        // MaxNorm
                        I1lOOO10 = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}) - 1;
                        IO1Ol100[(2*sig_width+2+2)-3:(2*sig_width+2-sig_width-2+2)] = -1;
                        lOOO0IO1[4] = 0;
                     end
                  end
                else
                  I1lOOO10 = I1lOOO10 - ({exp_width{1'b1}}>>1);
                //
                // Normal  (continued)
                //
                lOOO0IO1[5] = lOOO0IO1[5] | I1OOII00[1];
                // Reconstruct the floating point format.
                OOOlO11O = {l1OllIl0,I1lOOO10[exp_width-1:0],IO1Ol100[(2*sig_width+2+2)-3:(2*sig_width+2-sig_width-2+2)]};
              end //  result is normal value 
//          end  // Normal computation case
      end  // addition of products
    end  // normal inputs
end

assign status = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(d ^ d) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? {8'bx} :
		 (arch_type === 1)?O00ll1lO:lOOO0IO1;
assign z = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(d ^ d) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? 
	    {sig_width+exp_width+1{1'bx}} : 
	    (arch_type === 1)?O1Il1000:OOOlO11O;

 // synopsys translate_on

endmodule

