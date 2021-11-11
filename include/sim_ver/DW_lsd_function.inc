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
// AUTHOR:    Reto Zimmermann	Mar. 22, 2006
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 0e6bbc64
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Leading Signs Detector with encoded output
//
// MODIFIED:
//
////////////////////////////////////////////////////////////////////////////////

function [addr_width-1:0] DWF_lsd_enc;

  // synopsys map_to_operator LSD_ENC_UNS_OP
  // synopsys return_port_name Z 

  input  [a_width-1:0] A;
  reg [addr_width-1:0] temp;
  reg done;
  integer i;

  begin
    // synopsys translate_off
    done = 0;
    temp = a_width-1;   // default
    for (i=a_width-2; (done == 0) && (i >= 0); i=i-1) begin
      if ((A[i+1] === 1'bx) || (A[i] === 1'bx)) begin
        temp = {addr_width{1'bx}};
        done = 1;  // return "x" if "x" found first
      end
      else if (A[i+1] !== A[i]) begin
        temp = a_width - i - 2;
        done = 1;  // return first non-sign position
      end
    end
  
    DWF_lsd_enc = temp;
    // synopsys translate_on
  end
endfunction // DWF_lsd_enc


////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Leading Signs Detector with decoded output
//
// MODIFIED:
//
////////////////////////////////////////////////////////////////////////////////
function [a_width-1:0] DWF_lsd;

  // synopsys map_to_operator LSD_DEC_UNS_OP
  // synopsys return_port_name Z 

  input  [a_width-1:0] A;
  reg [addr_width-1:0] temp_enc;
  reg    [a_width-1:0] temp_dec;

  begin
    // synopsys translate_off
    temp_enc = DWF_lsd_enc (A);
    temp_dec = {a_width{1'b0}};

    if (^temp_enc === 1'bx)
      temp_dec = {a_width{1'bx}};
    else
      temp_dec[a_width - temp_enc - 1] = 1'b1;

    DWF_lsd = temp_dec;
    // synopsys translate_on
  end
endfunction // DWF_lsd
