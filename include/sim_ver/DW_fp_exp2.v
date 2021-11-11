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
// AUTHOR:    Alexandre Tenca, Septembter 2007
//
// VERSION:   Verilog Simulation Model for FP Base-2 Exponential
//
// DesignWare_version: 9518c973
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point Base-2 Exponential
//           Computes the base-2 exponential of a Floating-point number
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       I01O1O11 size,  2 to 60 bits
//              exp_width       I0OIl11O size,     3 to 31 bits
//              ieee_compliance 0 or 1
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
//                              Floating-point Number that represents exp2(a)
//              status          byte
//                              Status information about FP operation
//
// MODIFIED:
//          05/2008 - AFT - Fixed the inexact status bit.
//                    Fixed the tiny bit when ieee_compliance = 1. This bit
//                    must be set to 1 whenever the output is a denormal.
//          August 2008 - AFT - included new parameter (arch) and fixed some
//                    issues with accuracy and status information.
//          07/2015 - AFT - Star 9000927455
//                   Fix incorrect results when the I0OIl11O field size is 
//                   too small. The size of some variables had to be increased
//                   to avoid lOOI1OOO during calculations for these 
//                   special configurations. Since this is the simulation 
//                   model, the increase in the variable size was done 
//                   independently of the ieee_compliance value. Also reduced
//                   the upper bound of sig_width to 58 to avoid incorrect
//                   configuration of DW_exp2.
//
//-------------------------------------------------------------------------------

module DW_fp_exp2 (a, z, status);
parameter sig_width=10;
parameter exp_width=5; 
parameter ieee_compliance=0;
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
    
  
    if ( (sig_width < 2) || (sig_width > 58) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to 58)",
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
 

  reg [(exp_width + sig_width + 1)-1:0] OI1lOOII, OO01I101;
  reg [8    -1:0] O01Ol0OO, OO11O101;
  reg [sig_width+1:0] IOIOO00l;
  reg [sig_width+1:0] I0l1l1O0;
  wire [sig_width+1:0] O1I1OOI0;
  reg signed [exp_width+sig_width:0] Ol0lIO10;
  reg signed [exp_width+1:0] I11l1110;
  reg O11ll11O;
  reg [8    -1:0] IOI101Ol;
  reg l0010011, Ol1I0O1O, I00O0l0I, lO0O0OOl;
  
    reg l0lllII1;
    reg [exp_width:0] OIO10O00;
    reg signed [exp_width+sig_width:0] IO001001;
    reg [sig_width:0] l0Ol0000;
    reg [sig_width-1:0] I0OO1lOl;
    reg [sig_width-1:0] OIl100OI;
    reg [exp_width:0] l110Il0O;
    reg [(exp_width + sig_width + 1)-1:0] OO0111O1;
    reg [8    -1:0] I01lI1Ol;
    reg O0100111, O1ll0OO1, O1O1OOl1, Il1OIl01;
    reg [exp_width-1:0] O1l111I0;
    reg [(exp_width + sig_width + 1)-1:0] O0OO001l;
    reg [(exp_width + sig_width + 1)-1:0] IIOOl011;
    reg [(exp_width + sig_width + 1)-1:0] I1O11101;
    reg [(exp_width + sig_width + 1)-1:0] l1l0101I;
    reg [sig_width+1:0] lOIl1IOO;
    reg [exp_width-2:0] O1010O00;  
    reg signed [exp_width+sig_width:0] I1l11l1l;
    reg [sig_width+exp_width+3:0] O1IIIO11;
    reg IOOIl0OI;
    reg signed [exp_width+1:0] l1l0OOOl;
    reg [sig_width+1:0] OOO1000I;
    reg l1IO0l1I;
    reg [exp_width+1:0] O11O0I0O;
    reg [sig_width+1:0] O0O010l0;
    reg signed [exp_width+1:0] I0OIl11O;
    reg [sig_width:0] I01O1O11;
    reg [8    -1:0] O01I1lOl;
    reg [(exp_width + sig_width + 1)-1:0] IIl01O01;
    reg lOOI1OOO;
    reg l0O0IOOO;
    reg signed [exp_width+1:0] IIO0O111;
    reg signed [exp_width:0] Ill00OO0;
    reg signed [exp_width+1:0] IllO110I;
    reg l1OI1IOl;
    wire OO01OIO0;
    wire Ol0l11lI;
    wire l101IO1O;

  always @ (a)
  begin
    O1l111I0 = ((((1 << (exp_width-1)) - 1) * 2) + 1);
    OIl100OI = 0;
    l110Il0O = 0;
    O1010O00 = ((1 << (exp_width-1)) - 1);
    OIO10O00 = {1'b0,a[((exp_width + sig_width) - 1):sig_width]};
    IO001001 = OIO10O00;
    I0OO1lOl = a[(sig_width - 1):0];
    O0100111 = 0;
    O0OO001l = {1'b0, O1l111I0, OIl100OI};
    if (ieee_compliance === 1) 
        O0OO001l[0] = 1'b1;
    IIOOl011 = {1'b1,  O1l111I0, OIl100OI};
    I1O11101 = {1'b0,  O1l111I0, OIl100OI};
    l1l0101I = {2'b0, O1010O00, OIl100OI};
      
    if (ieee_compliance === 1 && OIO10O00 === l110Il0O) 
      begin
        if (I0OO1lOl === OIl100OI)
          begin
            O0100111 = 1'b1;
            O1ll0OO1 = 1'b0;
          end
        else
          begin
            O0100111 = 1'b0;
            O1ll0OO1 = 1'b1;
            IO001001[0] = 1'b1;
          end
        l0Ol0000 = {1'b0, I0OO1lOl};
      end
    else if (ieee_compliance === 0 && OIO10O00 === l110Il0O)
      begin
        l0Ol0000 = 1'b0 & OIl100OI;
        O0100111 = 1'b1;
        O1ll0OO1 = 1'b0;
      end
    else
      begin
        l0Ol0000 = {1'b1, I0OO1lOl};
        O0100111 = 1'b0;
        O1ll0OO1 = 1'b0;
      end
      
    if ((OIO10O00[exp_width-1:0] === ((((1 << (exp_width-1)) - 1) * 2) + 1)) &&
         ((ieee_compliance === 0) || (I0OO1lOl === OIl100OI))) 
      O1O1OOl1 = 1'b1;
    else
      O1O1OOl1 = 1'b0;
  
    if ((OIO10O00[exp_width-1:0] === ((((1 << (exp_width-1)) - 1) * 2) + 1)) &&
         (ieee_compliance === 1) && (I0OO1lOl !== OIl100OI)) 
       Il1OIl01 = 1'b1;
     else
       Il1OIl01 = 1'b0;
  
    l0lllII1 = a[(exp_width + sig_width)];
      
    I01lI1Ol = 0;
    OO0111O1 = 0;
    lOIl1IOO = {sig_width+2{1'b1}};
      
    if (Il1OIl01 === 1)
      begin
        OO0111O1 = O0OO001l;
        I01lI1Ol[2] = 1'b1;
      end
  
    else if ((O1O1OOl1 === 1'b1) && (l0lllII1 === 1'b0))   
      begin
        OO0111O1 = I1O11101;
        I01lI1Ol[1] = 1'b1;
      end
  
    else if ((O1O1OOl1 === 1'b1) && (l0lllII1 === 1'b1))   
      begin
        OO0111O1 = 0;
        I01lI1Ol[0] = 1'b1;
      end
  
    else if (O0100111 === 1'b1)     
      OO0111O1 = l1l0101I;
  
    else if (O1ll0OO1 === 1) 	
      begin
        lOIl1IOO = {l0Ol0000,1'b0};
        while (lOIl1IOO[sig_width+1] === 1'b0) 
          begin
            lOIl1IOO = lOIl1IOO << 1;
            IO001001 = IO001001 - 1;
          end
        OO0111O1 = 0;
      end
  
    else
      begin
        lOIl1IOO = {l0Ol0000,1'b0};
        OO0111O1 = 0;
      end
  
    OI1lOOII = OO0111O1;
    O01Ol0OO = I01lI1Ol;
    IOIOO00l = lOIl1IOO;
    Ol0lIO10 = $signed({1'b0,IO001001}) - $signed({1'b0,((1 << (exp_width-1)) - 1)});
    O11ll11O = l0lllII1;
    l0010011 = O0100111;
    Ol1I0O1O = O1ll0OO1;
    I00O0l0I = O1O1OOl1;
    lO0O0OOl = Il1OIl01;
  end
  
  always @ (IOIOO00l or Ol0lIO10 or O11ll11O)
  begin
    I1l11l1l = Ol0lIO10;
    O11O0I0O = 0;
    O1IIIO11 = {O11O0I0O, IOIOO00l};
    IOOIl0OI = 0;
    if (I1l11l1l < -1) 
      while (I1l11l1l < -1)
        begin
          IOOIl0OI = IOOIl0OI | O1IIIO11[0];
          O1IIIO11 = O1IIIO11 >> 1;
          I1l11l1l = I1l11l1l + 1;
        end
    else if (I1l11l1l > -1)
      while (I1l11l1l > -1 && O1IIIO11[sig_width+exp_width+3] === 1'b0) 
        begin
          O1IIIO11 = O1IIIO11 << 1;
          I1l11l1l = I1l11l1l - 1;
        end
                    
      l1l0OOOl = $signed({1'b0,O1IIIO11[sig_width+exp_width+3:sig_width+2]});
      OOO1000I = O1IIIO11[sig_width+1:0];
      if (OOO1000I === 0)
        l1IO0l1I = 1'b1;
      else
        l1IO0l1I = 1'b0;
            
    if (O11ll11O === 1'b1)
      if (l1IO0l1I === 1'b1)
        I11l1110 = -(l1l0OOOl);
      else
        I11l1110 = -(l1l0OOOl+1);
    else
      I11l1110 = l1l0OOOl;

    if (O11ll11O === 1'b1 && l1IO0l1I === 1'b0) 
      O0O010l0 = $unsigned(~OOO1000I) + 1;
    else
      O0O010l0 = OOO1000I;
    I0l1l1O0 = O0O010l0;
  end
    
  DW_exp2 #(sig_width+2,arch,1) U1 (.a(I0l1l1O0), .z(O1I1OOI0));

  always @ (I0l1l1O0 or O1I1OOI0 or Ol0lIO10 or I11l1110 or O11ll11O or IOOIl0OI)
  begin
    IIl01O01 = 0;
    O01I1lOl = 0;
    O01I1lOl[5] = |I0l1l1O0 | IOOIl0OI;
    I0OIl11O = I11l1110;
    I01O1O11 = O1I1OOI0[sig_width+1:1] + O1I1OOI0[0];

    if (&O1I1OOI0 == 1'b1)
      begin
        I0OIl11O = I0OIl11O + 1;
        I01O1O11[sig_width] = 1'b1;
      end
     
      IllO110I = {2'b0,((1 << (exp_width-1)) - 1)};
      IIO0O111 = I0OIl11O + $signed(IllO110I);

    lOOI1OOO = 1'b0;
    l0O0IOOO = 1'b0;
      Ill00OO0 = Ol0lIO10 - $signed(exp_width) + 1;
      if (Ill00OO0 > 0 && Ol0lIO10 > 0 && O11ll11O === 1'b0)  
          lOOI1OOO = 1'b1;
      else if ($unsigned(IIO0O111) >= ((1 << exp_width)-1) && O11ll11O === 1'b0) 
          lOOI1OOO = 1'b1;

      if (Ill00OO0 > 0 && Ol0lIO10 > 0 && O11ll11O === 1'b1)  
          l0O0IOOO = 1'b1;

      if (IIO0O111 <= 0)
        if (ieee_compliance === 1)
	  begin
            l0O0IOOO = 1'b0;
            l1OI1IOl = 1'b0;
            while (IIO0O111 <= 0)
              begin
                IIO0O111 = IIO0O111 + 1;
                l1OI1IOl = I01O1O11[0];
                I01O1O11 = I01O1O11 >> 1;
              end
              I01O1O11 = I01O1O11 + l1OI1IOl;
          end
        else
          l0O0IOOO = 1'b1;
         
    if (lOOI1OOO) 
      begin
        IIl01O01 = I1O11101;
        O01I1lOl[1] = 1'b1;
        O01I1lOl[4] = 1'b1;
        O01I1lOl[5] = 1'b1;
      end
    else if (l0O0IOOO) 
      begin
        IIl01O01 = 0;
        O01I1lOl[0] = 1'b1;
        O01I1lOl[3] = (ieee_compliance == 0);
        O01I1lOl[5] = 1'b1;
      end
    else 
      begin
        if (I01O1O11[sig_width] === 1'b0)
          begin
              IIl01O01 = {1'b0, {exp_width{1'b0}}, I01O1O11[sig_width-1:0]};
              if (I01O1O11[sig_width-1:0] == 0)
                begin
                  O01I1lOl[0] = 1'b1;
	          O01I1lOl[5] = 1'b1;
                end
              else
                O01I1lOl[3] = 1;
          end
        else
          begin
              IIl01O01 = {1'b0, IIO0O111[exp_width-1:0], I01O1O11[sig_width-1:0]};
          end           
      end
                    
    OO01I101 = IIl01O01;
    OO11O101 = O01I1lOl;
  end


  assign z = ((^(a ^ a) !== 1'b0)) ? {(exp_width + sig_width + 1){1'bx}}:
             (O01Ol0OO != 0 || OI1lOOII != 0) ? OI1lOOII:OO01I101;
  assign status = ((^(a ^ a) !== 1'b0)) ? {8    {1'bx}}:
                  (O01Ol0OO != 0 || OI1lOOII != 0) ? O01Ol0OO:OO11O101;

// synopsys translate_on

endmodule


