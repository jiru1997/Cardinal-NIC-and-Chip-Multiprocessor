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
// AUTHOR:    Doug Lee  May 10, 2006
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 4fad6e9d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Asymmetric Data Input Buffer Simulation Model
//
//           Input registers used for asymmetric data transfer when the
//           input data width is less than and an integer multiple
//           of the output data width.
//
//              Parameters:     Valid Values
//              ==========      ============
//              in_width        [ 1 to 256]
//              out_width       [ 1 to 256]
//                  Note: in_width must be less than
//                        out_width and an integer multiple:
//                        that is, out_width = K * in_width
//              err_mode        [ 0 = sticky error flag,
//                                1 = dynamic error flag ]
//              byte_order      [ 0 = the first byte (or subword) is in MSBs
//                                1 = the first byte  (or subword)is in LSBs ]
//              flush_value     [ 0 = fill empty bits of partial word with 0's upon flush
//                                1 = fill empty bits of partial word with 1's upon flush ]
//
//              Input Ports     Size    Description
//              ===========     ====    ===========
//              clk_push        1 bit   Push I/F Input Clock
//              rst_push_n      1 bit   Async. Push Reset (active low)
//              init_push_n     1 bit   Sync. Push Reset (active low)
//              push_req_n      1 bit   Push Request (active low)
//              data_in         M bits  Data subword being pushed
//              flush_n         1 bit   Flush the partial word into
//                                      the full word memory (active low)
//              fifo_full       1 bit   Full indicator of RAM/FIFO
//
//              Output Ports    Size    Description
//              ============    ====    ===========
//              push_wd_n       1 bit   Full word ready for transfer (active low)
//              data_out        N bits  Data word into RAM or FIFO
//              inbuf_full      1 bit   Inbuf registers all contain active data_in subwords
//              part_wd         1 bit   Partial word pushed flag
//              push_error      1 bit   Overrun of RAM or FIFO (includes inbuf registers)
//
//                Note: M is the value of the parameter in_width
//                      N is the value of the parameter out_width
//
//
// MODIFIED:
//
//   10/27/09  DLL  Addresses STAR#9000351964.  Fixed data corruption in
//                  the case when both flush and push are requested
//                  with the input buffer empty.
//
////////////////////////////////////////////////////////////////////////////////
module DW_asymdata_inbuf (
        clk_push,
        rst_push_n,
        init_push_n,
        push_req_n,
        data_in,
        flush_n,
        fifo_full,

        push_wd_n,
        data_out,
        inbuf_full,
        part_wd,
        push_error
        );

parameter in_width     = 8;  // RANGE 1 to 256
parameter out_width    = 16; // RANGE 1 to 256
parameter err_mode     = 0;  // RANGE 0 to 1
parameter byte_order   = 0;  // RANGE 0 to 1
parameter flush_value  = 0;  // RANGE 0 to 1


input                   clk_push;       // clk
input                   rst_push_n;     // active low async reset
input                   init_push_n;    // active low sync reset
input                   push_req_n;     // active low push reqest
input   [in_width-1:0]  data_in;        // data subword
input                   flush_n;        // active low flush partial word
input                   fifo_full;      // Full indicator of RAM/FIFO

output                  push_wd_n;      // active low ready to write full data word
output  [out_width-1:0] data_out;       // full data word
output                  inbuf_full;     // Inbuf registers all contain active data_in subwords
output                  part_wd;        // Partial word pushed flag
output                  push_error;     // Overrun of RAM or FIFO (includes inbuf registers)

// synopsys translate_off
`define DW_K (out_width/in_width)
`define DW_cnt_width  ((`DW_K>16)?((`DW_K>64)?((`DW_K>128)?8:7):((`DW_K>32)?6:5)):((`DW_K>4)?((`DW_K>8)?4:3):((`DW_K>2)?2:1)))


wire    [in_width-1:0]  data_in_int;     // internal data subword
wire                    fifo_full;   // internal fifo_full

reg     [out_width-1:0] data_out_int;
wire    [out_width-1:0] next_data_out_int;

reg                     push_error_int;
wire                    next_push_error_int;
wire                    pre_next_push_error_int;


reg     [in_width-1:0]       data_reg [0:`DW_K-2];
reg     [in_width-1:0]       next_data_reg [0:`DW_K-2];
reg     [(in_width*(`DW_K-1))-1:0]       data_reg_vec;
reg     [(in_width*(`DW_K-1))-1:0]       next_data_reg_vec;

reg     [`DW_cnt_width-1:0]  cntr;
wire    [`DW_cnt_width-1:0]  next_cntr;

wire    flush_ok;

reg     [in_width-1:0]       temp_sw;

integer  i, midx;
integer  v_sw, v_b;
integer  w_sw, w_b;


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
  
    if ( (flush_value < 0) || (flush_value > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter flush_value (legal range: 0 to 1)",
	flush_value );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



assign  data_in_int     = (data_in | (data_in ^ data_in));

assign  flush_ok  = ~flush_n & part_wd & ~fifo_full;

assign  next_cntr = (~push_req_n && flush_ok) ? 1'b1 :
                      flush_ok ? {`DW_cnt_width{1'b0}} :
                        (~push_req_n && !pre_next_push_error_int) ? 
                          ((cntr == `DW_K-1) ? 
                           {`DW_cnt_width{1'b0}} : cntr + 1) :
                          (~push_req_n && !inbuf_full) ?  cntr + 1 :
                          cntr; 

assign  pre_next_push_error_int  = ((~flush_n && part_wd) || (~push_req_n && inbuf_full)) && fifo_full;
assign  next_push_error_int      = (err_mode == 0) ? pre_next_push_error_int | push_error_int : pre_next_push_error_int;


always @(rst_push_n or init_push_n or push_req_n or flush_ok or 
	 data_in_int or cntr or data_reg_vec) begin : PROC_load_data_reg_vec
  if (push_req_n === 1'b0) begin
    if (flush_ok === 1'b0) begin
      for (v_sw=0; v_sw < `DW_K-1; v_sw=v_sw+1) begin
        for (v_b=0; v_b < in_width; v_b=v_b+1) begin
          if (v_sw == cntr) begin
            next_data_reg_vec[(in_width*v_sw)+v_b] = data_in_int[v_b];
          end else begin
            if (v_sw < cntr) begin
              next_data_reg_vec[(in_width*v_sw)+v_b] = data_reg_vec[(in_width*v_sw)+v_b];
            end else begin
              if (flush_value == 0)
                next_data_reg_vec[(in_width*v_sw)+v_b] = 1'b0;
              else
                next_data_reg_vec[(in_width*v_sw)+v_b] = 1'b1;
            end
          end 
        end // "v_b" loop
      end // "v_sw" loop
    end else begin // flush_ok=1
      for (v_sw=0; v_sw < `DW_K-1; v_sw=v_sw+1) begin
        for (v_b=0; v_b < in_width; v_b=v_b+1) begin
          if (v_sw == 0)
            next_data_reg_vec[v_b] = data_in_int[v_b];
          else
            if (flush_value == 0)
              next_data_reg_vec[(in_width*v_sw)+v_b] = {in_width{1'b0}};
            else
              next_data_reg_vec[(in_width*v_sw)+v_b] = {in_width{1'b1}};
        end // "v_b" loop
      end // "v_sw" loop
    end
  end else if ((rst_push_n === 1'b0) || (init_push_n === 1'b0)) begin
    for (i=0; i < (in_width*`DW_K-1); i=i+1) begin
      next_data_reg_vec[i] = {in_width{1'b0}};
    end
  end else begin
    for (i=0; i < (in_width*`DW_K-1); i=i+1) begin
      next_data_reg_vec[i] = data_reg_vec[i];
    end
  end
end   // of PROC_load_data_reg_vec



always @(data_in_int or flush_ok or data_reg_vec) begin : gen_data_out_PROC

  if (byte_order == 0) begin
    for (w_sw=0; w_sw<`DW_K; w_sw=w_sw+1) begin
      for (w_b=0; w_b<in_width; w_b=w_b+1) begin
        if (flush_ok) begin
          if (w_sw == `DW_K-1) begin
            if (flush_value == 0)
              data_out_int[w_b] = 1'b0;
            else
              data_out_int[w_b] = 1'b1;
          end else begin
            data_out_int[(in_width*((`DW_K-1)-w_sw))+w_b] = data_reg_vec[(in_width*w_sw)+w_b];
          end
        end else begin
          if (w_sw == `DW_K-1) begin
            data_out_int[w_b] = data_in_int[w_b];
          end else begin
            data_out_int[(in_width*((`DW_K-1)-w_sw))+w_b] = data_reg_vec[(in_width*w_sw)+w_b];
          end
        end 
      end
    end
  end else begin
    for (w_sw=0; w_sw<`DW_K; w_sw=w_sw+1) begin
      for (w_b=0; w_b<in_width; w_b=w_b+1) begin
        if (flush_ok) begin
          if (w_sw == `DW_K-1) begin
            if (flush_value == 0)
              data_out_int[(in_width*w_sw)+w_b] = 1'b0;
            else
              data_out_int[(in_width*w_sw)+w_b] = 1'b1;
          end else begin
            data_out_int[(in_width*w_sw)+w_b] = data_reg_vec[(in_width*w_sw)+w_b];
          end
        end else begin
          if (w_sw == `DW_K-1) begin
            data_out_int[(in_width*w_sw)+w_b] = data_in_int[w_b];
          end else begin
            data_out_int[(in_width*w_sw)+w_b] = data_reg_vec[(in_width*w_sw)+w_b];
          end
        end 
      end
    end
  end  // (byte_order == 1)
end  // of PROC_gen_data_out

  always @(posedge clk_push or negedge rst_push_n) begin : a1000_PROC
    if (rst_push_n === 1'b0) begin
      push_error_int     <= 1'b0;
      cntr               <= {`DW_cnt_width{1'b0}};
      for (midx=0; midx<`DW_K-1; midx=midx+1) begin
        data_reg[midx]   <= {in_width{1'b0}};
      end
      data_reg_vec       <= {(in_width*(`DW_K-1)){1'b0}};
    end else if (rst_push_n === 1'b1) begin
      if (init_push_n === 1'b0) begin
        push_error_int     <= 1'b0;
        cntr               <= {`DW_cnt_width{1'b0}};
        for (midx=0; midx<`DW_K-1; midx=midx+1) begin
          data_reg[midx]   <= {in_width{1'b0}};
        end
        data_reg_vec       <= {(in_width*(`DW_K-1)){1'b0}};
      end else if (init_push_n === 1'b1) begin
        push_error_int     <= next_push_error_int;
        cntr               <= next_cntr;
        for (midx=0; midx<`DW_K-1; midx=midx+1) begin
          data_reg[midx]   <= next_data_reg[midx];
        end
        data_reg_vec       <= next_data_reg_vec;
      end else begin
        push_error_int     <= 1'bX;
        cntr               <= {`DW_cnt_width{1'bX}};
        for (midx=0; midx<`DW_K-1; midx=midx+1) begin
          data_reg[midx]   <= {in_width{1'bX}};
        end
        data_reg_vec       <= {(in_width*(`DW_K-1)){1'bX}};
      end
    end else begin
      push_error_int     <= 1'bX;
      cntr               <= {`DW_cnt_width{1'bX}};
      for (midx=0; midx<`DW_K-1; midx=midx+1) begin
        data_reg[midx]   <= {in_width{1'bX}};
      end
      data_reg_vec       <= {(in_width*(`DW_K-1)){1'bX}};
    end
  end

  assign  push_wd_n   = ~(((~push_req_n && inbuf_full) || flush_ok) && ~pre_next_push_error_int);
  assign  data_out    = data_out_int;
  assign  push_error  = push_error_int;
  assign  inbuf_full  = cntr > `DW_K-2;
  assign  part_wd     = cntr > 0;

  
  always @ (clk_push) begin : monitor_clk_push 
    if ( (clk_push !== 1'b0) && (clk_push !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_push input.",
                $time, clk_push );
    end // monitor_clk_push 

`undef DW_K 
`undef DW_cnt_width 
// synopsys translate_on
endmodule
