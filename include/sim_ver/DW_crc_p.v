////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2000 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Jay Zhu, March 25, 2000
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 0971add2
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT : Generic parallel CRC Generator/Checker 
//
// MODIFIED :
//
//      LMSU    07/09/2015      Changed for compatibility with VCS Native Low Power
//
//	RJK	04/12/2011 	Recoded parts to clean for lint - STAR 9000444285
//
//-------------------------------------------------------------------------------

module	DW_crc_p(
		data_in,
		crc_in,
		crc_ok,
		crc_out
		);

parameter    data_width = 16;
parameter    poly_size  = 16;
parameter    crc_cfg    = 7;
parameter    bit_order  = 3;
parameter    poly_coef0 = 4129;
parameter    poly_coef1 = 0;
parameter    poly_coef2 = 0;
parameter    poly_coef3 = 0;

input [data_width-1:0]	data_in;
input [poly_size-1:0]	crc_in;
output			crc_ok;
output [poly_size-1:0]	crc_out;


// synopsys translate_off

`define	DW_max_data_crc_l (data_width>poly_size?data_width:poly_size)


wire [poly_size-1:0]		crc_in_inv;
wire [poly_size-1:0]		crc_reg;
wire [poly_size-1:0]		crc_out_inv;
wire [poly_size-1:0]		crc_chk_crc_in;

`ifdef UPF_POWER_AWARE
  `protected
>b3><Eaf:7eVKF]6##NWe#g0N6R+E_IP)D:+._c)Q>LRdB]<E:_K-)=Z<.5@^\.>
4e3)27U@<LQCQE;DQYN;Gfc_g>2)8J>+N@87fRKH/9Q<>W<cJO]8>f8,@)Nd>O-U
_7F@A;)L#0+;B_JJF;S7LY8XJ>2M)+#>H2MQ(0:=_=@c2TX)6E;+fW/=QVC<6Nf3
:AVI=?1aac6ZN-UCaV/MT;Vf6[IfFc,>aeNN4V,??;]OEG^.BRE7?;13#BA(;=eb
Bb\94\2F:IZ>3+8,PHY=3V[ga<I^Q:70YGE:b>bV<K51(B^^2@&3J(L0T#DXL)QX
?:D-0dXRJ#)]#>#df?@<C4G8ZWN\1G:Kc^X/WY+Z(PPg<C78F@:_P/H\O-;_(41&
a;0K-#.HJ\^dVM\V<RIQ=\;\SHJ5D.ab8X5Y5RWGb_5:)\S&fgPLcAS0YFN85\,e
,gg;NT:E9-JNZWdMS)_SWVX^8BgD-6-SQ[OG#MLYUZ(SGgT8IL;38E=b\&_C+0Q-
/YV\a>\,IJ.>,CcXVOM2O[SHZ6UfV)>.480bf\4ZN(C9?_b6&6&HB[IW;V[d69GK
8K10ZNc&MP2CXK7:=OTcEDMH8LB#2QB#3MHE5YRY+04@NAJZUa@+2I#M>PLL2?&4
,8Y_38?M,I_^Q2?60L=1+WHSBOT:P@\;,K_eTJ(YgX5cFS_(aKB/C<@a49Ma,TBV
Z,Xc>f>-3Ff^L129#e[g4-4H^/L7_HHbV:MEN3=2]Xaa-.0d+2TXH.,AM=WA=K3.
PQ(aeASLE3@>cAM\[MHVKE6_J17K3GYdE9:W@8ZcL91RTEO4F_Ce#^^25)=53J@G
D,IdfJ/0d4aFP0TRV;fO,)G+34K8TEZNSRY0dX0KK+7SJX2GN&Y&f[G0>+01fOUQ
,a0dW;SO38=@(bgO@0W5=@bDC2\CE_J[/T8,SU@BD\(\,9]JOfgJ=.1F)O,;F0dZ
g=T]>)6Z0bW:8I(00P201/QEePA1cDa(2b0)LA21_?NI=&=EF#VV#,_\JRM#^77<
bCFGd&TU1b_QC18fKafL1Efg7U;-U252UJ&Q.C2A-c>&3>WGVe74F<S\J+Y/bNS6
;F;_7edLAEV&B9,6D7QG/b4Tg[9E.;\-7aEE@/Y^06Ub9.B((9UU8BZG#gKJ_Tg6
?2Q5MY#f(D.Y^OW-b=#Lf+F#R\@3fTB.YTCR?+TH)2f0P:Z1Y@e7-C7@e#O#+T8>
I>[\.+/JE,<R^[)DYe4\+Z(a,\BfggO]Eb]aK_=+S56=6(.+GbUY.V[UbKDEAcE(
CHD.ZHgb<R660,MB1Z7O?7KEcD&_V^+K?RfD6<T)I>,NMg.5Qg:4+FbB8.J&NKQJ
I7KQATNLO(P#T3<._FUA8_=1T0VcMc]>1+M@DL<_eV+FNQ1->8Z2@,a_bg^2[HbQ
S_)/;1K&#-:_9#(G+T_:M#\G:<W#ILO?)]f#HS:fI9X+KWP6.Mf_b2X?&T?TS5QO
aW#0GH7DMK[I7&0bbL?EXDNSUac&=H?0Z]5C/0FXZ;I7/05NbI89YG@3PKP](P9B
M3[c7+K7LS#/#+a[M8P+f[(PGda8#c;e6Ad-f&)Z]ZTXF6eKI][aeDC)bX3)_))@
Ne^d/G\R<2>5a7R[fP=L27b@-e@<H>P(SB=AfS]gIL2XE$
`endprotected

`else
reg [poly_size-1:0]             crc_inv_alt;
reg [poly_size-1:0]             crc_polynomial;
`endif

function [`DW_max_data_crc_l-1:0]	bit_ordering;
    input [`DW_max_data_crc_l-1:0]	input_data;
    input [31:0]		v_width;

    begin : function_bit_ordering

	integer			width;
	integer			byte_idx;
	integer			bit_idx;

	width = v_width;

	case (bit_order) 
	    0 :
	  	bit_ordering = input_data;
	    1 :
		for(bit_idx=0; bit_idx<width; bit_idx=bit_idx+1)
		  bit_ordering[bit_idx] = input_data[width-bit_idx-1];
	    2 :
	  	for(byte_idx=0; byte_idx<width/8; byte_idx=byte_idx+1)
		  for(bit_idx=0;
		      bit_idx<8;
		      bit_idx=bit_idx+1)
	            bit_ordering[bit_idx+byte_idx*8]
		      = input_data[bit_idx+(width/8-byte_idx-1)*8];
	    3 :
		for(byte_idx=0; byte_idx<width/8; byte_idx=byte_idx+1)
		  for(bit_idx=0; bit_idx<8; bit_idx=bit_idx+1)
		    bit_ordering[byte_idx*8+bit_idx]
		          = input_data[(byte_idx+1)*8-1-bit_idx];
	    default : 
		begin 
		    $display("ERROR: %m : Internal Error.  Please report to Synopsys representative."); 
		    $finish; 
		end
	endcase

    end
endfunction // bit_ordering

function [poly_size-1 : 0] bit_order_crc;

    input [poly_size-1 : 0] crc_in;

    begin : function_bit_order_crc

        reg [`DW_max_data_crc_l-1 : 0] input_value;
        reg [`DW_max_data_crc_l-1 : 0] return_value;
	integer i;

	input_value = {`DW_max_data_crc_l{1'b0}};

	for (i=0 ; i < poly_size ; i=i+1)
	  input_value[i] = crc_in[i];

	return_value = bit_ordering(input_value,poly_size);

	bit_order_crc = return_value[poly_size-1 : 0];
    end
endfunction // bit_order_crc


function [data_width-1 : 0] bit_order_data;

    input [data_width-1 : 0] data_in;

    begin : function_bit_order_data

        reg [`DW_max_data_crc_l-1 : 0] input_value;
        reg [`DW_max_data_crc_l-1 : 0] return_value;
	integer i;

	input_value = {`DW_max_data_crc_l{1'b0}};

	for (i=0 ; i < data_width ; i=i+1)
	  input_value[i] = data_in[i];

	return_value = bit_ordering(input_value,data_width);

	bit_order_data = return_value[data_width-1 : 0];
    end
endfunction // bit_order_data


function [poly_size-1:0]	calculate_crc_w_in;

    input [poly_size-1:0]		crc_in;
    input [`DW_max_data_crc_l-1:0]	input_data;
    input [31:0]			width0;

    begin : function_calculate_crc_w_in

	integer			width;
	reg			feedback_bit;
	reg [poly_size-1:0]	feedback_vector;
	integer			bit_idx;

	width = width0;
	calculate_crc_w_in = crc_in;
	for(bit_idx=width-1; bit_idx>=0; bit_idx=bit_idx-1) begin
	    feedback_bit = calculate_crc_w_in[poly_size-1]
				^ input_data[bit_idx];
	    feedback_vector = {poly_size{feedback_bit}};

	    calculate_crc_w_in = {calculate_crc_w_in[poly_size-2:0],1'b0}
	  		^ (crc_polynomial & feedback_vector);
	end

    end
endfunction // calculate_crc_w_in


function [poly_size-1:0]	calculate_crc;
    input [data_width-1:0]	input_data;

    begin : function_calculate_crc

	reg [`DW_max_data_crc_l-1:0]	input_value;
	reg [poly_size-1:0]		crc_tmp;
	integer i;

	input_value = {`DW_max_data_crc_l{1'b0}};

	for (i=0 ; i < data_width ; i=i+1)
	  input_value[i] = input_data[i];

	crc_tmp = {poly_size{(crc_cfg % 2)?1'b1:1'b0}};
	calculate_crc = calculate_crc_w_in(crc_tmp, input_value,
			data_width);
    end
endfunction // calculate_crc_crc


function [poly_size-1:0]	calculate_crc_crc;
    input [poly_size-1:0]	input_crc;
    input [poly_size-1:0]	input_data;

    begin : function_calculate_crc_crc

	reg [`DW_max_data_crc_l-1:0]	input_value;
	reg [poly_size-1:0]		crc_tmp;
	integer i;

	input_value = {`DW_max_data_crc_l{1'b0}};

	for (i=0 ; i < poly_size ; i=i+1)
	  input_value[i] = input_data[i];

	calculate_crc_crc = calculate_crc_w_in(input_crc, input_value,
			poly_size);
    end
endfunction // calculate_crc_crc


    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    

	
    if ( (data_width < 1) || (data_width > 512) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 1 to 512)",
	data_width );
    end
	
    if ( (poly_size < 2) || (poly_size > 64) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_size (legal range: 2 to 64)",
	poly_size );
    end
	
    if ( (crc_cfg < 0) || (crc_cfg > 7) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter crc_cfg (legal range: 0 to 7)",
	crc_cfg );
    end
	
    if ( (bit_order < 0) || (bit_order > 3) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter bit_order (legal range: 0 to 3)",
	bit_order );
    end
	
    if ( (poly_coef0 < 1) || (poly_coef0 > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef0 (legal range: 1 to 65535)",
	poly_coef0 );
    end
	
    if ( (poly_coef1 < 0) || (poly_coef1 > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef1 (legal range: 0 to 65535)",
	poly_coef1 );
    end
	
    if ( (poly_coef2 < 0) || (poly_coef2 > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef2 (legal range: 0 to 65535)",
	poly_coef2 );
    end
	
    if ( (poly_coef3 < 0) || (poly_coef3 > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef3 (legal range: 0 to 65535)",
	poly_coef3 );
    end

	if(poly_coef0 %2 == 0) begin
	    param_err_flg = 1;
	    $display(
	      "ERROR: %m : Invalid even poly_coef0 (poly_coef0=%d).",
	      poly_coef0);
	end

	if(bit_order > 1 && (data_width % 8 > 0)) begin
	    param_err_flg = 1;
	    $display(
	      "ERROR: %m : Invalid configuration (bit_order=%d, data_width=%d).",
	      bit_order, data_width);
	end

	if(bit_order > 1 && (poly_size % 8 > 0)) begin
	    param_err_flg = 1;
	    $display(
	      "ERROR: %m : Invalid configuration (bit_order=%d, poly_size=%d).",
	      bit_order, poly_size);
	end

    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



`ifndef UPF_POWER_AWARE
    initial begin : initialize_vars

	reg [63:0]	crc_polynomial64;
	reg [15:0]	coef0;
	reg [15:0]	coef1;
	reg [15:0]	coef2;
	reg [15:0]	coef3;
	integer		bit_idx;

	coef0 = poly_coef0;
	coef1 = poly_coef1;
	coef2 = poly_coef2;
	coef3 = poly_coef3;

	crc_polynomial64 = {coef3, coef2, coef1, coef0};
	crc_polynomial = crc_polynomial64[poly_size-1:0];

	case(crc_cfg/2)
	    0 : crc_inv_alt = {poly_size{1'b0}};
	    1 : for(bit_idx=0; bit_idx<poly_size; bit_idx=bit_idx+1)
		crc_inv_alt[bit_idx] = (bit_idx % 2)? 1'b0 : 1'b1;
	    2 : for(bit_idx=0; bit_idx<poly_size; bit_idx=bit_idx+1)
		crc_inv_alt[bit_idx] = (bit_idx % 2)? 1'b1 : 1'b0;
	    3 : crc_inv_alt = {poly_size{1'b1}};
	    default : 
		begin 
		    $display("ERROR: %m : Internal Error.  Please report to Synopsys representative."); 
		    $finish; 
		end
	endcase

    end // initialize_vars


`endif
    assign	crc_in_inv = bit_order_crc(crc_in) ^ crc_inv_alt;

    assign	crc_reg = calculate_crc(bit_order_data(data_in));

    assign	crc_out_inv = crc_reg ^ crc_inv_alt;
    assign	crc_out = bit_order_crc(crc_out_inv);
    assign	crc_chk_crc_in = calculate_crc_crc(crc_reg, crc_in_inv);
    assign	crc_ok = ! (| crc_chk_crc_in);


`undef	DW_max_data_crc_l

// synopsys translate_on

endmodule
