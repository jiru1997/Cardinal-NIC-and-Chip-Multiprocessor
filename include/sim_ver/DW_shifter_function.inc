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
// AUTHOR:    Sourabh Tandon               July 19, 1999
//
// VERSION:   Functions
//
// DesignWare_version: c22cf8cb
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------
// ABSTRACT: Arithmetic and Barrel combo shifter
//           This component performs arithmatic and circular shifting in
//           both left and right directions.  
//
// MODIFIED:
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//-------------------------------------------------------------------------------


function[data_width-1:0] DWF_shifter_uns_uns;
 
  // synopsys map_to_operator SHIFTER_UNS_UNS_OP
  // synopsys return_port_name Z

  input [data_width-1:0] data_in;
  input [sh_width-1:0] sh;
  input sh_mode;
  reg   [data_width-1:0] data_out;
  integer j;

  begin 
    if(sh_mode == 1'b1)
      begin
         DWF_shifter_uns_uns = data_in << sh;
      end
    else begin
         data_out = data_in << (sh % data_width);
         for ( j = 0; j < (sh % data_width) ; j = j+1 )
              data_out[j] = data_in[ data_width - (sh % data_width) + j ];
         DWF_shifter_uns_uns = data_out;
    end
  end
endfunction // DWF_shifter_uns_uns


function[data_width-1:0] DWF_shifter_tc_uns;
 
  // synopsys map_to_operator SHIFTER_TC_UNS_OP
  // synopsys return_port_name Z
 
  input [data_width-1:0] data_in;
  input [sh_width-1:0] sh;
  input sh_mode;
  reg   [data_width-1:0] data_out;
  integer j;
 
  begin
    if(sh_mode == 1'b1)
      begin
         DWF_shifter_tc_uns = data_in << sh;
      end
    else begin
         data_out = data_in << (sh % data_width);
         for ( j = 0; j < (sh % data_width) ; j = j+1 )
              data_out[j] = data_in[ data_width - (sh % data_width) + j ];
         DWF_shifter_tc_uns = data_out;
    end
  end
endfunction // DWF_shifter_tc_uns


function[data_width-1:0] DWF_shifter_uns_tc;
 
  // synopsys map_to_operator SHIFTER_UNS_TC_OP
  // synopsys return_port_name Z
 
  input [data_width-1:0] data_in;
  input [sh_width-1:0] sh;
  input sh_mode;
  reg   [data_width-1:0] data_out;
  reg [sh_width-1:0] sh_abs;
  integer j;
 
  begin
    if(sh_mode == 1'b1)
       begin
         if(sh[sh_width-1] == 1'b0) 
           DWF_shifter_uns_tc = data_in << sh;
         else
           DWF_shifter_uns_tc = data_in >> (-sh);
       end
    else begin
         if(sh[sh_width-1] == 1'b0) begin
           data_out = data_in << (sh % data_width);
           for ( j = 0; j < (sh % data_width) ; j = j+1 )
                data_out[j] = data_in[ data_width - (sh % data_width) + j ];
           DWF_shifter_uns_tc = data_out;
         end
         else begin
           sh_abs = -sh;
           data_out = data_in >> (-sh);
           for ( j = (data_width - (sh_abs )); j <= (data_width-1) ; j = j+1 )
              begin
                data_out[j] = data_in[ (j + (sh_abs )) % data_width ];
              end
           DWF_shifter_uns_tc = data_out;
         end
    end
  end
endfunction // DWF_shifter_uns_tc


function[data_width-1:0] DWF_shifter_tc_tc;
 
  // synopsys map_to_operator SHIFTER_TC_TC_OP
  // synopsys return_port_name Z
 
  input [data_width-1:0] data_in;
  input [sh_width-1:0] sh;
  input sh_mode;
  integer j;
  reg [data_width-1:0] data_out;
  reg [sh_width-1:0] sh_abs;
  reg data_sign;
 
  begin
    if(sh_mode == 1'b1)
      begin
         if(sh[sh_width-1] == 1'b0)           DWF_shifter_tc_tc = data_in << sh;
         else begin
           sh_abs = -sh;
           data_sign = data_in[data_width-1];
           data_out = data_in >> sh_abs;
           // sign extension of right shifted data
           for(j=0; j<data_width; j=j+1) begin
             if((j > data_width-sh_abs-1)||(sh_abs >= data_width))
                DWF_shifter_tc_tc[j] = data_sign;
              else
                DWF_shifter_tc_tc[j] = data_out[j];
           end
         end
      end
      else begin
         if(sh[sh_width-1] == 1'b0) begin
           data_out = data_in << (sh % data_width);
           for ( j = 0; j < (sh % data_width) ; j = j+1 )
                data_out[j] = data_in[ data_width - (sh % data_width) + j ];
           DWF_shifter_tc_tc = data_out;
         end
         else begin
           data_out = data_in >> (-sh);
           sh_abs = (-sh);
           for ( j = (data_width - (sh_abs )); j <= (data_width-1) ; j = j+1 )
                data_out[j] = data_in[ (j + (sh_abs )) % data_width ];
           DWF_shifter_tc_tc = data_out;
         end
      end
  end
endfunction // DWF_shifter_tc_tc


function[data_width-1:0] shift_uns_uns;
 
  input [data_width-1:0] data_in;
  input [sh_width-1:0] sh;
  input sh_mode;
  input padded_value;
   
  reg   [data_width-1:0] data_out;
  integer j;

  begin 
    if(sh_mode == 1'b1)
      begin
         data_out = data_in << sh;
         for ( j = 0; j < sh ; j = j+1 )
              data_out[j] = padded_value;
      end
    else begin
         data_out = data_in << (sh % data_width);
         for ( j = 0; j < (sh % data_width) ; j = j+1 )
              data_out[j] = data_in[ data_width - (sh % data_width) + j ];
    end
         shift_uns_uns = data_out;
  end
endfunction // shift_uns_uns


function[data_width-1:0] shift_tc_uns;
 
  input [data_width-1:0] data_in;
  input [sh_width-1:0] sh;
  input sh_mode;
  input padded_value;
   
  reg   [data_width-1:0] data_out;
  reg [sh_width-1:0] sh_abs;
  reg data_sign;
  integer j;

  begin 
    if(sh_mode == 1'b1)
       begin
         if(sh[sh_width-1] == 1'b0) begin
	    data_out = data_in << sh;
	    for ( j = 0; j < sh ; j = j+1 )
	       data_out[j] = padded_value;	    
	 end // if (sh[sh_width-1] == 1'b0)
         else begin
           sh_abs = -sh;
           data_out = data_in >> sh_abs;
	    for ( j = 0; j < sh_abs ; j = j+1 )
	       data_out[data_width-1-j] = padded_value; 
	 end
       end
    else begin
       if(sh[sh_width-1] == 1'b0) begin
	  data_out = data_in << (sh % data_width);
	  for ( j = 0; j < (sh % data_width) ; j = j+1 )
	     data_out[j] = data_in[ data_width - (sh % data_width) + j ];
       end // if (sh[sh_width-1] == 1'b0)
       else begin
           sh_abs = -sh;
	  data_out = data_in >> sh_abs;
	  for ( j = 0; j < sh_abs ; j = j+1 )
	     data_out[data_width-1-j] = data_in[sh_abs -1- j ];
       end 	  
    end
         shift_tc_uns = data_out;
  end
endfunction // shift_tc_uns


function[data_width-1:0] shift_uns_tc;
 
  input [data_width-1:0] data_in;
  input [sh_width-1:0] sh;
  input sh_mode;
  input padded_value;
   
  reg   [data_width-1:0] data_out;
  integer j;

  begin 
    if(sh_mode == 1'b1) begin
       data_out = data_in << sh;
       for ( j = 0; j < sh ; j = j+1 )
	  data_out[j] = padded_value;
    end
    else begin
       data_out = data_in << (sh % data_width);
       for ( j = 0; j < (sh % data_width) ; j = j+1 )
	  data_out[j] = data_in[ data_width - (sh % data_width) + j ];
    end
     shift_uns_tc = data_out;
  end
endfunction // shift_uns_tc


function[data_width-1:0] shift_tc_tc;
   
   input [data_width-1:0] data_in;
   input [sh_width-1:0]   sh;
   input 		  sh_mode;
   input 		  padded_value;
   
   reg [data_width-1:0]   data_out;  
   reg [sh_width-1:0] 	  sh_abs;
   reg 			  data_sign;
   integer 		  j;

   begin 
      if(sh_mode == 1'b1)
	 begin
	    if(sh[sh_width-1] == 1'b0) begin
	       data_out = data_in << sh;
	       for ( j = 0; j < sh ; j = j+1 )
		  data_out[j] = padded_value;	    
	    end // if (sh[sh_width-1] == 1'b0)
	    else begin
	       sh_abs = -sh;
	       data_sign = data_in[data_width-1];
	       data_out = data_in >> sh_abs;
	       for ( j = 0; j < sh_abs ; j = j+1 )
		  data_out[data_width-1-j] = data_sign; 
	    end
	 end
      else begin
	 if(sh[sh_width-1] == 1'b0) begin
	    data_out = data_in << (sh % data_width);
	    for ( j = 0; j < (sh % data_width) ; j = j+1 )
	       data_out[j] = data_in[ data_width - (sh % data_width) + j ];
	 end // if (sh[sh_width-1] == 1'b0)
	 else begin
	    sh_abs = -sh;
	    data_out = data_in >> sh_abs;
	    for ( j = 0; j < sh_abs ; j = j+1 )
	       data_out[data_width-1-j] = data_in[sh_abs -1- j ];
	 end 	  
      end
      shift_tc_tc = data_out;
   end
endfunction // shift_tc_tc
