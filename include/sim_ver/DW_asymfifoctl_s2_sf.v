////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1998 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Bob Tong                           Aug. 98
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 8ca8c13c
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT:  Asymmetric Synchronous, dual clcok with Static Flags
//           (FIFO) with static programmable almost empty and almost
//           full flags.
//
//           This FIFO controller designed to interface to synchronous
//           true dual port RAMs.
//
//              Parameters:     Valid Values
//              ==========      ============
//              data_in_width   [1 to 4096]
//              data_out_width  [1 to 4096]
//                  Note: data_in_width and data_out_width must be
//                        in integer multiple relationship: either
//                              data_in_width = K * data_out_width
//                        or    data_out_width = K * data_in_width
//              depth           [ 4 to 16777216 ]
//              push_ae_lvl     [ 1 to depth-1 ]
//              push_af_lvl     [ 1 to depth-1 ]
//              pop_ae_lvl      [ 1 to depth-1 ]
//              pop_af_lvl      [ 1 to depth-1 ]
//              err_mode        [ 0 = sticky error flag,
//                                1 = dynamic error flag ]
//              push_sync       [ 1 = single synchronized,
//                                2 = double synchronized,
//                                3 = triple synchronized ]
//              pop_sync        [ 1 = single synchronized,
//                                2 = double synchronized,
//                                3 = triple synchronized ]
//              rst_mode        [ 0 = asynchronous reset,
//                                1 = synchronous reset ]
//              byte_order      [ 0 = the first byte is in MSBs
//                                1 = the first byte is in LSBs ]
//
//              Input Ports:    Size    Description
//              ===========     ====    ===========
//              clk_push        1 bit   Push I/F Input Clock
//              clk_pop         1 bit   Pop I/F Input Clock
//              rst_n           1 bit   Active Low Reset
//              push_req_n      1 bit   Active Low Push Request
//              flush_n         1 bit   Flush the partial word into
//                                      the full word memory.  For
//                                      data_in_width<data_out_width
//                                      only
//              pop_req_n       1 bit   Active Low Pop Request
//              data_in         L bits  FIFO data to push
//              rd_data         M bits  RAM data input to asymmetric
//                                      FIFO controller
//
//              Output Ports    Size    Description
//              ============    ====    ===========
//              we_n            1 bit   Active low Write Enable 
//                                      (to RAM)
//              push_empty      1 bit   Push I/F Empty Flag
//              push_ae         1 bit   Push I/F Almost Empty Flag
//              push_hf         1 bit   Push I/F Half Full Flag
//              push_af         1 bit   Push I/F Almost Full Flag
//              push_full       1 bit   Push I/F Full Flag
//              ram_full        1 bit   Push I/F ram Full Flag
//              part_wd         1 bit   Partial word read flag.  For
//                                      data_in_width<data_out_width
//                                      only
//              push_error      1 bit   Push I/F Error Flag
//              pop_empty       1 bit   Pop I/F Empty Flag
//              pop_ae          1 bit   Pop I/F Almost Empty Flag
//              pop_hf          1 bit   Pop I/F Half Full Flag
//              pop_af          1 bit   Pop I/F Almost Full Flag
//              pop_full        1 bit   Pop I/F Full Flag
//              pop_error       1 bit   Pop I/F Error Flag
//              wr_data         M bits  FIFO controller output data
//                                      to RAM
//              wr_addr         N bits  Write Address (to RAM)
//              rd_addr         N bits  Read Address (to RAM)
//              data_out        O bits  FIFO data to pop
//
//                Note: the value of L is parameter data_in_width
//                Note: the value of M is
//                         maximum(data_in_width, data_out_width)
//                Note: the value of N for wr_addr and rd_addr is
//                      determined from the parameter, depth.  The
//                      value of N is equal to:
//                              ceil( log2( depth ) )
//                Note: the value of O is parameter data_out_width
//
//
//
// MODIFIED:     Rajeev Huralikoppi - rewrite according to the new verilog
//                                  guidelines
//
//		RJK 5/21/03 Added new ports on instance of DW_fifoctl_s2_sf
//                          FIFO controller used in this model (STAR 169066)
//
//              DLL 6/2/06  Fix for STAR#9000116335.  Wrong next_buffer[i]
//                          result during "data_in_width < data_out_width"
//                          configuration where integer multiple > 2.  The
//                          bug shows up under specific ram_full and simultaneous
//                          push/flush sequences.
//
//		RJK 7/31/13 Corrected default value for the parameter
//			    rst_mode to match synthesis default of 1
//			    (STAR 9000629609)
//
//              9/10/14   RJK       Eliminated common async and sync reset coding
//				    style to support VCS NLP
//
//---------------------------------------------------------------------

  module DW_asymfifoctl_s2_sf (
    clk_push, clk_pop, rst_n, push_req_n, flush_n, pop_req_n, data_in,
    rd_data, we_n, push_empty, push_ae, push_hf, push_af, push_full,
    ram_full, part_wd, push_error, pop_empty, pop_ae, pop_hf, pop_af,
    pop_full, pop_error, wr_data, wr_addr, rd_addr, data_out );

 parameter data_in_width  =  3;
 parameter data_out_width = 12;
 parameter depth          =  8;
 parameter push_ae_lvl    =  2;
 parameter push_af_lvl    =  2;
 parameter pop_ae_lvl     =  2;
 parameter pop_af_lvl     =  2;
 parameter err_mode       =  0;
 parameter push_sync      =  2;
 parameter pop_sync       =  2;
 parameter rst_mode       =  1;
 parameter byte_order     =  0;
   
 `define DW_addr_width ((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))))
 `define DW_count_width ((depth+1>65536)?((depth+1>16777216)?((depth+1>268435456)?((depth+1>536870912)?30:29):((depth+1>67108864)?((depth+1>134217728)?28:27):((depth+1>33554432)?26:25))):((depth+1>1048576)?((depth+1>4194304)?((depth+1>8388608)?24:23):((depth+1>2097152)?22:21)):((depth+1>262144)?((depth+1>524288)?20:19):((depth+1>131072)?18:17)))):((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1)))))
 `define DW_K ((data_in_width>data_out_width) ?  (data_in_width/data_out_width): (data_out_width/data_in_width))
 `define DW_max_width ((data_in_width>data_out_width) ? data_in_width: data_out_width)
 `define DW_min_width ((data_in_width<data_out_width) ? data_in_width: data_out_width)
   
 input  clk_push;
 input  clk_pop;
 input  rst_n;
 input  push_req_n;
 input  flush_n;
 input  pop_req_n;
 input  [data_in_width-1 : 0]     data_in;
 input  [`DW_max_width-1 : 0]        rd_data;

 output  we_n;
 output  push_empty;
 output  push_ae;
 output  push_hf;
 output  push_af;
 output  push_full;
 output  ram_full;
 output  part_wd;
 output  push_error;
 output  pop_empty;
 output  pop_ae;
 output  pop_hf;
 output  pop_af;
 output  pop_full;
 output  pop_error;
 output [`DW_max_width-1 : 0]         wr_data;
 output [`DW_addr_width-1 : 0]        wr_addr;
 output [`DW_addr_width-1 : 0]        rd_addr;
 output[(data_out_width-1) : 0]    data_out;

 // synopsys translate_off
 
 wire ram_push_n;
 wire ram_pop_n;
 wire ram_pop_full;
 wire flush_n_int;
 wire ram_push_full;
 wire ram_push_error, next_ram_push_error;
 wire ram_pop_error, next_ram_pop_error;
 wire pop_empty_int;
 wire [data_in_width-1 : 0]     data_in;
   
   reg [(data_in_width-1) : 0] ubuffer;
 
 reg [(data_in_width-1) : 0]	buffer [`DW_K-1 : 0];
 reg [(data_in_width-1) : 0]	next_buffer [`DW_K-1 : 0];  
   
 reg ram_write_en_n;
 reg buff_write_en_n;
 reg ram_pop_n_int;
 reg push_full_int;
 reg part_wd_int, next_part_wd_int;
 reg buff_error, next_buff_error;
 reg [`DW_max_width-1 : 0] wr_data_int;
 reg push_error_int, next_push_error_int;
 reg pop_error_int, next_pop_error_int;
 reg [(data_out_width-1) : 0]	data_out_int;

 wire [`DW_count_width-1 : 0]	unused_pop_count;
 wire [`DW_count_width-1 : 0]	unused_push_count;

 integer wd_buff_addr, next_wd_buff_addr;
 integer rd_buff_addr, next_rd_buff_addr;

 assign pop_empty = pop_empty_int;
 assign flush_n_int = (
  (data_in_width < data_out_width ) ? (flush_n ) : (
  1'b1 ));
 assign ram_pop_n = (
  (data_in_width <= data_out_width ) ? pop_req_n : 
  (ram_pop_n_int) );
 assign data_out = (
  (data_in_width <= data_out_width ) ? rd_data : (
  data_out_int ));
 assign pop_error = (
  (data_in_width <= data_out_width ) ? ram_pop_error : (
  pop_error_int ));
  assign ram_push_n = (
  (data_in_width  >= data_out_width ) ? push_req_n : (
  (ram_write_en_n )));  
 assign wr_data = (
  (data_in_width  >= data_out_width ) ? data_in : (
  wr_data_int ));
 assign part_wd = (
  (data_in_width  >= data_out_width ) ? 1'b0 : (
  part_wd_int ));
 assign push_full = (
  (data_in_width  >= data_out_width ) ? ram_push_full : (
  push_full_int ));
 assign push_error = (
  (data_in_width  >= data_out_width ) ? ram_push_error : (
  buff_error | ram_push_error ));
 assign  pop_full = ram_pop_full;
 assign  ram_full = ram_push_full;
   

   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    

   
    if ( (data_in_width < 1) || (data_in_width > 4096 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_in_width (legal range: 1 to 4096 )",
	data_in_width );
    end
   
    if ( (data_out_width < 1) || (data_out_width > 4096 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_out_width (legal range: 1 to 4096 )",
	data_out_width );
    end
   
    if ( (depth < 4) || (depth > 16777216 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 4 to 16777216 )",
	depth );
    end
   
    if ( (push_ae_lvl < 1) || (push_ae_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_ae_lvl (legal range: 1 to depth-1 )",
	push_ae_lvl );
    end
   
    if ( (push_af_lvl < 1) || (push_af_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_af_lvl (legal range: 1 to depth-1 )",
	push_af_lvl );
    end
   
    if ( (pop_ae_lvl < 1) || (pop_ae_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_ae_lvl (legal range: 1 to depth-1 )",
	pop_ae_lvl );
    end
   
    if ( (pop_af_lvl < 1) || (pop_af_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_af_lvl (legal range: 1 to depth-1 )",
	pop_af_lvl );
    end
   
    if ( (push_sync < 1) || (push_sync > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_sync (legal range: 1 to 3 )",
	push_sync );
    end
   
    if ( (pop_sync < 1) || (pop_sync > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_sync (legal range: 1 to 3 )",
	pop_sync );
    end
   
    if ( (err_mode < 0) || (err_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 1 )",
	err_mode );
    end
   
    if ( (rst_mode < 0) || (rst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1 )",
	rst_mode );
    end
   
    if ( (byte_order < 0) || (byte_order > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter byte_order (legal range: 0 to 1 )",
	byte_order );
    end

   
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


     
     always @ (push_req_n or ram_push_full or flush_n_int or data_in 
	       or wd_buff_addr or part_wd_int )
       begin : mk_next_buff_data
	  integer i;
	  if (data_in_width < data_out_width) begin
	     if ((^(ram_push_full ^ ram_push_full) !== 1'b0) || (^(flush_n_int ^ flush_n_int) !== 1'b0) ||
		 ((^(push_req_n ^ push_req_n) !== 1'b0))) begin
		ram_write_en_n = 1'bx;
		buff_write_en_n = 1'bx;
		next_part_wd_int = 1'bx;
		next_buff_error = 1'bx;
		next_wd_buff_addr = -1;
		ubuffer = {data_in_width {1'bx}};
		for (i = 0; i <= (`DW_K - 2); i = i + 1) begin
		   next_buffer[i] = {data_in_width {1'bx}};
		end
	     end
	     else begin
		if (ram_push_full === 1'b1 && (
		    ((wd_buff_addr === `DW_K-1) && (push_req_n === 1'b0)) ||
		    ((wd_buff_addr > 0) && (flush_n_int === 1'b0))) )
		  next_buff_error = 1'b1;
		else
		  next_buff_error = 1'b0;
		
		if (((wd_buff_addr === `DW_K-1) && (push_req_n === 1'b0)) ||
		    ((wd_buff_addr > 0) && (flush_n_int === 1'b0)))
		  ram_write_en_n = (ram_push_full === 1'b1) ? 1'b1 : 1'b0;
		else 
		  ram_write_en_n = 1'b1;

		if ((ram_push_full === 1'b1) && 
		    (wd_buff_addr === `DW_K-1) && (push_req_n === 1'b0))
		  buff_write_en_n = 1'b1;
		else
		  buff_write_en_n = push_req_n;		
		
		if (ram_write_en_n === 1'b0 ) begin
		  if (push_req_n === 1'b0 && flush_n_int === 1'b0) begin
		     next_buffer[0] = data_in;
		     ubuffer = {data_in_width {1'b0}};
		     next_part_wd_int = 1'b1;
		     for (i = 1; i < (`DW_K - 1); i = i + 1) begin
			next_buffer[i] = {data_in_width {1'b0}};
		     end		     
		     next_wd_buff_addr = 1;
		  end
		  else begin
		     next_wd_buff_addr = 0;
		     next_part_wd_int = 1'b0;
		     ubuffer = {data_in_width {1'b0}};
		     if (flush_n_int === 1'b0) begin
			ubuffer = {data_in_width {1'b0}};
		       for (i = 1; i < (`DW_K - 1); i = i + 1) begin
			  next_buffer[i] = {data_in_width {1'b0}};
		       end
		     end 
		     else begin
			ubuffer = data_in;
			for (i = 0; i < (`DW_K - 1); i = i + 1) begin
			   next_buffer[i] = {data_in_width {1'b0}};
			end
		     end // else: !if(flush_n_int === 1'b0)
		  end // else: !if(push_req_n === 1'b0 && flush_n_int === 1'b0)
		end // if (ram_write_en_n = 1'b0)
		else begin
		   if (buff_write_en_n === 1'b0) begin
		      ubuffer = {data_in_width {1'b0}};
		      next_part_wd_int = 1'b1;
		      next_wd_buff_addr = wd_buff_addr+1;
                     for (i = 0; i < wd_buff_addr; i = i+1) begin
                        next_buffer[i] = buffer[i];
                     end
		     for (i = wd_buff_addr+1; i < `DW_K-1; i = i+1) begin
			next_buffer[i] = {data_in_width {1'b0}};
		     end			      
		      next_buffer[wd_buff_addr] = data_in;
		   end
		   else begin
		      ubuffer = {data_in_width {1'b0}};
		      next_wd_buff_addr = wd_buff_addr;
		      next_part_wd_int = part_wd_int;
		      for (i = 0; i <= (`DW_K - 1); i = i + 1) begin
			  next_buffer[i] = buffer[i];
		       end
		   end
		end // else: !if(ram_write_en_n = 1'b0)
	     end // else: !if((^(ram_push_full ^ ram_push_full) !== 1'b0) || (^(flush_n_int ^ flush_n_int) !== 1'b0) ||...     
	     end // if (data_in_width < data_out_width)
	  end // block: mk_next_buff_data

 
   always @ (wd_buff_addr or ubuffer or buffer[0] or ram_write_en_n)
     begin : write_data_proc
	integer i;
	reg [`DW_min_width-1 : 0] temp_buffer;
	reg [(data_in_width - 1 ): 0 ] data_in_temp;
	
	if (data_in_width < data_out_width) begin
           if ( ram_write_en_n === 1'b0 ) begin
	      data_in_temp = ubuffer;
           end
           else begin
	      data_in_temp = {data_in_width {1'b0}};
           end
           if ( byte_order == 0 ) begin
	      wr_data_int = {`DW_max_width{1'b0}};
	      for (i = 0; i < (`DW_K - 1); i = i + 1) begin
                 temp_buffer = buffer[i];
                 wr_data_int = wr_data_int |
			       ({{(`DW_max_width-`DW_min_width){1'b0}},
				 temp_buffer} <<
				(`DW_min_width * (`DW_K-1-i)));
	      end
	      for (i = 0; i <= (`DW_min_width-1); i = i + 1) begin
                 wr_data_int[i] = data_in_temp [i];
	      end
           end
           else begin
       	      wr_data_int = {`DW_max_width{1'b0}};
       	      for (i = 0 ; i < (`DW_K - 1); i = i + 1)  begin
                 temp_buffer = buffer[i];
                 wr_data_int = wr_data_int |
       			       ({{(`DW_max_width-`DW_min_width){1'b0}},
                                 temp_buffer} <<
       				(`DW_min_width * i));
       	      end
	      for (i = 0; i <= (`DW_min_width-1); i = i + 1) begin
                 wr_data_int[i+(`DW_min_width * (`DW_K-1))] =
						       data_in_temp[i];
	      end
           end
	end
     end
   
   always @ (wd_buff_addr or ram_push_full)
     begin : push_flag_proc
	
     if (data_in_width < data_out_width)
      begin
        if (wd_buff_addr === -1 || ram_push_full === 1'bX)
         begin
           push_full_int = 1'bX;
         end
        else if ( ram_push_full === 1'b1 && wd_buff_addr === (`DW_K-1) )
         begin
           push_full_int = 1'b1;
         end
        else
         begin
           push_full_int = 1'b0;
         end
      end
     end// block: push_flag_proc
   
   
   always @ (rd_buff_addr or pop_req_n or pop_empty_int)
     begin : mk_rd_buf_addr
	if (data_in_width > data_out_width) begin
	   if (pop_req_n === 1'b0 && pop_empty_int === 1'b0) begin
	      next_rd_buff_addr = (rd_buff_addr + 1) % `DW_K;
	   end
	   else begin
	      next_rd_buff_addr =  (pop_req_n === 1'b1 || 
				    pop_empty_int === 1'b1 ) ? 
				   rd_buff_addr : -1;
	   end
	end
     end // block: mk_rd_buf_addr
   
   
   always @ (rd_buff_addr or pop_req_n or pop_empty_int)
     begin : read_from_ram_proc 
	if (data_in_width > data_out_width)
	  begin    
             if (rd_buff_addr === -1)
               begin
		  ram_pop_n_int = 1'bX;
               end
             else if ( pop_req_n === 1'b0 &&
                       pop_empty_int === 1'b0 &&
                       rd_buff_addr === (`DW_K - 1) )
               begin
		  ram_pop_n_int = 1'b0;
               end
             else
               begin
		  ram_pop_n_int = 1'b1;
               end
	  end 
     end // block: read_from_ram_proc
   
   always @ (rd_buff_addr or rd_data)
     begin : data_out_proc
 
	if (data_in_width > data_out_width) begin
           if (rd_buff_addr > -1)  begin
	      if ( byte_order == 0 ) begin
		 begin : for_888
		    integer i;
		    for (i = 0; i < `DW_min_width; i = i + 1)   begin
		       data_out_int[i] = rd_data[`DW_max_width -
						 `DW_min_width + i -
						 (rd_buff_addr * `DW_min_width)];
		    end
		 end
	      end
	      else begin
		 begin : for_889
		    integer i;
		    for (i = 0; i < `DW_min_width; i = i + 1) begin
		       data_out_int[i] = rd_data[i+rd_buff_addr *
						 `DW_min_width];
		    end
		 end
	      end
           end // if (rd_buff_addr > -1)
	   else begin
	      data_out_int = {`DW_max_width -1{1'bx}};
	   end // else: !if(rd_buff_addr > -1)
	end
     end

   
   always @ (pop_req_n or pop_empty_int or pop_error_int or next_rd_buff_addr)
     begin : mk_pop_next_error
	if (data_in_width > data_out_width) begin
	   if ((err_mode < 1) && (pop_error_int !== 1'b0))
	     next_pop_error_int = pop_error_int;
	   else if (pop_req_n === 1'b0 && pop_empty_int === 1'b1 ) 
	     next_pop_error_int = 1'b1;
	   else
	     if (next_rd_buff_addr < 0)
	       next_pop_error_int = 1'bx;
	     else
	       next_pop_error_int = 1'b0;
	end // if (data_in_width > data_out_width)
     end // block: mk_pop_next_error
   

generate if (rst_mode == 0) begin : GEN_S_RM_EQ_0

  if (data_in_width < data_out_width) begin : GEN_D_IN_LT_D_OUT
    always @(posedge clk_push or negedge rst_n) begin : ar_push_registers_PROC
      integer i;
      if (rst_n === 1'b0) begin
        wd_buff_addr <= 0;
        part_wd_int <= 0;
        buff_error <= 1'b0;
        for (i = 0; i < (`DW_K - 1); i = i + 1) begin
          buffer[i] <= {data_in_width {1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        wd_buff_addr <= next_wd_buff_addr;
        part_wd_int <= next_part_wd_int;
        buff_error <= (err_mode === 0) ?
                      (next_buff_error | buff_error) : 
                      next_buff_error;
        for (i = 0; i < (`DW_K - 1); i = i + 1) begin
          buffer[i] <= next_buffer[i];
        end
      end else begin
        wd_buff_addr <= -1;
        buff_error <= 1'bx;
        part_wd_int <= 1'bx;
        for (i = 0; i < (`DW_K - 1); i = i + 1) begin
          buffer[i] <= {data_in_width {1'bx}};
        end
      end
    end // block: ar_push_registers_PROC
  end

  if (data_in_width > data_out_width) begin : GEN_D_IN_GT_D_OUT
    always @(posedge clk_pop or negedge rst_n) begin : ar_pop_registers_PROC
      if (rst_n === 1'b0) begin
        rd_buff_addr <= 0;
        pop_error_int <= 1'b0;
      end else if (rst_n === 1'b1) begin
        rd_buff_addr <= next_rd_buff_addr;
        pop_error_int <= next_pop_error_int;
      end else begin
        rd_buff_addr <= -1;
        pop_error_int <= 1'bx;
      end 
    end // block: ar_pop_registers_PROC
  end

end else begin : GEN_S_RM_NE_0

  if (data_in_width < data_out_width) begin : GEN_D_IN_LT_D_OUT
    always @(posedge clk_push) begin : sr_push_registers_PROC
      integer i;
      if (rst_n === 1'b0) begin
        wd_buff_addr <= 0;
        part_wd_int <= 0;
        buff_error <= 1'b0;
        for (i = 0; i < (`DW_K - 1); i = i + 1) begin
          buffer[i] <= {data_in_width {1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        wd_buff_addr <= next_wd_buff_addr;
        part_wd_int <= next_part_wd_int;
        buff_error <= (err_mode === 0) ?
                      (next_buff_error | buff_error) : 
                      next_buff_error;
        for (i = 0; i < (`DW_K - 1); i = i + 1)begin
          buffer[i] <= next_buffer[i];
        end
      end else begin
        wd_buff_addr <= -1;
        buff_error <= 1'bx;
        part_wd_int <= 1'bx;
        for (i = 0; i < (`DW_K - 1); i = i + 1) begin
          buffer[i] <= {data_in_width {1'bx}};
        end
      end
    end // block: sr_push_registers_PROC
  end

  if (data_in_width > data_out_width) begin : GEN_D_IN_GT_D_OUT
    always @(posedge clk_pop) begin : sr_pop_registers_PROC
      if (rst_n === 1'b0) begin
        rd_buff_addr <= 0;
        pop_error_int <= 1'b0;
      end else if (rst_n === 1'b1) begin
        rd_buff_addr <= next_rd_buff_addr;
        pop_error_int <= next_pop_error_int;
      end else begin
        rd_buff_addr <= -1;
        pop_error_int <= 1'bx;
      end 
    end // block: sr_pop_registers_PROC
  end

end endgenerate

   
 DW_fifoctl_s2_sf  #( depth, 
                      push_ae_lvl, 
                      push_af_lvl, 
                      pop_ae_lvl,
                      pop_af_lvl, 
                      err_mode, 
                      push_sync, 
                      pop_sync,
                      rst_mode )

 DW_fifoctl_s2_sf  ( .clk_push(clk_push), 
                     .clk_pop(clk_pop),
                     .rst_n(rst_n), 
                     .push_req_n(ram_push_n),
                     .pop_req_n(ram_pop_n), 
                     .we_n(we_n),
                     .push_empty(push_empty), 
                     .push_ae(push_ae),
                     .push_hf(push_hf), 
                     .push_af(push_af),
                     .push_full(ram_push_full),
                     .push_error(ram_push_error),
                     .pop_empty(pop_empty_int),
                     .pop_ae(pop_ae),
                     .pop_hf(pop_hf), 
                     .pop_af(pop_af), 
                     .pop_full(ram_pop_full),
                     .pop_error(ram_pop_error), 
                     .wr_addr(wr_addr), 
                     .rd_addr(rd_addr),
		     .push_word_count(unused_push_count),
		     .pop_word_count(unused_pop_count),
		     .test(1'b0));

 // synopsys translate_on

 `undef DW_addr_width
 `undef DW_count_width
 `undef DW_K
 `undef DW_max_width
 `undef DW_min_width
endmodule
