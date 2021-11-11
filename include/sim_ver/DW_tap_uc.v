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
// AUTHOR:    Bob Tong/RPH                   May 1, 1998/May 2002           
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 5f2a82b4
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  TAP Controller with USERCODE support
//
//
//  Parameters: 	Valid Values
//  ==========  	============
//  width		[ 2 to 32 ]
//  id			[ 0 = not present,
//			  1 = present ]
//  idcode_opcode  	[0 to 2**32-1]			  
//  version		[ 0 to 15 ]
//  part		[ 0 to 65535 ] 
//  man_num		[ 0 to 2047 ] 
//   			( not equal to 127 ) 
//          
//  sync_mode		[ 0 = asynchronous,
//			  1 = synchrounous ] 	
//
//  Input Ports:    Size    	Description
//  ===========     ====    	===========
//  tck		     1 bit   	Test clock 
//  trst_n	     1 bit   	Test reset, active low 
//  tms		     1 bit   	Test mode select 
//  tdi		     1 bit   	Test data in 
//  so		     1 bit   	Serial data from boundary scan 
//                          	  register and data registers 
//  bypass_sel	     1 bit   	Selects the bypass register 
//                         
//  sentinel_val    width - 1   User-defined status bits	
//  device_id_sel    1 bit   	Selects the device id  register
//  user_code_sel    1 bit   	Selects USERCODE instruction 
//  user_code_val    32 bits    USERCODE input to device id register
//  ver              4 bits     external version port
//  ver_sel          1 bit   	Selects the ver port
//  part_num         16 bits    external part number port 
//  part_num_sel     1 bit   	Selects the part_num port
//  mnfr_id          11 bits    external manufacturer's id port 
//  mnfr_id_sel      1 bit   	Selects the manufacturer's id port
//  
//  Output Ports    Size    	Description
//  ============    ====    	===========
//  clock_dr	     1 bit      Controls the boundary scan register	
//  shift_dr	     1 bit      Controls the boundary scan register
//  update_dr	     1 bit	Controls the boundary scan register
//  tdo		     1 bit	Test data out
//  tdo_en	     1 bit 	Enable for tdo output buffer
//  tap_state       16 bit	Current state of the TAP 
//				  finite state machine
//  instructions    width	Instruction register output	
//
//
//
// MODIFIED:
//
//   DLL 01/19/16  Re-structured most of the always blocks to be split
//                 into two pieces procedural and sequential.  No mix of
//                 combination logic and flip-flops in the same always block(s)
//                 anymore.  Edits made to be Native-Low-Power compatible.
//                 Addresses STAR#9000999057.
//
//   RJK 09/17/15  Eliminated initialized constants for NLP compatibility
//   bdean 6/28/05
//   added #0 for enables: star 9000067695
//   bdean 4/28/08
//   added #1 for enables: star 90000
//
//
//   Doug Lee   Nov. 3, 2004
//      Fixed bug in always block determining tdo_temp.  Added missing
//      "id_sel" signal to sensitivity list (STAR 9000034981).
//      Also, fixed non-STAR bugs:
//        (1) Decoding of id_sel.  Was decoding based on a fixed 
//            update_reg_ir value instead of the idcode_opcode
//            parameter value.
//        (2) id_code_vec was being double driven by two unique
//            equations.  One is right the other is wrong.  Should
//            not have been doubly driven in the first place.
//            Removed the "wrong" equation.
//
//   Rajeev P Huralikoppi  May 2002
//      This is a new component derived from the DW_tap component
//      with additional parameters/ports to support USERCODE and
//      external ports  to support device identity register programming
//      with recompiling. (STARs 113898, 121365, 131993 )   
//
//-----------------------------------------------------------------------
			  		
module DW_tap_uc ( tck, trst_n, tms, tdi, so, bypass_sel, sentinel_val, 
		   device_id_sel, user_code_sel, user_code_val,
		   ver, ver_sel, part_num, part_num_sel, mnfr_id, mnfr_id_sel,
		   clock_dr, shift_dr, update_dr, tdo, tdo_en, tap_state, 
		   instructions, sync_capture_en, sync_update_dr,test );

  parameter width = 2;
  parameter id = 0;
  parameter idcode_opcode = 1;
  parameter version = 0;
  parameter part = 0;
  parameter man_num = 0;
  parameter sync_mode = 0;
 
  input  tck;
  input  trst_n;
  input  tms;
  input  tdi;
  input  so;
  input  bypass_sel;
  input  [(width - 2):0] sentinel_val;
   input 		 device_id_sel, user_code_sel;
   input [31:0] 	 user_code_val;
   input 		 ver_sel, part_num_sel, mnfr_id_sel;
   input [3:0] ver;
   input [15:0] part_num;
   input [10:0] mnfr_id;
   
  output  clock_dr;
  output  shift_dr;
  output  update_dr;
  output  tdo;
  output  tdo_en;
  output  [15:0] tap_state;
  output  [(width - 1):0] instructions;
  output  sync_capture_en;
  output  sync_update_dr;
 
  input   test;
 
  wire clock_dr;
  reg shift_dr;
  wire update_dr;
  reg tdo;
  wire tdo_en;
  reg [15:0] tap_state;

  wire clock_ir;
  reg shift_ir;
  wire update_ir;

  wire tck_n;
  reg fsm_rst;
  wire instr_rst;

  wire capture_dr;
  wire capture_en_dr;
  wire data_in_int;
  reg bypass_so;

  wire capture_reg_dr_msb;
  reg [32:0] capture_reg_dr;

  wire capture_reg_ir_msb;
  reg [width:0] capture_reg_ir;
  reg [(width - 1):0] update_reg_ir;
  wire instr_so;
   
  reg update_reg_ir_temp;
  reg update_reg_ir_temp_n;
  reg update_reg_ir_temp_by;
   
  wire id_sel;
  wire bypass_int;
  reg tdo_temp;
  wire id_so;

  wire sync_capture_ir;

  localparam [width-1 : 0] idcode_opcode_cnst = idcode_opcode;
  localparam [4:0]  version_vec_cnst = version;
  localparam [16:0] part_vec_cnst = part;
  localparam [11:0] man_num_vec_cnst = man_num;
  wire [31:0] id_code_vec;
 
  wire [width-1 : 0] idcode_opcode_value;
   
  wire [4:0] temp_version_value;
  wire [16:0] temp_part_value;
  wire [11:0] temp_man_num_value;
   
  wire[(width - 1):0] instructions;
  wire sync_capture_en;
  wire sync_update_dr;
 
  // synopsys translate_off

  assign  tck_n  = (~(tck));
  assign  tdo_en = (shift_dr | shift_ir );
  assign  sync_capture_en = (~(shift_dr | (tap_state [3] | tap_state [4])));
  assign  sync_capture_ir = (~(shift_ir | (tap_state [10] | tap_state [11])));
  assign  sync_update_dr = tap_state [8];
  assign  clock_dr = ((tck | (~(tck | (tap_state [3] | tap_state [4])))) 
                           | (~(tap_state [3] | tap_state [4])));
  assign  clock_ir = ((tck | (~(tck | (tap_state [10] | tap_state [11])))) 
                           | (~(tap_state [10] | tap_state [11])));
  assign  update_dr = (tck_n & tap_state [8]);
  assign  update_ir = (tck_n & tap_state [15]);
  assign  instr_rst = test ? ~trst_n : (fsm_rst | (~trst_n ));
   assign  data_in_int = (tdi & shift_dr );
   
   assign temp_man_num_value = mnfr_id_sel === 1'b0 ? man_num_vec_cnst : mnfr_id;
   assign temp_part_value = part_num_sel === 1'b0 ? part_vec_cnst : part_num;
   assign temp_version_value = ver_sel === 1'b0 ? version_vec_cnst : ver;
   
   assign id_code_vec [0] = user_code_sel === 1'b0 ? 1'b1 : user_code_val[0];
   assign id_code_vec [11:1] = user_code_sel === 1'b0 ? temp_man_num_value[10:0] : user_code_val[11:1];
   assign id_code_vec [27:12] = user_code_sel === 1'b0 ? temp_part_value[15:0] : user_code_val[27:12];
   assign id_code_vec [31:28] = user_code_sel === 1'b0 ? temp_version_value[3:0] : user_code_val[31:28];
   
   assign  capture_reg_dr_msb = (tdi);
   assign  id_so  = capture_reg_dr [0];
   assign  capture_reg_ir_msb = (tdi);
   assign  instr_so  = capture_reg_ir [0];
   assign  instructions  = update_reg_ir;

  assign  id_sel  = (update_reg_ir == idcode_opcode_cnst);

   assign  bypass_int = ( update_reg_ir [0] & update_reg_ir [1] 
                         & update_reg_ir_temp_by );
  assign #1 capture_en_dr = (
   (sync_mode === 0 ) ? 1'b0 : (
   clock_dr ));


reg [15:0] next_tap_state;
 
  always @(tap_state or tms) begin : STATE_ENC_PROC
    integer i;
    reg [31:0] state_var_tmp;
    reg [31:0] state_var;

    if ((^(tap_state ^ tap_state) !== 1'b0)) begin : CHECK_FOR_XS
      next_tap_state = 16'bxxxx_xxxx_xxxx_xxxx;
    end else begin : NO_XS
      for (i = 15; i >= 0 ;i = i-1) begin 
        if (tap_state [i] === 1'b1)
          state_var_tmp = i;
      end
  
      if (tms === 1'b0) begin
        case (state_var_tmp)
          0 : state_var = 1;
          2 : state_var = 3;
          3 : state_var = 4;
          5 : state_var = 6;
          7 : state_var = 4;
          8 : state_var = 1;
          9 : state_var = 10;
          10 : state_var = 11;
          12 : state_var = 13;
          14 : state_var = 11;
          15 : state_var = 1;
          default: state_var = state_var_tmp;
        endcase
      end else begin 
        case (state_var_tmp)
          1 : state_var = 2;
          2 : state_var = 9;
          3 : state_var = 5;
          4 : state_var = 5;
          5 : state_var = 8;
          6 : state_var = 7;
          7 : state_var = 8;
          8 : state_var = 2;
          9 : state_var = 0;
          10 : state_var = 12;
          11 : state_var = 12;
          12 : state_var = 15;
          13 : state_var = 14;
          14 : state_var = 15;
          15 : state_var = 2;
          default: state_var = state_var_tmp;
        endcase
      end 
      for (i = 15; i >= 0; i = i-1) begin
        if (state_var == i) next_tap_state[i] = 1'b1;
        else next_tap_state[i] = 1'b0;
      end
    end
  end

  always @ (posedge tck or negedge trst_n) begin : TCK_REGS_PROC
      integer i;

      if (trst_n === 1'b0) begin 
          tap_state  <=  1;
      end else begin
          tap_state <= next_tap_state;
      end
  end

reg nxt_fsm_rst;
reg nxt_shift_dr;
reg nxt_shift_ir;

  always @(tap_state) begin : NXT_FSM_RST_SHIFTS_PROC
    integer i;
    reg [31:0] state_decode;

    if ((^(tap_state ^ tap_state) !== 1'b0)) begin
      nxt_fsm_rst = 1'bx;
      nxt_shift_dr = 1'bx;
      nxt_shift_ir = 1'bx;
    end else begin
      for (i = 15; i >= 0 ; i = i-1) begin 
        if (tap_state [i] === 1'b1) state_decode  = i;
      end
      
      case (state_decode)
        0 : begin
              nxt_fsm_rst = 1'b1;
              nxt_shift_dr = 1'b0;
              nxt_shift_ir = 1'b0;
              end
        4 : begin
              nxt_fsm_rst = 1'b0;
              nxt_shift_dr = 1'b1;
              nxt_shift_ir = 1'b0;
              end
        11 : begin
              nxt_fsm_rst = 1'b0;
              nxt_shift_dr = 1'b0;
              nxt_shift_ir = 1'b1;
              end
        default: begin
              nxt_fsm_rst = 1'b0;
              nxt_shift_dr = 1'b0;
              nxt_shift_ir = 1'b0;
              end
      endcase
    end
  end
 
  always @ (posedge tck_n or negedge trst_n) begin : TCK_N_REGS_PROC
      integer i;

      if (trst_n === 1'b0) begin 
        fsm_rst <= 1;
        shift_dr <= 0;
        shift_ir <= 0;
      end else begin
        fsm_rst <= nxt_fsm_rst;
        shift_dr <= nxt_shift_dr;
        shift_ir <= nxt_shift_ir;
      end
  end

 
  always @ (capture_reg_dr_msb) begin 
    capture_reg_dr[32] = capture_reg_dr_msb;
  end
 
  always @ (capture_reg_ir_msb) begin 
    capture_reg_ir [width] = capture_reg_ir_msb;
  end

  assign capture_dr = tap_state [3];

wire update_en_ir;
  assign update_en_ir = (sync_mode == 0) ? 1'b1 : (tap_state [15] & tck_n);
  
reg[(width  -  1 ): 0] data_in_ir;
  always @(sentinel_val) begin : DATA_IN_IR_PROC
    integer i;
    for (i = (width-1); i >= 0 ; i = i-1) begin 
      if ( i > 1 ) begin 
        data_in_ir[i] = sentinel_val[(i-2)];
      end else begin
        data_in_ir[1] = 1'b0;
        data_in_ir[0] = 1'b1;
      end
    end
  end

generate
  if (sync_mode == 0) begin : GEN_REGS_SM_EQ_0
    integer i;
    always @(posedge clock_dr) begin : BYP_SO_CAP_DR_SM_EQ_0_PROC
      if (capture_dr === 1'b0) begin 
        bypass_so <= data_in_int;
      end else begin
        if (capture_dr === 1'b1)
          bypass_so <= 1'b0;
      end
      capture_reg_dr [32] <= capture_reg_dr_msb;
      for (i = 31; i >= 0 ; i = i-1) begin
        if (shift_dr == 1'b0) begin
          capture_reg_dr[i] <= id_code_vec[i];
        end else begin
          capture_reg_dr[i] <= capture_reg_dr[(i+1)];
        end
      end
    end
    always @(posedge clock_ir) begin : CAP_REG_IR_SM_EQ_0_PROC0
      for (i = (width-1); i >= 0 ; i = i-1) begin 
        if (shift_ir === 1'b0) begin
          capture_reg_ir[i] <= data_in_ir[i];
        end else begin
          capture_reg_ir[i] <= capture_reg_ir[(i+1)];
        end
      end
    end
    always @(posedge update_ir or posedge instr_rst) begin : UPDATE_IR_REG_SM_EQ_0_PROC
      if (instr_rst == 1) begin
        if (id == 0) update_reg_ir <= {width{1'b1}};
        else update_reg_ir <= idcode_opcode_cnst;
      end else begin
        for (i = (width-1); i >= 0 ; i = i-1) begin
          if (update_en_ir == 1'b1) begin
            update_reg_ir[i] <= capture_reg_ir[i];
          end
        end
      end
    end
  end else begin : GEN_REGS_SM_NE_0
    integer i;
    always @(posedge tck) begin : REGS_SM_NE_0_PROC
      if (capture_dr == 1'b0) begin 
        if (capture_en_dr == 1'b0)
           bypass_so <= data_in_int;
      end else begin
        if (capture_dr == 1'b1)
          bypass_so <= 1'b0;
      end
      capture_reg_dr [32] <= capture_reg_dr_msb;
      for (i = 31; i >= 0 ; i = i-1) begin
        if ( capture_en_dr == 1'b0 ) begin
          if (shift_dr == 1'b0) begin
            capture_reg_dr[i] <= id_code_vec[i];
          end else begin
            capture_reg_dr[i] <= capture_reg_dr[(i+1)];
          end
        end
      end
      for (i = (width-1); i >= 0 ; i = i-1) begin 
        if (sync_capture_ir == 1'b0) begin
          if (shift_ir === 1'b0) begin
            capture_reg_ir[i] <= data_in_ir[i];
          end else begin
            capture_reg_ir[i] <= capture_reg_ir[(i+1)];
          end
        end
      end
    end
    always @(posedge tck_n or posedge instr_rst) begin : UPDATE_IR_REG_SM_NE_0_PROC
      if (instr_rst == 1) begin
        if (id == 0) update_reg_ir <= {width{1'b1}};
        else update_reg_ir <= idcode_opcode_cnst;
      end else begin
        for (i = (width-1); i >= 0 ; i = i-1) begin
          if ( update_en_ir === 1'b1 ) begin
            update_reg_ir[i] <= capture_reg_ir[i];
          end
        end
      end
    end
  end
endgenerate
 
  always @ (bypass_sel or bypass_int or id_so or device_id_sel or
            so or bypass_so or id_sel or tap_state)
    begin : tdo_combo1_proc
      if  ( (bypass_sel === 1'b1) | (bypass_int === 1'b1) )
        begin
          tdo_temp = bypass_so;
        end
      else if ((id ===  1) & ((device_id_sel === 1'b1) |
                              (id_sel === 1'b1) | (tap_state [0] === 1'b1) ))
        begin
          tdo_temp = id_so;
        end
      else
        begin
          tdo_temp = so;
        end
    end
  always @ (update_reg_ir)
    begin : instr_decode1_proc
      reg update_reg_ir_temp_n_var;
      reg update_reg_ir_temp_var;
      reg update_reg_ir_temp_by_var;
      update_reg_ir_temp_n_var = update_reg_ir [(width - 1)];
      update_reg_ir_temp_var = update_reg_ir [(width - 1)];
      update_reg_ir_temp_by_var = update_reg_ir [(width - 1)];

      if ( width > 2 )
        begin 
          begin : for_651
            integer i;
            for (i = (width-1); i >= 2; i = i-1)
              begin 
                update_reg_ir_temp_var = (update_reg_ir_temp_var 
                    | update_reg_ir [i]);
                update_reg_ir_temp_n_var = (update_reg_ir_temp_n_var 
                    | update_reg_ir [i]);
                update_reg_ir_temp_by_var = (update_reg_ir_temp_by_var
                    & update_reg_ir [i]);
              end
          end
        end
      else
        begin
          update_reg_ir_temp_var = (~update_reg_ir [1]);
        end 

      update_reg_ir_temp_n  = update_reg_ir_temp_n_var;
      update_reg_ir_temp  = update_reg_ir_temp_var;
      update_reg_ir_temp_by = update_reg_ir_temp_by_var;
    end 

  always @(posedge tck_n) begin : TDO_PROC
    if (tap_state [11] == 1'b0) tdo <= tdo_temp;
    else tdo <= instr_so;
  end
 
   // synopsys translate_on
 endmodule
