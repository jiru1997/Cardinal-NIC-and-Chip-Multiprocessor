////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1997 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rajeev Huralikoppi       11/10/97
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 45bef382
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Synchronous, dual clcok  with Static Flags
//           static programmable almost empty and almost full flags
//
//           This FIFO controller designed to interface to synchronous
//           true dual port RAMs.
//
//		Parameters:	Valid Values
//		==========	============
//		depth		[ 4 to 16777216 ]
//		push_ae_lvl	[ 1 to depth-1 ]
//		push_af_lvl	[ 1 to depth-1 ]
//		pop_ae_lvl	[ 1 to depth-1 ]
//		pop_af_lvl	[ 1 to depth-1 ]
//		err_mode	[ 0 = sticky error flag,
//				  1 = dynamic error flag ]
//		push_sync	[ 1 = single synchronized,
//				  2 = double synchronized,
//				  3 = triple synchronized ]
//		pop_sync	[ 1 = single synchronized,
//				  2 = double synchronized,
//				  3 = triple synchronized ]
//		rst_mode	[ 0 = Asynchronous reset
//				  1 = Synchronous reset ]
//		tst_mode	[ 0 = test input not connected
//				  1 = lock-up latches inserted for scan test ]
//		
//		Input Ports:	Size	Description
//		===========	====	===========
//		clk_push	1 bit	Push I/F Input Clock
//		clk_pop		1 bit	Pop I/F Input Clock
//		rst_n		1 bit	Active Low Reset
//		push_req_n	1 bit	Active Low Push Request
//		pop_req_n	1 bit	Active Low Pop Request
//
//		Output Ports	Size	Description
//		============	====	===========
//		we_n		1 bit	Active low Write Enable (to RAM)
//		push_empty	1 bit	Push I/F Empty Flag
//		push_ae		1 bit	Push I/F Almost Empty Flag
//		push_hf		1 bit	Push I/F Half Full Flag
//		push_af		1 bit	Push I/F Almost Full Flag
//		push_full	1 bit	Push I/F Full Flag
//		push_error	1 bit	Push I/F Error Flag
//		pop_empty	1 bit	Pop I/F Empty Flag
//		pop_ae		1 bit	Pop I/F Almost Empty Flag
//		pop_hf		1 bit	Pop I/F Half Full Flag
//		pop_af		1 bit	Pop I/F Almost Full Flag
//		pop_full	1 bit	Pop I/F Full Flag
//		pop_error	1 bit	Pop I/F Error Flag
//		wr_addr		N bits	Write Address (to RAM)
//		rd_addr		N bits	Read Address (to RAM)
//		push_word_count M bits  Words in FIFO (push IF perception)
//		pop_word_count  M bits  Words in FIFO (push IF perception)
//              test            1 bit   Test Input (controls lock-up latches)
//
//		  Note:	the value of N for wr_addr and rd_addr is
//			determined from the parameter, depth.  The
//			value of N is equal to:
//				ceil( log2( depth ) )
//		
//		  Note:	the value of M for push_word_count and pop_word_count
//			is determined from the parameter, depth.  The
//			value of M is equal to:
//				ceil( log2( depth+1 ) )
//
//
//
// MODIFIED:  11/11/1999 RPH      Rewrote for STAR 92843 fix
//
//             11/29/01     RJK   Fixed size mismatch related to
//                                STAR 129582 (but fixed with 131712)
//
//             12/3/2002    RJK   Added word count outputs
//
//             4/17/2006    DLL   Fixed  typos...was
//                                '_single_rs_n_'.
//
//             3/1/2016     RJK   Updated for compatibility with VCS NLP
//
//-----------------------------------------------------------------------------

module DW_fifoctl_s2_sf(clk_push, clk_pop,
			rst_n,
			push_req_n, pop_req_n, we_n,
                        push_empty, push_ae, push_hf, push_af, push_full, push_error,
			pop_empty, pop_ae, pop_hf, pop_af, pop_full, pop_error,
			wr_addr, rd_addr, push_word_count, pop_word_count, test);

parameter depth = 8;
parameter push_ae_lvl = 2;
parameter push_af_lvl = 2;
parameter pop_ae_lvl = 2;
parameter pop_af_lvl = 2;
parameter err_mode = 0;
parameter push_sync = 2;
parameter pop_sync = 2;
parameter rst_mode = 0;
parameter tst_mode = 0;
   
   
   

   input                       clk_push, clk_pop;
   input                       rst_n;
   input                       push_req_n, pop_req_n;
   output 		       we_n, push_empty, push_ae, push_hf, 
			       push_af, push_full;
   output 		       push_error, pop_empty, pop_ae, pop_hf, pop_af, 
			       pop_full, pop_error;
   output [((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))))-1 : 0]  wr_addr, rd_addr;
   output [((depth<16777216)?((depth+1>65536)?((depth+1>1048576)?((depth+1>4194304)?((depth+1>8388608)?24:23):((depth+1>2097152)?22:21)):((depth+1>262144)?((depth+1>524288)?20:19):((depth+1>131072)?18:17))):((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))):25)-1 : 0] push_word_count, pop_word_count;
   input                       test;

// synopsys translate_off

   reg 			       pop_ae, pop_hf, pop_af, pop_full;
   reg [((depth<16777216)?((depth+1>65536)?((depth+1>1048576)?((depth+1>4194304)?((depth+1>8388608)?24:23):((depth+1>2097152)?22:21)):((depth+1>262144)?((depth+1>524288)?20:19):((depth+1>131072)?18:17))):((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))):25)-1 : 0]    push_word_count, pop_word_count;
   reg 			       pop_empty_int, push_full_int, push_error_int, 
			       pop_error_int;	 
   reg 			       next_push_error_int, next_pop_error_int;
   
   reg 			       push_af, push_hf, push_ae, push_empty;

   integer 		       wd_count, next_wd_count;
   integer 		       rd_count, next_rd_count;
   integer 		       wr_addr_int, next_wr_addr_int;
   integer 		       rd_addr_int, next_rd_addr_int;
   integer                     wr_addr_ltch, rd_addr_ltch;
   integer                     wr_addr_smpl, rd_addr_smpl;
   integer 		       wcmp_addr, rcmp_addr;

   
   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
	    
  
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
  
    if ( (tst_mode < 0) || (tst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tst_mode (legal range: 0 to 1 )",
	tst_mode );
    end
  
    if ( (depth < 4) || (depth > 16777216 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 4 to 16777216 )",
	depth );
    end

   wd_count = -1;
   rd_count = -1;   
   wr_addr_int = -1;
   rd_addr_int = -1;
   wr_addr_ltch = -1;
   rd_addr_ltch = -1;
   
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

   

    always @ (push_req_n or wd_count or wr_addr_int)
	begin : mk_next_wr_addr_int
	   if (push_req_n === 1'b0)
	    next_wr_addr_int = (wd_count == depth)? wr_addr_int : 
				(wd_count < 0)? -1 : (wr_addr_int + 1) %  (((1 << ((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))))) == depth) ? (depth * 2) : (depth+2-(depth % 2))) ;
	
	   else
	     next_wr_addr_int = ((push_req_n !== 1'b1) && (wd_count != depth))? -1 :
					(wd_count < 0)? -1 : wr_addr_int;
	end // mk_next_wr_addr_int

   always @ (next_wr_addr_int or wcmp_addr or wd_count )
     begin : mk_next_wd_count
	if ( wd_count < 0 )
	  next_wd_count = wd_count;
	else
	  if (next_wr_addr_int < 0 || wcmp_addr < 0) begin
	    next_wd_count = -1;
	  end 
	  else if ((next_wr_addr_int < wcmp_addr) )
	    next_wd_count = (((1 << ((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))))) == depth) ? (depth * 2) : (depth+2-(depth % 2))) - (wcmp_addr - next_wr_addr_int );
	  else
	    next_wd_count = (next_wr_addr_int - wcmp_addr);
     end // mk_next_wd_count
   
    always @ (push_req_n or wr_addr_int or wd_count or push_error_int)
	begin : mk_push_next_error

	if ((err_mode < 1) && (push_error_int !== 1'b0))
	    next_push_error_int = push_error_int;
	
	else
	  if ((push_req_n === 1'b0) && (wd_count == depth))
		
	    next_push_error_int = 1'b1;
		
	  else
	    if ((wd_count >= 0) && (wr_addr_int >= 0)) 
	      next_push_error_int = 1'b0;
		    
	    else
	      next_push_error_int = 1'bx;
		    
    end // mk_push_next_error


generate
  if (rst_mode == 0) begin : GEN_S_RM_EQ_0
    always @ (posedge clk_push or negedge rst_n)
	begin : ar_push_registers_PROC
	   integer sync_raddr1, sync_raddr2;
	if (rst_n === 1'b0) begin
	   wr_addr_int <= 0;
	   wd_count <= 0;
	   push_error_int <= 1'b0;
	   wcmp_addr <= 0;
	   sync_raddr1 <= 0;
	   sync_raddr2 <= 0;
	end

	else
	    if (rst_n === 1'b1) begin
	       wr_addr_int <= next_wr_addr_int;
	       wd_count <= next_wd_count;
	       push_error_int <= next_push_error_int;
	       if (push_sync == 1)
		 wcmp_addr <= rd_addr_smpl;
	       else
		 begin
	            sync_raddr1 <= rd_addr_smpl;

		    if (push_sync == 2)
		      wcmp_addr <= sync_raddr1;
		    
		    else
		      begin
			sync_raddr2 <= sync_raddr1;
		        wcmp_addr <= sync_raddr2;
		      end
		 end
	    end

	    else begin
	       wr_addr_int <= -1;
	       wd_count <= -1;
	       push_error_int <= 1'bx;
	       wcmp_addr <= -1;
	       
	    end
	end // block: ar_push_registers_PROC
  end else begin : GEN_S_RM_NE_0
    always @ (posedge clk_push)
	begin : sr_push_registers_PROC
	   integer sync_raddr1, sync_raddr2;
	if (rst_n === 1'b0) begin
	   wr_addr_int <= 0;
	   wd_count <= 0;
	   push_error_int <= 1'b0;
	   wcmp_addr <= 0;
	   sync_raddr1 <= 0;
	   sync_raddr2 <= 0;
	   
	end

	else
	    if (rst_n === 1'b1) begin
	       wr_addr_int <= next_wr_addr_int;
	       wd_count <= next_wd_count;
	       push_error_int <= next_push_error_int;
	       if (push_sync == 1)
		 wcmp_addr <= rd_addr_smpl;
	       else
		 begin
	            sync_raddr1 <= rd_addr_smpl;

		    if (push_sync == 2)
		      wcmp_addr <= sync_raddr1;
		    
		    else
		      begin
			sync_raddr2 <= sync_raddr1;
		        wcmp_addr <= sync_raddr2;
		      end
		 end
	    end

	    else begin
	       wr_addr_int <= -1;
	       wd_count <= -1;
	       push_error_int <= 1'bx;
	       wcmp_addr <= -1;
	       
	    end
	end // block: sr_push_registers_PROC
  end
endgenerate
   
   
   always @ (wd_count) begin : mk_push_flags
	if ( wd_count < 0 ) begin
	  push_empty = 1'bx;
	  push_ae = 1'bx;
	  push_hf = 1'bx;
	  push_af = 1'bx;
	  push_full_int = 1'bx;
	  push_word_count = {((depth<16777216)?((depth+1>65536)?((depth+1>1048576)?((depth+1>4194304)?((depth+1>8388608)?24:23):((depth+1>2097152)?22:21)):((depth+1>262144)?((depth+1>524288)?20:19):((depth+1>131072)?18:17))):((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))):25){1'bx}};
	end else begin
	  push_empty = (wd_count == 0)?                    1'b1 : 1'b0;
	  push_ae    = (wd_count <= push_ae_lvl)?          1'b1 : 1'b0;
	  push_hf    = (wd_count < (depth+1)/2)?           1'b0 : 1'b1;
	  push_af    = (wd_count < (depth-push_af_lvl))?   1'b0 : 1'b1;
	  push_full_int  = (wd_count != depth)?                1'b0 : 1'b1;
	  push_word_count = wd_count[((depth<16777216)?((depth+1>65536)?((depth+1>1048576)?((depth+1>4194304)?((depth+1>8388608)?24:23):((depth+1>2097152)?22:21)):((depth+1>262144)?((depth+1>524288)?20:19):((depth+1>131072)?18:17))):((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))):25):0];
	end // else: !if( wd_count < 0 )
			  
     end // block: mk_push_flags


    always @ (clk_push or wr_addr_int) begin : mk_wr_addr_ltch
      if (clk_push == 1'b0)
	wr_addr_ltch = wr_addr_int;
    end // mk_wr_addr_ltch

    always @ (test or wr_addr_ltch or wr_addr_int) begin : mk_wr_addr_smpl
      if (tst_mode == 0) begin
	wr_addr_smpl = wr_addr_int;
      end else if (test === 1'b0) begin
	wr_addr_smpl = wr_addr_int;
      end else if (test === 1'b1) begin
	wr_addr_smpl = wr_addr_ltch;
      end else begin
	wr_addr_smpl = -1;
      end
    end // mk_wr_addr_smpl


    always @ (clk_pop or rd_addr_int) begin : mk_rd_addr_ltch
      if (clk_pop == 1'b0)
	rd_addr_ltch = rd_addr_int;
    end // mk_rd_addr_ltch

    always @ (test or rd_addr_ltch or rd_addr_int) begin : mk_rd_addr_smpl
      if (tst_mode == 0) begin
	rd_addr_smpl = rd_addr_int;
      end else if (test === 1'b0) begin
	rd_addr_smpl = rd_addr_int;
      end else if (test === 1'b1) begin
	rd_addr_smpl = rd_addr_ltch;
      end else begin
	rd_addr_smpl = -1;
      end
    end // mk_rd_addr_smpl


    always @ (pop_req_n or rd_count or rd_addr_int)
      begin : mk_next_rd_addr_int
	 if (pop_req_n === 1'b0)
		next_rd_addr_int = (rd_count > 0)? (rd_addr_int + 1) % (((1 << ((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))))) == depth) ? (depth * 2) : (depth+2-(depth % 2))) :
					(rd_count == 0)? rd_addr_int : -1;
	    
	 else
	   next_rd_addr_int = ((pop_req_n !== 1'b1) && (rd_count!=0))? -1 :
				(rd_count < 0)? -1 : rd_addr_int;
      end // mk_next_rd_addr_int

   always @ (next_rd_addr_int or rcmp_addr or rd_count)
     begin : mk_next_rd_count
	if ( rd_count < 0 )
	  next_rd_count = rd_count;
	else
	  if (next_rd_addr_int < 0 || rcmp_addr < 0) begin
	    next_rd_count = -1;
	  end 
	  else if (next_rd_addr_int > rcmp_addr) 
	    next_rd_count = (((1 << ((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))))) == depth) ? (depth * 2) : (depth+2-(depth % 2))) - (next_rd_addr_int - rcmp_addr);
	  else
	    next_rd_count = rcmp_addr - next_rd_addr_int ;

     end // mk_next_rd_count   

    always @ (pop_req_n or rd_count or rd_addr_int or pop_error_int)
	begin : mk_pop_next_error

	if ((err_mode < 1) && (pop_error_int !== 1'b0))
	    next_pop_error_int = pop_error_int;
	
	else
	  if ((pop_req_n === 1'b0) && (rd_count == 0))
		
	    next_pop_error_int = 1'b1;
		
	  else
	    if ( (rd_addr_int >= 0) && (rd_count >= 0) )
	      next_pop_error_int = 1'b0;
		    
	    else
	      next_pop_error_int = 1'bx;
		    
    end // mk_pop_next_error


generate
  if (rst_mode == 0) begin : GEN_D_RM_EQ_0
    always @ (posedge clk_pop or negedge rst_n)
	begin : ar_pop_registers_PROC
	   integer sync_waddr1, sync_waddr2;
	   
	if (rst_n === 1'b0) begin
	    rd_addr_int <= 0;
	    rd_count <= 0;
	    pop_error_int <= 1'b0;
	    rcmp_addr <= 0;
	    sync_waddr1 <= 0;
	    sync_waddr2 <= 0;
	end

	else
	    if (rst_n === 1'b1) begin
		rd_addr_int <= next_rd_addr_int;
		rd_count <= next_rd_count;
		pop_error_int <= next_pop_error_int;
	       if (pop_sync == 1)
		 rcmp_addr <= wr_addr_smpl;
	       else
		 begin
	            sync_waddr1 <= wr_addr_smpl;

		    if (pop_sync == 2)
		      rcmp_addr <= sync_waddr1;
		    
		    else
		      begin
			sync_waddr2 <= sync_waddr1;
			rcmp_addr <= sync_waddr2;
		      end
		 end	       
	    end

	    else begin
		rd_addr_int <= -1;
		rd_count <= -1;
		pop_error_int <= 1'bx;
	       rcmp_addr <= -1;
	    end
	end // block: ar_pop_registers_PROC
  end else begin : GEN_D_RM_NE_0
    always @ (posedge clk_pop)
	begin : sr_pop_registers_PROC
	   integer sync_waddr1, sync_waddr2;
	   
	if (rst_n === 1'b0) begin
	    rd_addr_int <= 0;
	    rd_count <= 0;
	    pop_error_int <= 1'b0;
	    rcmp_addr <= 0;
	    sync_waddr1 <= 0;
	    sync_waddr2 <= 0;
	end

	else
	    if (rst_n === 1'b1) begin
		rd_addr_int <= next_rd_addr_int;
		rd_count <= next_rd_count;
		pop_error_int <= next_pop_error_int;
	       if (pop_sync == 1)
		 rcmp_addr <= wr_addr_smpl;
	       else
		 begin
	            sync_waddr1 <= wr_addr_smpl;

		    if (pop_sync == 2)
		      rcmp_addr <= sync_waddr1;
		    
		    else
		      begin
			sync_waddr2 <= sync_waddr1;
			rcmp_addr <= sync_waddr2;
		      end
		 end	       
	    end

	    else begin
		rd_addr_int <= -1;
		rd_count <= -1;
		pop_error_int <= 1'bx;
	       rcmp_addr <= -1;
	    end
	end // block: sr_pop_registers_PROC
  end
endgenerate


   always @ (rd_count) begin : mk_pop_flags
	if ( rd_count < 0 ) begin
	  pop_empty_int = 1'bx;
	  pop_ae = 1'bx;
	  pop_hf = 1'bx;
	  pop_af = 1'bx;
	  pop_full = 1'bx;
	  pop_word_count = {((depth<16777216)?((depth+1>65536)?((depth+1>1048576)?((depth+1>4194304)?((depth+1>8388608)?24:23):((depth+1>2097152)?22:21)):((depth+1>262144)?((depth+1>524288)?20:19):((depth+1>131072)?18:17))):((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))):25){1'bx}};
	end else begin
	  pop_empty_int = (rd_count == 0)?                   1'b1 : 1'b0;
	  pop_ae    = (rd_count <= pop_ae_lvl)?          1'b1 : 1'b0;
	  pop_hf    = (rd_count < (depth+1)/2)?          1'b0 : 1'b1;
	  pop_af    = (rd_count < (depth-pop_af_lvl))?   1'b0 : 1'b1;
	  pop_full  = (rd_count != depth)?               1'b0 : 1'b1;
	  pop_word_count = rd_count[((depth<16777216)?((depth+1>65536)?((depth+1>1048576)?((depth+1>4194304)?((depth+1>8388608)?24:23):((depth+1>2097152)?22:21)):((depth+1>262144)?((depth+1>524288)?20:19):((depth+1>131072)?18:17))):((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))):25):0];
	end // else: !if( rd_count < 0 )
			  
     end // block: mk_pop_flags

   assign wr_addr = (wr_addr_int < 0)? {((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1))))){1'bx}} :
				wr_addr_int[((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))))-1:0];
   assign rd_addr = (rd_addr_int < 0)? {((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1))))){1'bx}} :
				rd_addr_int[((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))))-1:0];
   assign 		       push_full = push_full_int;
   assign 		       pop_empty = pop_empty_int;
   assign 		       push_error = push_error_int;
   assign 		       pop_error = pop_error_int;
   assign 		       we_n = push_full_int | push_req_n;
   

    
  always @ (clk_push) begin : clk_push_monitor 
    if ( (clk_push !== 1'b0) && (clk_push !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_push input.",
                $time, clk_push );
    end // clk_push_monitor 
    
  always @ (clk_pop) begin : clk_pop_monitor 
    if ( (clk_pop !== 1'b0) && (clk_pop !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_pop input.",
                $time, clk_pop );
    end // clk_pop_monitor 
   
// synopsys translate_on

endmodule
