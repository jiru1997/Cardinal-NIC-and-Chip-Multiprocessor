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
// VERSION:   Verilog Simulation Model - IFP to FP converter
//
// DesignWare_version: 5472649c
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point internal format to IEEE format converter
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_widthi      significand size,  2 to 253 bits
//              exp_widthi      exponent size,     3 to 31 bits
//              sig_width       significand size,  2 to 253 bits
//              exp_width       exponent size,     3 to 31 bits
//              use_denormal    0 or 1  (default 0)
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_widthi + exp_widthi + 7)-bits
//                              Internal Floating-point Number Input
//              rnd             3 bits
//                              Rounding mode
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              IEEE Floating-point Number
//              status          8 bits
//                              Status information about FP number
//
//           Important, although the IFP has a bit for 1's complement 
//           representation, this converter does not process this bit. 
//           An error message will be issued when an input in 1s complement
//           is applied.
//
// MODIFIED: 11/2008 - to include the manipulation of denormals and NaN
//
//------------------------------------------------------------------------------

module DW_ifp_fp_conv (a, rnd, z, status);
parameter sig_widthi=25;
parameter exp_widthi=8;  
parameter sig_width=23;
parameter exp_width=8;  
parameter use_denormal=0;                    


// declaration of inputs and outputs
input  [sig_widthi+exp_widthi+7-1:0] a;
input  [2:0] rnd;
output [sig_width+exp_width:0] z;
output [7:0] status;

// synopsys translate_off

function [4-1:0] O1I1O111;

  input [2:0] lllOI11l;
  input [0:0] OOIOOI1l;
  input [0:0] IOl0I1O0,OO11OI10,lO0IO0OO;


  begin
  O1I1O111[0] = 0;
  O1I1O111[1] = OO11OI10|lO0IO0OO;
  O1I1O111[2] = 0;
  O1I1O111[3] = 0;
  if ($time > 0)
  case (lllOI11l)
    3'b000:
    begin
      O1I1O111[0] = OO11OI10&(IOl0I1O0|lO0IO0OO);
      O1I1O111[2] = 1;
      O1I1O111[3] = 0;
    end
    3'b001:
    begin
      O1I1O111[0] = 0;
      O1I1O111[2] = 0;
      O1I1O111[3] = 0;
    end
    3'b010:
    begin
      O1I1O111[0] = ~OOIOOI1l & (OO11OI10|lO0IO0OO);
      O1I1O111[2] = ~OOIOOI1l;
      O1I1O111[3] = ~OOIOOI1l;
    end
    3'b011:
    begin
      O1I1O111[0] = OOIOOI1l & (OO11OI10|lO0IO0OO);
      O1I1O111[2] = OOIOOI1l;
      O1I1O111[3] = OOIOOI1l;
    end
    3'b100:
    begin
      O1I1O111[0] = OO11OI10;
      O1I1O111[2] = 1;
      O1I1O111[3] = 0;
    end
    3'b101:
    begin
      O1I1O111[0] = OO11OI10|lO0IO0OO;
      O1I1O111[2] = 1;
      O1I1O111[3] = 1;
    end
    default:
      $display("Error! illegal rounding mode.\n");
  endcase
  end

endfunction



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
  
    if ( (sig_width < 2) || (sig_width > sig_widthi) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to sig_widthi)",
	sig_width );
    end
  
    if ( (exp_width < 3) || (exp_width > exp_widthi) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_width (legal range: 3 to exp_widthi)",
	exp_width );
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


  reg IlOI0OlI;
  reg [exp_widthi-1:0] l00I11O1;
  reg [exp_widthi+2:0] O0OlO000;
  reg signed [sig_widthi:0] I1I11l00;
  reg signed [sig_widthi:0] O0l10lOl;
  reg [sig_width-1:0] OIO11I0l;
  reg [sig_width-1:0] Ol0IO000;
  reg [exp_width-1:0] llIlOOOI;
  reg [exp_width-1:0] OOO1I1O0;
  reg [7-1:0] lI11O100;
  reg [7:0] OO1IO111;
  reg [sig_width+exp_width:0] lI00OO0O;
  reg [sig_widthi:0] lOIO0l11;
  reg [sig_widthi+sig_width:0] O00OO01I;
  reg [sig_widthi+sig_width:0] I11OOl00;
  reg [sig_widthi+sig_width:0] OIO1Ol10;
  reg lO0IO0OO, OO01IO01, I01O1l01;
  reg [exp_width-1:0] l1010I10;
  reg [4-1:0] l1O0l10l;

// main process of information
always @(a or rnd)
begin
  // variable initialization
  OIO11I0l = 0;
  Ol0IO000 = 0;
  Ol0IO000[0] = 1'b1;
  llIlOOOI = 0;
  OOO1I1O0 = ~0;
  OO1IO111 = 0;
  l1010I10 = 1;
  lOIO0l11 = 0;
  O00OO01I = 0;
  lI00OO0O = 0;

  // Pass the status bits to the status output
  OO1IO111 = 0;
  lI11O100 = a[sig_widthi+exp_widthi+7-1:sig_widthi+exp_widthi];
  OO1IO111[2:0] = lI11O100[2:0]; // invalid/inf/zero flags
  OO1IO111[5] = lI11O100[3];
  if (lI11O100[4] == 1'b1)
      $display("ERROR: %m :\n  Module is receiving an input in 1s complement, and it does not process it");
    
  l00I11O1 = a[sig_widthi+exp_widthi-1:sig_widthi];
  IlOI0OlI = a[sig_widthi-1];
  I1I11l00 = $signed({a[sig_widthi-1:0],lI11O100[3]});
  if (IlOI0OlI == 1'b1) 
    O0l10lOl = -I1I11l00;
  else
    O0l10lOl = I1I11l00;
  O0l10lOl[0] = 1'b0;  
  if (OO1IO111[2:0]!= 0)
    begin  
      if (OO1IO111[0] == 1 && OO1IO111[2] == 0) 
        if (OO1IO111[5] == 1) 
          begin
            if ((rnd == 3 && lI11O100[5     ] == 1) ||
                (rnd == 2 && lI11O100[5     ] == 0) ||
                rnd == 5) 
              begin
                lI00OO0O = (use_denormal == 0)?
                         {lI11O100[5     ], l1010I10, OIO11I0l}:
                         {lI11O100[5     ], llIlOOOI, Ol0IO000};
                OO1IO111[0] = 1'b0;
                OO1IO111[3] = (use_denormal==0)?0:1;
              end
            else
  	      begin
                lI00OO0O = {lI11O100[5     ], llIlOOOI, OIO11I0l};
                OO1IO111[0] = 1'b1;
	        OO1IO111[3] = 1'b1;
              end
          end
        else
          lI00OO0O = {lI11O100[5     ], llIlOOOI, OIO11I0l};
      if (OO1IO111[1] == 1'b1 && OO1IO111[2] == 1'b0) 
	begin
          lI00OO0O = {lI11O100[5     ], OOO1I1O0, OIO11I0l};
          OO1IO111[0] = 1'b0;
        end
      if (OO1IO111[2] == 1'b1) 
        begin
          OO1IO111 = {8{1'b0}};
          if (use_denormal == 0)
            begin
              lI00OO0O = {1'b0, OOO1I1O0, OIO11I0l};
              OO1IO111[1] = 1'b1;
              OO1IO111[2] = 1'b1;
            end
          else
            begin
              lI00OO0O = {1'b0, OOO1I1O0, Ol0IO000};
              OO1IO111[2] = 1'b1;
            end
        end
    end
  else
    begin
      lO0IO0OO = OO1IO111[5];
      O0OlO000 = (O0l10lOl == 0)?0:$unsigned(l00I11O1);
      IlOI0OlI = (O0l10lOl == 0 & IlOI0OlI == 0)?lI11O100[5     ]:IlOI0OlI;
      lOIO0l11 = O0l10lOl;
      if (lOIO0l11[sig_widthi] == 1'b1 || O0OlO000 < l1010I10)
        begin
          lOIO0l11 = lOIO0l11 >> 1;
          O0OlO000 = O0OlO000 + 1;
        end
      while ( (lOIO0l11[sig_widthi:sig_widthi-1] == 0) && (O0OlO000 > l1010I10) ) 
        begin
          O0OlO000 = O0OlO000 - 1;
          lOIO0l11 = lOIO0l11 << 1;
        end
        if (sig_widthi+sig_width > sig_widthi)
          O00OO01I = lOIO0l11 << (sig_widthi+sig_width-sig_widthi);
        else
          O00OO01I = lOIO0l11;
  
        I11OOl00 = O00OO01I;
   
        lO0IO0OO = |O00OO01I[sig_widthi+sig_width-sig_width-1-1-1:0] | lO0IO0OO;
        OO01IO01 = O00OO01I[sig_widthi+sig_width-sig_width-1-1];
        I01O1l01 = O00OO01I[sig_widthi+sig_width-sig_width-1];
        l1O0l10l = O1I1O111(rnd, IlOI0OlI, I01O1l01, OO01IO01, lO0IO0OO);

       if (l1O0l10l[0] == 1'b1) 
         O00OO01I = O00OO01I + (1<<(sig_widthi+sig_width-sig_width-1));

        OIO1Ol10 = O00OO01I;

         if ( (O00OO01I[sig_widthi+sig_width] == 1'b1) ) 
           begin
             O0OlO000 = O0OlO000 + 1;
             O00OO01I = O00OO01I >> 1;
           end
  
        if (((O0OlO000 < l1010I10) && ((lO0IO0OO == 1'b1) || (lOIO0l11 != 0)))  ||
            ((O0OlO000 == l1010I10) && (O00OO01I[sig_widthi+sig_width:sig_widthi+sig_width-1]==0)&&
             ((lO0IO0OO == 1'b1) || (lOIO0l11 != 0))))
          begin
            if ((use_denormal == 1) && 
                (O00OO01I[sig_widthi+sig_width-2:sig_widthi+sig_width-sig_width-1] !== 0))
              begin
 	        lI00OO0O = {IlOI0OlI,llIlOOOI,O00OO01I[sig_widthi+sig_width-2:sig_widthi+sig_width-sig_width-1]};
                OO1IO111[3] = 1;
                if ((lO0IO0OO == 1) || (O00OO01I[sig_widthi+sig_width-sig_width-1-1:0] != 0))
                  OO1IO111[5] = 1;
                if (O00OO01I[sig_widthi+sig_width-2:sig_widthi+sig_width-sig_width-1] == 0) 
                  OO1IO111[0] = 1; 
              end
            else 
              begin               
              // value is zero of minimal non-zero representable FP,
              // when denormal is not used --> becomes zero or minFP
              // when denormal is used --> becomes zero or mindenorm
                if ((rnd == 3 && IlOI0OlI == 1'b1) ||
                    (rnd == 2 && IlOI0OlI == 1'b0) ||
                     rnd == 5) 
                  begin
                    lI00OO0O = (use_denormal == 0)?{IlOI0OlI, l1010I10, OIO11I0l}:
                                                 {IlOI0OlI, llIlOOOI, Ol0IO000};
                    OO1IO111[0] = 1'b0;
	            OO1IO111[3] = (use_denormal==0)?1'b0:1'b1;
                  end
                else
                  begin
                    lI00OO0O = {IlOI0OlI, llIlOOOI, OIO11I0l};
                    OO1IO111[0] = 1'b1;
                    OO1IO111[3] = 1'b1;
                  end
                OO1IO111[5] = 1'b1;
              end
          end
        else
        begin
          if (lOIO0l11 == 0)
            begin
              // output was reduced to a zero
              O0OlO000 = 0;
              O00OO01I = 0;
              OO1IO111[0] = 1'b1;
            end
          if (O0OlO000 >= ((((1 << (exp_width-1)) - 1) * 2) + 1)) 
            begin
              OO1IO111[4] = 1'b1;
              OO1IO111[5] = 1'b1;
              if (l1O0l10l[2] == 1'b1) 
                begin
                  O00OO01I[sig_widthi+sig_width:sig_widthi+sig_width-sig_width-1] = 0;
                  O0OlO000 = ((((1 << (exp_width-1)) - 1) * 2) + 1);
                  OO1IO111[1] = 1'b1;
                end
              else
                begin
                  O0OlO000 = ((((1 << (exp_width-1)) - 1) * 2) + 1) - 1;
                 O00OO01I[sig_widthi+sig_width:sig_widthi+sig_width-sig_width-1] = ~0;
                end
            end
            
          OO1IO111[5] = OO1IO111[5]|l1O0l10l[1];
          // Reconstruct the floating point format.
          lI00OO0O = {IlOI0OlI,O0OlO000[exp_width-1:0],O00OO01I[sig_widthi+sig_width-2:sig_widthi+sig_width-sig_width-1]};
        end
    end
  
end

assign z = ((^(a ^ a) !== 1'b0) | (^(rnd ^ rnd) !== 1'b0)) ? {sig_width+exp_width+1{1'bx}} : lI00OO0O;
assign status = OO1IO111;

// synopsys translate_on
endmodule

