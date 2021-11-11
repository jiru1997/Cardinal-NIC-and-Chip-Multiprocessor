//EE577b Project Phase 1 gold ring with four routers module design
//Author: Sihao Chen
//Date: Oct.13.2021

module gold_ring(pesi_1, pesi_2, pesi_3, pesi_4, pero_1, pero_2, pero_3, pero_4,
				pedi_1, pedi_2, pedi_3, pedi_4,
				peri_1, peri_2, peri_3, peri_4, peso_1, peso_2, peso_3, peso_4,
				pedo_1, pedo_2, pedo_3, pedo_4,
				clk, rst, polarity_1, polarity_2, polarity_3, polarity_4
				);
	parameter DATA_WIDTH = 64;
	input clk, rst;
	input pesi_1, pesi_2, pesi_3, pesi_4, pero_1, pero_2, pero_3, pero_4;
	input [DATA_WIDTH-1:0] pedi_1, pedi_2, pedi_3, pedi_4;
	output peri_1, peri_2, peri_3, peri_4, peso_1, peso_2, peso_3, peso_4;
	output [DATA_WIDTH-1:0] pedo_1, pedo_2, pedo_3, pedo_4;
	output polarity_1, polarity_2, polarity_3, polarity_4;

	wire cws_1, cws_2, cws_3, cws_4, cwr_1, cwr_2, cwr_3, cwr_4;
	wire [DATA_WIDTH-1:0] cwd_1, cwd_2, cwd_3, cwd_4;
	wire ccws_1, ccws_2, ccws_3, ccws_4, ccwr_1, ccwr_2, ccwr_3, ccwr_4;
	wire [DATA_WIDTH-1:0] ccwd_1, ccwd_2, ccwd_3, ccwd_4;

	gold_router r1(cws_4, cwr_4, cwd_4, cws_1, cwr_1, cwd_1, ccws_2, ccwr_2, ccwd_2, ccws_1, ccwr_1, ccwd_1, pesi_1, peri_1, pedi_1, peso_1, pero_1, pedo_1, clk, polarity_1, rst);
	gold_router r2(cws_1, cwr_1, cwd_1, cws_2, cwr_2, cwd_2, ccws_3, ccwr_3, ccwd_3, ccws_2, ccwr_2, ccwd_2, pesi_2, peri_2, pedi_2, peso_2, pero_2, pedo_2, clk, polarity_2, rst);
	gold_router r3(cws_2, cwr_2, cwd_2, cws_3, cwr_3, cwd_3, ccws_4, ccwr_4, ccwd_4, ccws_3, ccwr_3, ccwd_3, pesi_3, peri_3, pedi_3, peso_3, pero_3, pedo_3, clk, polarity_3, rst);
	gold_router r4(cws_3, cwr_3, cwd_3, cws_4, cwr_4, cwd_4, ccws_1, ccwr_1, ccwd_1, ccws_4, ccwr_4, ccwd_4, pesi_4, peri_4, pedi_4, peso_4, pero_4, pedo_4, clk, polarity_4, rst);

endmodule // gold_ring