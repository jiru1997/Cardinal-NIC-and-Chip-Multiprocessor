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
// AUTHOR:    Alexandre Tenca, May 2008
//
// VERSION:   Verilog Simulation Model for FP Exponential
//
// DesignWare_version: fe086ffa
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point Exponential
//           Computes the exponential of a Floating-point number
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       IllO0llO size,  2 to 60 bits
//              exp_width       OO1OOl0O size,     3 to 31 bits
//              ieee_compliance 0 or 1
//              arch            implementation select
//                              0 - area optimized
//                              1 - speed optimized
//                              2 - uses 2007.12 sub-components (default)
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number that represents exp(a)
//              status          byte
//                              Status information about FP operation
//
// MODIFIED:
//          August 2008 - AFT - included new parameter (arch) and fixed other
//               issues related to accuracy.
//          July 2015 - AFT - modified the simulation model to follow the
//               same scheme used in DW_fp_exp2. The difference is the input
//               scaling needed for the exp() function. The modification covers
//               issues in the Star 9000927859.
//          11/2015 - AFT - Star 9000972181
//              Increased the size of the internal constant log2(e) to handle
//              the situation when sig_width+exp_width+1 > 62. This is the case
//              for double-precision FP.
//
//-------------------------------------------------------------------------------

module DW_fp_exp (a, z, status);
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
    
  
    if ( (sig_width < 2) || (sig_width > 57) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to 57)",
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
 

localparam O010IOII = ((sig_width>256)?((sig_width>4096)?((sig_width>16384)?((sig_width>32768)?16:15):((sig_width>8192)?14:13)):((sig_width>1024)?((sig_width>2048)?12:11):((sig_width>512)?10:9))):((sig_width>16)?((sig_width>64)?((sig_width>128)?8:7):((sig_width>32)?6:5)):((sig_width>4)?((sig_width>8)?4:3):((sig_width>2)?2:1))));
localparam llOO01l1  = O010IOII;
  reg [(exp_width + sig_width + 1)-1:0] OOOl1I0O, I0I11OOl;
  reg [8    -1:0] OOll0O1I, OlO0Ol01;
  reg [sig_width+(exp_width+1)+1:0] O0O00I11;
  reg [sig_width+2:0] l1111010;
  wire [sig_width+2:0] II1O0IO0;
  reg [sig_width+3:0] O00l1OO1;
  reg signed [exp_width+sig_width:0] OOOII01O;
  reg signed [exp_width+llOO01l1+1:0] IlOOI10l;
  reg O1O0OI10;
  reg [8    -1:0] I1O001IO;
  reg O0100lO0, IO010101, l1lOO01I, IlO011I0;
  
    wire [91:0] O1lIlll1;
    wire [sig_width+(exp_width+1):0] I00OIIl1;
    reg lO10O10O;
    reg [exp_width:0] I0IlI100;
    reg signed [exp_width+sig_width:0] O0Ol1OI1;
    reg [sig_width:0] lO0l10O1;
    reg [sig_width+(exp_width+1):0] I110O0OO;
    reg [(2*(sig_width+(exp_width+1)+1)-1):0] Ill01110;
    reg [sig_width-1:0] lO1100I0;
    reg [sig_width-1:0] OO11II01;
    reg [exp_width:0] ll0OlO01;
    reg [(exp_width + sig_width + 1)-1:0] O1OlO10l;
    reg [8    -1:0] lll0I1O0;
    reg O1ll1001, Ol0O11I1, O1I110lO, O01lO1O1;
    reg [exp_width-1:0] O111Ol10;
    reg [(exp_width + sig_width + 1)-1:0] OOO0IOOO;
    reg [(exp_width + sig_width + 1)-1:0] I00l1lOl;
    reg [(exp_width + sig_width + 1)-1:0] O00OIO10;
    reg [(exp_width + sig_width + 1)-1:0] OlO1OIO0;
    reg [sig_width+(exp_width+1)+1:0] O010Il00;
    reg [exp_width-2:0] O011O1OO;  
    reg signed [exp_width+sig_width:0] O1O0O000;
    reg [(sig_width+(exp_width+1)+exp_width+llOO01l1) :0] OOlOl01O;
    reg l00O111O;
    reg signed [exp_width+llOO01l1:0] I01I101l;
    reg [sig_width+2:0] O0110O11;
    reg I01O001O;
    reg [exp_width+llOO01l1-2:0] lIIOIOOl;
    reg [sig_width+2:0] Ol0O0lI0;
    reg signed [exp_width+llOO01l1+1:0] OO1OOl0O;
    reg [sig_width+1:0] IllO0llO;
    reg [8    -1:0] OIIl10l1;
    reg [(exp_width + sig_width + 1)-1:0] lIOO11O1;
    reg O0I10OI0;
    reg O0010II1;
    reg signed [exp_width+llOO01l1+1:0] OO010OlI;
    reg signed [exp_width:0] O1I0OI00;
    reg signed [exp_width+1:0] l1IlO1O0;
    reg OIO10OO0;
    wire Ol110110;
    wire l11OOO0l;
    wire O11ll1I0;

  assign O1lIlll1 = 92'b10111000101010100011101100101001010111000001011111110000101110111011111010000111111111101101;
  assign I00OIIl1 = O1lIlll1[91:91-sig_width-(exp_width+1)];
  always @ (a or I00OIIl1)
  begin
    O111Ol10 = ((((1 << (exp_width-1)) - 1) * 2) + 1);
    OO11II01 = 0;
    ll0OlO01 = 0;
    O011O1OO = ((1 << (exp_width-1)) - 1);
    I0IlI100 = {1'b0,a[((exp_width + sig_width) - 1):sig_width]};
    O0Ol1OI1 = I0IlI100;
    lO1100I0 = a[(sig_width - 1):0];
    O1ll1001 = 0;
    OOO0IOOO = {1'b0, O111Ol10, OO11II01};
    if (ieee_compliance === 1) 
        OOO0IOOO[0] = 1'b1;
    I00l1lOl = {1'b1,  O111Ol10, OO11II01};
    O00OIO10 = {1'b0,  O111Ol10, OO11II01};
    OlO1OIO0 = {2'b0, O011O1OO, OO11II01};
      
    if (ieee_compliance === 1 && I0IlI100 === ll0OlO01) 
      begin
        if (lO1100I0 === OO11II01)
          begin
            O1ll1001 = 1'b1;
            Ol0O11I1 = 1'b0;
          end
        else
          begin
            O1ll1001 = 1'b0;
            Ol0O11I1 = 1'b1;
            O0Ol1OI1[0] = 1'b1;
          end
        lO0l10O1 = {1'b0, lO1100I0};
      end
    else if (ieee_compliance === 0 && I0IlI100 === ll0OlO01)
      begin
        lO0l10O1 = 1'b0 & OO11II01;
        O1ll1001 = 1'b1;
        Ol0O11I1 = 1'b0;
      end
    else
      begin
        lO0l10O1 = {1'b1, lO1100I0};
        O1ll1001 = 1'b0;
        Ol0O11I1 = 1'b0;
      end
      
    if ((I0IlI100[exp_width-1:0] === ((((1 << (exp_width-1)) - 1) * 2) + 1)) &&
         ((ieee_compliance === 0) || (lO1100I0 === OO11II01))) 
      O1I110lO = 1'b1;
    else
      O1I110lO = 1'b0;
  
    if ((I0IlI100[exp_width-1:0] === ((((1 << (exp_width-1)) - 1) * 2) + 1)) &&
         (ieee_compliance === 1) && (lO1100I0 !== OO11II01)) 
       O01lO1O1 = 1'b1;
     else
       O01lO1O1 = 1'b0;
  
    lO10O10O = a[(exp_width + sig_width)];
      
    lll0I1O0 = 0;
    O1OlO10l = 0;
    O010Il00 = {sig_width+(exp_width+1)+2{1'b1}};
    I110O0OO = {sig_width+(exp_width+1)+1{1'b0}};
    Ill01110 = {(2*(sig_width+(exp_width+1)+1)-1)+1{1'b0}};
 
    if (O01lO1O1 === 1)
      begin
        O1OlO10l = OOO0IOOO;
        lll0I1O0[2] = 1'b1;
      end
  
    else if ((O1I110lO === 1'b1) && (lO10O10O === 1'b0))   
      begin
        O1OlO10l = O00OIO10;
        lll0I1O0[1] = 1'b1;
      end
  
    else if ((O1I110lO === 1'b1) && (lO10O10O === 1'b1))   
      begin
        O1OlO10l = 0;
        lll0I1O0[0] = 1'b1;
      end
  
    else if (O1ll1001 === 1'b1)     
      O1OlO10l = OlO1OIO0;
  
    else
      begin
        I110O0OO = {lO0l10O1,{(exp_width+1){1'b0}}};
        Ill01110 = I110O0OO * I00OIIl1;
        O010Il00 = Ill01110[(2*(sig_width+(exp_width+1)+1)-1):sig_width+(exp_width+1)];
        O1OlO10l = 0;
      end
  
    OOOl1I0O = O1OlO10l;
    OOll0O1I = lll0I1O0;
    O0O00I11 = O010Il00;
    OOOII01O = $signed({1'b0,O0Ol1OI1}) - $signed({1'b0,((1 << (exp_width-1)) - 1)});
    O1O0OI10 = lO10O10O;
    O0100lO0 = O1ll1001;
    IO010101 = Ol0O11I1;
    l1lOO01I = O1I110lO;
    IlO011I0 = O01lO1O1;
  end
  
  always @ (O0O00I11 or OOOII01O or O1O0OI10 or O0100lO0 or l1lOO01I or IlO011I0)
  begin
    O1O0O000 = OOOII01O;
    lIIOIOOl = 0;
    OOlOl01O = {lIIOIOOl, O0O00I11};
    l00O111O = ~(O0100lO0 | l1lOO01I | IlO011I0);
    if (O1O0O000 < 0) 
      while (O1O0O000 < 0)
        begin
          l00O111O = l00O111O | OOlOl01O[0];
          OOlOl01O = OOlOl01O >> 1;
          O1O0O000 = O1O0O000 + 1;
        end
    else if (O1O0O000 > 0)
      while (O1O0O000 > 0 && OOlOl01O[(sig_width+(exp_width+1)+exp_width+llOO01l1) ] === 1'b0) 
        begin
          OOlOl01O = OOlOl01O << 1;
          O1O0O000 = O1O0O000 - 1;
        end
                    
      I01I101l = $signed(OOlOl01O[(sig_width+(exp_width+1)+exp_width+llOO01l1) :sig_width+(exp_width+1)]);
      O0110O11 = OOlOl01O[sig_width+(exp_width+1)-1:(exp_width+1)-3];
      if (O0110O11 === 0)
        I01O001O = 1'b1;
      else
        I01O001O = 1'b0;
            
    if (O1O0OI10 === 1'b1)
      if (I01O001O === 1'b1)
        IlOOI10l = -(I01I101l);
      else
        IlOOI10l = -(I01I101l+1);
    else
      IlOOI10l = I01I101l;

    if (O1O0OI10 === 1'b1 && I01O001O === 1'b0) 
      if (l00O111O == 1'b0)
        Ol0O0lI0 = $unsigned(~O0110O11) + 1;
      else
        Ol0O0lI0 = $unsigned(~O0110O11);
    else
      Ol0O0lI0 = O0110O11;
    l1111010 = Ol0O0lI0;
  end
    
  DW_exp2 #(sig_width+3,arch,1) U1 (.a(l1111010), .z(II1O0IO0));

  always @ (l1111010 or II1O0IO0 or OOOII01O or IlOOI10l or O1O0OI10 or l00O111O)
  begin
    lIOO11O1 = 0;
    OIIl10l1 = 0;
    OIIl10l1[5] = |l1111010 | l00O111O;
    OO1OOl0O = IlOOI10l;
    O00l1OO1 = II1O0IO0 + II1O0IO0[0];

    if (&II1O0IO0 == 1'b1)
      begin
        OO1OOl0O = OO1OOl0O + 1;
        IllO0llO = {sig_width+2{1'b0}};
        IllO0llO[sig_width] = 1'b1;
      end
     
      l1IlO1O0 = {2'b0,((1 << (exp_width-1)) - 1)};
      OO010OlI = OO1OOl0O + $signed(l1IlO1O0);

    O0I10OI0 = 1'b0;
    O0010II1 = 1'b0;
      O1I0OI00 = OOOII01O - $signed(exp_width) + 1;
      if (O1I0OI00 > 0 && OOOII01O > 0 && O1O0OI10 === 1'b0)  
          O0I10OI0 = 1'b1;
      else if ($unsigned(OO010OlI) >= ((1 << exp_width)-1) && O1O0OI10 === 1'b0) 
          O0I10OI0 = 1'b1;

      if (O1I0OI00 > 0 && OOOII01O > 0 && O1O0OI10 === 1'b1)  
          O0010II1 = 1'b1;

      if (OO010OlI <= 0)
        if (ieee_compliance === 1)
	  begin
            O0010II1 = 1'b0;
            while (OO010OlI <= 0)
              begin
                OO010OlI = OO010OlI + 1;
                O00l1OO1 = O00l1OO1 >> 1;
              end
          end
        else
          O0010II1 = 1'b1;
    OIO10OO0 = O00l1OO1[1];
    IllO0llO = O00l1OO1[sig_width+3:2] + OIO10OO0;
    if (&O00l1OO1[sig_width+2:2] == 1'b1 && OIO10OO0 == 1'b1)
      begin
        OO010OlI = OO010OlI + 1;
        if ($unsigned(OO010OlI) >= ((1 << exp_width)-1) && O1O0OI10 === 1'b0) 
          O0I10OI0 = 1'b1;
        IllO0llO = {sig_width+2{1'b0}};
        IllO0llO[sig_width] = 1'b1;
      end
         
    if (O0I10OI0) 
      begin
        lIOO11O1 = O00OIO10;
        OIIl10l1[1] = 1'b1;
        OIIl10l1[4] = 1'b1;
        OIIl10l1[5] = 1'b1;
      end
    else if (O0010II1) 
      begin
        lIOO11O1 = 0;
        OIIl10l1[0] = 1'b1;
        OIIl10l1[3] = (ieee_compliance == 0);
        OIIl10l1[5] = 1'b1;
      end
    else 
      begin
        if (|IllO0llO[sig_width+1:sig_width] === 1'b0)
          begin
              lIOO11O1 = {1'b0, {exp_width{1'b0}}, IllO0llO[sig_width-1:0]};
              if (IllO0llO[sig_width-1:0] == 0)
                begin
                  OIIl10l1[0] = 1'b1;
	          OIIl10l1[5] = 1'b1;
                end
              else
                OIIl10l1[3] = 1;
          end
        else
          begin
              lIOO11O1 = {1'b0, OO010OlI[exp_width-1:0], IllO0llO[sig_width-1:0]};
          end           
      end
                    
    I0I11OOl = lIOO11O1;
    OlO0Ol01 = OIIl10l1;
  end


  assign z = ((^(a ^ a) !== 1'b0)) ? {(exp_width + sig_width + 1){1'bx}}:
             (OOll0O1I != 0 || OOOl1I0O != 0) ? OOOl1I0O:I0I11OOl;
  assign status = ((^(a ^ a) !== 1'b0)) ? {8    {1'bx}}:
                  (OOll0O1I != 0 || OOOl1I0O != 0) ? OOll0O1I:OlO0Ol01;

// synopsys translate_on

endmodule


