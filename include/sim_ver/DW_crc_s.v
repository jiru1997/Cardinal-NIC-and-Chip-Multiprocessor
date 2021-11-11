////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1999 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Nitin Mhamunkar  Sept 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 65c777b5
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//#include "DW_crc_s.lbls"
//----------------------------------------------------------------------------
// ABSTRACT: Generic CRC 
//
// MODIFIED:
//
//      02/03/2016  Liming SU   Eliminated function calling from sequential
//                              always block in order for NLP tool to correctly
//                              infer FFs
//
//      07/09/2015  Liming SU   Changed for compatibility with VCS Native Low
//                              Power
//
//	09/19/2002  Rick Kelly  Fixed behavior of enable (STAR 147315) as well
//                              as discrepencies in other control logic.  Also
//			        updated to current simulation code guidelines.
//
//----------------------------------------------------------------------------
module DW_crc_s
    (
     clk ,rst_n ,init_n ,enable ,drain ,ld_crc_n ,data_in ,crc_in ,
     draining ,drain_done ,crc_ok ,data_out ,crc_out 
     );

parameter data_width = 16;
parameter poly_size  = 16;
parameter crc_cfg    = 7;
parameter bit_order  = 3;
parameter poly_coef0 = 4129;
parameter poly_coef1 = 0;
parameter poly_coef2 = 0;
parameter poly_coef3 = 0;
   
input clk, rst_n, init_n, enable, drain, ld_crc_n;
input [data_width-1:0] data_in;
input [poly_size-1:0]  crc_in;
   
output draining, drain_done, crc_ok;
output [data_width-1:0] data_out;
output [poly_size-1:0]  crc_out;
   
//   synopsys translate_off


  wire 			   clk, rst_n, init_n, enable, drain, ld_crc_n;
  wire [data_width-1:0]    data_in;
  wire [poly_size-1:0]     crc_in;
   
  reg			   drain_done_int;
  reg 			   draining_status;
   
  wire [poly_size-1:0]     crc_result;
   
  integer 		   drain_pointer, data_pointer;
  integer 		   drain_pointer_next, data_pointer_next;
  reg 			   draining_status_next;
  reg 			   draining_next;
  reg 			   draining_int;
  reg 			   crc_ok_result;
  wire [data_width-1:0]    insert_data;
  reg [data_width-1:0]     data_out_next;
  reg [data_width-1:0]     data_out_int;
  reg [poly_size-1:0] 	   crc_out_int;
  reg [poly_size-1:0] 	   crc_out_info; 
  reg [poly_size-1:0] 	   crc_out_info_next;
  reg [poly_size-1:0] 	   crc_out_info_temp;
   
  reg [poly_size-1:0] 	   crc_out_next;
  reg [poly_size-1:0] 	   crc_out_temp;
  wire [poly_size-1:0]     insert_crc_info;
  wire [poly_size-1:0]     crc_swaped_info; 
  wire [poly_size-1:0]     crc_out_next_shifted;
  wire [poly_size-1:0]     crc_swaped_shifted;
  reg 			   drain_done_next;
  reg 			   crc_ok_int;
   
`ifdef UPF_POWER_AWARE
  `protected
>b3><Eaf:7eVKF]6##NWe#g0N6R+E_IP)D:+._c)Q>LRdB]<E:_K-)=Z<.5@^\.>
4e3)27U@<LQCQE;DQYN;Gfc_g>2)8J>+-C#TVA7=NPZ]E\Lb4SSS7&DUeFa+Me]B
/HDaH3>]X3G8TIe)G/#C&J7F4.I,(UV2=f,VXSIG3FCSFT:9@=&0O4g;0V]ZS6GM
9RCJafN@>K5^>9+bKC9U@D7?/bV#QJY,^:8-Q<MITVB#1b<=&VA-a^f1M<&4N4DJ
L:9,L,cK++aS1c>)0=L.48)cg<g:Ga)7[.K[/JR/<B?JGYXL7IN;DH,A]cFc/I[X
;<a&^B:6&?2#MM;R8-ES+^]B+c+3^RY)A1?9GZ7Z5_FV8YIO8&1X[2,0)U>-S(N2
cCP)5(-6#8)LP)2FX&&2+?X=:VW6,>f^gV&E::[J3,/d=T@F.YM5I677OSMUdV5c
4U8(C:,IU.9PbYDdWfH)Gf>GTQ\7K7&#fZ=+Za_>C:ERMJP_A-.J/L>FaIT>XX]J
UCSZM;8X;96?8ENJ@=@+U(UH[+RZ.KVKU=L+J.e?<>[8^370b?ICb?]&96JITM@H
2:_C\GWU3GIH2MQR50#FGb);<2LGK7CX=:O9745^OY2A+-IeO9[3e?CO@RaTJ6AT
(8^NdR#C<BC6d\R9?V6]>:,<\0VWG31K?fBL71RTXEGG.096[5]QC6R6?ZCgFHg4
\)&1Xbfe\,;eBI[CRB6?GQ>8dNS+O5EfB#+7@QFcX=F_ZGBY((PHXDd<f?[ga,L4
3bQ:@6J3T,&,=Y/A3JEHR@KAL\86))4IQYBebIf0BS(U63J9-OV@:&b^I(;U:PBV
SF#V>O(P.+Z;/+5-=4B;=c8fXZ5Y@:>&9^H\QNL7<8R)KCL4<2DdHTVU6Xc08V.X
22\I39O_([.QFSRTBM&>\ZXR?#\W@ReIc?=BbaGUbNNHLW87NYKYI1V72)6<9F9Z
UC/6H+(gaI.C8YB^R5+Z4W1g+(e9MJVB68&R=8#18(4[HY[P-^J-PB326L\A:[c_
0A5?VX@-J4c,Nc6\/;D3J^7+8FQ/f0?O1<SP&ZCYX-R(N0[VS0;Hc3@(JWT6)(P-
0EKZXb[@LH;B(J(WDD^^TSdbO&G=/UC[HbW[=#@,)TX)Q\#aT/2_=(9<_#c/^QWH
6TJD?3+;Q5^GcH(U:<]<Q1g7J0_#O)2G^K)M5Kd]3M,3[&2/&aT6A)(eJ22gM<V?
:E<Za5B0;Y[)K-1(KCB9ERS,gD<DD55Cfd=?G5HTRM,O>#CGKQLRd:12dGK(NAaD
#&+FAgN:O9Sg/ageHb4MO]Z?H4JbFL#J,Z,#Cg<LVb^M+cTM,/&2U[3KN0E]LH1B
CE?N)Ua(1e;25g_e-Z?bfUgM+IQPdX1G;H[3;]EZ<aG9=HCOFd7)?eegPO7P,W3f
R>@R2d3>+50^^f3GRCe)?>JN9-Z9/C[0AI?&(+KGUAJ?^NUJ-W.SC>1GZX/_B>V_
?EKb0:f2;J?(@Fc@&6&\g7ZaS^T=?^<JP&-9LK\1Y/a6>f^C+]IN^XI_(-U\DKYU
9<LI@@J^9?T<;?b\4FJeL.4EI-RYIGZ[]79Q,>;G)SZ?35WOW2I4L;Y\E44TA[\Z
dYb2,Y]-aG1=gXUIHe7Z]/BS/EL=D>Z?Yf.\;UV/4KZeM@VZ@,BG]V/@^R^edI]O
8RV2f&YcLXXW1I5UM0EAJ.<3)-0b:3d95PRI#VVaE?L3VeG4+5O#CRa@:cB33adE
g,OTAPJ-6)<R4_a(fa<DaH=#<gTB=BgFDDF.5-JE.M^.CDSLE\N)AGD&7LP]IWZ:
@aRIbG7#_@^b);_G+c8O_4/RTH0=_480U2d7/3e7.+A=G1.G=RA.>]cC#K2LZXVV
6D,IGK\#5V]D]]E<^e=/AF0O-+0D6V63??_J_:+&05NPI&F:E/58#(d&S;c3b,5a
E^&,\QL1^JG/PNe-&:#8&FEGeQ>.KT2aT&g\>I-<A)NGEV+6>IDU4,aOZ7,&K9d]
30FcY#<L46>6(1<GM<+GIKWfM0c4#Lc&+(^,L(4;Q_70a>c=bZI[-[((fe\0f+]\
_>Pb#f?f/VYXa[bK]0@dH7+N&//[Qa7cP5##bJ-N..A<XBX?H(E+b=#-(;>dQD:0
B7M7c<I8)4ZVLMc=-=916B,=86Cgd-5(EQH&:VGMJA(,d6eWULgB]a(:O@3KBQRZ
04\FC/AH5AU3HM)LKNXV1ZeMd;TFNRCA]>a#STP0bPS>G6_GQHIQKN.T\\JWab,O
gcUKQ_P1:XO56HN,]0:0bV/_5-BAY_=g>WX_>IW2??5:9Y1X?:-II394&e<f+WQP
bR+I(FL9a^\3Qb&L,./c[I-,LOS=Y=#/c;(R#A8?>=@.c#G]Z.DgOWIg.Gcb\>^e
cQ&cIbRgH\212cQ3>gC@9Y0+K#=E+L]+H7DaP_R8d/VNUP1&[H6K[;PV^2EY&2^[S$
`endprotected

`else
  reg [poly_size-1:0]      reset_crc_reg;
  reg [poly_size-1:0]      crc_polynomial;
  reg [poly_size-1:0] 	   crc_xor_constant;
  reg [poly_size-1:0]      crc_ok_info;
`endif
 

  function [poly_size-1:0] fswap_bytes_bits;
    input [poly_size-1:0] swap_bytes_of_word;
    input [1:0] bit_order;
    begin : FUNC_SWAP_INPUT_DATA 
      reg[data_width-1:0] swaped_word;
      integer 	     no_of_bytes;
      integer 	     byte_boundry1;
      integer 	     byte_boundry2;
      integer 	     i, j;
     
      byte_boundry1 = 0;
      byte_boundry2 = 0;
     
      no_of_bytes = data_width/8;
	if(bit_order == 0)
	  swaped_word = swap_bytes_of_word; 
	else if(bit_order == 1) begin
	  for(i=0;i<=(data_width-1);i=i+1) begin
	    swaped_word[(data_width-1)-i] = swap_bytes_of_word[i];
	  end 
	end  
	else if(bit_order == 3) begin
	  for(i=1;i<=no_of_bytes;i=i+1) begin 
	    byte_boundry1 = (i * 8) - 1;
	    byte_boundry2 = (i - 1)* 8;
	    for (j=0;j<8;j=j+1) begin 
	      swaped_word [(byte_boundry2  + j)] = 
		      swap_bytes_of_word [(byte_boundry1  - j)];
	    end
	  end
	end
	else begin
	  for(i=1;i<=no_of_bytes;i=i+1) begin
	    byte_boundry1 = data_width - (i*8);
	    byte_boundry2 = ((i - 1)* 8);
	    for(j=0;j<8;j=j+1) begin 
	      swaped_word [(byte_boundry2 + j)] = 
      	      	      swap_bytes_of_word [(byte_boundry1  + j)];
	    end
	  end
	end
	 
	fswap_bytes_bits = swaped_word;
      end
  endfunction // FUNC_SWAP_INPUT_DATA





  function [poly_size-1:0] fswap_crc;
    input [poly_size-1:0] swap_crc_data;
    begin : FUNC_SWAP_CRC
      reg[data_width-1:0]   swap_data;
      reg [data_width-1:0] swaped_data;
      reg [poly_size-1:0]  swaped_crc;
      integer 	           no_of_words;
      integer 	           data_boundry1;
      integer 	           data_boundry2;
      integer 	           i, j;
     
      no_of_words = poly_size/data_width;
     
      data_boundry1 = (poly_size-1) + data_width;
      while (no_of_words > 0) begin 
	data_boundry1 = data_boundry1 - data_width;
	data_boundry2 = data_boundry1 - (data_width-1);
	j=0;
	for(i=data_boundry2;i<=data_boundry1;i = i + 1) begin
	  swap_data[j] = swap_crc_data[i];
	  j = j + 1;
	end      
	    
	swaped_data = fswap_bytes_bits (swap_data, bit_order);
	    
	j=0;
	for(i=data_boundry2;i<=data_boundry1;i = i + 1) begin
	  swaped_crc[i] = swaped_data[j];
	  j = j + 1;
	end   
	
	no_of_words = (no_of_words  -  1);
      end
     
      fswap_crc = swaped_crc;
    end
  endfunction // FUNC_SWAP_CRC


  function [poly_size-1:0] fcalc_crc;
    input [data_width-1:0] data_in;
    input [poly_size-1:0] crc_temp_data;
    input [poly_size-1:0] crc_polynomial;
    input [1:0]  bit_order;
    begin : FUNC_CAL_CRC
      reg[data_width-1:0] swaped_data_in;
      reg [poly_size-1:0] crc_data;
      reg 		     xor_or_not;
      integer 	     i;
     
     
     
      swaped_data_in = fswap_bytes_bits (data_in ,bit_order);
      crc_data = crc_temp_data ;
      i = 0 ;
      while (i < data_width ) begin 
	xor_or_not = 
	  swaped_data_in[(data_width-1) - i] ^ crc_data[(poly_size-1)];
	crc_data = {crc_data [((poly_size-1)-1):0],1'b0 };
	if(xor_or_not === 1'b1)
	  crc_data = (crc_data ^ crc_polynomial);
	else if(xor_or_not !== 1'b0)
	  crc_data = {data_width{xor_or_not}} ;
	i = i + 1;
      end
      fcalc_crc = crc_data ;
    end
  endfunction // FUNC_CAL_CRC





  function check_crc;
    input [poly_size-1:0] crc_out_int;
    input [poly_size-1:0] crc_ok_info;
    begin : FUNC_CRC_CHECK
      integer i;
      reg 	 crc_ok_func;
      reg [poly_size-1:0] data1;
      reg [poly_size-1:0] data2;
      data1 = crc_out_int ;
      data2 = crc_ok_info ;
     
      i = 0 ;
      while(i < poly_size) begin 
	if(data1[i] === 1'b0  || data1[i] === 1'b1) begin 
	  if(data1[i] === data2 [i]) begin
	    crc_ok_func = 1'b1;
	  end
	  else begin
	    crc_ok_func = 1'b0;
	    i = poly_size;
	  end 
	end
	else begin
	  crc_ok_func = data1 [i];
	  i = poly_size;
	end 
	i = i + 1;
      end
     
      check_crc = crc_ok_func ;
    end
  endfunction // FUNC_CRC_CHECK



   
  always @(drain or
           draining_status or
           drain_done_int or
           data_pointer or
           drain_pointer or
           insert_data or
           crc_out_next_shifted or
           crc_out_info or
           data_in or
           crc_result or
           ld_crc_n or
           crc_in or
           crc_ok_info)
  begin: PROC_DW_crc_s_sim_com

    if(draining_status === 1'b0) begin
      if((drain & ~drain_done_int) === 1'b1) begin
       draining_status_next = 1'b1;
       draining_next = 1'b1;
       drain_pointer_next = drain_pointer + 1;
       data_pointer_next = data_pointer  - 1;
       data_out_next = insert_data;
       crc_out_next = crc_out_next_shifted;
       crc_out_info_next = crc_out_info; 
       drain_done_next = drain_done_int;
      end  
      else if((drain & ~drain_done_int) === 1'b0) begin
       draining_status_next = 1'b0;
       draining_next = 1'b0;
       drain_pointer_next = 0;
       data_pointer_next = (poly_size/data_width) ; 
       data_out_next = data_in ;
       crc_out_next = crc_result;
       crc_out_info_next = crc_result;
       drain_done_next = drain_done_int;
      end  
      else begin
       draining_status_next = 1'bx ;
       draining_next = 1'bx ;
       drain_pointer_next = 0;
       data_pointer_next = 0 ; 
       data_out_next = {data_width {1'bx}};
       crc_out_next = {poly_size {1'bx}};
       crc_out_info_next = {poly_size {1'bx}}; 
       drain_done_next = 1'bx;
      end  
    end
    else if(draining_status === 1'b1) begin 
      if(data_pointer == 0) begin 
       draining_status_next = 1'b0 ;
       draining_next = 1'b0 ;
       drain_pointer_next = 0 ;
       data_pointer_next = 0 ; 
       data_out_next = data_in ;
       crc_out_next = crc_result;
       crc_out_info_next = crc_result; 
       drain_done_next = 1'b1;
      end
      else begin
       draining_status_next = 1'b1 ;
       draining_next = 1'b1 ;
       drain_pointer_next = drain_pointer + 1;
       data_pointer_next = data_pointer  - 1;
       data_out_next = insert_data ;
       crc_out_next = crc_out_next_shifted;
       crc_out_info_next = crc_out_info;
       drain_done_next = drain_done_int;
      end   
    end   // draining_status === 1'b1
    else begin 
      draining_status_next = 1'bx ;
      draining_next = 1'bx ;
      drain_pointer_next = data_pointer ;
      data_pointer_next = drain_pointer;
      data_out_next = {data_width{1'bx}} ;
      crc_out_next = {poly_size{1'bx}}  ;
      crc_out_info_next = {poly_size{1'bx}}  ; 
      drain_done_next = 1'bx ;
    end   

    if(ld_crc_n === 1'b0) begin
      crc_out_temp = crc_in;
      crc_out_info_temp = crc_in;
    end
    else if(ld_crc_n === 1'b1) begin
      crc_out_temp = crc_out_next;
      crc_out_info_temp = crc_out_info_next;
    end
    else begin
      crc_out_temp = {poly_size{1'bx}};
      crc_out_info_temp = {poly_size{1'bx}}; 
    end 

    crc_ok_result = check_crc(crc_out_temp ,crc_ok_info);

  end // PROC_DW_crc_s_sim_com

  always @ (posedge clk or negedge rst_n) begin : DW_crc_s_sim_seq_PROC
        
    if(rst_n === 1'b0) begin
      draining_status <= 1'b0 ;
      draining_int <= 1'b0 ;
      drain_pointer <= 0 ;
      data_pointer <= (poly_size/data_width) ;
      data_out_int <= {data_width{1'b0}} ;
      crc_out_int <= reset_crc_reg ; 
      crc_out_info <= reset_crc_reg ;  
      drain_done_int <= 1'b0 ;
      crc_ok_int <= 1'b0;   
    end else if(rst_n === 1'b1) begin 
      if(init_n === 1'b0) begin
        draining_status <= 1'b0 ;
        draining_int <= 1'b0 ;
        drain_pointer <= 0 ;
        data_pointer <= (poly_size/data_width) ;
        data_out_int <= {data_width{1'b0}} ;
        crc_out_int <= reset_crc_reg ;
        crc_out_info <= reset_crc_reg ; 
        drain_done_int <= 1'b0 ;
        crc_ok_int <= 1'b0;
      end else if(init_n === 1'b1) begin 
        if(enable === 1'b1) begin
          draining_status <= draining_status_next;
          draining_int <= draining_next ;
          drain_pointer <= drain_pointer_next ;
          data_pointer <= data_pointer_next ;
          data_out_int <= data_out_next ;
          crc_out_int <= crc_out_temp ;
          crc_out_info <= crc_out_info_temp ;
          drain_done_int <= drain_done_next ;
          crc_ok_int <= crc_ok_result;
        end else if(enable === 1'b0) begin
           draining_status <= draining_status ;
           draining_int <= draining_int ;
           drain_pointer <= drain_pointer ;
           data_pointer <= data_pointer ;
           data_out_int <= data_out_int ;
           crc_out_int <= crc_out_int ;
           crc_out_info <= crc_out_info ;
           drain_done_int <= drain_done_int ;
           crc_ok_int <= crc_ok_int ;
        end else begin
           draining_status <= 1'bx ;
           draining_int <= 1'bx ;
           drain_pointer <= 0 ;
           data_pointer <= (poly_size/data_width) ;
           data_out_int <= {data_width{1'bx}} ;
           crc_out_int <= {poly_size{1'bx}} ;
           crc_out_info <= {poly_size{1'bx}} ; 
           drain_done_int <= 1'bx ;
           crc_ok_int <= 1'bx ; 
        end
      end else begin 
        draining_status <= 1'bx ;
        draining_int <= 1'bx ;
        drain_pointer <= 0 ;
        data_pointer <= (poly_size/data_width) ;
        data_out_int <= {data_width{1'bx}} ;
        crc_out_int <= {poly_size{1'bx}} ;
        crc_out_info <= {poly_size{1'bx}} ; 
        drain_done_int <= 1'bx ;
        crc_ok_int <= 1'bx ; 
      end      
    end else begin
      draining_status <= 1'bx ;
      draining_int <= 1'bx ;
      drain_pointer <= 0 ;
      data_pointer <= 0 ;
      data_out_int <= {data_width{1'bx}} ;
      crc_out_int <= {poly_size{1'bx}} ;
      crc_out_info <= {poly_size{1'bx}} ; 
      drain_done_int <= 1'bx ;
      crc_ok_int <= 1'bx ;
    end 
       
  end // PROC_DW_crc_s_sim_seq

   assign crc_out_next_shifted = crc_out_int << data_width; 
   assign crc_result = fcalc_crc (data_in ,crc_out_int ,crc_polynomial ,bit_order);
   assign insert_crc_info = (crc_out_info ^ crc_xor_constant);
   assign crc_swaped_info = fswap_crc (insert_crc_info);
   assign crc_swaped_shifted = crc_swaped_info << (drain_pointer*data_width);
   assign insert_data = crc_swaped_shifted[poly_size-1:poly_size-data_width];

   assign crc_out = crc_out_int;
   assign draining = draining_int;
   assign data_out = data_out_int;
   assign crc_ok = crc_ok_int;
   assign drain_done = drain_done_int;
   
   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
      
       
    if ( (poly_size < 2) || (poly_size > 64 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_size (legal range: 2 to 64 )",
	poly_size );
    end
       
    if ( (data_width < 1) || (data_width > poly_size ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 1 to poly_size )",
	data_width );
    end
       
    if ( (bit_order < 0) || (bit_order > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter bit_order (legal range: 0 to 3 )",
	bit_order );
    end
       
    if ( (crc_cfg < 0) || (crc_cfg > 7 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter crc_cfg (legal range: 0 to 7 )",
	crc_cfg );
    end
       
    if ( (poly_coef0 < 0) || (poly_coef0 > 65535 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef0 (legal range: 0 to 65535 )",
	poly_coef0 );
    end
       
    if ( (poly_coef1 < 0) || (poly_coef1 > 65535 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef1 (legal range: 0 to 65535 )",
	poly_coef1 );
    end
       
    if ( (poly_coef2 < 0) || (poly_coef2 > 65535 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef2 (legal range: 0 to 65535 )",
	poly_coef2 );
    end
       
    if ( (poly_coef3 < 0) || (poly_coef3 > 65535 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef3 (legal range: 0 to 65535 )",
	poly_coef3 );
    end
       
    if ( (poly_coef0 % 2) == 0 ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter (poly_coef0 value MUST be an odd number)" );
    end
       
    if ( (poly_size % data_width) > 0 ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination (poly_size MUST be a multiple of data_width)" );
    end
       
    if ( (data_width % 8) > 0 && (bit_order > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination (crc_cfg > 1 only allowed when data_width is multiple of 8)" );
    end

   
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

      

`ifndef UPF_POWER_AWARE
  initial begin : init_vars
	
    reg [63:0]			con_poly_coeff;
    reg [15:0]			v_poly_coef0;
    reg [15:0]			v_poly_coef1;
    reg [15:0]			v_poly_coef2;
    reg [15:0]			v_poly_coef3; 
    reg [poly_size-1:0 ]	int_ok_calc;
    reg[poly_size-1:0]		x;
    reg				xor_or_not_ok;
    integer			i;
	
    v_poly_coef0 = poly_coef0;
    v_poly_coef1 = poly_coef1;
    v_poly_coef2 = poly_coef2;
    v_poly_coef3 = poly_coef3;
	
    con_poly_coeff = {v_poly_coef3, v_poly_coef2,
			v_poly_coef1, v_poly_coef0 };

    crc_polynomial = con_poly_coeff [poly_size-1:0];
	
    if(crc_cfg % 2 == 0)
      reset_crc_reg = {poly_size{1'b0}};
    else
      reset_crc_reg = {poly_size{1'b1}};
	 
    
    if(crc_cfg == 0 || crc_cfg == 1) begin 
      x = {poly_size{1'b0}};
    end
    else if(crc_cfg == 6 || crc_cfg == 7) begin 
      x = {poly_size{1'b1}};
    end
    else begin
      if(crc_cfg == 2 || crc_cfg == 3) begin 
        x[0] = 1'b1;
      end
      else begin 
        x[0] = 1'b0;
      end 
       
      for(i=1;i<poly_size;i=i+1) begin 
        x[i] = ~x[i-1];
      end
    end
    
    crc_xor_constant = x;

    int_ok_calc = crc_xor_constant;
    i = 0;
    while(i < poly_size) begin 
      xor_or_not_ok = int_ok_calc[(poly_size-1)];
      int_ok_calc = { int_ok_calc[((poly_size-1)-1):0], 1'b0};
      if(xor_or_not_ok === 1'b1)
	int_ok_calc = (int_ok_calc ^ crc_polynomial);
      i = i + 1; 
    end
    crc_ok_info = int_ok_calc;
	
   end  // init_vars
`endif
   
   
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

 // synopsys translate_on
      
endmodule
