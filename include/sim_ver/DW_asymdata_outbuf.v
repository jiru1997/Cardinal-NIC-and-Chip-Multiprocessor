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
// AUTHOR:    Doug Lee  May 26, 2006
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 1cf4e60e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Asymmetric Data Output Buffer Simulation Model
//           Output multiplexer used for asymmetric data transfers when the
//           input data width is greater than and an integer multiple
//           of the output data width.
//
//              Parameters:     Valid Values
//              ==========      ============
//              in_width        [ 1 to 256]
//              out_width       [ 1 to 256]
//                  Note: in_width must be greater than
//                        out_width and an integer multiple:
//                        that is, in_width = K * out_width
//              err_mode        [ 0 = sticky error flag,
//                                1 = dynamic error flag ]
//              byte_order      [ 0 = the first byte (or subword) is in MSBs
//                                1 = the first byte (or subword)is in LSBs ]
//
//              Input Ports     Size    Description
//              ===========     ====    ===========
//              clk_pop         1 bit   Pop I/F Input Clock
//              rst_pop_n       1 bit   Async. Pop Reset (active low)
//              init_pop_n      1 bit   Sync. Pop Reset (active low)
//              pop_req_n       1 bit   Active Low Pop Request
//              data_in         M bits  Data 'full' word being popped
//              fifo_empty      1 bit   Empty indicator from fifoctl that RAM/FIFO is empty
//
//              Output Ports    Size    Description
//              ============    ====    ===========
//              pop_wd_n        1 bit   Full word for transfered (active low)
//              data_out        N bits  Data subword into RAM or FIFO
//              part_wd         1 bit   Partial word poped flag
//              pop_error       1 bit   Underrun of RAM or FIFO
//
//                Note: M is the value of the parameter in_width
//                      N is the value of the parameter out_width
//
//
// MODIFIED:
//
////////////////////////////////////////////////////////////////////////////////
module DW_asymdata_outbuf(
        clk_pop,
        rst_pop_n,
        init_pop_n,
        pop_req_n,
        data_in,
        fifo_empty,

        pop_wd_n,
        data_out,
        part_wd,
        pop_error
        );


parameter in_width     = 16; // RANGE 1 to 256
parameter out_width    =  8; // RANGE 1 to 256
parameter err_mode     =  0; // RANGE 0 to 1
parameter byte_order   =  0; // RANGE 0 to 1
  

input                   clk_pop;        // clk
input                   rst_pop_n;      // active low async reset
input                   init_pop_n;     // active low sync reset
input                   pop_req_n;      // active high pop reqest
input   [in_width-1:0]  data_in;        // data full word
input                   fifo_empty;     // empty indicator from fifoctl that RAM/FIFO is empty

output                  pop_wd_n;       // full data word read
output  [out_width-1:0] data_out;       // data subword
output                  part_wd;        // Partial word poped flag
output                  pop_error;      // Underrun of RAM or FIFO


// synopsys translate_off
`define DW_K (in_width/out_width)
`define DW_cnt_width  ((`DW_K>16)?((`DW_K>64)?((`DW_K>128)?8:7):((`DW_K>32)?6:5)):((`DW_K>4)?((`DW_K>8)?4:3):((`DW_K>2)?2:1)))


wire    [in_width-1:0]  data_in_int;     // internal data subword
wire                    fifo_full;   // internal fifo_full

reg     [out_width-1:0] data_out_int;
wire    [out_width-1:0] next_data_out_int;

reg                     pop_error_int;
wire                    next_pop_error_int;
wire                    pre_next_pop_error_int;


reg     [`DW_cnt_width-1:0]  cntr;
wire    [`DW_cnt_width-1:0]  next_cntr;

integer   w_sw, w_b;

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if (in_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter in_width (lower bound: 1)",
	in_width );
    end
  
    if (out_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter out_width (lower bound: 1)",
	out_width );
    end
  
    if ( (err_mode < 0) || (err_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 1)",
	err_mode );
    end
  
    if ( (byte_order < 0) || (byte_order > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter byte_order (legal range: 0 to 1)",
	byte_order );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


assign  data_in_int     = (data_in | (data_in ^ data_in));

assign  next_cntr  = (!pop_req_n && !pre_next_pop_error_int) ? 
                       ((cntr == `DW_K-1) ? 
                         {`DW_cnt_width{1'b0}} : cntr + 1) :
                       cntr; 

assign  pre_next_pop_error_int  = ~pop_req_n && fifo_empty;
assign  next_pop_error_int      = (err_mode == 0) ? pre_next_pop_error_int | pop_error_int : pre_next_pop_error_int;


always @(data_in_int or cntr) begin : gen_data_out_PROC
  data_out_int = {out_width{1'b0}};
  if (byte_order == 0) begin
    for (w_sw=0; w_sw<`DW_K; w_sw=w_sw+1) begin
      for (w_b=0; w_b<out_width; w_b=w_b+1) begin
        if (w_sw === cntr) begin
          data_out_int[w_b] = data_in_int[(in_width-(out_width*(w_sw+1)))+w_b];
        end
      end
    end
  end else begin
    for (w_sw=0; w_sw<`DW_K; w_sw=w_sw+1) begin
      for (w_b=0; w_b<out_width; w_b=w_b+1) begin
        if (w_sw === cntr) begin
          data_out_int[w_b] = data_in_int[(out_width*w_sw)+w_b];
        end
      end
    end
  end  // (byte_order == 1)
end  // of PROC_gen_data_out

  always @(posedge clk_pop or negedge rst_pop_n) begin : a1000_PROC
    if (rst_pop_n === 1'b0) begin
      pop_error_int     <= 1'b0;
      cntr              <= {`DW_cnt_width{1'b0}};
    end else if (rst_pop_n === 1'b1) begin
      if (init_pop_n === 1'b0) begin
        pop_error_int     <= 1'b0;
        cntr              <= {`DW_cnt_width{1'b0}};
      end else if (init_pop_n === 1'b1) begin
        pop_error_int     <= next_pop_error_int;
        cntr              <= next_cntr;
      end else begin
        pop_error_int     <= 1'bX;
        cntr              <= {`DW_cnt_width{1'bX}};
      end
    end else begin
      pop_error_int     <= 1'bX;
      cntr              <= {`DW_cnt_width{1'bX}};
    end
  end

  assign  pop_wd_n   = ~(((pop_req_n === 1'b0) && (cntr === `DW_K-1)) && ~pre_next_pop_error_int);
  assign  data_out   = data_out_int;
  assign  pop_error  = pop_error_int;
  assign  part_wd    = cntr > 0;

  
  always @ (clk_pop) begin : monitor_clk_pop 
    if ( (clk_pop !== 1'b0) && (clk_pop !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_pop input.",
                $time, clk_pop );
    end // monitor_clk_pop 

`undef DW_K 
`undef DW_cnt_width 
// synopsys translate_on
endmodule
