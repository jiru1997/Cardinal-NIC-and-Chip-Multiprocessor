
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2010 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Kyung-Nam Han   Oct. 26, 2010
//
// VERSION:   Verilog Synthesis Model for DW_lp_multifunc_DG
//
// DesignWare_version: 26e9b7a7
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT: Fixed-point Multi-function Unit with Datapath Gating
//
//              DW_lp_multifunc_DG calculates transcendental functions 
//              with polynomial approximation method. Functions that are 
//              implemented include reciprocal, square root, inverse 
//              square root, trigonometric functions, logarithm and 
//              exponential function. All can be implemented in one unit,
//              but user can choose some of them or just one function for
//              the implementation. The DG_ctrl input controls Datapath Gating.
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              op_width        operand width,  3 to 24 bits
//              func_select     Select functions to be implemented
//                              16-bit binary parameter
//                              func_select[0]: reciprocal, 1/x
//                              func_select[1]: square root, sqrt(x)
//                              func_select[2]: inv. square root, 1/sqrt(x)
//                              func_select[3]: sine function, sin(pi*x)
//                              func_select[4]: cosine function, cos(pi*x)
//                              func_select[5]: base-2 log function, log2(x)
//                              func_select[6]: base-2 power function, 2^x
//                              func_select[7:15]: reserved
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (op_width + 1) bits
//                              Fixed-point Number Input
//              func            16-bit Function selection port
//                              Output function is determined by FUNC
//              DG_ctrl         Datapath gating contro input
//                              1 bit (default is 1)
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (op_width + 2) bits
//                              Fixed-point number output
//              status          1 bit
//
//-----------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////

module DW_lp_multifunc_DG( a, func, DG_ctrl, z, status );

parameter op_width = 24;
parameter func_select = 127;

input [op_width : 0] a;
input [15 : 0] func;
input DG_ctrl;

output [op_width+1 : 0] z;
output status;

// synopsys translate_off

wire [op_width+1 : 0] z_temp;
wire status_temp;

// Instance of DW_lp_multifunc
DW_lp_multifunc #(op_width, func_select) U1 (
                    .a(a),
                    .func(func),
                    .z(z_temp),
                    .status(status_temp) 
);

assign z = (DG_ctrl) ? z_temp : {(op_width + 2){1'bX}};
assign status = (DG_ctrl) ? status_temp : 1'bX;

// synopsys translate_on

endmodule
