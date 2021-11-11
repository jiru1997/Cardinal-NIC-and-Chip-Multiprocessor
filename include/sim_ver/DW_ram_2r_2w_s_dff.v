////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2014 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly    7/2/14
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 513eca14
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

// Description : Four port synchronous DFF-based RAM 
//
//	Pameter		value range	description
//	=======		===========	===========
//      width           1 to 8192       Data word width
//      addr_width      1 to 12         Address bus width
//	rst_mode	0 to 1		Reset mode (0 => async reset)
//
//	Port		size 	   dir  description
//      ====            ====            ===========
//      clk              1          I   Clock input (rising edge sensitive)
//      rst_n            1          I   Active low reset input (async)
//
//      en_w1_n          1          I   Active low write port 1 write enable
//      addr_w1       addr_width    I   Write address for write port 1
//      data_w1         width       I   Data to be written via write port 1
//
//      en_w2_n          1          I   Active low write port 2 write enable
//      addr_w2       addr_width    I   Write address for write port 2
//      data_w2         width       I   Data to be written via write port 2
//
//      en_r1_n          1          I   Active low read port 1 read enable
//      addr_r1      addr_width     I   Read address for read port 1
//      data_r1        width        O   Data read from port 1
//
//      en_r2_n          1          I   Active low read port 2 read enable
//      addr_r2      addr_width     I   Read address for read port 2
//      data_r2        width        O   Data read from port 2

module DW_ram_2r_2w_s_dff(

	clk,
	rst_n,

	en_w1_n,
	addr_w1,
	data_w1,

	en_w2_n,
	addr_w2,
	data_w2,

	en_r1_n,
	addr_r1,
	data_r1,

	en_r2_n,
	addr_r2,
	data_r2

	);


  parameter width = 8;		// RANGE 1 to 8192
  parameter addr_width = 3;	// RANGE 1 to 12
  parameter rst_mode = 0;	// RANGE 0 to 1

  localparam depth = 1 << addr_width;

input			clk;
input			rst_n;
input			en_w1_n;
input  [addr_width-1:0]	addr_w1;
input  [width-1:0]	data_w1;
input			en_w2_n;
input  [addr_width-1:0]	addr_w2;
input  [width-1:0]	data_w2;

input			en_r1_n;
input  [addr_width-1:0]	addr_r1;
output [width-1:0]	data_r1;
input			en_r2_n;
input  [addr_width-1:0]	addr_r2;
output [width-1:0]	data_r2;

// synopsys translate_off

reg  [depth*width-1:0]	mem_array;
reg  [depth*width-1:0]	mem_array_next;

reg  [width-1:0]	data_r1_int;
reg  [width-1:0]	data_r2_int;


  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
	    
  
    if ( (width < 1) || (width > 8192) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 8192)",
	width );
    end
  
    if ( (addr_width < 1) || (addr_width > 12 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter addr_width (legal range: 1 to 12 )",
	addr_width );
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



  always @ (mem_array, en_r1_n, addr_r1) begin : data_r1_PROC
    integer i;

    if (en_r1_n === 1'b1) begin
      data_r1_int = {width{1'b0}};
    end else begin
      if ((^(en_r1_n ^ en_r1_n) !== 1'b0) || (^(addr_r1 ^ addr_r1) !== 1'b0)) begin
        data_r1_int = {width{1'bx}};
      end else begin
        for (i=0 ; i < width ; i=i+1) begin
	  data_r1_int[i] = mem_array[(addr_r1*width)+i];
	end
      end
    end
  end

  always @ (mem_array, en_r2_n, addr_r2) begin : data_r2_PROC
    integer i;

    if (en_r2_n === 1'b1) begin
      data_r2_int = {width{1'b0}};
    end else begin
      if ((^(en_r2_n ^ en_r2_n) !== 1'b0) || (^(addr_r2 ^ addr_r2) !== 1'b0)) begin
        data_r2_int = {width{1'bx}};
      end else begin
        for (i=0 ; i < width ; i=i+1) begin
	  data_r2_int[i] = mem_array[(addr_r2*width)+i];
	end
      end
    end
  end

  always @ (mem_array, en_w1_n, addr_w1, data_w1, en_w2_n, addr_w2, data_w2)
						      begin : mem_array_next_PROC
    integer i, j;

    mem_array_next = mem_array;

    if (en_w2_n !== 1'b1) begin

      if ((^(addr_w2 ^ addr_w2) !== 1'b0)) begin
        mem_array_next = {depth*width{1'bx}};

      end else begin

	for (i=0 ; i < width ; i=i+1) begin
	  if (en_w2_n === 1'b0) begin
	    mem_array_next[(width*addr_w2)+i] = (data_w2[i] | (data_w2[i] ^ data_w2[i]));

	  end else begin
	    if (mem_array[(width*addr_w2)+1] !== (data_w2[i] | (data_w2[i] ^ data_w2[i]))) begin
	      mem_array_next[(width*addr_w2)+1] = 1'bx;
	    end
	  end
	end
      end
    end


    if (en_w1_n !== 1'b1) begin

      if ((^(addr_w1 ^ addr_w1) !== 1'b0)) begin
        mem_array_next = {depth*width{1'bx}};

      end else begin

	for (i=0 ; i < width ; i=i+1) begin
	  if (en_w1_n === 1'b0) begin
	    mem_array_next[(width*addr_w1)+i] = (data_w1[i] | (data_w1[i] ^ data_w1[i]));

	  end else begin
	    if (mem_array[(width*addr_w1)+1] !== (data_w1[i] | (data_w1[i] ^ data_w1[i]))) begin
	      mem_array_next[(width*addr_w1)+1] = 1'bx;
	    end
	  end
	end
      end
    end

  end

generate
  if (rst_mode == 0) begin : GEN_RM_EQ0
    always @ (posedge clk or negedge rst_n) begin : REGISTER_A_PROC
      if (rst_n == 1'b0) begin
	mem_array <= {depth*width{1'b0}};
      end else begin
	mem_array <= mem_array_next;
      end
    end
  end else begin : GEN_RM_NE0
    always @ (posedge clk) begin : REGISTER_S_PROC
      if (rst_n == 1'b0) begin
	mem_array <= {depth*width{1'b0}};
      end else begin
	mem_array <= mem_array_next;
      end
    end
  end
endgenerate

  assign data_r1 = data_r1_int;
  assign data_r2 = data_r2_int;

  
  always @ (clk) begin : clk_monitor_PROC 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor_PROC 

// synopsys translate_on
endmodule
