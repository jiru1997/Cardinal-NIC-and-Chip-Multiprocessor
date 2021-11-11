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
// AUTHOR:    Alexandre Tenca, June 2008
//
// VERSION:   Verilog Simulation Model for FP Natural Logarithm
//
// DesignWare_version: 68b33b6c
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point Natural Logarithm
//           Computes the natural logarithm of a FP number
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand size,  2 to 60 bits
//              exp_width       O1OO1OO1 size,     3 to 31 bits
//              ieee_compliance 0 or 1
//              extra_prec      0 to 60-sig_width bits
//              arch            implementation select
//                              0 - area optimized
//                              1 - speed optimized
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number that represents ln(a)
//              status          byte
//                              Status information about FP operation
//
// MODIFIED:
//           07/2015 - AFT - Star 9000927308
//             The fix of this star implied the following actions:
//             (1) the fixed-point DW_log2 is called with
//             one more bit than the sig_width of DW_fp_ln. As a 
//             consequence, when sig_width=60, DW_log2 input width gets
//             out of range (61). Had to modify the upper bound of sig_width
//             to 59 and adjust the limits for extra_prec. 
//             (2) for extreme cases, e.g. parameter set (59,3,1,0,x), the 
//             calculation of exponents overflows, caused by small vectors. 
//             Had to increase the precision of some variable to guarantee
//             correct computation.
//           11/2015 - AFT - Star 9000854445
//             the ln(-0) should be the same as ln(+0)=-inf
//
//-------------------------------------------------------------------------------

module DW_fp_ln (a, z, status);
parameter sig_width=10;
parameter exp_width=5; 
parameter ieee_compliance=0;
parameter extra_prec=0;
parameter arch=0;

// declaration of inputs and outputs
input  [sig_width + exp_width:0] a;
output [sig_width + exp_width:0] z;
output [7:0] status;

// synopsys translate_off
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (sig_width < 2) || (sig_width > 59) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to 59)",
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
  
    if ( (extra_prec < 0) || (extra_prec > 59-sig_width) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter extra_prec (legal range: 0 to 59-sig_width)",
	extra_prec );
    end
  
    if ( (arch < 0) || (arch > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch (legal range: 0 to 1)",
	arch );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



 
// signals
  reg  [(exp_width + sig_width + 1)-1:0] OOO10100, IO10000O;
  reg  [8    -1:0] lOO0O0l0, OOO11lOO;
  `define DW_l1111OlI (sig_width+extra_prec+1)
  `define DW_O1I0O100 (`DW_l1111OlI+exp_width+5)
  `define DW_O0OO0OO1 8
  reg  [`DW_l1111OlI-1:0] O1IOl1I1;
  wire [`DW_l1111OlI-1:0] OI0O0lO0;
  reg signed [`DW_O1I0O100-1:0] O0O01lI1;
  reg lOI10I11;
  reg [`DW_O1I0O100-1:0] OIO0I1Ol;
  reg [sig_width:0] OO10lI1l;
  reg [sig_width-1:0] l1I111Il;
  reg [sig_width-1:0] OIlOllO0;
  reg [(exp_width + sig_width + 1)-1:0] lI00O010;
  reg [8    -1:0] OOOO1I0I;
  reg II1l110I, lOO00I0l, I100llOO, I010Il1O;
  reg [(exp_width + sig_width + 1)-1:0] O1001111;
  reg [(exp_width + sig_width + 1)-1:0] OI11lI10;
  reg [(exp_width + sig_width + 1)-1:0] l100101I;
  reg [sig_width:0] O101OI0O;
  reg signed [exp_width+5:0] O1OO1OO1;
  reg signed [`DW_O1I0O100-1:0] lI01I1ll, OOI111O0;
  reg signed [`DW_O1I0O100-1:0] Ol0Il1O0;
  reg [`DW_O1I0O100-1:0] OOIOOlO1;
  reg [`DW_O1I0O100-1:0] O101OI0I;
  reg [`DW_l1111OlI:0] Il1O0IOO;
  reg [sig_width+1:0] O10IO0I0;
  reg [`DW_O1I0O100-1:0] l010Ol0I;
  reg signed [`DW_O1I0O100:0] lOO1l101;
  reg signed [`DW_O1I0O100:0] I10IO001;
  reg signed [`DW_O1I0O100-1:0] OI1l00OO;
  reg [8    -1:0] OO1O1OO0;
  reg lO1O00Ol;
  wire OOO0O1O1;
  `define DW_lIl001Ol 93
  wire [(`DW_lIl001Ol - 1):0] l1000Il0;
  assign l1000Il0 = `DW_lIl001Ol'b010110001011100100001011111110111110100011100111101111001101010111100100111100011101100111001;
  wire [`DW_l1111OlI-1:0] O10O001O;
  assign O10O001O = l1000Il0[(`DW_lIl001Ol - 1)-1:(`DW_lIl001Ol - 1)-`DW_l1111OlI]+l1000Il0[(`DW_lIl001Ol - 1)-`DW_l1111OlI-1];

  always @ (a)
    begin                             
    OIlOllO0 = 0;
    OIO0I1Ol = {1'b0,a[((exp_width + sig_width) - 1):sig_width]};
    l1I111Il = a[(sig_width - 1):0];
    II1l110I = 0;
    O1001111 = {1'b0, {exp_width{1'b1}}, OIlOllO0};
    O1001111[0] = (ieee_compliance == 1)?1:0;

    OI11lI10 = {1'b1, {exp_width{1'b1}},OIlOllO0};
    l100101I = {1'b0, {exp_width{1'b1}},OIlOllO0};
    
    if (ieee_compliance == 1 && OIO0I1Ol == 0)
      begin
        if (l1I111Il == OIlOllO0)
          begin
            II1l110I = 1;
            lOO00I0l = 0;
          end
        else
          begin
            II1l110I = 0;
            lOO00I0l = 1;
            OIO0I1Ol[0] = 1;
          end
        OO10lI1l = {1'b0, a[(sig_width - 1):0]};
      end
    else if (ieee_compliance == 0 && OIO0I1Ol == 0)
      begin
        OO10lI1l = {1'b0,OIlOllO0};
        II1l110I = 1;
        lOO00I0l = 0;
      end
    else
      begin
        OO10lI1l = {1'b1, a[(sig_width - 1):0]};
        II1l110I = 0;
        lOO00I0l = 0;
      end
    
    if ((OIO0I1Ol[exp_width-1:0] == ((((1 << (exp_width-1)) - 1) * 2) + 1)) && 
        ((ieee_compliance == 0) || (l1I111Il == 0)))
      I100llOO = 1;
    else
      I100llOO = 0;
  
    if ((OIO0I1Ol[exp_width-1:0] == ((((1 << (exp_width-1)) - 1) * 2) + 1)) && 
        (ieee_compliance == 1) && (l1I111Il != 0))
      I010Il1O = 1;
    else
      I010Il1O = 0;
  
    lOI10I11 = a[(exp_width + sig_width)];
      
    OOOO1I0I = 0;
    lI00O010 = 0;
    O101OI0O = -1;
  
    if ((I010Il1O == 1) ||	((lOI10I11 == 1'b1) && (II1l110I == 1'b0)))
      begin
        lI00O010 = O1001111;
        OOOO1I0I[2] = 1;
      end
  
    else if (I100llOO == 1) 
      begin
        lI00O010 = l100101I;
        OOOO1I0I[1] = 1;
      end
  
    else if (II1l110I == 1)
      begin
        lI00O010 = OI11lI10;
        OOOO1I0I[1] = 1;
      end
  
    else if (lOO00I0l == 1)
      begin
        O101OI0O = OO10lI1l;
        while (O101OI0O[sig_width] == 0)
          begin
            O101OI0O = O101OI0O<<1;
            OIO0I1Ol = OIO0I1Ol - 1;
          end
        lI00O010 = 0;
      end
    else if (OIO0I1Ol == ((1 << (exp_width-1)) - 1) &&  l1I111Il == 0 && lOI10I11 == 0)
      begin
        lI00O010 = 0;
        OOOO1I0I[0] = 1;
      end
    else
      begin
        O101OI0O = OO10lI1l;
        lI00O010 = 0;
      end
  
    OOO10100 = lI00O010;
    lOO0O0l0 = OOOO1I0I;
    O1IOl1I1 = O101OI0O << (`DW_l1111OlI-(sig_width+1));
    O0O01lI1 = OIO0I1Ol - ((1 << (exp_width-1)) - 1);
  end

  DW_ln #(`DW_l1111OlI,arch) U1 (.a(O1IOl1I1), .z(OI0O0lO0));

  always @ (OI0O0lO0 or O0O01lI1 or O10O001O)
  begin
    O1OO1OO1 = ((1 << (exp_width-1)) - 1);
    lOO1l101 = $signed(O0O01lI1);
    I10IO001 = lOO1l101 * $unsigned(O10O001O);
    OI1l00OO = I10IO001[`DW_O1I0O100-1:0];
    lI01I1ll = OI1l00OO;
    l010Ol0I = OI0O0lO0;
    OOI111O0 = l010Ol0I;
    Ol0Il1O0 = lI01I1ll + OOI111O0;
    if (Ol0Il1O0 < 0)
      begin
        OOIOOlO1 = -Ol0Il1O0;
        lO1O00Ol = 1;
      end
    else
      begin
        OOIOOlO1 = Ol0Il1O0;
        lO1O00Ol = 0;
      end
    O101OI0I = $unsigned(OOIOOlO1);
    while ((O101OI0I[`DW_O1I0O100-1:`DW_l1111OlI+1] != 0) && 
           (O101OI0I != 0))
      begin
        O101OI0I = O101OI0I >> 1;
        O1OO1OO1 = O1OO1OO1 + 1; 
      end
    Il1O0IOO = O101OI0I[`DW_l1111OlI:0];
    while ((Il1O0IOO[`DW_l1111OlI] == 0) && (Il1O0IOO != 0) && (O1OO1OO1 > 1))
      begin
        Il1O0IOO = Il1O0IOO << 1;
        O1OO1OO1 = O1OO1OO1 - 1; 
      end
    
    O10IO0I0 = {1'b0,Il1O0IOO[`DW_l1111OlI:extra_prec+1]}+Il1O0IOO[extra_prec];
    if (O10IO0I0[sig_width+1]==1)
      begin
        O10IO0I0 = O10IO0I0 >> 1;
        O1OO1OO1 = O1OO1OO1 + 1;
      end
    if (O10IO0I0[sig_width] == 0)
      if (ieee_compliance == 1)
	begin
          IO10000O = {lO1O00Ol, {exp_width{1'b0}}, O10IO0I0[sig_width-1:0]};
          OO1O1OO0[3] = 1;
        end
      else
        begin
          IO10000O = 0;
          OO1O1OO0[3] = 1;
          OO1O1OO0[0] = 1;
        end
    else
      begin
        if (|O1OO1OO1[exp_width+5:exp_width] == 1)
          begin
            OO1O1OO0[4] = 1;
            OO1O1OO0[5] = 1;
            OO1O1OO0[1] = 1;
            IO10000O = OI11lI10;
          end
        else
          begin
            OO1O1OO0 = 0;
            IO10000O = {lO1O00Ol, O1OO1OO1[exp_width-1:0],O10IO0I0[sig_width-1:0]};
          end
      end
    OO1O1OO0[5] = ~ OO1O1OO0[1] &
                                    ~ OO1O1OO0[2] &
                                    ~ (OO1O1OO0[0] &
                                         ~ OO1O1OO0[3]);
    OOO11lOO = OO1O1OO0;
  end

  assign z = ((^(a ^ a) !== 1'b0)) ? {(exp_width + sig_width + 1){1'bx}} : 
             (lOO0O0l0 != 0) ? OOO10100 : IO10000O;
  assign status = ((^(a ^ a) !== 1'b0)) ? {8    {1'bx}} : 
                  (lOO0O0l0 != 0) ? lOO0O0l0 : OOO11lOO;

`undef DW_l1111OlI
`undef DW_O1I0O100
`undef DW_lIl001Ol

// synopsys translate_on

endmodule


