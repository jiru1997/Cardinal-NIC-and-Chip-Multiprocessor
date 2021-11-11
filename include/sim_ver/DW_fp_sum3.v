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
// AUTHOR:    Alexandre F. Tenca (August 2006)
//
// VERSION:   Verilog Simulation Model - FP SUM3
//
// DesignWare_version: 5c2e7ece
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Three-operand Floating-point Adder (SUM3)
//           Computes the addition of three FP numbers. The format of the FP
//           numbers is defined by the number of bits in the significand 
//           (sig_width) and the number of bits in the exponent (exp_width).
//           The outputs are a FP number and status flags with information 
//           about special number representations and exceptions. 
//
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
//              b               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              c               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              rnd             3 bits
//                              rounding mode
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number -> a+b+c
//              status          byte
//                              info about FP result
//
// MODIFIED:
//-------------------------------------------------------------------------------

module DW_fp_sum3 (a, b, c, rnd, z, status);
parameter sig_width=23;             // RANGE 2 to 253 bits
parameter exp_width=8;              // RANGE 3 to 31 bits
parameter ieee_compliance=0;        // RANGE 0 or 1           
parameter arch_type=0;              // RANGE 0 or 1           

// declaration of inputs and outputs
input  [sig_width+exp_width:0] a,b,c;
input  [2:0] rnd;
output [7:0] status;
output [sig_width+exp_width:0] z;

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





function [4-1:0] O1111O11;

  input [2:0] Il1O1O1O;
  input [0:0] l0OOO100;
  input [0:0] O0I1IIIl,I1O001O0,O001I111;


  begin
  O1111O11[0] = 0;
  O1111O11[1] = I1O001O0|O001I111;
  O1111O11[2] = 0;
  O1111O11[3] = 0;
  if ($time > 0)
  case (Il1O1O1O)
    3'b000:
    begin
      O1111O11[0] = I1O001O0&(O0I1IIIl|O001I111);
      O1111O11[2] = 1;
      O1111O11[3] = 0;
    end
    3'b001:
    begin
      O1111O11[0] = 0;
      O1111O11[2] = 0;
      O1111O11[3] = 0;
    end
    3'b010:
    begin
      O1111O11[0] = ~l0OOO100 & (I1O001O0|O001I111);
      O1111O11[2] = ~l0OOO100;
      O1111O11[3] = ~l0OOO100;
    end
    3'b011:
    begin
      O1111O11[0] = l0OOO100 & (I1O001O0|O001I111);
      O1111O11[2] = l0OOO100;
      O1111O11[3] = l0OOO100;
    end
    3'b100:
    begin
      O1111O11[0] = I1O001O0;
      O1111O11[2] = 1;
      O1111O11[3] = 0;
    end
    3'b101:
    begin
      O1111O11[0] = I1O001O0|O001I111;
      O1111O11[2] = 1;
      O1111O11[3] = 1;
    end
    default:
      $display("Error! illegal rounding mode.\n");
  endcase
  end

endfunction




reg [8    -1:0] ll110l1I;
reg [(exp_width + sig_width):0] lIOO1001;
reg I0Il0O1I, OO101OOO, O0I0O01O;
reg [exp_width-1:0] Ol1Oll0I,O10111O0,OO0000OO; // Exponents
reg [sig_width-1:0] OI011O11,OO0O001O,OOlI01lO; // fraction bits
reg [sig_width:0] lOO0I110,OO1OO1l0,l1O1I0OO; // The Mantissa numbers
reg [((2*(sig_width+1)+2+4)-1)-3:0] OlOIO0l0,l111OO11,OlO1OOOI; // shifted mantissas
reg IIl00Ol1,OO01O0I1,OOO0O111;               // sign bits
reg [sig_width+3:0] O100O1I0;
reg O111OlI1, O00llO1O, lOO0I0lO;

// The biggest possible exponent for addition/subtraction
reg [exp_width-1:0] Ol1I00ll;
reg [exp_width-1:0] I0OIOlO0, l0l1lOO0, OI100lII;
reg [exp_width+1:0] OO11I001;
reg [(((2*(sig_width+1)+2+4)-1)-1)  :0] OI1lIl0O, O10IOI0O; // The Mantissa numbers.

reg [(exp_width + sig_width):0] O1O1IlI1;               // NaN FP number

reg [4-1:0] IlO1I01O;

// indication of special cases for the inputs
reg lO0l111O, IO11011l, IOIOIllO;
reg l0lI0000, l1O0O1OO, O1l111O0;
reg lIO0lIOl, Oll11OIO, I1IOO1OO;
reg lOOll11l, IO00OO1I, l0I11010;

// internal variables
reg [((2*(sig_width+1)+2+4)-1):0] O000OO0O, O0011101, OI10O11O; 
reg [((2*(sig_width+1)+2+4)-1):0] OOIO01O1; 
reg O00IOO01;
reg [((2*(sig_width+1)+2+4)-1)-1:0] l001011I; 
reg [((2*(sig_width+1)+2+4)-1):0] O1011Ol0, OOO1O1O1, lOIO1OO1; 
reg O001I111;
reg [exp_width-1:0] O1IOI01O;
reg [(exp_width + sig_width + 1)-1:0] lO010O10;
reg [(exp_width + sig_width + 1)-1:0] I00O01lO;

//---------------------------------------------------------------
// The following portion of the code describes DW_fp_sum3 when
// arch_type = 1
//---------------------------------------------------------------


wire [sig_width+exp_width : 0] l10O0O1I;
wire [7 : 0] I0IO0O0O;

wire [sig_width+2+exp_width+6:0] l010O0ll;
wire [sig_width+2+exp_width+6:0] Ol0010O0;
wire [sig_width+2+3+exp_width+1+6:0] O1OI0l10; 
wire [sig_width+2+3+exp_width+1+6:0] l11OOlI1; // result of a+b = d
wire [sig_width+2+3+sig_width+exp_width+1+1+6:0] lO111I0I; // result of d+c


  // Instances of DW_fp_ifp_conv  -- format converters
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U1 ( .a(a), .z(l010O0ll) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U2 ( .a(b), .z(Ol0010O0) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2+3, exp_width+1, ieee_compliance, 0)
          U3 ( .a(c), .z(O1OI0l10) );
  // Instances of DW_ifp_addsub
    DW_ifp_addsub #(sig_width+2, exp_width, sig_width+2+3, exp_width+1, ieee_compliance, 0)
	  U4 ( .a(l010O0ll), .b(Ol0010O0), .op(1'b0), .rnd(rnd), 
               .z(l11OOlI1) );
    DW_ifp_addsub #(sig_width+2+3, exp_width+1, sig_width+2+3+sig_width, exp_width+1+1, ieee_compliance, 0)
	  U5 ( .a(l11OOlI1), .b(O1OI0l10), .op(1'b0), .rnd(rnd),
               .z(lO111I0I) );
  // Instance of DW_ifp_fp_conv  -- format converter
    DW_ifp_fp_conv #(sig_width+2+3+sig_width, exp_width+1+1, sig_width, exp_width, ieee_compliance)
          U6 ( .a(lO111I0I), .rnd(rnd), .z(l10O0O1I), .status(I0IO0O0O) );

//-------------------------------------------------------------------
// The following code is used to describe the DW_fp_sum3 component
// when arch_type = 0
//-------------------------------------------------------------------
// main process of information
always @(a or b or c or rnd)
begin
  O1O1IlI1 = (ieee_compliance === 1)?{1'b0,{exp_width{1'b1}},{sig_width-1{1'b0}},1'b1}:
                                  {1'b0,{exp_width{1'b1}},{sig_width{1'b0}}};
  ll110l1I = 0;
  O100O1I0 = 0;
  O111OlI1 = 0;
  O00llO1O = 0;
  lOO0I0lO = 0;
  lO010O10[(exp_width + sig_width)] = 0;
  lO010O10[((exp_width + sig_width) - 1):sig_width] = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
  lO010O10[(sig_width - 1):0] = 0;
  I00O01lO[(exp_width + sig_width)] = 1;
  I00O01lO[((exp_width + sig_width) - 1):sig_width] = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
  I00O01lO[(sig_width - 1):0] = 0;

  Ol1Oll0I = a[((exp_width + sig_width) - 1):sig_width];
  O10111O0 = b[((exp_width + sig_width) - 1):sig_width];
  OO0000OO = c[((exp_width + sig_width) - 1):sig_width];
  OI011O11 = a[(sig_width - 1):0];
  OO0O001O = b[(sig_width - 1):0];
  OOlI01lO = c[(sig_width - 1):0];
  IIl00Ol1 = a[(exp_width + sig_width)];
  OO01O0I1 = b[(exp_width + sig_width)];
  OOO0O111 = c[(exp_width + sig_width)]; 

  if ((Ol1Oll0I === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((OI011O11 === 0) || (ieee_compliance === 0)))
     l0lI0000 = 1;
  else
     l0lI0000 = 0;
  if ((O10111O0 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((OO0O001O === 0) || (ieee_compliance === 0)))
     l1O0O1OO = 1;
  else
     l1O0O1OO = 0;
  if ((OO0000OO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((OOlI01lO === 0) || (ieee_compliance === 0)))  
     O1l111O0 = 1;
  else
     O1l111O0 = 0;
  if ((Ol1Oll0I === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (OI011O11 != 0) && (ieee_compliance === 1))  
     lIO0lIOl = 1;
  else
     lIO0lIOl = 0;
  if ((O10111O0 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (OO0O001O != 0) && (ieee_compliance === 1))  
     Oll11OIO = 1;
  else
     Oll11OIO = 0;
  if ((OO0000OO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (OOlI01lO != 0) && (ieee_compliance === 1))  
     I1IOO1OO = 1;
  else
     I1IOO1OO = 0;
  if ((Ol1Oll0I === {exp_width{1'b0}}) && ((OI011O11 === 0) || (ieee_compliance === 0))) 
    begin
      lOOll11l = 1;
      OI011O11 = 0;
    end
  else
    lOOll11l = 0;
  if ((O10111O0 === {exp_width{1'b0}}) && ((OO0O001O === 0) || (ieee_compliance === 0)))  
    begin
      IO00OO1I = 1;
      OO0O001O = 0;
    end
  else
    IO00OO1I = 0;
  if ((OO0000OO === {exp_width{1'b0}}) && ((OOlI01lO === 0) || (ieee_compliance === 0)))  
    begin
      l0I11010 = 1;
      OOlI01lO = 0;
    end
  else
     l0I11010 = 0;
  if ((Ol1Oll0I === {exp_width{1'b0}}) && (OI011O11 != 0) && (ieee_compliance === 1)) 
    begin
      lO0l111O = 1;
      Ol1Oll0I = {{exp_width-1{1'b0}},1'b1};
    end
  else
    lO0l111O = 0;
  if ((O10111O0 === {exp_width{1'b0}}) && (OO0O001O != 0) && (ieee_compliance === 1)) 
    begin
      IO11011l = 1;
      O10111O0 = {{exp_width-1{1'b0}},1'b1};
    end
  else
    IO11011l = 0;
  if ((OO0000OO === {exp_width{1'b0}}) && (OOlI01lO != 0) && (ieee_compliance === 1)) 
    begin
      IOIOIllO = 1;
      OO0000OO = {{exp_width-1{1'b0}},1'b1};
    end
  else
    IOIOIllO = 0;

  if ((lIO0lIOl === 1) || (Oll11OIO === 1) || (I1IOO1OO === 1)) 
    begin
      lIOO1001 = O1O1IlI1;
      ll110l1I[2] = 1;
    end
  else if  (l0lI0000 === 1) 
    if (((l1O0O1OO === 1) && (IIl00Ol1 != OO01O0I1)) || ((O1l111O0 === 1) && (IIl00Ol1 != OOO0O111))) 
      begin
        lIOO1001 = O1O1IlI1;
        ll110l1I[2] = 1;
        ll110l1I[1] = (ieee_compliance === 1)?0:1;
      end
    else 
      begin
        ll110l1I[1] = 1;
        lIOO1001 = (IIl00Ol1)?I00O01lO:lO010O10;
      end
  else if (l1O0O1OO === 1) 
    if (((l0lI0000 === 1) && (IIl00Ol1 != OO01O0I1)) || ((O1l111O0 === 1) && (OO01O0I1 != OOO0O111))) 
      begin
        lIOO1001 = O1O1IlI1;
        ll110l1I[2] = 1;
        ll110l1I[1] = (ieee_compliance === 1)?0:1;
      end
    else
      begin
        ll110l1I[1] = 1;
        lIOO1001 = (OO01O0I1)?I00O01lO:lO010O10;
      end
  else if (O1l111O0 === 1) 
    if (((l0lI0000 === 1) && (IIl00Ol1 != OOO0O111)) || ((l1O0O1OO === 1) && (OO01O0I1 != OOO0O111))) 
      begin
        lIOO1001 = O1O1IlI1;
        ll110l1I[2] = 1;
        ll110l1I[1] = (ieee_compliance === 1)?0:1;
      end
    else
      begin
        ll110l1I[1] = 1;
        lIOO1001 = (OOO0O111)?I00O01lO:lO010O10;
      end

  else if ((lOOll11l === 1) && (IO00OO1I === 1) && (l0I11010 === 1)) 
    begin
      lIOO1001 =  0;
      ll110l1I[0] = 1;
      if (ieee_compliance === 0)
        if (rnd === 3)
          lIOO1001[(exp_width + sig_width)] = 1'b1;
        else
          lIOO1001[(exp_width + sig_width)] = 1'b0;
      else
        if ((IIl00Ol1 === OO01O0I1) && (OO01O0I1 === OOO0O111)) 
          lIOO1001[(exp_width + sig_width)] = IIl00Ol1;
        else
          if (rnd === 3) 
            lIOO1001[(exp_width + sig_width)] = 1'b1;
          else
            lIOO1001[(exp_width + sig_width)] = 1'b0;
    end

  else if ((a[((exp_width + sig_width) - 1):0] == b[((exp_width + sig_width) - 1):0]) && (IIl00Ol1 != OO01O0I1))
    begin
      lIOO1001 = c;
      ll110l1I[0] = l0I11010;
      ll110l1I[3] = IOIOIllO;
      if (l0I11010 === 1)
        begin
          if (rnd == 3)
            lIOO1001[(exp_width + sig_width)] = 1'b1;
          else
            lIOO1001[(exp_width + sig_width)] = 1'b0;
        end
    end

  else if ((b[((exp_width + sig_width) - 1):0] == c[((exp_width + sig_width) - 1):0]) && (OO01O0I1 != OOO0O111))
    begin
      lIOO1001 = a;
      ll110l1I[0] = lOOll11l;
      ll110l1I[3] = lO0l111O;
      if (lOOll11l === 1)
        begin
          if (rnd == 3)
            lIOO1001[(exp_width + sig_width)] = 1'b1;
          else
            lIOO1001[(exp_width + sig_width)] = 1'b0;
        end
    end

  else if ((a[((exp_width + sig_width) - 1):0] == c[((exp_width + sig_width) - 1):0]) && (IIl00Ol1 != OOO0O111))
    begin
      lIOO1001 = b;
      ll110l1I[0] = IO00OO1I;
      ll110l1I[3] = IO11011l;
      if (IO00OO1I === 1)
        begin
          if (rnd == 3)
            lIOO1001[(exp_width + sig_width)] = 1'b1;
          else
            lIOO1001[(exp_width + sig_width)] = 1'b0;
        end
    end

  else  
  begin
    if (lO0l111O === 1 || lOOll11l === 1) 
       lOO0I110 = (ieee_compliance == 1)?{1'b0,OI011O11}:0;
    else
       lOO0I110 = {1'b1,OI011O11};
    if (IO11011l === 1 || IO00OO1I === 1) 
       OO1OO1l0 = (ieee_compliance == 1)?{1'b0,OO0O001O}:0;
    else
       OO1OO1l0 = {1'b1,OO0O001O};
    if (IOIOIllO === 1 || l0I11010 === 1) 
       l1O1I0OO = (ieee_compliance == 1)?{1'b0,OOlI01lO}:0;
    else
       l1O1I0OO = {1'b1,OOlI01lO};
  
    if ((Ol1Oll0I > O10111O0) && (Ol1Oll0I > OO0000OO)) 
      Ol1I00ll = Ol1Oll0I;
    else if ((O10111O0 >= Ol1Oll0I) && (O10111O0 > OO0000OO)) 
      Ol1I00ll = O10111O0;
    else
      Ol1I00ll = OO0000OO;
    I0OIOlO0 = Ol1I00ll - Ol1Oll0I;
    l0l1lOO0 = Ol1I00ll - O10111O0;
    OI100lII = Ol1I00ll - OO0000OO;

    I0Il0O1I = 0;
    OlOIO0l0 = {lOO0I110,O100O1I0};
    O1IOI01O = I0OIOlO0;
    while ( (OlOIO0l0 != 0) && (O1IOI01O != {exp_width{1'b0}}) ) 
      begin
        I0Il0O1I = OlOIO0l0[0] || I0Il0O1I;
        OlOIO0l0 = OlOIO0l0 >> 1;
        O1IOI01O = O1IOI01O - 1;
      end
    I0Il0O1I = OlOIO0l0[0] || I0Il0O1I;
    OlOIO0l0[0] = 0;

    OO101OOO = 0;
    l111OO11 = {OO1OO1l0,O100O1I0};
    O1IOI01O = l0l1lOO0;
    while ( (l111OO11 != 0) && (O1IOI01O != {exp_width{1'b0}}) ) 
      begin
        OO101OOO = l111OO11[0] || OO101OOO;
        l111OO11 = l111OO11 >> 1;
        O1IOI01O = O1IOI01O - 1;
      end
    OO101OOO = l111OO11[0] || OO101OOO;
    l111OO11[0] = 0;

    O0I0O01O = 0;
    OlO1OOOI = {l1O1I0OO,O100O1I0};
    O1IOI01O = OI100lII;
    while ( (OlO1OOOI != 0) && (O1IOI01O != {exp_width{1'b0}}) ) 
      begin
        O0I0O01O = OlO1OOOI[0] || O0I0O01O;
        OlO1OOOI = OlO1OOOI >> 1;
        O1IOI01O = O1IOI01O - 1;
      end
    O0I0O01O = OlO1OOOI[0] || O0I0O01O;
    OlO1OOOI[0] = 0;

    if ((I0Il0O1I == 1) && (OO101OOO == 1))
      begin
        O111OlI1 = ({Ol1Oll0I,lOO0I110} < {O10111O0,OO1OO1l0});
        O00llO1O = ~O111OlI1;
        lOO0I0lO = 0;      
      end
    if ((OO101OOO == 1) && (O0I0O01O == 1)) 
      begin
        O00llO1O = ({O10111O0,OO1OO1l0} < {OO0000OO,l1O1I0OO});
        lOO0I0lO = ~O00llO1O;
        O111OlI1 = 0;      
      end
    if ((I0Il0O1I == 1) && (O0I0O01O == 1)) 
      begin
        O111OlI1 = ({Ol1Oll0I,lOO0I110} < {OO0000OO,l1O1I0OO});
        lOO0I0lO = ~O111OlI1;
        O00llO1O = 0;      
      end

    OlOIO0l0[0] = (~O111OlI1 & I0Il0O1I) | OlOIO0l0[0];
    l111OO11[0] = (~O00llO1O & OO101OOO) | l111OO11[0];
    OlO1OOOI[0] = (~lOO0I0lO & O0I0O01O) | OlO1OOOI[0];

    O1011Ol0 = {3'b0,OlOIO0l0};
    OOO1O1O1 = {3'b0,l111OO11};
    lOIO1OO1 = {3'b0,OlO1OOOI};

    if (IIl00Ol1 === 1) 
      O000OO0O = ~O1011Ol0 + 1;
    else 
      O000OO0O = O1011Ol0;
    if (OO01O0I1 === 1) 
      O0011101 = ~OOO1O1O1 + 1;
    else 
      O0011101 = OOO1O1O1;
    if (OOO0O111 === 1) 
      OI10O11O = ~lOIO1OO1 + 1;
    else 
      OI10O11O = lOIO1OO1;

    OOIO01O1 = O000OO0O + O0011101 + OI10O11O;
    
    O00IOO01 = OOIO01O1[((2*(sig_width+1)+2+4)-1)];
    if (O00IOO01 === 1) 
      l001011I = ~OOIO01O1[((2*(sig_width+1)+2+4)-1)-1:0]+1;
    else
      l001011I = OOIO01O1[((2*(sig_width+1)+2+4)-1)-1:0];

    OI1lIl0O = l001011I;
    O10IOI0O = l001011I;
    
    OO11I001 = {2'b0, Ol1I00ll};

      O001I111 = 0;
      if (OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  ] === 1) 
        begin
          OO11I001 = OO11I001 + 1;
          O001I111 = OI1lIl0O[0];
          OI1lIl0O = OI1lIl0O>>1;
        end
      if (OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  -1] === 1) 
        begin
          OO11I001 = OO11I001 + 1;
          O001I111 = O001I111 || OI1lIl0O[0];
          OI1lIl0O = OI1lIl0O>>1;
        end

      while ( (OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  -2] === 0) && (OO11I001 > {{exp_width-1{1'b0}},1'b1}) ) 
        begin
          OO11I001 = OO11I001 - 1;
          OI1lIl0O = {OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  -1:0], 1'b0};
        end

        IlO1I01O = O1111O11(rnd, O00IOO01, OI1lIl0O[((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)], OI1lIl0O[(((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)-1) ],
                           (|{OI1lIl0O[(((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)-1) -1:0],I0Il0O1I,OO101OOO,O0I0O01O,O001I111}));

        if (IlO1I01O[0] === 1) 
          OI1lIl0O = OI1lIl0O + (1<<((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width));

        if ( (OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  -1] === 1) ) 
          begin
            OO11I001 = OO11I001 + 1;
            OI1lIl0O = OI1lIl0O >> 1;
          end 

      if (OI1lIl0O === 0) 
        begin
          ll110l1I[0] = 1;
          lIOO1001 = 0;
          if (rnd === 3) 
            lIOO1001[(exp_width + sig_width)] = 1;
          else
            lIOO1001[(exp_width + sig_width)] = 0;
        end

       else 
        if (OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  :(((2*(sig_width+1)+2+4)-1)-1)  -2] === 0) 
          begin
            if (ieee_compliance == 1)
              begin
                lIOO1001 = {O00IOO01, {exp_width{1'b0}}, OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  -3:((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)]};
                ll110l1I[3] = 1;
                ll110l1I[5] =  IlO1I01O[1];
                if (OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  -3:((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)] == 0)
                  ll110l1I[0] = 1; 
              end
            else
              begin
                ll110l1I[3] = 1;
                ll110l1I[5] = 1;
                if ((rnd == 3 && O00IOO01 == 1) ||
                    (rnd == 2 && O00IOO01 == 0) || rnd == 5) 
                  begin
                    lIOO1001 = {O00IOO01, {exp_width-1{1'b0}}, 1'b1, {sig_width{1'b0}}};
                    ll110l1I[0] = 0;
                  end
                else
                  begin
                    lIOO1001 = {O00IOO01, {exp_width+sig_width{1'b0}}};
                    ll110l1I[0] = 1;
                  end
              end
          end
        else
          begin
            if (OO11I001 >= ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) 
              begin
                ll110l1I[5] = 1;
                if (IlO1I01O[2] === 1) 
                  begin
                    OI1lIl0O = 0;
                    OO11I001 = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
                    ll110l1I[1] = 1;
                    ll110l1I[4] = 1;
                  end
                else
                  begin
                    OO11I001 = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}) - 1;
                    OI1lIl0O = ~(0);
                  end
              end
             else
               if (OO11I001 <= {exp_width{1'b0}}) 
                 OO11I001 = {exp_width{1'b0}} + 1;

            ll110l1I[5] = ll110l1I[5] || IlO1I01O[1];
            lIOO1001 = {O00IOO01, OO11I001[exp_width-1:0], OI1lIl0O[(((2*(sig_width+1)+2+4)-1)-1)  -3:((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)]};

          end
      
  end

end

assign status = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0)  || (^(c ^ c) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? {8'bx} : 
                 (arch_type === 1)?I0IO0O0O:ll110l1I;
assign z = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? {sig_width+exp_width+1{1'bx}} : 
                 (arch_type === 1)?l10O0O1I:lIOO1001;
  
// synopsys translate_on  

endmodule
