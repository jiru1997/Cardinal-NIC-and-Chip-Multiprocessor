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
// AUTHOR:    Rick Kelly              Nov. 7, 2006
//
// VERSION:   Verilog simulation model
//
// DesignWare_version: 0bab50b5
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT:  D-type flip-flop based dual port RAM with
//            separate write and read clocks and independently
//            configurable pre and post array retiming registers.
//
//            Parameters:     Valid Values
//            ==========      ============
//             width          [ 1 to 1024 ]
//             depth          [ 2 to 1024 ]
//             addr_width     ceil(log2(depth)) [ 1 to 10 ]
//             mem_mode       [ 0 to 7 ]
//             rst_mode       [ 0 => resets clear RAM array
//				1 => reset do not clear RAM ]
//
//            Write Port Interface
//            ====================
//            Ports           Size      Description
//            =====           ====      ===========
//            clk_w            1        Write Port clock
//            rst_w_n          1        Active Low Asynchronous Reset (write clock domain)
//            init_w_n         1        Active Low Synchronous  Reset (write clock domain)
//            en_w_n           1        Active Low Write Enable input
//            addr_w       addr_width   write address input
//            data_w         width      write data input
//
//            Read Port Interface
//            ====================
//            Ports           Size      Description
//            =====           ====      ===========
//            clk_r            1        Read Port clock
//            rst_r_n          1        Active Low Asynchronous Reset (read clock domain)
//            init_r_n         1        Active Low Synchronous  Reset (read clock domain)
//            en_r_n           1        Active Low Read Enable input
//            addr_r       addr_width   read address input
//            data_r_a         1        read data arrival output
//            data_r         width      read data output
//
//
// MODIFIED:
//
//
////////////////////////////////////////////////////////////////////////////////


module DW_ram_r_w_2c_dff(
	clk_w,		// Write clock input
	rst_w_n,	// write domain active low asynch. reset
	init_w_n,	// write domain active low synch. reset
	en_w_n,		// acive low write enable
	addr_w,		// Write address input
	data_w,		// Write data input

	clk_r,		// Read clock input
	rst_r_n,	// read domain active low asynch. reset
	init_r_n,	// read domain active low synch. reset
	en_r_n,		// acive low read enable
	addr_r,		// Read address input
	data_r_a,	// Read data arrival status output
	data_r		// Read data output
);

parameter width = 8;	// RANGE 1 to 1024
parameter depth = 4;	// RANGE 2 to 1024
parameter addr_width = 2; // RANGE 1 to 10
parameter mem_mode = 1; // RANGE 0 to 7
parameter rst_mode = 0;	// RANGE 0 to 1

 input				clk_w;
 input				rst_w_n;
 input				init_w_n;
 input				en_w_n;
 input [addr_width-1 : 0]	addr_w;
 input [width-1 : 0]		data_w;

 input				clk_r;
 input				rst_r_n;
 input				init_r_n;
 input				en_r_n;
 input [addr_width-1 : 0]	addr_r;
output				data_r_a;
output [width-1 : 0]		data_r;


// synopsys translate_off


 reg [width-1 : 0]	ram_array [0 : depth-1];

 reg			en_w_q;
 reg [addr_width-1 : 0]	addr_w_q;
 reg [width-1 : 0]	data_w_q;

 reg			en_r_q;
 reg [addr_width-1 : 0]	addr_r_q;

wire			ram_en_w;
wire [addr_width-1 : 0]	ram_addr_w;
wire [width-1 : 0]	ram_data_w;
wire			ram_en_r;
wire [addr_width-1 : 0]	ram_addr_r;
wire [width-1 : 0]	ram_data_r;

 reg			en_r_qq;
 reg [width-1 : 0]	data_r_q;

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (width < 1) || (width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 1024)",
	width );
    end
  
    if ( (depth < 2) || (depth > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 1024 )",
	depth );
    end
  
    if ( (1<<addr_width) < depth ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : parameter, addr_width, value too small for depth of memory" );
    end
  
    if ( (1<<(addr_width-1)) >= depth ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : parameter, addr_width, value too large for depth of memory" );
    end
  
    if ( (mem_mode < 0) || (mem_mode > 7 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter mem_mode (legal range: 0 to 7 )",
	mem_mode );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1 )",
	rst_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  
  always @ (posedge clk_w or negedge rst_w_n) begin : clk_w_registers_PROC
    integer i;

    if (rst_w_n === 1'b0) begin			// Asynch. reset
      if (rst_mode == 0) begin
	for (i=0 ; i < depth ; i=i+1)
	  ram_array[i] <= {width{1'b0}};
      end
      en_w_q   <= 1'b0;
      addr_w_q <= {addr_width{1'b0}};
      data_w_q <= {width{1'b0}};
    end else if (rst_w_n === 1'b1) begin
      if (init_w_n === 1'b0) begin		// Synch. reset
	if (rst_mode == 0) begin
	  for (i=0 ; i < depth ; i=i+1)
	    ram_array[i] <= {width{1'b0}};
	end
	en_w_q   <= 1'b0;
	addr_w_q <= {addr_width{1'b0}};
	data_w_q <= {width{1'b0}};
      end else if (init_w_n === 1'b1) begin	// Clock registers
	en_w_q   <= ~en_w_n;
	if (en_w_n === 1'b0) begin
	  addr_w_q <= (addr_w | (addr_w ^ addr_w));
	  data_w_q <= (data_w | (data_w ^ data_w));
	end else if (en_w_n !== 1'b1) begin
	  addr_w_q <= {addr_width{1'bx}};
	  data_w_q <= {width{1'bx}};
	end
        if (ram_en_w === 1'b1) begin
	  if ((^(ram_addr_w ^ ram_addr_w) !== 1'b0)) begin
	    for (i=0 ; i < depth ; i=i+1)
	      ram_array[i] <= {width{1'bx}};
	  end else if (ram_addr_w < depth) begin
	    ram_array[ram_addr_w] <= ram_data_w;
	  end
	end else if (ram_en_w !== 1'b0) begin	// ram_en_w = unknown
	  if ((^(ram_addr_w ^ ram_addr_w) !== 1'b0)) begin
	    for (i=0 ; i < depth ; i=i+1)
	      ram_array[i] <= {width{1'bx}};
	  end else if (ram_addr_w < depth) begin
	    ram_array[ram_addr_w] <= {width{1'bx}};
	  end
	end
      end else begin				// init_w_n = unknown
	if (rst_mode == 0) begin
	  for (i=0 ; i < depth ; i=i+1)
	    ram_array[i] <= {width{1'bx}};
	end
	en_w_q   <= 1'bx;
	addr_w_q <= {addr_width{1'bx}};
	data_w_q <= {width{1'bx}};
      end
    end else begin				// rst_w_n = unknown
      if (rst_mode == 0) begin
	for (i=0 ; i < depth ; i=i+1)
	  ram_array[i] <= {width{1'bx}};
      end
      en_w_q   <= 1'bx;
      addr_w_q <= {addr_width{1'bx}};
      data_w_q <= {width{1'bx}};
    end
  end

  assign ram_en_w   = ((mem_mode > 3) == 1)?   en_w_q : ~en_w_n;
  assign ram_addr_w = ((mem_mode > 3) == 1)? addr_w_q : addr_w;
  assign ram_data_w = ((mem_mode > 3) == 1)? data_w_q : data_w;

  assign ram_en_r   = ((mem_mode % 4) > 1)?   en_r_q : ~en_r_n;
  assign ram_addr_r = ((mem_mode % 4) > 1)? addr_r_q : addr_r;

  assign ram_data_r = ((^(ram_addr_r ^ ram_addr_r) !== 1'b0))? {width{1'bx}} :
			(ram_addr_r < depth)? ram_array[ram_addr_r] :
			  {width{1'bx}};

  
  always @ (posedge clk_r or negedge rst_r_n) begin : clk_r_registers_PROC
    integer i;

    if (rst_r_n === 1'b0) begin			// Asynch. reset
      en_r_q   <= 1'b0;
      addr_r_q <= {addr_width{1'b0}};
      en_r_qq  <= 1'b0;
      data_r_q <= {width{1'b0}};
    end else if (rst_r_n === 1'b1) begin
      if (init_r_n === 1'b0) begin		// Synch. reset
	en_r_q   <= 1'b0;
	addr_r_q <= {addr_width{1'b0}};
	en_r_qq  <= 1'b0;
	data_r_q <= {width{1'b0}};
      end else if (init_r_n === 1'b1) begin	// Clock registers
	en_r_q   <= ~en_r_n;
	if (en_r_n === 1'b0) begin
	  addr_r_q <= (addr_r | (addr_r ^ addr_r));
	end else if (en_r_n !== 1'b1) begin
	  addr_r_q <= {addr_width{1'bx}};
	end
	en_r_qq <= ram_en_r;
	if (ram_en_r === 1'b1) begin
	  data_r_q <= ram_data_r;
	end else if (ram_en_r !== 1'b0) begin
	  data_r_q <= {width{1'bx}};
	end
      end else begin				// init_r_n = unknown
	en_r_q   <= 1'bx;
	addr_r_q <= {addr_width{1'bx}};
	en_r_qq  <= 1'bx;
	data_r_q <= {width{1'bx}};
      end
    end else begin				// rst_r_n = unknown
      en_r_q   <= 1'bx;
      addr_r_q <= {addr_width{1'bx}};
      en_r_qq  <= 1'bx;
      data_r_q <= {width{1'bx}};
    end
  end

  assign data_r_a   = ((mem_mode & 1) == 1)? en_r_qq  : ram_en_r;
  assign data_r     = ((mem_mode & 1) == 1)? data_r_q : ram_data_r;

// synopsys translate_on
endmodule
