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
// AUTHOR:    Alexandre Tenca, August 2007
//
// VERSION:   Verilog Simulation Model for FP Base-2 Logarithm
//
// DesignWare_version: baa91a78
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point Base-2 Logarithm
//           Computes the base-2 logarithm of a FP number
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand size,  2 to 60 bits
//              exp_width       Ol0lOO0l size,     3 to 31 bits
//              ieee_compliance 0 or 1
//              extra_prec      0 to 60-sig_width (default 0)
//              arch            implementation select
//                              0 - area optimized
//                              1 - speed optimized
//                              2 - 2007.12 implementation (default)
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number that represents log2(a)
//              status          byte
//                              Status information about FP operation
//
// MODIFIED:
//            10/10/2007 - AFT - 
//               Included a new parameter to increase the internal precision.
//            09/2008 - AFT - included new parameter (arch) and fixed some
//               issues with accuracy and status information.
//            08/12/2010 - Alex Tenca, Kyung-Nam Han (STAR 9000409445)
//               Fixed bugs with sig_width=23 and exp_width=4
//            07/07/2015 - AFT - Star 9000926897
//               The fixed-point DW_log2 is called with
//               one more bit than the sig_width of DW_fp_log2. As a 
//               consequence, when sig_width=60, DW_log2 input width gets
//               out of range (61). Had to modify the upper bound of sig_width
//               to 59 and adjust the limits for extra_prec. Also, for extreme
//               cases, e.g. parameter set (59,3,1,0,x), the calculation 
//               overflows, caused by small vectors. Had to increase the 
//               precision of some variable to guarantee correct computation.
//             12/2015 - AFT - Star 9000984209
//               Fixed case when input is -0 to be log2(-0)=-inf 
//
//-------------------------------------------------------------------------------

module DW_fp_log2 (a, z, status);
parameter sig_width=10;
parameter exp_width=5; 
parameter ieee_compliance=0;
parameter extra_prec=0;
parameter arch=2;

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
  
    if ( (arch < 0) || (arch > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch (legal range: 0 to 2)",
	arch );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


// definitions used in the code
 
// signals
  reg  [(exp_width + sig_width + 1)-1:0] l0I1l1I0, l11OOl11;
  reg  [8    -1:0] OOlIIl1O, I1lO1I0O;
  `define DW_lO11100O (sig_width+extra_prec+1)
  `define DW_lI1lIOOO (`DW_lO11100O+exp_width+5)
  reg  [`DW_lO11100O-1:0] ll0OIO0O;
  wire [`DW_lO11100O-1:0] lIIOl00O;
  reg signed [`DW_lI1lIOOO-1:0] I1I1O1O1;
  reg O1O00011;
  reg signed [`DW_lI1lIOOO-1:0] O1OI1I0I;
  reg [sig_width:0] lIIOO1O0;
  reg [sig_width-1:0] O1O0IO0I;
  reg [sig_width-1:0] Ol11Il00;
  reg [(exp_width + sig_width + 1)-1:0] O0l00010;
  reg [8    -1:0] OI0O001l;
  reg l010OO01, O1101lll, II0l1011, IOOII00I;
  reg [(exp_width + sig_width + 1)-1:0] l0O111Ol;   // Not-a-number
  reg [(exp_width + sig_width + 1)-1:0] O1101l11;  // minus infinity
  reg [(exp_width + sig_width + 1)-1:0] OOl0l110;   // plus infinity
  reg [sig_width:0] IO01l1lO;
  reg signed [exp_width+5:0] Ol0lOO0l;
  reg signed [`DW_lI1lIOOO-1:0] OOO1lO0l, lOOOI1O0;
  reg signed [`DW_lI1lIOOO-1:0] OlI00O00;
  reg [`DW_lI1lIOOO-1:0] I1Ol0OlI;
  reg [`DW_lI1lIOOO-1:0] Ol0001IO;
  reg [`DW_lO11100O:0] OIll0O01;
  reg [sig_width+1:0] lO0111Ol;
  reg [`DW_lI1lIOOO-1:0] O1011010;
  reg [`DW_lI1lIOOO-1:0] l011IOI1;
  reg [8    -1:0] l100OO01;
  reg Ol1OI0O1;
  wire O01OI110;
  wire O1lI1O00, OlOOOO0O, OO1lOl00, OO1l1OO0;
  wire OO1OI100;
  wire OlO01101;
  wire OlO0O1OO;
  wire Ol0I1l00;
  wire O100110O;
  wire O0OOl011;
  wire I0l0l101;
  wire O0OlI011;

  always @ (a)
  begin                             
  Ol11Il00 = 0;
  O1OI1I0I = $signed({2'b00,a[((exp_width + sig_width) - 1):sig_width]});
  O1O0IO0I = a[(sig_width - 1):0];
  l010OO01 = 0;
  l0O111Ol = {1'b0, {exp_width{1'b1}}, Ol11Il00};
  l0O111Ol[0] = (ieee_compliance == 1)?1:0;  // mantissa is 1 when number is NAN
                                          // and it should be ieee compliant
  O1101l11 = {1'b1, {exp_width{1'b1}},Ol11Il00};
  OOl0l110 = {1'b0, {exp_width{1'b1}},Ol11Il00};
  
  if (ieee_compliance == 1 && O1OI1I0I == 0)
    begin
      if (O1O0IO0I == Ol11Il00)
        begin
          l010OO01 = 1;
          O1101lll = 0;
        end
      else
        begin
          l010OO01 = 0;
          O1101lll = 1;
          O1OI1I0I[0] = 1;                  // make the value the minimum Ol0lOO0l
        end
      lIIOO1O0 = {1'b0, a[(sig_width - 1):0]};
    end
  else if (ieee_compliance == 0 && O1OI1I0I == 0)
    begin
      lIIOO1O0 = {1'b0,Ol11Il00};
      l010OO01 = 1;
      O1101lll = 0;
    end
  else
    begin
      lIIOO1O0 = {1'b1, a[(sig_width - 1):0]};
      l010OO01 = 0;
      O1101lll = 0;
    end
  
  if ((O1OI1I0I[exp_width-1:0] == ((((1 << (exp_width-1)) - 1) * 2) + 1)) && 
      ((ieee_compliance == 0) || (O1O0IO0I == 0)))
    II0l1011 = 1;
  else
    II0l1011 = 0;

  if ((O1OI1I0I[exp_width-1:0] == ((((1 << (exp_width-1)) - 1) * 2) + 1)) && 
      (ieee_compliance == 1) && (O1O0IO0I != 0))
    IOOII00I = 1;
  else
    IOOII00I = 0;

  O1O00011 = a[(exp_width + sig_width)]; // minus zero is also considered negative value
    
  OI0O001l = 0;
  O0l00010 = 0;
  IO01l1lO = -1;

  if ((IOOII00I == 1) ||	// a is NaN.
      (O1O00011 == 1 && l010OO01 == 0)) // a is negative and not zero
    begin
      // output is NaN or infinity, depending on ieee_compliance
      // but status bit is marked as invalid operation
      O0l00010 = l0O111Ol;
      OI0O001l[2] = 1;
    end

  else if (II0l1011 == 1) 
    begin
      O0l00010 = OOl0l110;
      OI0O001l[1] = 1;
    end

  else if (l010OO01 == 1)
    begin
      O0l00010 = O1101l11;
      OI0O001l[1] = 1;
    end

  else if (O1101lll == 1)
    begin
      IO01l1lO = lIIOO1O0;
      // normalize it
      while (IO01l1lO[sig_width] == 0)
        begin
          IO01l1lO = IO01l1lO<<1;
          O1OI1I0I = O1OI1I0I - 1;
        end
      O0l00010 = 0;
    end
  else if (O1OI1I0I == ((1 << (exp_width-1)) - 1) &&  O1O0IO0I == 0 && O1O00011 == 0)
    begin
      O0l00010 = 0;
      OI0O001l[0] = 1;
    end
  else
    begin
      IO01l1lO = lIIOO1O0;
      O0l00010 = 0;
    end

  l0I1l1I0 = O0l00010;
  OOlIIl1O = OI0O001l;
  ll0OIO0O = IO01l1lO << (`DW_lO11100O-(sig_width+1));
  I1I1O1O1 = O1OI1I0I - $signed({1'b0, ((1 << (exp_width-1)) - 1)});
  end

  DW_log2 #(`DW_lO11100O, arch, 1) U1 (.a(ll0OIO0O), .z(lIIOl00O));

  // Once the fixed-point log2 is computed, normalize the output and
  // adjust Ol0lOO0l.
  always @ (lIIOl00O or I1I1O1O1)
  begin
    Ol0lOO0l = ((1 << (exp_width-1)) - 1);
    l011IOI1 = I1I1O1O1;
    OOO1lO0l = l011IOI1 <<< (`DW_lO11100O);
    O1011010 = lIIOl00O;
    lOOOI1O0 = O1011010;
    OlI00O00 = OOO1lO0l + lOOOI1O0;
    if (I1I1O1O1 < 0)
      begin
        I1Ol0OlI = -OlI00O00;
        Ol1OI0O1 = 1;
      end
    else
      begin
        I1Ol0OlI = OlI00O00;
        Ol1OI0O1 = 0;
      end
    // normalize/denormalize the output
    Ol0001IO = $unsigned(I1Ol0OlI);
    while ((Ol0001IO[`DW_lI1lIOOO-1:`DW_lO11100O+1] != 0) && 
           (Ol0001IO != 0))
      begin
        Ol0001IO = Ol0001IO >> 1;
        Ol0lOO0l = Ol0lOO0l + 1; 
      end
    OIll0O01 = Ol0001IO[`DW_lO11100O:0];
    while ((OIll0O01[`DW_lO11100O] == 0) && (OIll0O01 != 0) && (Ol0lOO0l > 1))
      begin
        OIll0O01 = OIll0O01 << 1;
        Ol0lOO0l = Ol0lOO0l - 1; 
      end
    
    
     // perform rounding
    lO0111Ol = {1'b0,OIll0O01[`DW_lO11100O:extra_prec+1]}+OIll0O01[extra_prec];
    if (lO0111Ol[sig_width+1]==1)
      // post-rounding normalization
      begin
        lO0111Ol = lO0111Ol >> 1;
        Ol0lOO0l = Ol0lOO0l + 1;
      end
    // decide on the output value
    if (lO0111Ol[sig_width] == 0)
      // it is a denormalized output
      if (ieee_compliance == 1)
	begin
          l11OOl11 = {Ol1OI0O1, {exp_width{1'b0}}, lO0111Ol[sig_width-1:0]};
          l100OO01[3] = 1;
        end
      else
        begin
          l11OOl11 = 0;
          l100OO01[3] = 1;
          l100OO01[0] = 1;
        end
    else
      begin
        // it is a normalized number
        if (|Ol0lOO0l[exp_width+5:exp_width] == 1)
          begin
            l100OO01[4] = 1;
            l100OO01[5] = 1;
            l100OO01[1] = 1;
            l11OOl11 = O1101l11;
          end
        else
          begin
            l100OO01 = 0;
            l11OOl11 = {Ol1OI0O1, Ol0lOO0l[exp_width-1:0],lO0111Ol[sig_width-1:0]};
          end
      end
    I1lO1I0O = l100OO01;
  end

  assign z = ((^(a ^ a) !== 1'b0)) ? {(exp_width + sig_width + 1){1'bx}} : 
             (OOlIIl1O != 0) ? l0I1l1I0 : l11OOl11;
  assign status = ((^(a ^ a) !== 1'b0)) ? {8    {1'bx}} : 
                  (OOlIIl1O != 0) ? OOlIIl1O : I1lO1I0O;

`undef DW_lO11100O
`undef DW_lI1lIOOO

// synopsys translate_on

endmodule


