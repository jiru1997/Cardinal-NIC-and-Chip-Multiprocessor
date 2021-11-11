////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2007 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Bruce Dean May 22 2007     
//
// VERSION:   
//
// DesignWare_version: e988f9fc
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
//
//  ABSTRACT:  
//    This block performs a 2d discrete cosine transform using Chen's
//    factorization. The block performs 2 1d transforms, and writes to
//    an intermediate ram. Please see data sheet for more i/o detail.
//
//             Parameters:     Valid Values
//             ==========      ============
//             bpp             4 - 24	
//             n               4-16 even numbers
//             reg_out         0/1 register outputs
//             16            12-16 bits of 16icion of scaled coef
//             16_inc        0/1 limit progressive word size
//             tc_mode         0/1 input data type-0 is binary, 1 = two's complement
//             rt_mode        0-2 round/halfround/truncate:0= truncate 1=halfround 2=round
//             idct            0/1 forward or inverse dct applied to input data
//             mem_elem        internal/external transposition memory
//             plex_mode       simplex/duplex operation:
//             co_a            coeficient input
//
//             Input Ports:    Size           Description
//             ============    ======         =======================
//               clk           1              clock input
//               rst_n         1              asynchronous reset
//               init_n        1              synchronous reset
//               enable        1              enable: 0 stall processing
//               start         1              1 clock cycle high starts processing
//               dct_rd_data         bpp/bpt         read data input, pels or transform data
//               tp_rd_data      n+bpp          transform intermediate data
//
//             Output Ports    Size    Description
//             ============    ====== =======================
//               done          1              first data block read
//               ready         1              first transform available
//               dct_rd_add          bit width(n)   fetch data address out
//               tp_rd_add       bit width(n)   fetch transpose data address out
//               tp_wr_add       bit width(n)   write transpose data address out
//               tp_wr_n         1              transpose data write(not) signal
//               tp_wr_data      n+bpp          transpose intermediate data out
//               dct_wr_add          bit width(n)   write data out
//               dct_wr_n          1              final data write(not) signal
//               dct_wr_data          n/2+bpp        final transformed data out(dct or pels)
//
//  MODIFIED:
//           03/10/2016     LMSU    Removed unused intial blocks to be compatible with NLP
//
//           jbd original simulation model 0707
//
module DW_dct_2d(clk,rst_n,init_n,enable,start,dct_rd_data, tp_rd_data, 
		    done,ready,dct_rd_add,tp_rd_add,tp_wr_add,tp_wr_n,tp_wr_data,dct_wr_add,dct_wr_n,dct_wr_data);
  parameter bpp = 8;
  parameter n   = 8;
  parameter reg_out = 0;
  parameter tc_mode = 0;
  parameter rt_mode = 0;
  parameter idct_mode = 0;
  parameter co_a = 23170 ;
  parameter co_b = 32138 ;
  parameter co_c = 30274 ;
  parameter co_d = 27245 ;
  parameter co_e = 18205 ;
  parameter co_f = 12541 ;
  parameter co_g = 6393  ;
  parameter co_h = 35355 ;
  parameter co_i = 49039 ;
  parameter co_j = 46194 ;
  parameter co_k = 41573 ;
  parameter co_l = 27779 ;
  parameter co_m = 19134 ;
  parameter co_n = 9755  ;
  parameter co_o = 35355 ;
  parameter co_p = 49039 ;

 `define DW_nwidth ((n>16)?((n>64)?((n>128)?8:7):((n>32)?6:5)):((n>4)?((n>8)?4:3):((n>2)?2:1)))
 `define DW_addwidth ((n*n>16)?((n*n>64)?((n*n>128)?8:7):((n*n>32)?6:5)):((n*n>4)?((n*n>8)?4:3):((n*n>2)?2:1)))
 `define DW_rddatsz ((idct_mode == 1) ? (n/2+bpp) : bpp) 
 `define DW_fnldat  ((idct_mode == 1) ? bpp: (n/2+bpp))
 `define DW_idatsz (bpp/2+bpp+4  + ((1-tc_mode)*(1-idct_mode)))
  input clk,rst_n,init_n,enable,start;
  input  [((`DW_rddatsz))-1:0] dct_rd_data;
  input  [(`DW_idatsz)-1:0] tp_rd_data;
  output done,ready;
  output [`DW_addwidth-1:0] dct_rd_add,tp_rd_add,tp_wr_add;
  output tp_wr_n,dct_wr_n;
  output  [(`DW_idatsz)-1:0] tp_wr_data;
  output [`DW_addwidth-1:0] dct_wr_add;
  output [(`DW_fnldat)-1:0] dct_wr_data;
// synopsys_translate_off
 `define DW_fwrdsz (tc_mode ? bpp:(bpp+1))
 `define DW_frstadr ((idct_mode == 1) ? (bpp/2+bpp+1) : ((`DW_fwrdsz) +1))
 `define DW_frstprod (((`DW_frstadr) + 17))
 `define DW_frstsum  (`DW_frstprod + bpp/2-1)
 `define DW_product1 (((`DW_idatsz)) + 16)

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
      
    if ( (n < 4) || (n > 16) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter n (legal range: 4 to 16)",
	n );
    end
      
    if ( (bpp < 4) || (bpp > 32) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter bpp (legal range: 4 to 32)",
	bpp );
    end
      
    if ( (reg_out < 0) || (reg_out > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_out (legal range: 0 to 1)",
	reg_out );
    end
      
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end
      
    if ( (rt_mode < 0) || (rt_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rt_mode (legal range: 0 to 1)",
	rt_mode );
    end
      
    if ( (idct_mode < 0) || (idct_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter idct_mode (legal range: 0 to 1)",
	idct_mode );
    end
      
    if ( (co_a < 0) || (co_a > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_a (legal range: 0 to 65535)",
	co_a );
    end
      
    if ( (co_b < 0) || (co_b > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_b (legal range: 0 to 65535)",
	co_b );
    end
      
    if ( (co_c < 0) || (co_c > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_c (legal range: 0 to 65535)",
	co_c );
    end
      
    if ( (co_d < 0) || (co_d > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_d (legal range: 0 to 65535)",
	co_d );
    end
      
    if ( (co_e < 0) || (co_e > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_e (legal range: 0 to 65535)",
	co_e );
    end
      
    if ( (co_f < 0) || (co_f > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_f (legal range: 0 to 65535)",
	co_f );
    end
      
    if ( (co_g < 0) || (co_g > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_g (legal range: 0 to 65535)",
	co_g );
    end
      
    if ( (co_h < 0) || (co_h > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_h (legal range: 0 to 65535)",
	co_h );
    end
      
    if ( (co_i < 0) || (co_i > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_i (legal range: 0 to 65535)",
	co_i );
    end
      
    if ( (co_j < 0) || (co_j > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_j (legal range: 0 to 65535)",
	co_j );
    end
      
    if ( (co_k < 0) || (co_k > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_k (legal range: 0 to 65535)",
	co_k );
    end
      
    if ( (co_l < 0) || (co_l > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_l (legal range: 0 to 65535)",
	co_l );
    end
      
    if ( (co_m < 0) || (co_m > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_m (legal range: 0 to 65535)",
	co_m );
    end
      
    if ( (co_n < 0) || (co_n > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_n (legal range: 0 to 65535)",
	co_n );
    end
      
    if ( (co_o < 0) || (co_o > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_o (legal range: 0 to 65535)",
	co_o );
    end
      
    if ( (co_p < 0) || (co_p > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter co_p (legal range: 0 to 65535)",
	co_p );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  //-------------------------------------------------------------------------

  
  reg  [`DW_nwidth-1:0] coef_add_int;
  wire [`DW_nwidth-1:0] coef_add_nxt;
  wire               coef_add_rst;  
  reg  [n:0]    rnsc_int;
  wire          rnsx;  
  wire          rnsc;  
  wire          ready_nxt;
  reg           ready_int;
  reg  [(n*((`DW_rddatsz)))-1:0]  rx0;
  reg  [(n*((`DW_rddatsz)))-1:0]  rx1;
  wire [((n+1)*16)-1:0]          coefi_parms;

  reg  [`DW_addwidth-1:0] runstate;
  wire [`DW_addwidth-1:0] runnxt;
  wire [`DW_nwidth-1:0]   rd_add_rwcnt;
  wire [`DW_nwidth-1:0]   rd_add_clcnt;
  reg  [`DW_nwidth-1:0]   rd_add_rwcnt_int;
  reg  [`DW_nwidth-1:0]   rd_add_clcnt_int;
  wire [`DW_addwidth-1:0] rd_add_nxt;
  reg                  rn_mode;
  wire                 rn_rst;
  wire                 rn_nxt;
  wire                 rn_xfr;
  
  wire                 done_nxt;
  reg                  done_int;
  reg                  rd_mode;
  wire                 rd_mode_rst;
  wire                 int_rst;
  
  assign rn_nxt = enable && rn_mode;
  assign rn_rst = (!start && (runstate === n*n-1));
  assign runnxt  = rn_rst || (runstate === n*n-1) ? 0 : (rn_nxt || start ? runstate + 1:runstate);

  assign rn_xfr = runstate%n == 1 && rn_mode;
  assign rnsx  = rnsc_int[n-2];
  assign rnsc  = rnsc_int[n-1];
  assign coefi_parms = get_params(n);
  assign done_nxt = runstate === n*n-1;
  assign rd_mode_rst = runstate === n*n-1;
  assign int_rst = start && runstate != 0;
  
  assign rd_add_clcnt =  start || rd_add_clcnt_int == n-1 ? 0 : rn_nxt ? rd_add_clcnt_int+1 : rd_add_clcnt_int;
  assign rd_add_rwcnt = start || (rd_add_rwcnt_int == n-1 && rd_add_clcnt_int == n-1) ? 0 :
                        ( rn_nxt && rd_add_clcnt_int == n-1 )? rd_add_rwcnt_int+1: rd_add_rwcnt_int;
  assign rd_add_nxt = idct_mode ? rd_add_clcnt * n + rd_add_rwcnt : runstate;
  
  
  reg   [`DW_addwidth-1:0] tp_wr_state;
  wire  [`DW_addwidth-1:0] tp_wr_stnxt;
  wire  [`DW_addwidth-1:0] tp_wr_add_wire;
  reg                   tp_wr_mode;
  wire                  tp_wr_start;
  reg   [n:0]           tp_state_pipe;
  wire                  tp_wr_run;
  wire                  tp_wr_rst_mode;
  wire                  tp_wr_rst_en;
  wire                  tp_wr_rst;
  assign tp_wr_run       = tp_wr_mode && enable;
  assign tp_wr_start     = rnsc_int[n-2];//runstate%n === 1 || start;// early start resets write mode
  assign tp_wr_rst_en    = tp_wr_state == n*(n -1);
  assign tp_wr_rst_mode  = tp_wr_rst_en || int_rst;//! tp_wr_start;
  assign tp_wr_rst = (int_rst || tp_wr_rst_en);// || start;

  assign tp_wr_stnxt     = tp_wr_rst ? 0 : tp_wr_run ? tp_wr_state +n:tp_wr_state;

  reg   [`DW_nwidth-1:0] tp_wr_col;
  reg   [n:0]         tp_col_pipe;
  wire  [`DW_nwidth-1:0] tp_wr_colnxt;
  wire   tp_wr_col_rst;
  assign tp_wr_col_rst   = (int_rst || tp_wr_col == n-1) && tp_wr_rst_en;
  assign tp_wr_colnxt    = tp_wr_col_rst ? 0: tp_state_pipe[n-1] ? tp_wr_col + 1 : tp_wr_col;
  assign tp_wr_add_wire       = tp_wr_col + tp_wr_state;

  assign coef_add_rst = (coef_add_int == n-1);
  assign coef_add_nxt = coef_add_rst  ? 0 :  (tp_wr_run  ? coef_add_int + 1:coef_add_int);

  reg  signed [(`DW_frstprod):0] idat_sum;
  wire        [(`DW_idatsz)-1:0] ytrnc;
  wire        [(`DW_idatsz)-1:0] yrnd;
  wire        [(`DW_idatsz)+4:0] yrnd_wire;
  wire        [(`DW_frstprod):0] rndnum;

  assign rndnum = 1'b1 << ((`DW_frstprod)-(`DW_idatsz));
  assign yrnd_wire = $signed((idat_sum>>>4)+5);//[`DW_frstprod:(`DW_frstprod)-(`DW_idatsz)-4]+5);
  assign ytrnc     = $signed(idat_sum>>>16);
  //$signed(idat_sum[`DW_idatsz+11:15]);
  //$signed(idat_sum[`DW_frstprod:(`DW_frstprod)-(`DW_idatsz)]);
  assign yrnd      = idat_sum >>> 16;//$signed(yrnd_wire>>10);//[(`DW_idatsz)+4:0]);

  reg  [n:0]         tp_rd_pipe;
  wire [`DW_addwidth-1:0] tp_rd_add_wire;
  reg  [`DW_addwidth-1:0] tp_rd_state;
  wire [`DW_addwidth-1:0] tp_rd_statenxt;
  wire               tp_rd_run;
  reg                tp_rd_mode;
  wire               tp_rd_start;
  wire               tp_rd_rst_mode;
  wire               tp_rd_update;
  reg                tp_rd_hi;
  wire               tp_rd_hi_nxt;
  
  assign tp_rd_start    = tp_wr_add_wire == 2*n + n-2 ;
  assign tp_rd_run      = enable && tp_rd_mode;//(tp_rd_mode || tp_rd_start);
  assign tp_rd_rst_mode = tp_rd_hi_nxt ? int_rst || tp_rd_state == 2*n*n-1: int_rst || tp_rd_state == n*n-1;
  assign tp_rd_statenxt = tp_rd_rst_mode ? 0 : tp_rd_run  ? tp_rd_state +1:tp_rd_state;
  assign tp_rd_add_wire      = tp_rd_run ? tp_rd_state:0;
  assign tp_rd_update   = tp_rd_add_wire%n == 2;
  assign tp_rd_hi_nxt   = start ? tp_rd_run : tp_rd_hi;
  
  wire [`DW_nwidth-1:0] tp_rd_coef_nxt;
  reg                tp_rd_coef_tgl;
  wire               tp_rd_coef_tgl_nxt;
  wire               tp_rd_coef_start;
  reg                tp_rd_coef_mode;
  reg  [`DW_nwidth-1:0] tp_rd_coef_int;
  wire               tp_rd_coef_rst;
  wire               tp_rd_coef_run;
  reg [n:0]          tp_rd_coef_pipe;
  
  assign tp_rd_coef_start = tp_rd_state%n==1;
  assign tp_rd_coef_run   = enable && tp_rd_coef_mode;
  assign tp_rd_coef_rst   = int_rst || tp_rd_coef_int == n-1;
  assign tp_rd_coef_nxt   = tp_rd_coef_rst ? 0:tp_rd_coef_run ? tp_rd_coef_int +1:tp_rd_coef_int;
  assign tp_rd_coef_tgl_nxt = tp_rd_coef_run ? !tp_rd_coef_tgl : 0;

  reg  [n/2*15:0]   coefnxt_int;
  reg  [(n*((`DW_idatsz)))-1:0] dct_wr_data0 ;
  reg  [(n*((`DW_idatsz)))-1:0] dct_wr_data1 ;
 
  reg  [n:0]           wr_pipe;
  reg  [`DW_addwidth-1:0] wr_state_int;
  reg  [`DW_addwidth-1:0] wr_state_out;
  wire [`DW_addwidth-1:0] wr_state_nxt;
  wire [`DW_nwidth-1:0]   wr_add_rwcnt;
  wire [`DW_nwidth-1:0]   wr_add_clcnt;
  reg  [`DW_nwidth-1:0]   wr_add_rwcnt_int;
  reg  [`DW_nwidth-1:0]   wr_add_clcnt_int;
  reg  [`DW_addwidth-1:0] wr_add_int;
  wire [`DW_addwidth-1:0] wr_add_nxt;
  reg                  wr_mode;
  reg                  wr_run_int;
  wire                 wr_rst;
  wire                 wr_dct_wr_n;
  reg                  wr_dct_wr_n_int;
  wire                 wr_mode_rst;
  wire                 wr_run;
  wire                 wr_start;
  
  assign wr_start    = tp_rd_add_wire == n;// +1;
  assign wr_run      = enable && wr_mode;
  assign wr_state_nxt = wr_mode_rst ? 0 : wr_run ? wr_state_int +1 : wr_state_int;
  assign wr_rst = (!int_rst && (wr_state_int === n*n-1));
  assign wr_dct_wr_n = (wr_run ) && !(wr_state_int === n*n-1);

  assign wr_mode_rst = int_rst || wr_state_int === n*n-1;
  
  assign wr_add_clcnt =  int_rst || wr_add_clcnt_int == n-1 ? 0 
                            : wr_run ? wr_add_clcnt_int + 1 : wr_add_clcnt_int;
  assign wr_add_rwcnt = int_rst || (wr_add_rwcnt_int == n-1 && wr_add_clcnt_int == n-1) ? 0 :
                        ( wr_run && wr_add_clcnt_int == n-1 )? wr_add_rwcnt_int+1: wr_add_rwcnt_int;
  assign wr_add_nxt = idct_mode == 0 ? wr_add_clcnt_int * n + wr_add_rwcnt_int : wr_state_int;
  
  reg  signed [(`DW_product1)-1:0] fnl_datsum;
  reg  signed [(`DW_fnldat)-1:0] ydctsave_int;
  wire signed [(`DW_fnldat)-1:0] ydctrnd;
  wire signed [(`DW_fnldat)-1:0] ydcttrnc;
  wire signed [(`DW_fnldat)+2:0] ydcthld;
  wire signed [(`DW_fnldat)-1:0] ydctsave;
  wire signed [(`DW_fnldat)+2:0] ydctrnd_wire;
  wire signed [(`DW_product1)-1:0] fnl_rnd;

  assign fnl_rnd = 1'b1 << ((`DW_product1)-(`DW_fnldat)-1)-((bpp-1)*idct_mode);
  //assign fnl_rnd = idct_mode ? 1'b1 << 16: 1'b1 << bpp/2+15;
  //assign fnl_rnd = idct_mode ? 1'b1 << 16: 1'b1 << halfn+15;
  assign ydcthld = fnl_datsum[(`DW_product1)-1:(`DW_product1)-(`DW_fnldat)-2];
  assign ydctrnd_wire = fnl_datsum[(`DW_product1)-1] ? $signed((ydcthld-fnl_rnd)): $signed((ydcthld+fnl_rnd));
  assign ydcttrnc = idct_mode ?  $signed(fnl_datsum>>>17)
                   :$signed(fnl_datsum[(`DW_product1)-1:(`DW_product1)-(`DW_fnldat)]);// >> 16;
  assign ydctrnd  = idct_mode ? ydctrnd_wire>>> 16:ydctrnd_wire>>>2;//$signed(ydctrnd_wire[(`DW_fnldat):1]);
  assign ydctsave = ydcttrnc; //rt_mode == 0 ? ydcttrnc:ydctrnd; 
  assign ready_nxt = wr_state_nxt == 1;//dct_wr_n == 0 && wr_state_nxt == 1;

  always @ (posedge clk or negedge rst_n) begin : STATE_SEQ_PROC
    if(rst_n == 1'b0) begin
      ready_int <= 0;
      rx0      <=  0;
      coef_add_int  <=  0;
      runstate <= 0;
      rn_mode  <= 0;
      rx1      <= 0;
      rnsc_int     <= 0;
      rd_mode     <= 0;
      rd_add_rwcnt_int <= 0;
      rd_add_clcnt_int <= 0;
      tp_wr_mode  <= 0;
      tp_wr_state <= 0;
      tp_state_pipe <= 0;
      tp_col_pipe <= 0;
      tp_wr_col <= 0;
      tp_rd_mode <= 0;
      tp_rd_state <= 0;
      tp_rd_pipe <= 0;
      tp_rd_coef_int <= 0;
      tp_rd_coef_mode <= 0;
      tp_rd_coef_pipe <= 0;
      tp_rd_coef_tgl <= 0;
      tp_rd_hi  <= 0;    
      wr_mode     <= 0;
      wr_run_int     <= 0;
      wr_pipe     <= 0;
      wr_state_int    <= 0;
      wr_state_out    <= 0;
      wr_add_int <= 0;
      wr_add_clcnt_int <= 0;
      wr_add_rwcnt_int <= 0;
      wr_dct_wr_n_int <= 0;
      done_int    <= 0;
      dct_wr_data0       <= 0;
      dct_wr_data1       <= 0;
      coefnxt_int <= 0;
      ydctsave_int <= 0;
    end else if(rst_n == 1) begin
      if(init_n == 0) begin
        ready_int <= 0;
        rx0      <=  0;
        coef_add_int  <=  0;
        runstate <= 0;
        rn_mode  <= 0;
        rx1      <= 0;
        rnsc_int     <= 0;
        rd_mode     <= 0;
        rd_add_rwcnt_int <= 0;
        rd_add_clcnt_int <= 0;
        tp_wr_mode  <= 0;
        tp_wr_state <= 0;
        tp_state_pipe <= 0;
        tp_col_pipe <= 0;
        tp_wr_col <= 0;
        tp_rd_mode <= 0;
        tp_rd_state <= 0;
        tp_rd_pipe <= 0;
        tp_rd_coef_int <= 0;
        tp_rd_coef_mode <= 0;
        tp_rd_coef_pipe <= 0;
        tp_rd_coef_tgl <= 0;
        tp_rd_hi  <= 0;    
        wr_mode     <= 0;
        wr_run_int     <= 0;
        wr_pipe     <= 0;
        wr_state_int    <= 0;
        wr_state_out    <= 0;
        wr_add_int <= 0;
        wr_add_clcnt_int <= 0;
        wr_add_rwcnt_int <= 0;
        wr_dct_wr_n_int <= 0;
        done_int    <= 0;
        dct_wr_data0       <= 0;
        dct_wr_data1       <= 0;
        coefnxt_int <= 0;
        ydctsave_int <= 0;
      end else if(init_n == 1) begin
        ready_int <= ready_nxt;
        rnsc_int     <= {rnsc_int[n-1:0],rn_xfr};
        done_int     <= done_nxt;
        tp_wr_state  <= tp_wr_stnxt;
        tp_state_pipe <= {tp_state_pipe[n-1:0],tp_wr_start};
        tp_col_pipe   <= {tp_col_pipe[n-1:0],tp_wr_col_rst};
        tp_wr_col <= tp_wr_colnxt;
        tp_rd_state <= tp_rd_statenxt;
        coef_add_int <= coef_add_nxt;
        tp_rd_pipe <= {tp_rd_pipe[n-1:0],tp_rd_update};
        tp_rd_coef_int <= tp_rd_coef_nxt;
        tp_rd_coef_pipe <= {tp_rd_coef_pipe[n-1:0],tp_rd_coef_start};
        tp_rd_coef_tgl  <= tp_rd_coef_tgl_nxt;
        tp_rd_hi  <= tp_rd_hi_nxt;    
        wr_pipe <= {wr_pipe[n-1:0],wr_run};
        wr_state_int <= wr_state_nxt;
        ydctsave_int <= ydctsave;
        rd_add_rwcnt_int <= rd_add_rwcnt;
        rd_add_clcnt_int <= rd_add_clcnt;
        wr_add_clcnt_int <= wr_add_clcnt;
        wr_add_rwcnt_int <= wr_add_rwcnt;
        wr_add_int <= wr_add_nxt;
        wr_run_int     <= wr_run;
        wr_state_out    <= wr_state_int;
        wr_dct_wr_n_int <= wr_dct_wr_n;
        if(rn_mode || start) begin
          rx0       <= {rx0[(n*(((`DW_rddatsz))))-((`DW_rddatsz))-1:0],dct_rd_data};
  	runstate  <= runnxt;
        end 
        if(rnsx) begin
          rx1 <= rx0;
        end
        if(start) begin
          rd_mode <= 1'b1;
        end else if(rd_mode_rst) begin
          rd_mode <= 1'b0;
        end
        if(start) begin
          rn_mode <= 1'b1;
        end else if(rn_rst) begin
          rn_mode <= 1'b0;
        end
        if(tp_wr_start) begin
          tp_wr_mode <= 1'b1;
        end else if(tp_wr_rst) begin
          tp_wr_mode <= 1'b0;
        end
        if(tp_rd_start) begin
          tp_rd_mode <= 1'b1;
        end else if(tp_rd_rst_mode) begin
          tp_rd_mode <= 1'b0;
        end
        if(tp_rd_mode) begin
          dct_wr_data0 <= {dct_wr_data0[(n*((`DW_idatsz))) - ((`DW_idatsz))-1:0],tp_rd_data};
        end
        if(tp_rd_coef_pipe[n-2])
  	dct_wr_data1           <= dct_wr_data0;
        if(tp_rd_coef_pipe[n-1])begin
          tp_rd_coef_mode <= 1;
        end else if (tp_rd_coef_rst) begin
          tp_rd_coef_mode <= 0;
        end
        if(wr_start) begin
          wr_mode    <= 1;
        end else if(wr_mode_rst) begin
          wr_mode    <= 0;
        end
      end else begin
        ready_int <= 'bx;
        rx0      <=  'bx;
        coef_add_int  <=  'bx;
        runstate <= 'bx;
        rn_mode  <= 'bx;
        rx1      <= 'bx;
        rnsc_int     <= 'bx;
        rd_mode     <= 'bx;
        rd_add_rwcnt_int <= 'bx;
        rd_add_clcnt_int <= 'bx;
        tp_wr_mode  <= 'bx;
        tp_wr_state <= 'bx;
        tp_state_pipe <= 'bx;
        tp_col_pipe <= 'bx;
        tp_wr_col <= 'bx;
        tp_rd_mode <= 'bx;
        tp_rd_state <= 'bx;
        tp_rd_pipe <= 'bx;
        tp_rd_coef_int <= 'bx;
        tp_rd_coef_mode <= 'bx;
        tp_rd_coef_pipe <= 'bx;
        tp_rd_coef_tgl <= 'bx;
        tp_rd_hi  <= 'bx;    
        wr_mode     <= 'bx;
        wr_run_int     <= 'bx;
        wr_pipe     <= 'bx;
        wr_state_int    <= 'bx;
        wr_state_out    <= 'bx;
        wr_add_int <= 'bx;
        wr_add_clcnt_int <= 'bx;
        wr_add_rwcnt_int <= 'bx;
        wr_dct_wr_n_int <= 'bx;
        done_int    <= 'bx;
        dct_wr_data0       <= 'bx;
        dct_wr_data1       <= 'bx;
        coefnxt_int <= 'bx;
        ydctsave_int <= 'bx;
      end
    end else begin
      ready_int <= 'bx;
      rx0      <=  'bx;
      coef_add_int  <=  'bx;
      runstate <= 'bx;
      rn_mode  <= 'bx;
      rx1      <= 'bx;
      rnsc_int     <= 'bx;
      rd_mode	  <= 'bx;
      rd_add_rwcnt_int <= 'bx;
      rd_add_clcnt_int <= 'bx;
      tp_wr_mode  <= 'bx;
      tp_wr_state <= 'bx;
      tp_state_pipe <= 'bx;
      tp_col_pipe <= 'bx;
      tp_wr_col <= 'bx;
      tp_rd_mode <= 'bx;
      tp_rd_state <= 'bx;
      tp_rd_pipe <= 'bx;
      tp_rd_coef_int <= 'bx;
      tp_rd_coef_mode <= 'bx;
      tp_rd_coef_pipe <= 'bx;
      tp_rd_coef_tgl <= 'bx;
      tp_rd_hi  <= 'bx;    
      wr_mode	  <= 'bx;
      wr_run_int     <= 'bx;
      wr_pipe	  <= 'bx;
      wr_state_int    <= 'bx;
      wr_state_out    <= 'bx;
      wr_add_int <= 'bx;
      wr_add_clcnt_int <= 'bx;
      wr_add_rwcnt_int <= 'bx;
      wr_dct_wr_n_int <= 'bx;
      done_int    <= 'bx;
      dct_wr_data0	  <= 'bx;
      dct_wr_data1	  <= 'bx;
      coefnxt_int <= 'bx;
      ydctsave_int <= 'bx;
    end
  end

  always@(rx1 or coef_add_int or rd_mode or tp_wr_mode) begin : calc_1st_dct_PROC
    integer i,j,k;
    reg [(n+1)*16-1:0] coefin;
    reg [(`DW_frstadr)-1:0]        temp_data;
    reg [(n*(`DW_rddatsz))-1:0]    temp_dct_rd_data;
    reg signed [(`DW_frstadr)-1:0] temp_ddata;
    reg [15:0]                  temp_coef;
    reg signed [(`DW_frstprod)-1:0] temp_prod;
    reg signed [(`DW_frstprod)-1:0] temp_ppy;
    reg sign;
    temp_dct_rd_data = rx1;
    temp_data = 0;
    if(idct_mode == 1)
      coefin = scalepcoef(coef_add_int);
    else 
      coefin = scalecoef(coef_add_int);
    if(rd_mode || tp_wr_mode)begin
    temp_ppy = 0;
    for(i=0;i<n;i=i+1) begin
      if(idct_mode == 0) begin
        if(tc_mode == 0)
          temp_data[((`DW_rddatsz))-1:0] = $signed(temp_dct_rd_data[((`DW_rddatsz))-1:0]);
        else
          temp_data  = $signed(temp_dct_rd_data[((`DW_rddatsz))-1:0]);
      end else begin
          temp_data  = $signed(temp_dct_rd_data[((`DW_rddatsz))-1:0]);
      end
      temp_dct_rd_data = temp_dct_rd_data >> ((`DW_rddatsz));
      temp_coef = coefin[15:0];
      coefin = coefin >> 16;
      temp_prod = $signed(temp_coef) * $signed(temp_data);
      temp_ppy = temp_ppy + temp_prod;
    end
    if(temp_ppy[`DW_frstprod-1] == 0)
      temp_ppy = temp_ppy + rndnum;
    else
      temp_ppy = temp_ppy - rndnum;//~((~(temp_ppy-1) + rndnum)+1);
   idat_sum = temp_ppy;
   end else
     idat_sum = 0;
  end
  

  always@(dct_wr_data1 or wr_add_clcnt_int or tp_rd_mode or wr_mode) begin : calc_2nd_dct_PROC
    integer i,j,k;
    reg [(n+1)*16-1:0] coefin;
    reg [(`DW_idatsz)-1:0] temp_data;
    reg [(`DW_idatsz)-1:0] temp_ddata;
    reg signed [(`DW_idatsz)-1:0] temp_prod;
    reg [(n*((`DW_idatsz)))-1:0] temp_dct_rd_data;
    reg [15:0]    temp_coef;
    reg signed [(`DW_product1)-1:0] temp_ppy;
    reg signed [(`DW_product1)-1:0] temp_sum;
    temp_ppy = 0;
    temp_dct_rd_data = dct_wr_data1;
    if(idct_mode == 1)
      coefin = scalepcoef(wr_add_clcnt_int);
    else
      coefin = scalecoef(wr_add_clcnt_int);//coef_int[coef_add_int];
    if(wr_mode || tp_rd_mode) begin
    for(i=0;i<n;i=i+1) begin
      temp_data  = $signed(temp_dct_rd_data[(`DW_idatsz)-1:0]);
      temp_dct_rd_data = temp_dct_rd_data >> (`DW_idatsz);
      temp_coef = coefin[15:0];
      coefin = coefin >> 16;
      temp_ppy = temp_ppy + $signed(temp_coef) * $signed(temp_data);
    end
    if(rt_mode == 1'b0)
      if(temp_ppy[`DW_product1-1] == 0) begin
        temp_ppy = temp_ppy +fnl_rnd;
      end else begin
        temp_ppy = temp_ppy -fnl_rnd;//~((~(temp_ppy-1) + fnl_rnd)+1);
      end
      fnl_datsum = temp_ppy;
    end else
      fnl_datsum = 0;//temp_ppy;
  end
  

// port assigns
  assign done  = reg_out ? done_int  : done_nxt;
  assign ready = reg_out ? ready_int : ready_nxt;
  assign dct_rd_add  = rd_add_nxt;
  assign tp_wr_add  = tp_wr_add_wire;
  assign tp_wr_data = idat_sum[`DW_frstprod:(`DW_frstprod-(`DW_idatsz))+1];//(1-tc_mode)];
  assign tp_rd_add  = tp_rd_add_wire;
  assign tp_wr_n    = !tp_wr_run;
  assign dct_wr_n  = reg_out ? !wr_run_int:!wr_run;
  assign dct_wr_add  = reg_out ? wr_add_int:wr_add_nxt;//cadd_int;
  assign dct_wr_data  = reg_out ? ydctsave_int:ydctsave;
  
// Functions follow

function [(n+1)*16 - 1:0]scalecoef;
input[4:0] linenum;
integer cnt,ploop,cindx;
reg [n*4-1:0]  csel;
reg [(n+1)*16-1:0]  tempcoef;
reg [n-1:0]    signsel;
reg [15:0] tcoef;
reg [15:0] bcoef;
reg [16:0] coefin;
reg [3:0]      indx;
reg            tsign;
integer        scalein;
integer        convfac;
begin
  csel = coefsel(linenum);
  signsel = signbit(linenum);
  scalecoef = 0;
  tempcoef  = 0;
  for ( cnt = 0; cnt <= n; cnt = cnt + 1) begin
    indx = csel[3:0];
    csel = csel >> 4;
    for(ploop = 0; ploop < 16; ploop = ploop +1) begin
      cindx = 16 * indx + ploop;
      tcoef[ploop] = coefi_parms[cindx];
    end
      tsign = signsel[cnt];
      if(tsign == 1)
        bcoef = ~tcoef+1;
      else
        bcoef = tcoef;
	
        coefin  = bcoef;//{tsign,bcoef[15:0]};
    tempcoef = {coefin,tempcoef[(n+1)*16-1:16]};
  end // cnt looped n times
  scalecoef = tempcoef;
end
endfunction


function [n-1:0]signbit;
  input [n-1:0] linenum;
begin
  case(n)
    4 : begin
      case (linenum) 
          0 : signbit = 4'b0000;
          1 : signbit = 4'b0011;
          2 : signbit = 4'b0110;
          3 : signbit = 4'b0101;
        endcase
      end
    6 : begin
      case (linenum) 
          0 : signbit = 6'b000000;
          1 : signbit = 6'b000111;
          2 : signbit = 6'b001100;
          3 : signbit = 6'b011001;
          4 : signbit = 6'b010010;
          5 : signbit = 6'b010101;
        endcase
      end
    8 : begin
      case (linenum) 
          0 : signbit = 8'b00000000;
          1 : signbit = 8'b00001111;
          2 : signbit = 8'b00111100;
          3 : signbit = 8'b01110001;
          4 : signbit = 8'b01100110;
          5 : signbit = 8'b01001101;
          6 : signbit = 8'b01011010;
          7 : signbit = 8'b01010101;
        endcase
      end
    10 : begin
      case (linenum) 
          0 : signbit = 10'b0000000000;
          1 : signbit = 10'b0000011111;
          2 : signbit = 10'b0001111100;
          3 : signbit = 10'b0011100011;
          4 : signbit = 10'b0111001110;
          5 : signbit = 10'b0110011001;
          6 : signbit = 10'b0110110010;
          7 : signbit = 10'b0100101101;
          8 : signbit = 10'b0101001010;
          9 : signbit = 10'b0101010101;
        endcase
      end
    12 : begin
      case (linenum) 
           0 : signbit = 12'b000000000000;
           1 : signbit = 12'b000000111111;
           2 : signbit = 12'b000111111000;
           3 : signbit = 12'b001111000011;
           4 : signbit = 12'b001110001110;
           5 : signbit = 12'b011100110001;
           6 : signbit = 12'b011001100110;
           7 : signbit = 12'b011011001001;
           8 : signbit = 12'b010010010010;
           9 : signbit = 12'b010110100101;
          10 : signbit = 12'b010101101010;
          11 : signbit = 12'b010101010101;
        endcase
      end
    14 : begin
      case (linenum) 
           0 : signbit = 14'b00000000000000;
           1 : signbit = 14'b00000001111111;
           2 : signbit = 14'b00001111111000;
           3 : signbit = 14'b00111110000011;
           4 : signbit = 14'b00111000011100;
           5 : signbit = 14'b01110001110001;
           6 : signbit = 14'b01110011000110;
           7 : signbit = 14'b01100110011001;
           8 : signbit = 14'b01101100110110;
           9 : signbit = 14'b01001001101101;
          10 : signbit = 14'b01001011010010;
          11 : signbit = 14'b01010010110101;
          12 : signbit = 14'b01010100101010;
          13 : signbit = 14'b01010101010101;
        endcase
      end
    16 : begin
      case (linenum) 
           0 : signbit = 16'b0000000000000000;
           1 : signbit = 16'b0000000011111111;
           2 : signbit = 16'b0000111111110000;
           3 : signbit = 16'b0001111100000111;
           4 : signbit = 16'b0011110000111100;
           5 : signbit = 16'b0011100011100011;
           6 : signbit = 16'b0111000110001110;
           7 : signbit = 16'b0110001100111001;
           8 : signbit = 16'b0110011001100110;
           9 : signbit = 16'b0110110011001001;
          10 : signbit = 16'b0100110110110010;
          11 : signbit = 16'b0100100101101101;
          12 : signbit = 16'b0101101001011010;
          13 : signbit = 16'b0101001010110101;
          14 : signbit = 16'b0101010110101010;
          15 : signbit = 16'b0101010101010101;
        endcase
      end
  endcase
end
endfunction

function [(n*4)-1:0] coefsel;
  input [n-1:0] linenum;
begin
  case (n)
      4 : begin
      case (linenum) 
          0 : coefsel = 16'h0000;
          1 : coefsel = 16'h1331;
          2 : coefsel = 16'h2222;
          3 : coefsel = 16'h3113;
        endcase
      end
    6 : begin
      case (linenum) 
          0 : coefsel = 24'h000000;
          1 : coefsel = 24'h105501;
          2 : coefsel = 24'h262262;
          3 : coefsel = 24'h333333;
          4 : coefsel = 24'h404404;
          5 : coefsel = 24'h501105;
        endcase
      end
    8 : begin
      case (linenum) 
          0 : coefsel = 32'h00000000;
          1 : coefsel = 32'h13577531;
          2 : coefsel = 32'h26622662;
          3 : coefsel = 32'h37155173;
          4 : coefsel = 32'h44444444;
          5 : coefsel = 32'h51733715;
          6 : coefsel = 32'h62266226;
          7 : coefsel = 32'h75311357;
        endcase
      end
    10 : begin
      case (linenum) 
          0 : coefsel = 40'h0000000000;
          1 : coefsel = 40'h1307997031;
          2 : coefsel = 40'h26a6226a62;
          3 : coefsel = 40'h3901771093;
          4 : coefsel = 40'h4808448084;
          5 : coefsel = 40'h5555555555;
          6 : coefsel = 40'h62a2662a26;
          7 : coefsel = 40'h7109339017;
          8 : coefsel = 40'h8404884048;
          9 : coefsel = 40'h9703113079;
        endcase
      end
    12 : begin
      case (linenum) 
           0 : coefsel = 48'h000000000000;
           1 : coefsel = 48'h13579bb97531;
           2 : coefsel = 48'h20aa0220aa02;
           3 : coefsel = 48'h399339933993;
           4 : coefsel = 48'h4c44c44c44c4;
           5 : coefsel = 48'h591b3773b195;
           6 : coefsel = 48'h666666666666;
           7 : coefsel = 48'h73b195591b37;
           8 : coefsel = 48'h808808808808;
           9 : coefsel = 48'h933993399339;
          10 : coefsel = 48'ha0220aa0220a;
          11 : coefsel = 48'hb9753113579b;
        endcase
      end
    14 : begin
      case (linenum) 
           0 : coefsel = 56'h00000000000000;
           1 : coefsel = 56'h13509bddb90531;
           2 : coefsel = 56'h26aea6226aea62;
           3 : coefsel = 56'h39d015bb510d93;
           4 : coefsel = 56'h4c808c44c808c4;
           5 : coefsel = 56'h5d30b1991b03d5;
           6 : coefsel = 56'h6a2e2a66a2e2a6;
           7 : coefsel = 56'h77777777777777;
           8 : coefsel = 56'h84c0c4884c0c48;
           9 : coefsel = 56'h91b03d55d30b19;
          10 : coefsel = 56'ha26e62aa26e62a;
          11 : coefsel = 56'hb510d9339d015b;
          12 : coefsel = 56'hc84048cc84048c;
          13 : coefsel = 56'hdb9053113509bd;
        endcase
      end
    16 : begin
      case (linenum) 
           0 : coefsel = 64'h0000000000000000;
           1 : coefsel = 64'h13579bdffdb97531;
           2 : coefsel = 64'h26aeea6226aeea62;
           3 : coefsel = 64'h39fb517dd715bf93;
           4 : coefsel = 64'h4cc44cc44cc44cc4;
           5 : coefsel = 64'h5f73d91bb19d37f5;
           6 : coefsel = 64'h6e2aa2e66e2aa2e6;
           7 : coefsel = 64'h7b3f1d5995d1f3b7;
           8 : coefsel = 64'h8888888888888888;
           9 : coefsel = 64'h95d1f3b77b3f1d59;
          10 : coefsel = 64'ha2e66e2aa2e66e2a;
          11 : coefsel = 64'hb19d37f55f73d91b;
          12 : coefsel = 64'hc44cc44cc44cc44c;
          13 : coefsel = 64'hd715bf9339fb517d;
          14 : coefsel = 64'hea6226aeea6226ae;
          15 : coefsel = 64'hfdb9753113579bdf;
        endcase
      end
  endcase
end
endfunction 
function [(n+1)*16-1:0] get_params;
input [n:0] blocksize;
begin
  case (blocksize)
     4 : get_params = {co_e[15:0],co_d[15:0],co_c[15:0],co_b[15:0],co_a[15:0]};
     6 : get_params = {co_g[15:0],co_f[15:0],co_e[15:0],co_d[15:0],co_c[15:0],co_b[15:0],co_a[15:0]};
     8 : get_params = {co_i[15:0],co_h[15:0],co_g[15:0],co_f[15:0],co_e[15:0],co_d[15:0],co_c[15:0],
                       co_b[15:0],co_a[15:0]};
    10 : get_params = {co_k[15:0],co_j[15:0],co_i[15:0],co_h[15:0],co_g[15:0],co_f[15:0],co_e[15:0],
                       co_d[15:0],co_c[15:0],co_b[15:0],co_a[15:0]};
    12 : get_params = {co_m[15:0],co_l[15:0],co_k[15:0],co_j[15:0],co_i[15:0],co_h[15:0],co_g[15:0],
                       co_f[15:0],co_e[15:0],co_d[15:0],co_c[15:0],co_b[15:0],co_a[15:0]};
    14 : get_params = {co_o[15:0],co_n[15:0],co_m[15:0],co_l[15:0],co_k[15:0],co_j[15:0],co_i[15:0],
                       co_h[15:0],co_g[15:0],co_f[15:0],co_e[15:0],co_d[15:0],co_c[15:0],
		       co_b[15:0],co_a[15:0]}; 
    16 : get_params = {co_p[15:0],co_p[15:0],co_o[15:0],co_n[15:0],co_m[15:0],co_l[15:0],co_k[15:0],
                       co_j[15:0],co_i[15:0],co_h[15:0],co_g[15:0],co_f[15:0],co_e[15:0],
		       co_d[15:0],co_c[15:0],co_b[15:0],co_a[15:0]};  
  endcase
end
endfunction
function [((n+1)*16)-1:0] scalepcoef;
input[`DW_nwidth-1:0] linenum;
integer i,j,k,l;
reg [((n+1)*16)-1:0] temp, temp_prime;
begin
temp_prime = 0;
temp = 0;
    for(i=0;i<n;i=i+1)begin
      temp = scalecoef(i);
      for(j=0;j<16;j=j+1) begin
        k = (n - (linenum)-1) * 16;
        l = (n - (i)-1) * 16;
        temp_prime[l+j] = temp[k+j];
      end
    end
  scalepcoef = temp_prime;
end
endfunction

`undef DW_fwrdsz
`undef DW_frstadr
`undef DW_frstprod
`undef DW_frstsum
`undef DW_product1
// synopsys_translate_on
`undef DW_nwidth
`undef DW_addwidth
`undef DW_rddatsz
`undef DW_fnldat
`undef DW_idatsz

endmodule
