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
// VERSION:   Verilog Simulation Model - FP SUM4
//
// DesignWare_version: fafcada1
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Four-operand Floating-point Adder (SUM4)
//           Computes the addition of four FP numbers. The format of the FP
//           numbers is defined by the number of bits in the significand 
//           (sig_width) and the number of bits in the exponent (exp_width).
//           The total number of bits in each FP number is sig_width+exp_width+1.
//           The sign bit takes the place of the MS bit in the significand,
//           which is always 1 (unless the number is a denormal; a condition 
//           that can be detected testing the exponent value).
//           The outputs are a FP number and status flags with information about
//           special number representations and exceptions. 
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand f,  2 to 253 bits
//              exp_width       exponent e,     3 to 31 bits
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
//              d               (sig_width + exp_width + 1)-bits
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
//
// MODIFIED:
//
//-------------------------------------------------------------------------------

module DW_fp_sum4 (a, b, c, d, rnd, z, status);
parameter sig_width=23;
parameter exp_width=8;
parameter ieee_compliance=0;                    
parameter arch_type=0;

// declaration of inputs and outputs
input  [sig_width+exp_width:0] a,b,c,d;
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




function [4-1:0] ll1lO01I;

  input [2:0] I0OO1101;
  input [0:0] Sign;
  input [0:0] I0OOOOOO,l111I0I1,O101lII0;


  begin
  ll1lO01I[0] = 0;
  ll1lO01I[1] = l111I0I1|O101lII0;
  ll1lO01I[2] = 0;
  ll1lO01I[3] = 0;
  if ($time > 0)
  case (I0OO1101)
    3'b000:
    begin
      ll1lO01I[0] = l111I0I1&(I0OOOOOO|O101lII0);
      ll1lO01I[2] = 1;
      ll1lO01I[3] = 0;
    end
    3'b001:
    begin
      ll1lO01I[0] = 0;
      ll1lO01I[2] = 0;
      ll1lO01I[3] = 0;
    end
    3'b010:
    begin
      ll1lO01I[0] = ~Sign & (l111I0I1|O101lII0);
      ll1lO01I[2] = ~Sign;
      ll1lO01I[3] = ~Sign;
    end
    3'b011:
    begin
      ll1lO01I[0] = Sign & (l111I0I1|O101lII0);
      ll1lO01I[2] = Sign;
      ll1lO01I[3] = Sign;
    end
    3'b100:
    begin
      ll1lO01I[0] = l111I0I1;
      ll1lO01I[2] = 1;
      ll1lO01I[3] = 0;
    end
    3'b101:
    begin
      ll1lO01I[0] = l111I0I1|O101lII0;
      ll1lO01I[2] = 1;
      ll1lO01I[3] = 1;
    end
    default:
      $display("Error! illegal rounding mode.\n");
  endcase
  end

endfunction




reg [8    -1:0] OOI0101l;
reg [(exp_width + sig_width):0] l00O1I0O;
reg O01l1O11, I010O1Il, I01IO10l, OOOl1lI0;
reg [exp_width-1:0] l00OlIOI,l1OlOO0l,lO001000,IO0lOOlO; // Exponents
reg [sig_width-1:0] IOO10001,OOO000lI,O10O1I1O,l100OOIl; // fraction bits
reg [sig_width:0] O11llO11,O0Ol1O1l,O110011O,lIl1ll0I;   // The Mantissa bit vectors
reg [(2*(sig_width+1)+3+2+1)-1-3:0] Ol1O0O11,ll0O0OI1,I1OO01OI,OO011l1I;  
reg I0O1IOO1,O1OI1I1O,l110O0O1,O01I0O1l;          // sign bits
reg lI11O1Ol, l110OOll, lOOOIl1O, O1OlOlOO;
reg lOIOl1l1;
reg Ol0O010O,l0I0O110,OI0100IO,lOOO10I1;

// The biggest possible exponent for addition/subtraction
reg [exp_width-1:0] OO1I100l;
reg [exp_width-1:0] II011O01, O1OI100O, I0O10l11, O0OIOl10;
reg [exp_width+1:0] Ol1OO1l0;
reg [(((2*(sig_width+1)+3+2+1)-1)-1)  :0] O00l1lI1, l1l10lOO; // The Mantissa numbers.
reg [sig_width+2+1:0] I111101l;

reg [(exp_width + sig_width):0] O1IlOl1I;               // NaN FP number

// Contains values returned by ll1lO01I function.
reg [4-1:0] lOOOII0I;

// indication of special cases for the inputs
reg OO10IO0O, O0O01OO0, OIOl0O1O, I010Il1O;
reg O0O0OO1O, O00010IO, OlOlOI0O, OO111110;
reg llOlO1l1, lOOIOlOl, OOOOl1OI, O0I1l11I;
reg OO00100I, Ol0l01IO, llO1IOl0, l1O110II;

// internal variables
reg [((2*(sig_width+1)+3+2+1)-1):0] l00O1IO0, lOl1lIOO, OlIll11O, OO000000; 
reg [((2*(sig_width+1)+3+2+1)-1):0] O1ll0100; 
reg I1IlO10O;
reg [((2*(sig_width+1)+3+2+1)-1)-1:0] O0lIl1Ol; 
reg [((2*(sig_width+1)+3+2+1)-1):0] O1I110OO, I0lI1010, IOl0lOO0, O011IOl0; 
reg O11lI101;
reg [exp_width-1:0] O00I1OlI;
reg [(((2*(sig_width+1)+3+2+1)-1)-1)  :0] OOI0IO1I;
reg [(exp_width + sig_width + 1)-1:0] l01000Ol;
reg [(exp_width + sig_width + 1)-1:0] O00I10O0;

//---------------------------------------------------------------
// The following portion of the code describes DW_fp_sum3 when
// arch_type = 1
//---------------------------------------------------------------


wire [sig_width+exp_width : 0] IO10OIlO;
wire [7 : 0] l0O01OIO;

wire [sig_width+2+exp_width+6:0] l0OOO110;
wire [sig_width+2+exp_width+6:0] l1IIO0O1;
wire [sig_width+2+exp_width+6:0] O1O10l10; 
wire [sig_width+2+exp_width+6:0] OO101IOO;
wire [sig_width+2+3+exp_width+1+6:0] O1I0OlO0; // result of a+b = e
wire [sig_width+2+3+exp_width+1+6:0] I0OOIllO; // result of c+d = f
wire [sig_width+2+3+sig_width+exp_width+1+1+6:0] Oll0110I; // result of e+f = g

  // Instances of DW_fp_ifp_conv  -- format converters
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U1 ( .a(a), .z(l0OOO110) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U2 ( .a(b), .z(l1IIO0O1) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U3 ( .a(c), .z(O1O10l10) );
    DW_fp_ifp_conv #(sig_width, exp_width, sig_width+2, exp_width, ieee_compliance, 0)
          U4 ( .a(d), .z(OO101IOO) );
  // Instances of DW_ifp_addsub
    DW_ifp_addsub #(sig_width+2, exp_width, sig_width+2+3, exp_width+1, ieee_compliance)
          U5 ( .a(l0OOO110), .b(l1IIO0O1), .op(1'b0), .rnd(rnd), 
               .z(O1I0OlO0) );
    DW_ifp_addsub #(sig_width+2, exp_width, sig_width+2+3, exp_width+1, ieee_compliance)
          U6 ( .a(O1O10l10), .b(OO101IOO), .op(1'b0), .rnd(rnd), 
               .z(I0OOIllO) );
    DW_ifp_addsub #(sig_width+2+3, exp_width+1, sig_width+2+3+sig_width, exp_width+1+1, ieee_compliance)
          U7 ( .a(O1I0OlO0), .b(I0OOIllO), .op(1'b0), .rnd(rnd), 
               .z(Oll0110I) );
  // Instance of DW_ifp_fp_conv  -- format converter
    DW_ifp_fp_conv #(sig_width+2+3+sig_width, exp_width+1+1, sig_width, exp_width, ieee_compliance)
          U8 ( .a(Oll0110I), .rnd(rnd), .z(IO10OIlO), .status(l0O01OIO) );


//-------------------------------------------------------------------
// The following code is used to describe the DW_fp_sum4 component
// when arch_type = 0
//-------------------------------------------------------------------
// main process of information
always @(a or b or c or d or rnd)
begin
  O1IlOl1I = (ieee_compliance === 1)?{1'b0,{exp_width{1'b1}},{sig_width-1{1'b0}},1'b1}:
                                  {1'b0,{exp_width{1'b1}},{sig_width{1'b0}}};
  OOI0101l = 0;
  I111101l = 0;
  lI11O1Ol = 0;
  l110OOll = 0;
  lOOOIl1O = 0;
  O1OlOlOO = 0;
  l01000Ol[(exp_width + sig_width)] = 0;
  l01000Ol[((exp_width + sig_width) - 1):sig_width] = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
  l01000Ol[(sig_width - 1):0] = 0;
  O00I10O0[(exp_width + sig_width)] = 1;
  O00I10O0[((exp_width + sig_width) - 1):sig_width] = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
  O00I10O0[(sig_width - 1):0] = 0;

  l00OlIOI = a[((exp_width + sig_width) - 1):sig_width];
  l1OlOO0l = b[((exp_width + sig_width) - 1):sig_width];
  lO001000 = c[((exp_width + sig_width) - 1):sig_width];
  IO0lOOlO = d[((exp_width + sig_width) - 1):sig_width];
  IOO10001 = a[(sig_width - 1):0];
  OOO000lI = b[(sig_width - 1):0];
  O10O1I1O = c[(sig_width - 1):0];
  l100OOIl = d[(sig_width - 1):0];
  I0O1IOO1 = a[(exp_width + sig_width)];
  O1OI1I1O = b[(exp_width + sig_width)];
  l110O0O1 = c[(exp_width + sig_width)]; 
  O01I0O1l = d[(exp_width + sig_width)]; 

  if ((l00OlIOI === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((IOO10001 === 0) || (ieee_compliance === 0)))
     O0O0OO1O = 1;
  else
     O0O0OO1O = 0;
  if ((l1OlOO0l === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((OOO000lI === 0) || (ieee_compliance === 0)))
     O00010IO = 1;
  else
     O00010IO = 0;
  if ((lO001000 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((O10O1I1O === 0) || (ieee_compliance === 0)))  
     OlOlOI0O = 1;
  else
     OlOlOI0O = 0;
  if ((IO0lOOlO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && ((l100OOIl === 0) || (ieee_compliance === 0)))  
     OO111110 = 1;
  else
     OO111110 = 0;
  if ((l00OlIOI === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (IOO10001 != 0) && (ieee_compliance === 1))  
     llOlO1l1 = 1;
  else
     llOlO1l1 = 0;
  if ((l1OlOO0l === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (OOO000lI != 0) && (ieee_compliance === 1))  
     lOOIOlOl = 1;
  else
     lOOIOlOl = 0;
  if ((lO001000 === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (O10O1I1O != 0) && (ieee_compliance === 1))  
     OOOOl1OI = 1;
  else
     OOOOl1OI = 0;
  if ((IO0lOOlO === ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) && (l100OOIl != 0) && (ieee_compliance === 1))  
     O0I1l11I = 1;
  else
     O0I1l11I = 0;
  if ((l00OlIOI === {exp_width{1'b0}}) && ((IOO10001 === 0) || (ieee_compliance === 0))) 
    begin
      OO00100I = 1;
      IOO10001 = 0;
    end
  else
     OO00100I = 0;
  if ((l1OlOO0l === {exp_width{1'b0}}) && ((OOO000lI === 0) || (ieee_compliance === 0))) 
    begin
      Ol0l01IO = 1;
      OOO000lI = 0;
    end
  else
     Ol0l01IO = 0;
  if ((lO001000 === {exp_width{1'b0}}) && ((O10O1I1O === 0) || (ieee_compliance === 0))) 
    begin
      llO1IOl0 = 1;
      O10O1I1O = 0;
    end
  else
     llO1IOl0 = 0;
  if ((IO0lOOlO === {exp_width{1'b0}}) && ((l100OOIl === 0) || (ieee_compliance === 0))) 
    begin
      l1O110II = 1;
      l100OOIl = 0;
    end
  else
     l1O110II = 0;
  if ((l00OlIOI === {exp_width{1'b0}}) && (IOO10001 != 0) && (ieee_compliance === 1)) 
    begin
      OO10IO0O =  1;
      l00OlIOI = {{exp_width-1{1'b0}},1'b1};
    end
  else
     OO10IO0O = 0;
  if ((l1OlOO0l === {exp_width{1'b0}}) && (OOO000lI != 0) && (ieee_compliance === 1)) 
    begin
      O0O01OO0 =  1;
      l1OlOO0l = {{exp_width-1{1'b0}},1'b1};
    end     
  else
     O0O01OO0 = 0;
  if ((lO001000 === {exp_width{1'b0}}) && (O10O1I1O != 0) && (ieee_compliance === 1)) 
    begin
      OIOl0O1O =  1;
      lO001000 = {{exp_width-1{1'b0}},1'b1};
    end     
  else
     OIOl0O1O = 0;
  if ((IO0lOOlO === {exp_width{1'b0}}) && (l100OOIl != 0) && (ieee_compliance === 1)) 
    begin
      I010Il1O =  1;
      IO0lOOlO = {{exp_width-1{1'b0}},1'b1};
    end     
  else
     I010Il1O = 0;

  if ((llOlO1l1 === 1) || (lOOIOlOl === 1) || (OOOOl1OI === 1) || (O0I1l11I === 1)) 
    begin
      l00O1I0O = O1IlOl1I;
      OOI0101l[2] = 1;
    end
  else if  (O0O0OO1O === 1) 
    if (((O00010IO === 1) && (I0O1IOO1 != O1OI1I1O)) || ((OlOlOI0O === 1) && (I0O1IOO1 != l110O0O1))
         || ((OO111110 === 1) && (I0O1IOO1 != O01I0O1l))) 
      begin
        l00O1I0O =O1IlOl1I;
        OOI0101l[2] = 1;
        OOI0101l[1] = (ieee_compliance === 1)?0:1;
      end
    else 
      begin
        OOI0101l[1] = 1;
        l00O1I0O = (I0O1IOO1)?O00I10O0:l01000Ol;
      end
  else if (O00010IO === 1) 
    if (((O0O0OO1O === 1) && (I0O1IOO1 != O1OI1I1O)) || ((OlOlOI0O === 1) && (O1OI1I1O != l110O0O1))
        || ((OO111110 === 1) && (O1OI1I1O != O01I0O1l))) 
      begin
        l00O1I0O = O1IlOl1I;
        OOI0101l[2] = 1;
        OOI0101l[1] = (ieee_compliance === 1)?0:1;
      end
    else
      begin
        OOI0101l[1] = 1;
        l00O1I0O = (O1OI1I1O)?O00I10O0:l01000Ol;
      end
  else if (OlOlOI0O === 1) 
    if (((O0O0OO1O === 1) && (I0O1IOO1 != l110O0O1)) || ((O00010IO === 1) && (O1OI1I1O != l110O0O1)) 
        || ((OO111110 === 1) && (O01I0O1l != l110O0O1))) 
      begin
        l00O1I0O = O1IlOl1I;
        OOI0101l[2] = 1;
        OOI0101l[1] = (ieee_compliance === 1)?0:1;
      end
    else
      begin
        OOI0101l[1] = 1;
        l00O1I0O = (l110O0O1)?O00I10O0:l01000Ol;
      end
  else if (OO111110 === 1) 
    if (((O0O0OO1O === 1) && (I0O1IOO1 != O01I0O1l)) || ((O00010IO === 1) && (O1OI1I1O != O01I0O1l)) 
        || ((OlOlOI0O === 1) && (O01I0O1l != l110O0O1))) 
      begin
        l00O1I0O = O1IlOl1I;
        OOI0101l[2] = 1;
         OOI0101l[1] = (ieee_compliance === 1)?0:1;
     end
    else
      begin
        OOI0101l[1] = 1;
        l00O1I0O = (O01I0O1l)?O00I10O0:l01000Ol;
      end
  
  else if ((OO00100I === 1) && (Ol0l01IO === 1) && (llO1IOl0 === 1) && (l1O110II === 1)) 
    begin
      l00O1I0O =  0;
      OOI0101l[0] = 1;
      if (ieee_compliance === 0)
        begin
          if (rnd === 3) 
            l00O1I0O[(exp_width + sig_width)] = 1'b1;
          else
            l00O1I0O[(exp_width + sig_width)] = 1'b0;
	end
      else
        if (I0O1IOO1 === O1OI1I1O && O1OI1I1O === l110O0O1 && l110O0O1 === O01I0O1l) 
          l00O1I0O[(exp_width + sig_width)] = I0O1IOO1;
        else
          begin
            if (rnd === 3) 
              l00O1I0O[(exp_width + sig_width)] = 1'b1;
            else
              l00O1I0O[(exp_width + sig_width)] = 1'b0;
          end
    end

  else  
  begin                                       
    if (OO10IO0O === 1 || OO00100I === 1) 
       O11llO11 = (ieee_compliance == 1)?{1'b0,IOO10001}:0;
    else
       O11llO11 = {1'b1,IOO10001};
    if (O0O01OO0 === 1 || Ol0l01IO === 1) 
       O0Ol1O1l = (ieee_compliance == 1)?{1'b0,OOO000lI}:0;
    else
       O0Ol1O1l = {1'b1,OOO000lI};
    if (OIOl0O1O === 1 || llO1IOl0 === 1) 
       O110011O = (ieee_compliance == 1)?{1'b0,O10O1I1O}:0;
    else
       O110011O = {1'b1,O10O1I1O};
    if (I010Il1O === 1 || l1O110II === 1) 
       lIl1ll0I = (ieee_compliance == 1)?{1'b0,l100OOIl}:0;
    else
       lIl1ll0I = {1'b1,l100OOIl};
    if ((l00OlIOI === l1OlOO0l) && (O11llO11 === O0Ol1O1l) && (I0O1IOO1 !== O1OI1I1O))
    begin 
      l00OlIOI = 0;
      O11llO11 = 0;
      l1OlOO0l = 0;
      O0Ol1O1l = 0;
    end
    if ((l00OlIOI === lO001000) && (O11llO11 === O110011O) && (I0O1IOO1 !== l110O0O1))
    begin 
      l00OlIOI = 0;
      O11llO11 = 0;
      lO001000 = 0;
      O110011O = 0;
    end
    if ((l00OlIOI === IO0lOOlO) && (O11llO11 === lIl1ll0I) && (I0O1IOO1 !== O01I0O1l))
    begin 
      l00OlIOI = 0;
      O11llO11 = 0;
      IO0lOOlO = 0;
      lIl1ll0I = 0;
    end
    if ((l1OlOO0l === lO001000) && (O0Ol1O1l === O110011O) && (O1OI1I1O !== l110O0O1))
    begin 
      l1OlOO0l = 0;
      O0Ol1O1l = 0;
      lO001000 = 0;
      O110011O = 0;
    end
    if ((l1OlOO0l === IO0lOOlO) && (O0Ol1O1l === lIl1ll0I) && (O1OI1I1O !== O01I0O1l))
    begin 
      l1OlOO0l = 0;
      O0Ol1O1l = 0;
      IO0lOOlO = 0;
      lIl1ll0I = 0;
    end
    if ((lO001000 === IO0lOOlO) && (O110011O === lIl1ll0I) && (l110O0O1 !== O01I0O1l))
    begin 
      lO001000 = 0;
      O110011O = 0;
      IO0lOOlO = 0;
      lIl1ll0I = 0;
    end
  
    if ((l00OlIOI > l1OlOO0l) && (l00OlIOI > lO001000) && (l00OlIOI > IO0lOOlO)) 
      OO1I100l = l00OlIOI;
    else if ((l1OlOO0l >= l00OlIOI) && (l1OlOO0l > lO001000) && (l1OlOO0l > IO0lOOlO)) 
      OO1I100l = l1OlOO0l;
    else if ((lO001000 >= l00OlIOI) && (lO001000 >= l1OlOO0l) && (lO001000 > IO0lOOlO)) 
      OO1I100l = lO001000;
    else
      OO1I100l = IO0lOOlO;

    II011O01 = OO1I100l - l00OlIOI;
    O1OI100O = OO1I100l - l1OlOO0l;
    I0O10l11 = OO1I100l - lO001000;
    O0OIOl10 = OO1I100l - IO0lOOlO;

    O01l1O11 = 0;
    Ol1O0O11 = {O11llO11,I111101l};
    O00I1OlI = II011O01;
    while ( (Ol1O0O11 != 0) && (O00I1OlI != {exp_width{1'b0}}) ) 
      begin
        O01l1O11 = Ol1O0O11[0] || O01l1O11;
        Ol1O0O11 = Ol1O0O11 >> 1;
        O00I1OlI = O00I1OlI - 1;
      end
    O01l1O11 = Ol1O0O11[0] | O01l1O11;

    I010O1Il = 0;
    ll0O0OI1 = {O0Ol1O1l,I111101l};
    O00I1OlI = O1OI100O;
    while ( (ll0O0OI1 != 0) && (O00I1OlI != {exp_width{1'b0}}) ) 
      begin
        I010O1Il = ll0O0OI1[0] || I010O1Il;
        ll0O0OI1 = ll0O0OI1 >> 1;
        O00I1OlI = O00I1OlI - 1;
      end
    I010O1Il = ll0O0OI1[0] | I010O1Il;

    I01IO10l = 0;
    I1OO01OI = {O110011O,I111101l};
    O00I1OlI = I0O10l11;
    while ( (I1OO01OI != 0) && (O00I1OlI != {exp_width{1'b0}}) ) 
      begin
        I01IO10l = I1OO01OI[0] || I01IO10l;
        I1OO01OI = I1OO01OI >> 1;
        O00I1OlI = O00I1OlI - 1;
      end
    I01IO10l = I1OO01OI[0] | I01IO10l;

    OOOl1lI0 = 0;
    OO011l1I = {lIl1ll0I,I111101l};
    O00I1OlI = O0OIOl10;
    while ( (OO011l1I != 0) && (O00I1OlI != {exp_width{1'b0}}) ) 
      begin
        OOOl1lI0 = OO011l1I[0] || OOOl1lI0;
        OO011l1I = OO011l1I >> 1;
        O00I1OlI = O00I1OlI - 1;
      end
    OOOl1lI0 = OO011l1I[0] | OOOl1lI0;

    lOIOl1l1 = 0;
    lI11O1Ol = 0;
    l110OOll = 0;
    lOOOIl1O = 0;
    O1OlOlOO = 0;

    Ol0O010O = (Ol1O0O11[(2*(sig_width+1)+3+2+1)-1-3:1] == 0);
    l0I0O110 = (ll0O0OI1[(2*(sig_width+1)+3+2+1)-1-3:1] == 0);
    OI0100IO = (I1OO01OI[(2*(sig_width+1)+3+2+1)-1-3:1] == 0);
    lOOO10I1 = (OO011l1I[(2*(sig_width+1)+3+2+1)-1-3:1] == 0);

  
    if ((O01l1O11 == 1) && (Ol0O010O == 1) && 
        (I010O1Il == 1) && (l0I0O110 == 1) && 
        (I01IO10l == 1) && (OI0100IO == 1))
      begin
      lOIOl1l1 = 1;
      if (({l00OlIOI,O11llO11} > {l1OlOO0l,O0Ol1O1l}) && ({l00OlIOI,O11llO11} > {lO001000,O110011O})) 
	begin
          l110OOll = 1;
          lOOOIl1O = 1;
          O1OlOlOO = 1;
        end
      else
        if (({lO001000,O110011O} > {l00OlIOI,O11llO11}) && ({lO001000,O110011O} > {l1OlOO0l,O0Ol1O1l})) 
  	  begin
            lI11O1Ol = 1;
            l110OOll = 1;
            O1OlOlOO = 1;
          end
        else
          if (({l1OlOO0l,O0Ol1O1l} > {l00OlIOI,O11llO11}) && ({l1OlOO0l,O0Ol1O1l} > {lO001000,O110011O})) 
            begin
              lI11O1Ol = 1;
              lOOOIl1O = 1;
              O1OlOlOO = 1;
            end
      end
    if ((O01l1O11 == 1) && (Ol0O010O == 1) && 
        (I010O1Il == 1) && (l0I0O110 == 1) && 
        (OOOl1lI0 == 1) && (lOOO10I1 == 1)) 
      begin
      lOIOl1l1 = 1;
      if (({l00OlIOI,O11llO11} > {l1OlOO0l,O0Ol1O1l}) && ({l00OlIOI,O11llO11} > {IO0lOOlO,lIl1ll0I})) 
        begin
          l110OOll = 1;
          lOOOIl1O = 1;
          O1OlOlOO = 1;
        end
      else
        if (({l1OlOO0l,O0Ol1O1l} > {l00OlIOI,O11llO11}) && ({l1OlOO0l,O0Ol1O1l} > {IO0lOOlO,lIl1ll0I})) 
          begin
            lI11O1Ol = 1;
            lOOOIl1O = 1;
            O1OlOlOO = 1;
          end
        else
          if (({IO0lOOlO,lIl1ll0I} > {l00OlIOI,O11llO11}) && ({IO0lOOlO,lIl1ll0I} > {l1OlOO0l,O0Ol1O1l})) 
            begin
              lI11O1Ol = 1;
              l110OOll = 1;
              lOOOIl1O = 1;
            end
      end
    if ((O01l1O11 == 1) && (Ol0O010O == 1) && 
        (I01IO10l == 1) && (OI0100IO == 1) && 
        (OOOl1lI0 == 1) && (lOOO10I1 == 1)) 
      begin
      lOIOl1l1 = 1;
      if (({l00OlIOI,O11llO11} > {lO001000,O110011O}) && ({l00OlIOI,O11llO11} > {IO0lOOlO,lIl1ll0I})) 
        begin
          l110OOll = 1;
          lOOOIl1O = 1;
          O1OlOlOO = 1;
        end
      else
        if (({lO001000,O110011O} > {l00OlIOI,O11llO11}) && ({lO001000,O110011O} > {IO0lOOlO,lIl1ll0I})) 
          begin
            lI11O1Ol = 1;
            l110OOll = 1;
            O1OlOlOO = 1;
          end
        else
          if (({IO0lOOlO,lIl1ll0I} > {l00OlIOI,O11llO11}) && ({IO0lOOlO,lIl1ll0I} > {lO001000,O110011O})) 
            begin
              lI11O1Ol = 1;
              l110OOll = 1;
              lOOOIl1O = 1;
            end
      end
    if ((I010O1Il == 1) && (l0I0O110 == 1) && 
        (I01IO10l == 1) && (OI0100IO == 1) && 
        (OOOl1lI0 == 1) && (lOOO10I1 == 1)) 
      begin
      lOIOl1l1 = 1;
      if (({l1OlOO0l,O0Ol1O1l} > {lO001000,O110011O}) && ({l1OlOO0l,O0Ol1O1l} > {IO0lOOlO,lIl1ll0I})) 
        begin
          lI11O1Ol = 1;
          lOOOIl1O = 1;
          O1OlOlOO = 1;
        end
      else
        if (({lO001000,O110011O} > {l1OlOO0l,O0Ol1O1l}) && ({lO001000,O110011O} > {IO0lOOlO,lIl1ll0I})) 
	  begin
            lI11O1Ol = 1;
            l110OOll = 1;
            O1OlOlOO = 1;
          end
        else
          if (({IO0lOOlO,lIl1ll0I} > {l1OlOO0l,O0Ol1O1l}) && ({IO0lOOlO,lIl1ll0I} > {lO001000,O110011O})) 
            begin
              lI11O1Ol = 1;
              l110OOll = 1;
              lOOOIl1O = 1;
            end
      end
    if (lOIOl1l1 == 0) 
      begin
      if ((O01l1O11 == 1) && (Ol0O010O == 1) && 
          (((I010O1Il == 1) && (l0I0O110 == 1) && 
            ({l00OlIOI,O11llO11} < {l1OlOO0l,O0Ol1O1l})) ||
           ((I01IO10l == 1) && (OI0100IO == 1) && 
            ({l00OlIOI,O11llO11} < {lO001000,O110011O})) ||
           ((OOOl1lI0 == 1) && (lOOO10I1 == 1) && 
            ({l00OlIOI,O11llO11} < {IO0lOOlO,lIl1ll0I})))   ) 
        lI11O1Ol = 1;
      else
        lI11O1Ol = 0;
      if ((I010O1Il == 1) && (l0I0O110 == 1) && 
          (((O01l1O11 == 1) && (Ol0O010O == 1) && 
            ({l1OlOO0l,O0Ol1O1l} < {l00OlIOI,O11llO11})) ||
           ((I01IO10l == 1) && (OI0100IO == 1) && 
            ({l1OlOO0l,O0Ol1O1l} < {lO001000,O110011O})) ||
          ((OOOl1lI0 == 1) && (lOOO10I1 == 1) && 
            ({l1OlOO0l,O0Ol1O1l} < {IO0lOOlO,lIl1ll0I})))   ) 
        l110OOll = 1;
      else
        l110OOll = 0;
      if ((I01IO10l == 1) && (OI0100IO == 1) && 
          (((O01l1O11 == 1) && (Ol0O010O == 1) && 
            ({lO001000,O110011O} < {l00OlIOI,O11llO11})) ||
           ((I010O1Il == 1) && (l0I0O110 == 1) && 
            ({lO001000,O110011O} < {l1OlOO0l,O0Ol1O1l})) ||
           ((OOOl1lI0 == 1) && (lOOO10I1 == 1) && 
            ({lO001000,O110011O} < {IO0lOOlO,lIl1ll0I})))   ) 
        lOOOIl1O = 1;
      else
        lOOOIl1O = 0;
      if ((OOOl1lI0 == 1) && (lOOO10I1 == 1) && 
          (((O01l1O11 == 1) && (Ol0O010O == 1) && 
            ({IO0lOOlO,lIl1ll0I} < {l00OlIOI,O11llO11})) ||
           ((I010O1Il == 1) && (l0I0O110 == 1) && 
            ({IO0lOOlO,lIl1ll0I} < {l1OlOO0l,O0Ol1O1l})) ||
           ((I01IO10l == 1) && (OI0100IO == 1) && 
            ({IO0lOOlO,lIl1ll0I} < {lO001000,O110011O})))   ) 
        O1OlOlOO = 1;
      else
        O1OlOlOO = 0;
      end 

    O1I110OO = {Ol1O0O11[(2*(sig_width+1)+3+2+1)-1-3:1],(~lI11O1Ol & O01l1O11)};
    I0lI1010 = {ll0O0OI1[(2*(sig_width+1)+3+2+1)-1-3:1],(~l110OOll & I010O1Il)};
    IOl0lOO0 = {I1OO01OI[(2*(sig_width+1)+3+2+1)-1-3:1],(~lOOOIl1O & I01IO10l)};
    O011IOl0 = {OO011l1I[(2*(sig_width+1)+3+2+1)-1-3:1],(~O1OlOlOO & OOOl1lI0)};

    if (I0O1IOO1 === 1) 
      l00O1IO0 = ~O1I110OO + 1;
    else 
      l00O1IO0 = O1I110OO;
    if (O1OI1I1O === 1) 
      lOl1lIOO = ~I0lI1010 + 1;
    else 
      lOl1lIOO = I0lI1010;
    if (l110O0O1 === 1) 
      OlIll11O = ~IOl0lOO0 + 1;
    else 
      OlIll11O = IOl0lOO0;
    if (O01I0O1l === 1) 
      OO000000 = ~O011IOl0 + 1;
    else 
      OO000000 = O011IOl0;

    O1ll0100 = l00O1IO0 + lOl1lIOO + OlIll11O + OO000000;
    
    I1IlO10O = O1ll0100[((2*(sig_width+1)+3+2+1)-1)];
    if (I1IlO10O === 1) 
      O0lIl1Ol = ~O1ll0100[((2*(sig_width+1)+3+2+1)-1)-1:0]+1;
    else
      O0lIl1Ol = O1ll0100[((2*(sig_width+1)+3+2+1)-1)-1:0];

    O00l1lI1 = O0lIl1Ol;
    l1l10lOO = O0lIl1Ol;
    
    Ol1OO1l0 = {2'b0, OO1I100l};

    if ((O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  :(sig_width+2+1)-2] == 0) && 
        (O01l1O11 | I010O1Il | I01IO10l | OOOl1lI0))
      begin
        if (O01l1O11 == 1)
          begin
            l00O1I0O = a; 
            OOI0101l[0] = OO00100I;
            OOI0101l[5] = 0;
            OOI0101l[3] = 0;
            OOI0101l[4] = 0;
            OOI0101l[1] = O0O0OO1O;
            OOI0101l[2] = llOlO1l1;
          end
        if (I010O1Il == 1)
          begin
            l00O1I0O = b; 
            OOI0101l[0] = Ol0l01IO;
            OOI0101l[5] = 0;
            OOI0101l[3] = 0;
            OOI0101l[4] = 0;
            OOI0101l[1] = O00010IO;
            OOI0101l[2] = lOOIOlOl;
          end
        if (I01IO10l == 1)
          begin
            l00O1I0O = c; 
            OOI0101l[0] = llO1IOl0;
            OOI0101l[5] = 0;
            OOI0101l[3] = 0;
            OOI0101l[4] = 0;
            OOI0101l[1] = OlOlOI0O;
            OOI0101l[2] = OOOOl1OI;
          end
        if (OOOl1lI0 == 1)
          begin
            l00O1I0O = d; 
            OOI0101l[0] = l1O110II;
            OOI0101l[5] = 0;
            OOI0101l[3] = 0;
            OOI0101l[4] = 0;
            OOI0101l[1] = OO111110;
            OOI0101l[2] = O0I1l11I;
          end
      end
    else
    begin
    O11lI101 = 0;
    if (O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  ] === 1) 
      begin
        Ol1OO1l0 = Ol1OO1l0 + 1;
        O11lI101 = O00l1lI1[0] || O11lI101;
        O00l1lI1 = O00l1lI1>>1;
      end
    if (O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  -1] === 1) 
      begin
        Ol1OO1l0 = Ol1OO1l0 + 1;
        O11lI101 = O00l1lI1[0] || O11lI101;
        O00l1lI1 = O00l1lI1>>1;
      end
    while ( (O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  -2] === 0) && (Ol1OO1l0 > {{exp_width-1{1'b0}},1'b1}) ) 
      begin
        Ol1OO1l0 = Ol1OO1l0 - 1;
        O00l1lI1 = {O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  -1:0], 1'b0};
      end

      lOOOII0I = ll1lO01I(rnd, I1IlO10O, O00l1lI1[(sig_width+3+1)], O00l1lI1[(sig_width+2+1)],
                (|{O00l1lI1[(sig_width+2+1)-1:0],O01l1O11,I010O1Il,I01IO10l,OOOl1lI0,O11lI101}));

      OOI0IO1I = 1 << (sig_width+3+1);

      if (lOOOII0I[0] === 1) 
        O00l1lI1 = O00l1lI1 + OOI0IO1I;

      if ( (O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  -1] === 1) ) 
        begin
          Ol1OO1l0 = Ol1OO1l0 + 1;
          O00l1lI1 = O00l1lI1 >> 1;
        end 

      if (O00l1lI1 === 0) 
        begin
          OOI0101l[0] = 1;
          l00O1I0O = 0;
          if (rnd === 3) 
            l00O1I0O[(exp_width + sig_width)] = 1;
          else
            l00O1I0O[(exp_width + sig_width)] = 0;
        end
      else    
        if (O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  :(((2*(sig_width+1)+3+2+1)-1)-1)  -2] === 0) 
          begin
            if (ieee_compliance == 1)
              begin
                l00O1I0O = {I1IlO10O, {exp_width{1'b0}}, O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  -3:(sig_width+3+1)]};
                OOI0101l[3] = 1;
                OOI0101l[5] =  lOOOII0I[1];
                if (O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  -3:(sig_width+3+1)] == 0)
                  OOI0101l[0] = 1; 
              end
            else
              begin
                OOI0101l[3] = 1;
                OOI0101l[5] = 1;
                if ((rnd == 3 && I1IlO10O == 1) ||
                    (rnd == 2 && I1IlO10O == 0) || rnd == 5) 
                  begin
                    l00O1I0O = {I1IlO10O, {exp_width-1{1'b0}}, 1'b1, {sig_width{1'b0}}};
                    OOI0101l[0] = 0;
                  end
                else
                  begin
                    l00O1I0O = {I1IlO10O, {exp_width+sig_width{1'b0}}};
                    OOI0101l[0] = 1;
                  end
              end
          end
        else
          begin
            if (Ol1OO1l0 >= ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1})) 
              begin
              	OOI0101l[5] = 1;
	        if (lOOOII0I[2] === 1) 
	          begin
                    O00l1lI1 = 0;
                    Ol1OO1l0 = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1});
                    OOI0101l[1] = 1;
                    OOI0101l[4] = 1;
                  end
                else
                  begin
                    // MaxNorm
                    Ol1OO1l0 = ((({exp_width{1'b1}}>>1) << 1) + {{exp_width-1{1'b0}},1'b1}) - 1;
                    O00l1lI1 = ~(0);
                  end
              end
            else
             if (Ol1OO1l0 <= {exp_width{1'b0}}) 
               Ol1OO1l0 = {exp_width{1'b0}} + 1;
             else
               OOI0101l[5] = lOOOII0I[1];

            l00O1I0O = {I1IlO10O, Ol1OO1l0[exp_width-1:0], O00l1lI1[(((2*(sig_width+1)+3+2+1)-1)-1)  -3:(sig_width+3+1)]};

          end
      end
  end

end

assign status = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0)  || (^(c ^ c) !== 1'b0) || (^(d ^ d) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ?
                 {8'bx} : 
                 (arch_type  === 1)?l0O01OIO:OOI0101l;
assign z = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(d ^ d) !== 1'b0) || (^(rnd ^ rnd) !== 1'b0)) ? 
                 {sig_width+exp_width+1{1'bx}} : 
                 (arch_type === 1)?IO10OIlO:l00O1I0O;
  
// synopsys translate_on  

endmodule
