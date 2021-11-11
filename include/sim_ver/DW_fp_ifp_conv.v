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
// VERSION:   Verilog Simulation Model - FP to IFP converter
//
// DesignWare_version: 26e84ce4
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point format to internal format converter
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_widthi      significand size,  2 to 253 bits
//              exp_widthi      exponent size,     3 to 31 bits
//              sig_widtho      significand size,  sig_widthi to 253 bits
//              exp_widtho      exponent size,     exp_widthi to 31 bits
//              use_denormal    0 or 1  (default 0)
//              use_1scmpl      0 or 1  (default 0)
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_widthi + exp_widthi + 1)-bits
//                              Floating-point Number Input
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_widtho + exp_widtho + 7) bits
//                              Internal Floating-point Number
//
// MODIFIED: 
//          11/2008 - Includes the processing of denormals and NaNs when use_denormal=1
//
//------------------------------------------------------------------------------
module DW_fp_ifp_conv (a, z);
parameter sig_widthi=23;
parameter exp_widthi=8;  
parameter sig_widtho=25;
parameter exp_widtho=8;  
parameter use_denormal=0;                    
parameter use_1scmpl=0;


// declaration of inputs and outputs
input  [sig_widthi+exp_widthi:0] a;
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
  
    if ( (sig_widtho < sig_widthi+2) || (sig_widtho > 253) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_widtho (legal range: sig_widthi+2 to 253)",
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
  
    if ( (use_1scmpl < 0) || (use_1scmpl > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter use_1scmpl (legal range: 0 to 1)",
	use_1scmpl );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


reg O01OIO01;
reg [exp_widthi-1:0] OlOOO0O1;
reg [sig_widthi:0] II0l1OO1;
reg [sig_widthi-1:0] O0I1lOlI;
reg [sig_widthi-1:0] l0OIl0Ol;
reg [exp_widthi-1:0] I0l0OO10;
reg [exp_widthi-1:0] l1IOO011;
reg [exp_widthi-1:0] OlIIOOl1;
reg [7-1:0] OO01001O;
reg [sig_widthi+1:0] OI00O001;
reg [sig_widtho-1:0] OO10lO1O;
reg [sig_widtho+exp_widtho+7-1:0] Il0000O1;
reg [exp_widtho-1:0] O0OOIO1l;
reg [sig_widtho-1:0] I1O01O10;
reg [sig_widtho-1:0] OOI00lIl;
`define DW_l0l1100O ((sig_widtho > (sig_widthi+2))?(sig_widtho-sig_widthi-2):0)
`define DW_IO011l0l ((exp_widtho > exp_widthi)?(exp_widtho-exp_widthi):0)

// main process of information
always @(a)
begin
  OlIIOOl1 = ~0;
  l0OIl0Ol = 0;
  I0l0OO10 = 0;
  l1IOO011 = 1;
  OlOOO0O1 = a[sig_widthi+exp_widthi-1:sig_widthi];
  O0I1lOlI = a[sig_widthi-1:0];
  O01OIO01 = a[sig_widthi+exp_widthi];
  OO01001O = 0;
  OO01001O[5     ] = O01OIO01;

  if (use_denormal == 0)
  begin 
  if (OlOOO0O1 == 0) 
    begin
      OO01001O[0] = 1'b1;
      OlOOO0O1 = 0;
      II0l1OO1 = 0;
    end
  else if (OlOOO0O1 == OlIIOOl1)
    begin
      OO01001O[1] = 1'b1;
      OlOOO0O1 = 0;
      II0l1OO1 = 0;
    end
  else
    II0l1OO1 = {1'b1, O0I1lOlI};
  end
  else
  begin 
  if (OlOOO0O1 == 0 && O0I1lOlI == 0) 
    begin
      OO01001O[0] = 1'b1;
      OlOOO0O1 = 0;
      II0l1OO1 = 0;
    end
  else if (OlOOO0O1 == OlIIOOl1 && O0I1lOlI == 0)
    begin
      OO01001O[1] = 1'b1;
      OlOOO0O1 = 0;
      II0l1OO1 = 0;
    end
  else if (OlOOO0O1 == 0 && O0I1lOlI != 0)
    begin
      OlOOO0O1 = 1;
      II0l1OO1 = {1'b0, O0I1lOlI};
    end
  else if (OlOOO0O1 == OlIIOOl1 && O0I1lOlI !== 0)
    begin
      OO01001O[2] = 1'b1;
      OlOOO0O1 = 0;
      II0l1OO1 = 0;
    end
  else
    II0l1OO1 = {1'b1, O0I1lOlI};
  end

  OI00O001 = ({1'b0,II0l1OO1});

  if (sig_widtho > sig_widthi+2) 
    OOI00lIl = {OI00O001,{`DW_l0l1100O{1'b0}}};
  else
    OOI00lIl = OI00O001;

  if (O01OIO01 == 1 && ~(OO01001O[0] | OO01001O[1])) 
    begin
      if (use_1scmpl)
        begin
          OO10lO1O = ~OOI00lIl;
          OO01001O[4     ] = 1'b1;
        end
      else
        OO10lO1O = ~OOI00lIl + 1;
    end
  else if (OO01001O[0] | OO01001O[1])
    OO10lO1O = 0;
  else
    OO10lO1O = OOI00lIl;
  I1O01O10 = OO10lO1O;

  if (exp_widtho > exp_widthi)
    O0OOIO1l = {{`DW_IO011l0l{1'b0}},OlOOO0O1};
  else
    O0OOIO1l = OlOOO0O1;

  Il0000O1 = {OO01001O,O0OOIO1l,I1O01O10};
  
end

assign z = ((^(a ^ a) !== 1'b0)) ? {sig_widtho+exp_widtho+4{1'bx}} : Il0000O1;

`undef DW_l0l1100O
`undef DW_IO011l0l

// synopsys translate_on
endmodule

