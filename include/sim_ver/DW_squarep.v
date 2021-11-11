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
// AUTHOR:    Rick Kelly        5/17/99
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 7ec6c516
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Integer Squarer, parital products
//
//    **** >>>>  NOTE:	This model is architecturally different
//			from the 'wall' implementation of DW_squarep
//			but will generate exactly the same result
//			once the two partial product outputs are
//			added together
//
// MODIFIED:
// RPH                 10/16/2002
//                     Added parameter Chceking and added DC directives
//
//------------------------------------------------------------------------------
//

`ifdef VCS
`include "vcs/DW_squarep.v"
`else

module DW_squarep(a, tc, out0, out1);

   parameter width = 8;
   parameter verif_en = 1;

   input [width-1 : 0] a;
   input 	       tc;
   output [2*width-1 : 0] out0, out1;
   
  // synopsys translate_off
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
     
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
    end
   
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

     

   reg [2*width-1 : 0]    out0_fixed_cs, out1_fixed_cs;
   reg [width-1 : 0]      abs_a;


 //-----------------------------------------------------------------------------

     always @ (a or tc)
         begin : absval_a
            reg [width-1 : 0] a_temp;
            integer           indx;

            if ((tc & a[width-1]) === 1'b0)
               abs_a = a;

            else begin
               if ((tc & a[width-1]) === 1'b1)
                  begin
                     a_temp = ~a;

                     indx = 0;
                     while ((a_temp[indx] === 1'b1) && (indx < width))
                        begin
                           a_temp[indx] = 1'b0;
                           indx = indx + 1;
                        end

                     if (indx < width)
                        a_temp[indx] = ~a_temp[indx];

                     abs_a = a_temp;
                  end

               else
                  abs_a = {width{1'bx}};
            end
         end


   always @ (abs_a)
      begin : mult_array
         reg [2*width-1 : 0] pp_array [0 : width-1];
         reg [2*width-1 : 0] tmp_pp_sum, tmp_pp_carry;
         integer             indx, pp_count;

         if ( (^(abs_a ^ abs_a) !== 1'b0) ) begin
            out0_fixed_cs = {2*width{1'bx}};
            out1_fixed_cs = {2*width{1'bx}};
         end

         else begin
            if (width > 1)
               begin
                  for (indx=1 ; indx < width ; indx=indx+1)
                     begin
                        if (abs_a[indx] === 1'b1)
                           pp_array[indx] = {{width{1'b0}}, abs_a} << indx;
                        else
                           pp_array[indx] = {2*width{1'b0}};
                     end
               end

            if (abs_a[0] === 1'b1)
               pp_array[0] = {{width{1'b0}},abs_a};
            else
               pp_array[0] = {2*width{1'b0}};

            pp_count = width;

            while (pp_count > 2)
               begin
                  for (indx=0 ; indx < (pp_count/3) ; indx=indx+1)
                     begin
                        tmp_pp_sum = pp_array[indx*3] ^ pp_array[indx*3+1] ^
                            pp_array[indx*3+2];

                        tmp_pp_carry = pp_array[indx*3] & pp_array[indx*3+1] |
                                       pp_array[indx*3+1] & pp_array[indx*3+2] |
                                       pp_array[indx*3+2] & pp_array[indx*3];

                        pp_array[indx*2] = tmp_pp_sum;
                        pp_array[indx*2+1] = {tmp_pp_carry[width*2-2:0], 1'b0};
                     end

                  if ( (pp_count % 3) > 0 )
                     begin
                        for (indx=0 ; indx < (pp_count % 3) ; indx=indx+1)
                           pp_array[2 * (pp_count/3) + indx] =
                                  pp_array[3 * (pp_count/3) + indx];
                     end

                  pp_count = pp_count - (pp_count/3);
               end

            out0_fixed_cs = pp_array[0];

            if (pp_count == 1)
               out1_fixed_cs = {width*2{1'b0}};
            else
               out1_fixed_cs = pp_array[1];

         end
      end



   assign out1 = out1_fixed_cs;
   assign out0 = out0_fixed_cs; 
   // synopsys translate_on
endmodule
`endif

