
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2007 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Kyung-Nam Han, Jul. 16, 2007
//
// VERSION:   Verilog Simulation Model for DW_fp_recip
//
// DesignWare_version: 6233afc7
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
//
// ABSTRACT: Floating-Point Reciprocal
//
//              DW_fp_recip calculates the floating-point reciprocal
//              with 1 ulp error.
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand size,  2 to 60 bits
//              exp_width       exponent size,     3 to 31 bits
//              ieee_compliance support the IEEE Compliance 
//                              0 - IEEE 754 compatible without denormal support
//                                  (NaN becomes Infinity, Denormal becomes Zero)
//                              1 - IEEE 754 compatible with denormal support
//                                  (NaN and denormal numbers are supported)
//              faithful_round  select the faithful_rounding that admits 1 ulp error
//                              0 - default value. it keeps all rounding modes
//                              1 - z has 1 ulp error. RND input does not affect 
//                                  the output
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              rnd             3 bits
//                              Rounding Mode Input
//              z               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Output
//              status          8 bits
//                              Status Flags Output
//
// Modified:
//   06/03/10  Kyung-Nam Han (from D-2010.03-SP3)
//             1) with sig_width=8, it had larger than 1 ulp error. Fixed.
//             2) with faithful_round=1, 1/denormal was not 'Inf' when the
//                true result is at the infinite region. Fixed
//-----------------------------------------------------------------------------

module DW_fp_recip (a, rnd, z, status);

  parameter sig_width = 23;      // range 2 to 60
  parameter exp_width = 8;       // range 3 to 31
  parameter ieee_compliance = 0; // range 0 to 1
  parameter faithful_round = 0;  // range 0 to 1

  input  [sig_width + exp_width:0] a;
  input  [2:0] rnd;
  output [sig_width + exp_width:0] z;
  output [7:0] status;

  // synopsys translate_off


  `define DW_Ill0lOl1  4
  `define DW_O110O00O  0
  `define DW_IOI010lO  1
  `define DW_OOO101O1  2
  `define DW_IIlI101I  3
  `define DW_l01OI1IO  (2 * sig_width + 2)
  `define DW_O0OI011O    (sig_width + 2)
  `define DW_OOO111l0 ((sig_width >= 25) ? sig_width - 25 : 0)
  `define DW_OO00OII1 ((sig_width >= 24) ? 2 * sig_width - 47 : 0)
  `define DW_OI11IOIO ((sig_width >= 11) ? 2 * sig_width - 21 : 0)
  `define DW_OO1I11OI ((sig_width >= 11) ? sig_width - 11 : 0)
  `define DW_l10I000l ((sig_width >= 25) ? 2 * sig_width - 47 : 0)
  `define DW_O0110OO1 ((sig_width >= 25) ? sig_width - 22 : 0)
  `define DW_l1l001Ol ((sig_width >= 25) ? sig_width - 11 : 0)
  `define DW_O0011I0l ((sig_width >= 25) ? 13 : 0)
  `define DW_IO011OIO ((sig_width >= 25) ? sig_width + 3 : 0)
  `define DW_OOO01OOO ((sig_width >= 25) ? 27 : 0)
  `define DW_O1IOlO0O ((sig_width >= 25) ? 2 * sig_width - 47 : 0)
  `define DW_l1O11100 ((sig_width >= 25) ? sig_width - 23 : 0)
  `define DW_l111IlIO ((sig_width >= 11) ? sig_width + 1 : 0)
  `define DW_O1l0O0OO ((sig_width >= 11) ? 12 : 0)
  `define DW_lIOl0IO1 ((sig_width >= 11) ? 2 * sig_width - 21 : 0)
  `define DW_O00IO001 ((sig_width >= 11) ? sig_width - 10 : 0)
  `define DW_O1l1lOO1 ((sig_width >= 11) ? sig_width + 3 : 0)
  `define DW_O1I1OlOO ((sig_width >= 11) ? 14 : 0)
  `define DW_OOlO0O1O ((sig_width >= 9) ? 1 : 9 - sig_width)
  `define DW_OI0lO110 ((sig_width >= 9) ? sig_width - 9 : 0)
  `define DW_OOOI0O01 ((sig_width > 8) ? 0 : 8 - sig_width - 1)
  `define DW_O00OO01O ((sig_width < 8) ? `DW_OOOI0O01 + 1 : 1)
  `define DW_IlOl1lOO ((sig_width >= 8) ? 0 : 8 - sig_width - 1)

  //-------------------------------------------------------------------------
  // parameter legality check
  //-------------------------------------------------------------------------
    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
      
    if ( (sig_width < 2) || (sig_width > 60) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to 60)",
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
      
    if ( (faithful_round < 0) || (faithful_round > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter faithful_round (legal range: 0 to 1)",
	faithful_round );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  //-------------------------------------------------------------------------


  function [`DW_Ill0lOl1-1:0] OO11l0O1;
  
    input [2:0] O1OI1lI0;
    input [0:0] O100OOI0;
    input [0:0] ll00I010,Ill1lII0,OIllO0O1;

    begin
      OO11l0O1[`DW_O110O00O] = 0;
      OO11l0O1[`DW_IOI010lO] = Ill1lII0|OIllO0O1;
      OO11l0O1[`DW_OOO101O1] = 0;
      OO11l0O1[`DW_IIlI101I] = 0;
      
      if ($time > 0)
      begin
        case (O1OI1lI0)
          3'b000:
          begin
            // round to nearest (even)
            OO11l0O1[`DW_O110O00O] = Ill1lII0&(ll00I010|OIllO0O1);
            OO11l0O1[`DW_OOO101O1] = 1;
            OO11l0O1[`DW_IIlI101I] = 0;
          end
          3'b001:
          begin
            // round to zero
            OO11l0O1[`DW_O110O00O] = 0;
            OO11l0O1[`DW_OOO101O1] = 0;
            OO11l0O1[`DW_IIlI101I] = 0;
          end
          3'b010:
          begin
            // round to positive infinity
            OO11l0O1[`DW_O110O00O] = ~O100OOI0 & (Ill1lII0|OIllO0O1);
            OO11l0O1[`DW_OOO101O1] = ~O100OOI0;
            OO11l0O1[`DW_IIlI101I] = ~O100OOI0;
          end
          3'b011:
          begin
            // round to negative infinity
            OO11l0O1[`DW_O110O00O] = O100OOI0 & (Ill1lII0|OIllO0O1);
            OO11l0O1[`DW_OOO101O1] = O100OOI0;
            OO11l0O1[`DW_IIlI101I] = O100OOI0;
          end
          3'b100:
          begin
            // round to nearest (up)
            OO11l0O1[`DW_O110O00O] = Ill1lII0;
            OO11l0O1[`DW_OOO101O1] = 1;
            OO11l0O1[`DW_IIlI101I] = 0;
          end
          3'b101:
          begin
            // round away form 0
            OO11l0O1[`DW_O110O00O] = Ill1lII0|OIllO0O1;
            OO11l0O1[`DW_OOO101O1] = 1;
            OO11l0O1[`DW_IIlI101I] = 1;
          end
          default:
          begin
            $display("error! illegal rounding mode.\n");
            $display("a : %b", a);
            $display("rnd : %b", O1OI1lI0);
          end
        endcase
      end
    end
  endfunction

  reg [(exp_width + sig_width):0] lOO011OI;
  reg [exp_width-1:0] OlO000O1,IOOI01IO;
  reg [exp_width+1:0] I0l110I0;
  reg [exp_width+1:0] lOO00lI0;
  reg [exp_width+1:0] l0l0IOlO;
  reg signed [exp_width+1:0] O0I11O0l;
  reg [sig_width:0] O00IO10O,l011011l,OO01l0I0,O1IlO100,I11l0100;
  reg [sig_width:0] OIIIOl01;
  reg [sig_width:0] lI0l111l;
  reg [sig_width:0] Ill1lII0;
  reg OIllO0O1,O100OOI0;
  reg [1:0] OI0llO10;
  reg [`DW_Ill0lOl1-1:0] l0100O0l;
  reg [8    -1:0] l1O10II1;
  reg [(exp_width + sig_width):0] OOO0l10l;
  reg [(exp_width + sig_width):0] OIOlO100;
  reg O0l10lOO;
  reg IOOO0OOO;
  reg OO0I1OIl;
  reg I00101O1;
  reg I00I01O1;
  reg lOIIOI1l;
  reg l00lOI1I;
  reg O00001Ol;
  reg OO0O1O11;
  reg [sig_width - 1:0] lOOllO11;
  reg [sig_width - 1:0] OI0Ill10;
  reg [7:0] I1I0l10O;
  reg [7:0] O1I11010;
  reg [exp_width + 1:0] lOO00O01;
  reg [sig_width + exp_width:0] lI1l011I;
  reg [2:0] O1OI1lI0;
  reg [8:0] l0OO0101;
  reg [8:0] O000O0Il;
  reg [sig_width:0] lO10010I;
  reg [sig_width + 3:0] IOOO0Ol0;
  reg [sig_width + 3:0] Ol1O10O0;
  reg [sig_width + 3:0] l101lO0O;
  reg [sig_width + 9:0] l0O1Ol0O;
  reg [sig_width + 1:0] lO1l1OO0;
  reg [sig_width + 18:0] OI0OIlO1;
  reg [`DW_OI11IOIO:0] IlOI0OOI;
  reg [`DW_OO1I11OI:0] II1ll01l;
  reg [`DW_OI11IOIO:0] I11O1I01;
  reg [`DW_OOO111l0:0] Oll0O1lO;
  reg [`DW_OO00OII1:0] l1O0IlOI;
  reg [`DW_OO00OII1:0] O100lO10;
  reg [`DW_OOO111l0:0] l110lO1l;
  reg [9:0] I001ll10;
  reg IO0OlO1O;
  reg [8:0] O00O101I;
  reg [sig_width + 3:0] O001OII0;
  reg [sig_width + 3:0] OOOO00O1;
  reg [sig_width + 3:0] OO1l11IO;
  reg [8:8 - sig_width] O0Ol1Il1;
  reg [sig_width:0] lIO001IO;
  reg [sig_width:0] O1I110II;
  reg [sig_width:0] O0O0OlOl;
  wire [sig_width + exp_width:0] O00OI111;
  wire [7:0] O1010O0O;
  wire [sig_width + exp_width:0] l0I1l1O1;

  assign l0I1l1O1 = {2'b0, {(exp_width - 1){1'b1}}, {(sig_width){1'b0}}};

  DW_fp_div #(sig_width, exp_width, ieee_compliance) u1 (
    .a(l0I1l1O1),
    .b(a),
    .rnd(rnd),
    .z(O00OI111),
    .status(O1010O0O)
  );

  always @(a) begin : a1000_PROC
    O1OI1lI0 = 1;
    lI1l011I = {1'b0, 1'b0, {(exp_width - 1){1'b1}}, {(sig_width){1'b0}}};
    O100OOI0 = a[(exp_width + sig_width)] ^ lI1l011I[(exp_width + sig_width)];
    OlO000O1 = lI1l011I[((exp_width + sig_width) - 1):sig_width];
    IOOI01IO = a[((exp_width + sig_width) - 1):sig_width];
    lOOllO11 = lI1l011I[(sig_width - 1):0];
    OI0Ill10 = a[(sig_width - 1):0];
    I1I0l10O = 0;
    O1I11010 = 0;
    OIIIOl01 = 0;

    l1O10II1 = 0;

    if (ieee_compliance)
    begin
      O0l10lOO = (OlO000O1 == ((((1 << (exp_width-1)) - 1) * 2) + 1)) & (lOOllO11 == 0);
      IOOO0OOO = (IOOI01IO == ((((1 << (exp_width-1)) - 1) * 2) + 1)) & (OI0Ill10 == 0);
      OO0I1OIl = (OlO000O1 == ((((1 << (exp_width-1)) - 1) * 2) + 1)) & (lOOllO11 != 0);
      I00101O1 = (IOOI01IO == ((((1 << (exp_width-1)) - 1) * 2) + 1)) & (OI0Ill10 != 0);
      I00I01O1 = (OlO000O1 == 0) & (lOOllO11 == 0);
      lOIIOI1l = (IOOI01IO == 0) & (OI0Ill10 == 0);
      l00lOI1I = (OlO000O1 == 0) & (lOOllO11 != 0);
      O00001Ol = (IOOI01IO == 0) & (OI0Ill10 != 0);
      OOO0l10l = {O100OOI0, {(exp_width){1'b1}}, {(sig_width){1'b0}}}; 
      OIOlO100 = {1'b0, {(exp_width){1'b1}}, {(sig_width - 1){1'b0}}, 1'b1};
    end
    else
    begin
      O0l10lOO = (OlO000O1 == ((((1 << (exp_width-1)) - 1) * 2) + 1));
      IOOO0OOO = (IOOI01IO == ((((1 << (exp_width-1)) - 1) * 2) + 1));
      OO0I1OIl = 0;
      I00101O1 = 0;
      I00I01O1 = (OlO000O1 == 0);
      lOIIOI1l = (IOOI01IO == 0);
      l00lOI1I = 0;
      O00001Ol = 0;
      OOO0l10l = {O100OOI0, {(exp_width){1'b1}}, {(sig_width){1'b0}}};
      OIOlO100 = {1'b0, {(exp_width){1'b1}}, {(sig_width){1'b0}}};
    end

    l1O10II1[7] = lOIIOI1l; 

    if (OO0I1OIl || I00101O1 || (O0l10lOO && IOOO0OOO) || (I00I01O1 && lOIIOI1l))
    begin
      lOO011OI = OIOlO100;
      l1O10II1[2] = 1;
    end
    else if (O0l10lOO || lOIIOI1l)
    begin
      lOO011OI = OOO0l10l;
      l1O10II1[1] = 1;
    end
    else if (I00I01O1 || IOOO0OOO)
    begin
      l1O10II1[0] = 1;
      lOO011OI = 0;
      lOO011OI[(exp_width + sig_width)] = O100OOI0;
    end
  
    else
    begin
      if (ieee_compliance) 
      begin

        if (l00lOI1I) 
        begin
          O00IO10O = {1'b0, lI1l011I[(sig_width - 1):0]};

          while(O00IO10O[sig_width] != 1)
          begin
            O00IO10O = O00IO10O << 1;
            I1I0l10O = I1I0l10O + 1;
          end
        end 
        else
        begin
          O00IO10O = {1'b1, lI1l011I[(sig_width - 1):0]};
        end

        if (O00001Ol) 
        begin
          l011011l = {1'b0, a[(sig_width - 1):0]};
          while(l011011l[sig_width] != 1)
          begin
            l011011l = l011011l << 1;
            O1I11010 = O1I11010 + 1;
          end
        end 
        else
        begin
          l011011l = {1'b1, a[(sig_width - 1):0]};
        end
      end
      else
      begin
        O00IO10O = {1'b1, lI1l011I[(sig_width - 1):0]};
        l011011l = {1'b1, a[(sig_width - 1):0]};
      end

      IO0OlO1O = (l011011l[sig_width - 1:0] == 0);
      lO10010I = (ieee_compliance) ? 
                 l011011l :
                 {1'b1, OI0Ill10[sig_width - 1:0]};
      l0OO0101 = (sig_width >= 9) ? 
                  lO10010I[sig_width - 1:`DW_OI0lO110] : 
                  {lO10010I[sig_width - 1:0], {(`DW_OOlO0O1O){1'b0}}};
      I001ll10 = {1'b1, l0OO0101[8:0]};
      O000O0Il = {1'b1, 18'b0} / (I001ll10 + 1);
      l0O1Ol0O = lO10010I * O000O0Il;
      lO1l1OO0 = ~l0O1Ol0O[sig_width + 1:0];
      OI0OIlO1 = O000O0Il * ((1 << (sig_width + 9)) + lO1l1OO0);
      IOOO0Ol0 = OI0OIlO1[sig_width  + 17:14];
      IlOI0OOI = (sig_width >= 11) ? lO1l1OO0[`DW_l111IlIO:`DW_O1l0O0OO] * lO1l1OO0[`DW_l111IlIO:`DW_O1l0O0OO] : 0;
      II1ll01l = (sig_width >= 11) ? IlOI0OOI[`DW_lIOl0IO1:`DW_O00IO001] : 0;
      I11O1I01 = (sig_width >= 11) ? IOOO0Ol0[`DW_O1l1lOO1:`DW_O1I1OlOO] * II1ll01l : 0;
      Ol1O10O0 = IOOO0Ol0 + I11O1I01[`DW_lIOl0IO1:`DW_O00IO001];
      Oll0O1lO = (sig_width >= 25) ? II1ll01l[`DW_l1l001Ol:`DW_O0011I0l] : 0;
      l1O0IlOI = Oll0O1lO * Oll0O1lO;
      O100lO10 = (sig_width >= 25) ? Ol1O10O0[`DW_IO011OIO:`DW_OOO01OOO] * l1O0IlOI[`DW_O1IOlO0O:`DW_l1O11100] : 0;
      l110lO1l = (sig_width >= 25) ? O100lO10[`DW_l10I000l:`DW_O0110OO1] : 0;
      l101lO0O = Ol1O10O0 + l110lO1l;
      O00O101I = (sig_width == 8) ? O000O0Il + 1 :
               (sig_width < 8) ? O000O0Il + {1'b1, {(`DW_O00OO01O){1'b0}}} : 0;
               //(sig_width < 8) ? O000O0Il + {1'b1, {(`DW_OOOI0O01 + 1){1'b0}}} : 0;
      O001OII0 = IOOO0Ol0 + 4'b1000;
      OOOO00O1 = Ol1O10O0 + 4'b1000;
      OO1l11IO = l101lO0O + 4'b1000;
      O0Ol1Il1 = (sig_width == 8) ? O00O101I[8:`DW_OOOI0O01 + 1] :
                   (O000O0Il[`DW_IlOl1lOO]) ? O00O101I[8:`DW_OOOI0O01 + 1] : O000O0Il[8:`DW_OOOI0O01 + 1];
      lIO001IO = (IOOO0Ol0[2]) ? O001OII0[sig_width + 3:3] : IOOO0Ol0[sig_width + 3:3];
      O1I110II = (Ol1O10O0[2]) ? OOOO00O1[sig_width + 3:3] : Ol1O10O0[sig_width + 3:3];
      O0O0OlOl = (l101lO0O[2]) ? OO1l11IO[sig_width + 3:3] : l101lO0O[sig_width + 3:3];
      lI0l111l = (IO0OlO1O) ? 0 :
          (sig_width <= 8) ? O0Ol1Il1 :
          (sig_width <= 14) ? lIO001IO :
          (sig_width <= 30) ? O1I110II : O0O0OlOl;

      Ill1lII0 = 1;

      I0l110I0 = (OlO000O1 - I1I0l10O + l00lOI1I) - (IOOI01IO - O1I11010 + O00001Ol) + ((1 << (exp_width-1)) - 1);
      lOO00lI0 = (IO0OlO1O) ? I0l110I0 : I0l110I0-1;

      O1IlO100 = lI0l111l;
      OI0llO10 = 0;
      O0I11O0l = lOO00lI0;
      OIllO0O1 = 1;

      if (ieee_compliance) begin
        if ((O0I11O0l <= 0) | (O0I11O0l[exp_width + 1] == 1)) begin

          OO0O1O11 = 1;
          lOO00O01 = 1 - O0I11O0l;
        
          {O1IlO100, OIIIOl01} = {O1IlO100, {(sig_width + 1){1'b0}}} >> lOO00O01;

          if (lOO00O01 > sig_width + 1) begin
            OIllO0O1 = 1;
          end

          OI0llO10[1] = O1IlO100[0];
          OI0llO10[0] = OIIIOl01[sig_width];

          if (OIIIOl01[sig_width - 1:0] != 0) begin
            OIllO0O1 = 1;
          end
        end
        else begin
          OO0O1O11 = 0;
        end
      end

      l0100O0l = OO11l0O1(O1OI1lI0, O100OOI0, OI0llO10[1], OI0llO10[0], OIllO0O1);
   
      I11l0100 = (l0100O0l[`DW_O110O00O] === 1)? (O1IlO100+1):O1IlO100;

      if ((O0I11O0l >= ((((1 << (exp_width-1)) - 1) * 2) + 1)) & (O0I11O0l[exp_width+1] === 1'b0)) begin
        l1O10II1[4] = 1;
        l1O10II1[5] = 1;

        if((l0100O0l[`DW_OOO101O1] === 1) || (faithful_round == 1)) begin
          OO01l0I0 = OOO0l10l[sig_width:0];
          l0l0IOlO = ((((1 << (exp_width-1)) - 1) * 2) + 1);
          l1O10II1[1] = 1;
        end
        else begin
          OO01l0I0 = -1;
          l0l0IOlO = ((((1 << (exp_width-1)) - 1) * 2) + 1) - 1;
        end
      end
  
      else if ((O0I11O0l <= 0) | (O0I11O0l[exp_width+1] === 1'b1)) begin
        l1O10II1[3] = 1;

        if (ieee_compliance == 0) begin
          l1O10II1[5] = 1;

          if(l0100O0l[`DW_IIlI101I] === 1) begin
            OO01l0I0 = 0;
            l0l0IOlO = 0 + 1;
          end
          else begin
            OO01l0I0 = 0;
            l0l0IOlO = 0;
            l1O10II1[0] = 1;
          end
        end
        else begin
          OO01l0I0 = I11l0100;
          l0l0IOlO = I11l0100[sig_width];
        end
      end
      else begin
        OO01l0I0 = I11l0100;
        l0l0IOlO = O0I11O0l;
      end

      if (ieee_compliance & (O0I11O0l == 0) & (O1IlO100 == 0)) begin
        OO01l0I0[sig_width - 1] = 1;
      end

      if ((OO01l0I0[sig_width - 1:0] == 0) & (l0l0IOlO[exp_width - 1:0] == 0)) begin
        l1O10II1[0] = 1;
      end
  
      l1O10II1[5] = l1O10II1[5] | (l0100O0l[`DW_IOI010lO] & ~IO0OlO1O);
   
      lOO011OI = {O100OOI0,l0l0IOlO[exp_width-1:0],OO01l0I0[sig_width-1:0]};
    end
  end
   
  assign status = (faithful_round) ? l1O10II1 : O1010O0O;
  assign z = (faithful_round) ? lOO011OI : O00OI111;
   
  `undef DW_Ill0lOl1
  `undef DW_O110O00O
  `undef DW_IOI010lO
  `undef DW_OOO101O1
  `undef DW_IIlI101I
  `undef DW_l01OI1IO
  `undef DW_O0OI011O
  `undef DW_OOO111l0
  `undef DW_OO00OII1
  `undef DW_OI11IOIO
  `undef DW_OO1I11OI
  `undef DW_l10I000l
  `undef DW_O0110OO1
  `undef DW_l1l001Ol
  `undef DW_O0011I0l
  `undef DW_IO011OIO
  `undef DW_OOO01OOO
  `undef DW_O1IOlO0O
  `undef DW_l1O11100
  `undef DW_l111IlIO
  `undef DW_O1l0O0OO
  `undef DW_lIOl0IO1
  `undef DW_O00IO001
  `undef DW_O1l1lOO1
  `undef DW_O1I1OlOO
  `undef DW_OOlO0O1O
  `undef DW_OI0lO110
  `undef DW_OOOI0O01
  `undef DW_O00OO01O
  `undef DW_IlOl1lOO

  // synopsys translate_on

endmodule
  
  
  
