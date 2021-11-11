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
// AUTHOR:    Alexandre Tenca December 2007
//
// VERSION:   Verilog Simulation Model for FP adder/subtractor -- internal FP format
//
// DesignWare_version: 24805353
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point two-operand Adder/Subtractor in Internal FP format
//           Computes the addition/subtraction of two FP numbers in internal
//           (proprietary) FP format. 
//           The format of the FP numbers is defined by the number of bits 
//           in the significand (sig_width) and the number of bits in the 
//           exponent (exp_width). The internal format uses status (7 bits),
//           exponent, and significand fields. The significand is expressed 
//           in two's complement. 
//           The total number of bits in the FP number is sig_width+exp_width+7
//           The output follows the same format.
//           Subtraction is forced when op=1
//           Althought rounding is not done, the sign of zeros requires this
//           information.
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_widthi      significand size of the input,  2 to 253 bits
//              exp_widthi      exponent size of the input,     3 to 31 bits
//              sig_widtho      significand size of the output, 2 to 253 bits
//              exp_widtho      exponent size of the output,    3 to 31 bits
//              use_denormal    0 or 1  (default 0)
//              use_1scmpl      0 or 1  (default 0)
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_widthi + exp_widthi + 7)-bits
//                              Floating-point Number Input
//              b               (sig_widthi + exp_widthi + 7)-bits
//                              Floating-point Number Input
//              op              1 bit
//                              add/sub control: 0 for add - 1 for sub
//              rnd             3 bits
//                              Rounding mode
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_widtho + exp_widtho + 7) bits
//                              Floating-point Number result
//
// MODIFIED: 
//
//------------------------------------------------------------------------------
module DW_ifp_addsub (a, b, op, rnd, z);
parameter sig_widthi=17;
parameter exp_widthi=9;  
parameter sig_widtho=17;
parameter exp_widtho=9;  
parameter use_denormal=0;                    
parameter use_1scmpl=0;                    

// declaration of inputs and outputs
input  [sig_widthi+exp_widthi+7-1:0] a,b;
input  op;
input  [2:0] rnd;
output [sig_widtho+exp_widtho+7-1:0] z;

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
  
    if ( (use_denormal < 0) || (use_denormal > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter use_denormal (legal range: 0 to 1)",
	use_denormal );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



reg [7-1:0] l1Oll11l;
reg [7-1:0] I1OI11O1;
reg [7-1:0] O1l1O1Ol;
reg [exp_widtho+sig_widtho+7-1:0] O00IlII1;
reg I0O0llII, l00I1l00, IIl0110I, O0O11OlO, I11IOOO0, O000I1ll, I000101O, OOOOlOlO;
reg Ol11OO1I,OOOlO00l,lO0O1111;
reg [exp_widtho-1:0] II1IO1IO,l0I00110;
reg [exp_widtho-1:0] O1OOOI0O, I11l0011, llO01I1I;
// The biggest possible exponent for addition/subtraction
reg [exp_widtho-1:0] O0lO100I;
reg signed [sig_widtho:0] OlO0OO10,I01O0l00;
reg signed [sig_widtho+1:0] lO1ll111;
reg signed [sig_widtho+1:0] O01Ol0O1;
reg signed [sig_widtho+1:0] OIIll00O;
reg signed [sig_widtho+1:0] lOOO01OO;
reg signed [sig_widtho+1:0] O000OOO0;
reg signed [sig_widtho:0] OOOO1011;
reg signed [sig_widtho:0] lI0OlO11;
reg signed [sig_widtho:0] OO1O000O;  
reg signed [sig_widtho:0] I0lOO1IO;  
reg signed [sig_widtho:0] O0Ol1110;  
reg Ol1OO100, Il00OOl1;
reg lO11IO10;
reg l0O1I1OO;
reg lO1OOIOO;
reg I1lOO001;
reg O01O0Ol0;
reg [2:0] O0O1lOI0;
reg [2:0] l0O0OO00;
reg [sig_widtho-sig_widthi:0] O1110111;
reg [sig_widtho-sig_widthi:0] lO11lO10;
reg III111lO, OI1lI1O0;
reg Ol1OOOO0, O0l101O1;
reg l00O01OO;

// main process of information
always @(a or b or op or rnd)
begin
  Ol1OOOO0 = 0;
  O0l101O1 = 0;
  I1OI11O1 = a[sig_widthi+exp_widthi+7-1:sig_widthi+exp_widthi];
  O1l1O1Ol = b[sig_widthi+exp_widthi+7-1:sig_widthi+exp_widthi];
  I0O0llII = I1OI11O1[2];
  l00I1l00 = I1OI11O1[1];
  O0O11OlO = I1OI11O1[3     ];
  I11IOOO0 = O1l1O1Ol[2];
  O000I1ll = O1l1O1Ol[1];
  OOOOlOlO = O1l1O1Ol[3     ];
  lO11IO10 = I1OI11O1[4];
  l0O1I1OO = O1l1O1Ol[4];
  III111lO = (I1OI11O1[6     ] & a[0]) |
             (lO11IO10 & a[sig_widthi-1]);
  OI1lI1O0 = (O1l1O1Ol[6     ] & b[0]) |
             (l0O1I1OO & b[sig_widthi-1]);
  O1110111 = {sig_widtho-sig_widthi+1{III111lO}};
  lO11lO10 = {sig_widtho-sig_widthi+1{OI1lI1O0}};

  if (exp_widthi < exp_widtho) 
    begin
      II1IO1IO = {{exp_widtho-exp_widthi{1'b0}},a[sig_widthi+exp_widthi-1:sig_widthi]};
      l0I00110 = {{exp_widtho-exp_widthi{1'b0}},b[sig_widthi+exp_widthi-1:sig_widthi]};
    end
  else
    begin
      II1IO1IO = a[sig_widthi+exp_widthi-1:sig_widthi];               // same value
      l0I00110 = b[sig_widthi+exp_widthi-1:sig_widthi];
    end
  if (sig_widthi < sig_widtho) 
    begin
      {OO1O000O,l00O01OO}= {a[sig_widthi-1],a[sig_widthi-1:0],O1110111[sig_widtho-sig_widthi:0]};
      {I0lOO1IO,l00O01OO} = {b[sig_widthi-1],b[sig_widthi-1:0],lO11lO10[sig_widtho-sig_widthi:0]};
    end
  else
    begin
      OO1O000O = {a[sig_widthi-1],a[sig_widthi-1:0]};
      I0lOO1IO = {b[sig_widthi-1],b[sig_widthi-1:0]};
    end
  IIl0110I = I1OI11O1[0] | (~l00I1l00 & ~I0O0llII & ~|OO1O000O);
  I000101O = O1l1O1Ol[0] | (~O000I1ll & ~I11IOOO0 & ~|I0lOO1IO);
  if (IIl0110I) 
    II1IO1IO = 0;
  if (I000101O)
    l0I00110 = 0;

  l1Oll11l = 0;

  if (op == 1)
    if (use_1scmpl == 0)
      O0Ol1110 = -I0lOO1IO;
    else
      begin
        O0Ol1110 = -I0lOO1IO-1;
        lO1OOIOO = ~l0O1I1OO; 
      end
  else
    begin
      O0Ol1110 = I0lOO1IO;    
      lO1OOIOO = l0O1I1OO; 
    end

  Ol1OO100 = OO1O000O[sig_widtho];
  Il00OOl1 = O0Ol1110[sig_widtho];
  
  OOOlO00l = Ol1OO100 ^ Il00OOl1;

  Ol11OO1I = 0;
  if (II1IO1IO < l0I00110)
    begin
      Ol11OO1I = 1;
      O1OOOI0O = l0I00110;
      I11l0011 = II1IO1IO;
      OlO0OO10 = O0Ol1110;
      I01O0l00 = OO1O000O;
      I1lOO001 = (use_1scmpl)?lO1OOIOO:0;
      O01O0Ol0 = (use_1scmpl)?lO11IO10:0;
    end
  else
    begin
      Ol11OO1I = 0;
      O1OOOI0O = II1IO1IO;
      I11l0011 = l0I00110;
      OlO0OO10 = OO1O000O;
      I01O0l00 = O0Ol1110;
      I1lOO001 = (use_1scmpl)?lO11IO10:0;
      O01O0Ol0 = (use_1scmpl)?lO1OOIOO:0;
    end

  if ((IIl0110I & Ol11OO1I) | (I000101O & ~Ol11OO1I))
    I01O0l00 = 0;

  if (I0O0llII | I11IOOO0)
    begin
      l1Oll11l[2] = 1'b1;
    end
  if (l00I1l00 | O000I1ll) 
    begin
      l1Oll11l[1] = 1;
      l1Oll11l[5     ] = 0;
      if (l00I1l00 == 1) 
        l1Oll11l[5     ] = I1OI11O1[5     ];
      if (O000I1ll == 1)
        l1Oll11l[5     ] = O1l1O1Ol[5     ] ^ op;
      if (l00I1l00 == 1 && O000I1ll == 1 && 
          (I1OI11O1[5     ] != (O1l1O1Ol[5     ]^op)))
        begin
          l1Oll11l[2] = 1'b1;
          l1Oll11l[1] = 1'b0;
          l1Oll11l[5     ] = 1'b0;
        end
    end
  if (IIl0110I == 1 && I000101O == 1)
    begin
      l1Oll11l[0] = 1;
      Ol1OOOO0 = I1OI11O1[5     ];
      O0l101O1 = O1l1O1Ol[5     ]^op;
      if (Ol1OOOO0 !== O0l101O1)
        if (rnd === 3)
          l1Oll11l[5     ] = 1'b1;        
        else
          l1Oll11l[5     ] = 1'b0;
      else
        l1Oll11l[5     ] = Ol1OOOO0;
    end    
  begin                                         
      if (IIl0110I) 
        if (Ol11OO1I) I01O0l00 = 0;
        else OlO0OO10 = 0;
      if (I000101O)
        if (Ol11OO1I) OlO0OO10 = 0;
        else I01O0l00 = 0;

      lO0O1111 = 0;
      llO01I1I = O1OOOI0O - I11l0011;
      while ( (llO01I1I != 0) & (I01O0l00 != 0))
        begin
          lO0O1111 = (I01O0l00[0] ^ O01O0Ol0) | lO0O1111;
          I01O0l00 = I01O0l00 >>> 1;
          llO01I1I = llO01I1I - 1;
        end

        l1Oll11l[6     ] = ((OOOlO00l | (Ol1OO100 & Il00OOl1)) & lO0O1111) | 
                                    (I000101O & I1OI11O1[6     ]) |
                                    (IIl0110I & O1l1O1Ol[6     ]);

      lO1ll111 = $signed({OlO0OO10,1'b0});
      O01Ol0O1 = $signed({I01O0l00,lO0O1111});
      O0O1lOI0 = {1'b0, I1lOO001, 1'b0};
      l0O0OO00 = {1'b0, O01O0Ol0, 1'b0};
      OIIll00O = $signed(O0O1lOI0);
      lOOO01OO = $signed(l0O0OO00);
      O000OOO0 = lO1ll111 + O01Ol0O1 + OIIll00O + lOOO01OO;
      OOOO1011 = O000OOO0[sig_widtho+1:1];
      O0lO100I = O1OOOI0O;

      lI0OlO11 = OOOO1011;
      O0lO100I = O0lO100I + 1;
      l1Oll11l[3     ] = (lO0O1111 | O0O11OlO | OOOOlOlO | lI0OlO11[0]) & ~(l00I1l00 | O000I1ll | I0O0llII | I11IOOO0);
      if (O0lO100I < O1OOOI0O) 
        l1Oll11l[1] = 1'b1;
      if (OOOO1011 == 0 && ~IIl0110I && ~I000101O 
          && l1Oll11l[2:1] == 0)
	if (rnd == 3'b011)
          l1Oll11l[5     ] = 1'b1;
        else
          l1Oll11l[5     ] = 1'b0;
      O00IlII1 = {l1Oll11l,O0lO100I,lI0OlO11[sig_widtho:1]};
  end 
end

assign z = ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(op ^ op) !== 1'b0)) ? {sig_widtho+exp_widtho+7-1{1'bx}} : O00IlII1;

// synopsys translate_on
endmodule

