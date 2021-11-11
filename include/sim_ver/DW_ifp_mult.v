
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
// AUTHOR:    Alex Tenca and Kyung-Nam Han, March 14, 2008
//
// VERSION:   Verilog Simulation Model for DW_ifp_mult
//
// DesignWare_version: 7ed42f1b
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
//
// ABSTRACT: Floating-Point Multiplier - Internal format
//
//              DW_ifp_mult calculates the floating-point multiplication
//              while receiving and generating FP values in internal
//              FP format (no normalization).
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_widthi      significand size of the input,  2 to 253 bits
//              exp_widthi      exponent size of the input,     3 to 31 bits
//              sig_widtho      significand size of the output, 2 to 253 bits
//              exp_widtho      exponent size of the output,    3 to 31 bits
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_widthi + exp_widthi + 7)-bits
//                              Internal Floating-point Number Input
//              b               (sig_widthi + exp_widthi + 7)-bits
//                              Internal Floating-point Number Input
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_widtho + exp_widtho + 7)-bits
//                              Internal Floating-point Number Output
//
//-----------------------------------------------------------------------------

module DW_ifp_mult (a, b, z);

  parameter sig_widthi = 23;      // RANGE 2 TO 253
  parameter exp_widthi = 8;       // RANGE 3 TO 31
  parameter sig_widtho = 23;      // RANGE 2 TO 253
  parameter exp_widtho = 8;       // RANGE 3 TO 31

  input  [exp_widthi + sig_widthi + 6:0] a;
  input  [exp_widthi + sig_widthi + 6:0] b;
  output [exp_widtho + sig_widtho + 6:0] z;

  // synopsys translate_off

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
      
    if ( (sig_widthi < 2) || (sig_widthi > 253) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_widthi (legal range: 2 to 253)",
	sig_widthi );
    end
      
    if ( (exp_widthi < 3) || (exp_widthi > 31) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_widthi (legal range: 3 to 31)",
	exp_widthi );
    end
      
    if ( (sig_widtho < sig_widthi) || (sig_widtho > 253) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_widtho (legal range: sig_widthi to 253)",
	sig_widtho );
    end
      
    if ( (exp_widtho < exp_widthi) || (exp_widtho > 31) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_widtho (legal range: exp_widthi to 31)",
	exp_widtho );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  //-------------------------------------------------------------------------


`define DW_OlII0lOI (sig_widtho-1)
`define DW_OOIl0O01 (2*sig_widtho-1)
`define DW_lOI0111I exp_widtho
`define DW_I1I01IIl (exp_widtho-1)
  reg [7-1:0] I0111lO1;
  reg [7-1:0] OIO10OO0;
  reg [7-1:0] IlO1l1O1;
  reg [exp_widtho+sig_widtho+7-1:0] OIl11lO1;
  reg l1O10II0, l11lllOl, lO1I0I0O, IOIOOll0, l1IOO110, O10IIO1l, OI11O1Il, OO1lII11;
  reg I00O1O00;
  reg [`DW_I1I01IIl:0] llI101OI,OI10O10l;
  reg [`DW_lOI0111I:0] lOOOIOl1;
  reg signed [`DW_OOIl0O01:0] I00IOO0l;
  reg signed [`DW_OlII0lOI:0] OIOll01I;  
  reg signed [`DW_OlII0lOI:0] OOlO11O0;  
  reg l01O1I0l, l10I111O, l110l0lI;
  reg I1O11O01;
  reg OO1001Ol;
  reg [sig_widtho-sig_widthi:0] O1000OO0;
  reg [sig_widtho-sig_widthi:0] O1IOI0ll;
  reg O011OOOl, l1O0OOll;
  reg [exp_widtho:0] Ill0I10O;
  reg [exp_widtho:0] O1OI0IOl;
  reg [exp_widtho:0] I1OOII00;

  always @ (a or b)
  begin

  OIO10OO0 = a[sig_widthi+exp_widthi+7-1:sig_widthi+exp_widthi];
  IlO1l1O1 = b[sig_widthi+exp_widthi+7-1:sig_widthi+exp_widthi];
  l1O10II0 = OIO10OO0[2];
  l11lllOl = OIO10OO0[1];
  IOIOOll0 = OIO10OO0[3     ];
  l1IOO110 = IlO1l1O1[2];
  O10IIO1l = IlO1l1O1[1];
  OO1lII11 = IlO1l1O1[3     ];
  I1O11O01 = OIO10OO0[4];
  OO1001Ol = IlO1l1O1[4];
  O011OOOl = (OIO10OO0[6     ] & a[0]) |
              (I1O11O01 & a[sig_widthi-1]);
  l1O0OOll = (IlO1l1O1[6     ] & b[0]) |
              (OO1001Ol & b[sig_widthi-1]);
  O1000OO0 = {sig_widtho-sig_widthi+1{O011OOOl}};
  O1IOI0ll = {sig_widtho-sig_widthi+1{l1O0OOll}};
                   
  if (exp_widthi < exp_widtho) 
    begin
      llI101OI = {{exp_widtho-exp_widthi{1'b0}},a[sig_widthi+exp_widthi-1:sig_widthi]};
      OI10O10l = {{exp_widtho-exp_widthi{1'b0}},b[sig_widthi+exp_widthi-1:sig_widthi]};
    end
  else
    begin
      llI101OI = a[sig_widthi+exp_widthi-1:sig_widthi];  // same value
      OI10O10l = b[sig_widthi+exp_widthi-1:sig_widthi];
    end
  if (sig_widthi < sig_widtho)
    begin
      OIOll01I = $signed({a[sig_widthi-1:0],
                     O1000OO0[(sig_widtho-sig_widthi):1]});
      OOlO11O0 = $signed({b[sig_widthi-1:0],
                     O1IOI0ll[(sig_widtho-sig_widthi):1]});
    end
  else
    begin
      OIOll01I = $signed(a[sig_widthi-1:0]);
      OOlO11O0 = $signed(b[sig_widthi-1:0]);
    end
  lO1I0I0O = OIO10OO0[0] |
           (~l11lllOl & ~|OIOll01I);
  OI11O1Il = IlO1l1O1[0] |
           (~O10IIO1l & ~|OOlO11O0);
  if (lO1I0I0O == 1)
    llI101OI = 0;
  if (OI11O1Il == 1)
    OI10O10l = 0;

  I0111lO1 = 0;

  l01O1I0l = OIOll01I[`DW_OlII0lOI];
  l01O1I0l = ((lO1I0I0O | l11lllOl) & OIO10OO0[5     ]) |
            ((~(lO1I0I0O | l11lllOl)) & l01O1I0l);
  l10I111O = OOlO11O0[`DW_OlII0lOI];
  l10I111O = ((OI11O1Il | O10IIO1l) & IlO1l1O1[5     ]) |
            ((~(OI11O1Il | O10IIO1l)) & l10I111O);
  l110l0lI = l01O1I0l ^ l10I111O;

  if (l1O10II0 == 1 | l1IOO110 == 1)
    I0111lO1[2] = 1;
  if (l11lllOl == 1 || O10IIO1l == 1) 
    if (lO1I0I0O == 1 || OI11O1Il == 1)
      I0111lO1[2] = 1;
    else
      begin
        I0111lO1[1] = 1;
        I0111lO1[5     ] = l110l0lI;
      end
  if ( (lO1I0I0O == 1 || OI11O1Il == 1) &&
       I0111lO1 == 0)
    begin
      I0111lO1[0] = 1;
      I0111lO1[5     ] = l110l0lI;
      OIOll01I = 0;
      llI101OI = 0;
      OOlO11O0 = 0;
      OI10O10l = 0;
    end

  Ill0I10O = (1 << (exp_widthi-1))-1;
  O1OI0IOl = Ill0I10O;
  I1OOII00 = ~O1OI0IOl;

  I00IOO0l = (OIOll01I * OOlO11O0);   
  lOOOIOl1 = ({1'b0,llI101OI} + {1'b0,OI10O10l}) + I1OOII00 + 3;
  if (lOOOIOl1[`DW_lOI0111I] == 1'b1 && I0111lO1 == 0)
    begin
      // overflow  or underflow condition when output is a regular value
      // it is underflow when the input exponents are too small
      if (llI101OI[`DW_I1I01IIl] == 1'b1)
	lOOOIOl1 = {exp_widtho{1'b1}};
      else
	begin
	  I00IOO0l = {exp_widtho{1'b0}};
          I0111lO1[3     ] = 1'b1;
          I0111lO1[5     ] = l110l0lI;
        end
    end
  I00O1O00 = |I00IOO0l[`DW_OOIl0O01-sig_widtho:0] | IOIOOll0 | OO1lII11;
  I0111lO1[3     ] = I0111lO1[3     ] | I00O1O00;
  if (I0111lO1[2] == 0 &&
      (I0111lO1[0] == 1 ||
       I0111lO1[1] == 1))
    I0111lO1[5     ] = l110l0lI;
  OIl11lO1 = {I0111lO1, lOOOIOl1[exp_widtho-1:0], 
	    I00IOO0l[`DW_OOIl0O01:`DW_OOIl0O01-sig_widtho+1]};

  end
  
  //-------------------------------------------------------
  // Output Format
  //-------------------------------------------------------

  assign z =  ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0)) ?  
               {sig_widtho+exp_widtho+7-1{1'bx}} : OIl11lO1;
  
  `undef DW_OlII0lOI 
  `undef DW_OOIl0O01
  `undef DW_lOI0111I 
  `undef DW_I1I01IIl 

// synopsys translate_on
  
endmodule

