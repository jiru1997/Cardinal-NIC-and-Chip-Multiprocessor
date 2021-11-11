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
// AUTHOR:    Jay Zhu		July 2, 1998
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 594222e6
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Duplex Adder-Subtractor
//
// MODIFIED:
//
//--------------------------------------------------------------------

module DW_addsub_dx (a, b, ci1, ci2, addsub, tc, sat, avg, dplx,
			sum, co1, co2);

  parameter		width = 4;
  parameter		p1_width = 2;

  input[width-1:0]	a;
  input[width-1:0]	b;
  input			ci1;
  input			ci2;
  input			addsub;
  input			tc;
  input			sat;
  input			avg;
  input			dplx;

  output[width-1:0]	sum;
  output		co1;
  output		co2;

  reg[width-1:0]	sum;
  reg[width+1:0]	sum_int;
  reg			co1;
  reg			co2;

// synopsys translate_off


function[width+1:0] add;

  input			tc;
  input			ci;
  input[width-1:0]	a;
  input[width-1:0]	b;
  input[31:0]		in_width;

begin : block_add

  reg[width:0]		a_in;
  reg[width:0]		b_in;
  reg 			carry;
  reg			co;
  reg[width+1:0]	sum;

  integer		i;

	for (i=0; i< in_width; i=i+1)
	begin
	  a_in[i] = a[i];
	  b_in[i] = b[i];
	end
	a_in[in_width] = a_in[in_width-1] & tc;
	b_in[in_width] = b_in[in_width-1] & tc;
	carry = ci;

	begin : for_each_bit_154
	  integer i;
	  for (i = 0; i <= (in_width - 1); i = i + 1)
	  begin 
	    sum[i] = (a_in[i] ^ b_in[i]) ^ carry;
	    carry = (a_in[i] & b_in[i])
			| (a_in[i] & carry )
			| (carry & b_in[i]);
	  end
	end

	sum[in_width] = (a_in[in_width] ^ b_in[in_width]) ^ carry;
	sum[in_width+1] = carry;
	add = sum;
end
endfunction



function[width+1:0] sub;

  input			tc;
  input			ci;
  input[width-1:0]	a;
  input[width-1:0]	b;
  input[31:0]		in_width;

begin : block_add

  reg[width:0]		a_in;
  reg[width:0]		b_in;
  reg[width:0]		bv;
  reg 			carry;
  reg			co;
  reg[width+1:0]	sum;
  integer		i;

	for (i=0; i< in_width; i=i+1)
	begin
	  a_in[i] = a[i];
	  b_in[i] = b[i];
	end
	a_in[in_width] = a_in[in_width-1] & tc;
	b_in[in_width] = b_in[in_width-1] & tc;
	bv = ~b_in;

	carry = ~ci;

	begin : for_each_bit_154
	  integer i;
	  for (i = 0; i <= (in_width - 1); i = i + 1)
	  begin 
	    sum[i] = (a_in[i] ^ bv[i]) ^ carry;
	    carry = (a_in[i] & bv[i])
			| (a_in[i] & carry )
			| (carry & bv[i]);
	  end
	end

	sum[in_width] = (a_in[in_width] ^ bv[in_width]) ^ carry;
	sum[in_width+1] = ~carry;
	sub = sum;
end
endfunction



function[width+1:0] addsub_func;

  input			add_sub_ctl;
  input			tc;
  input			ci;
  input[width-1:0]	a;
  input[width-1:0]	b;
  input[31:0]		in_width;

begin : block_addsub_func

reg[width+1:0] 	sum;
integer		i;

	if (add_sub_ctl === 1'b0)
	begin 
	  sum = add(tc, ci, a, b, in_width);
	end
	else if (add_sub_ctl === 1'b1)
	begin 
	  sum = sub(tc, ci, a, b, in_width);
	end
	else
	begin
	  for(i=0; i<width+2; i=i+1)
	  begin
	    sum[i] = 1'bx;
	  end
	end 

	addsub_func = sum;

end
endfunction



function[width:0] saturation;

  input			sat;
  input			avg;
  input			addsub;
  input			tc;
  input			ci;
  input[width-1:0]	a;
  input[width-1:0]	b;
  input[31:0]		in_width;

begin : block_saturation

  reg[width+1:0]	sum;
  reg			carry;
  reg			sum_sign;
  reg			sum_ext_sign;
  reg[width-1:0]	sat_out;
  reg[width-1:0]	avg_out;
  reg[width:0]		final_out;
  reg[1:0]		overflow_type;
  integer		i;

	sum  = addsub_func(addsub, tc, ci, a, b, in_width);
	sum_sign = sum[in_width-1];
	sum_ext_sign = sum[in_width];
	carry = sum_ext_sign;

	for (i=0; i<in_width; i=i+1)
	begin
	  sat_out[i] = sum[i];
	end

	if (sat === 1'b1)
	begin 

	  if (tc === 1'b0)
	  begin 
	    carry = 1'b0;

	    if (sum_ext_sign === 1'b1)
	    begin 
  	      for (i=0; i<in_width; i=i+1)
	      begin
	        sat_out[i] = ~addsub;
	      end 
	    end 
	    else if (sum_ext_sign === 1'b0)
	    begin 
  	      for (i=0; i<in_width; i=i+1)
	      begin
	        sat_out[i] = sum[i];
	      end 
	    end 
	    else
	    begin 
  	      for (i=0; i<in_width; i=i+1)
	      begin
	        sat_out[i] = 1'bx;
	      end 
	    end
	  end

	  else if (tc === 1'b1)
	  begin 

	    overflow_type = {sum_ext_sign, sum_sign};

	    case (overflow_type)
	      2'b00,
	      2'b11:
	      begin
	      end

	      2'b01:
	      begin
	        for (i=0; i<in_width-1; i=i+1)
	        begin
		  sat_out[i] = 1'b1;
		end
		sat_out[in_width-1] = 1'b0;
	      end

	      2'b10:
	      begin
		for (i=0; i<in_width-1; i=i+1)
		begin
		  sat_out[i] = 1'b0;
		end
		sat_out[in_width-1] = 1'b1;
	      end

	      default:
	      begin
		for (i=0; i<in_width; i=i+1)
		begin
		  sat_out[i] = 1'bx;
		end
	      end

	    endcase

	  end

	  else
	  begin
	    for (i=0; i<in_width; i=i+1)
	    begin
	      sat_out[i] = 1'bx;
	    end 
	  end 

	end

	else if (sat === 1'bx)
	begin 
	  if (tc === 1'b0)
	  begin 
	    if (sum_ext_sign != sum_sign)
	    begin 
	      for (i=0; i<in_width; i=i+1)
	      begin
	        sat_out[i] = 1'bx;
	      end 
	      carry = 1'bx;
	    end 
	  end

	  else if (tc === 1'b1)
	  begin 

	    overflow_type = {sum_ext_sign, sum_sign};

	    case (overflow_type)
	      2'b00,
	      2'b11:
		begin
	        end

	      2'b01,
	      2'b10:
		begin
	          for (i=0; i<in_width; i=i+1)
	          begin
	            sat_out[i] = 1'bx;
	          end
		  carry = 1'bx;
	        end

	      default:
		begin
	          for (i=0; i<in_width; i=i+1)
	          begin
	            sat_out[i] = 1'bx;
	          end
		  carry = 1'bx;
	        end

	    endcase

	  end

	  else
	  begin
	    for (i=0; i<in_width; i=i+1)
	    begin
	      sat_out[i] = 1'bx;
	    end 
	    carry = 1'bx;
	  end 

	end

	if (avg === 1'b0)
	begin
	  avg_out = sat_out;
	end

	else if (avg === 1'b1)
	begin 

	  if (tc === 1'b0)
	  begin
	    carry = 1'b0;
	  end
	  else if (tc === 1'bx)
	  begin
	    if (carry != 1'b0)
	    begin
	      carry = 1'bx;
	    end
	  end

	  if (sat === 1'b0)
	  begin
	    for (i=0; i<in_width; i=i+1)
	    begin
	      avg_out[i] = sum[i+1];
	    end
	  end

	  else if (sat === 1'b1)
	  begin
	    for (i=0; i<in_width-1; i=i+1)
	    begin
	      avg_out[i] = sat_out[i+1];
	    end
	    avg_out[in_width-1] = sat_out[in_width-1] & tc;
	  end

	end

	else
	begin
	  for (i=0; i<in_width; i=i+1)
	  begin
	    avg_out[i] = 1'bx;
	  end 
	  carry = 1'bx;
	end 

	for (i=0; i<in_width; i=i+1)
	begin
	  final_out[i] = avg_out[i];
	end
	final_out[in_width] = carry;

	saturation = final_out;

	end

endfunction



function[width+1:0] addsub_dx;

  input[width-1:0]	a;
  input[width-1:0]	b;
  input			ci1;
  input			ci2;
  input			addsub;
  input			tc;
  input			sat;
  input			avg;
  input			dplx;

begin : block_addsub_dx

  reg			co1;
  reg			co2;
  reg[width-1:0]	sum;
  reg[width:0]		sum_int;
  reg[p1_width:0]	sum_int1;
  reg[width-p1_width:0]	sum_int2;
  integer		i;

	if(dplx === 1'b0)
	begin 
	  sum_int = saturation(sat, avg, addsub, tc, ci1, a, b, width);
	  sum = sum_int[width-1:0];
	  co1 = 1'b0;
	  co2 = sum_int[width];
	end

	else if(dplx === 1'b1)
	begin 

	  sum_int1 = saturation(sat, avg, addsub,
			tc, ci1, a[p1_width-1:0], b[p1_width-1:0],
			p1_width);
	  for (i=0; i<p1_width; i=i+1)
	  begin
	    sum[i] = sum_int1[i];
	  end
	  co1 = sum_int1[p1_width];

	  sum_int2 = saturation(sat, avg, addsub,
			tc, ci2, a[width-1:p1_width],
			b[width-1:p1_width],
			width-p1_width);
	  for (i=0; i< width-p1_width; i=i+1)
	  begin
	    sum[i+p1_width] = sum_int2[i];
	  end
	  co2 = sum_int2[width-p1_width];
	end

	else if(dplx === 1'bx)
	begin 
	  sum = 1'bx;
	  co1 = 1'bx;
	  co2 = 1'bx;
	end 

	addsub_dx = {co1, co2, sum};
	end

endfunction


always @(a or b or ci1 or ci2 or addsub or tc or sat or avg or dplx)
begin
	sum_int = addsub_dx(a, b, ci1, ci2, addsub,
			tc, sat, avg, dplx );

	sum = sum_int[width-1:0];

	co1 = sum_int[(width + 1 )];

	co2 = sum_int[width];
end

// synopsys translate_on

endmodule
