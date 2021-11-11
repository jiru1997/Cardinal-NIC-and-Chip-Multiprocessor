//EE577b Project Phase 1 router - router module design
//Author: Sihao Chen
//Date: Oct.13.2021

module gold_router(cwsi, cwri, cwdi, cwso, cwro, cwdo, ccwsi, ccwri, ccwdi, ccwso, ccwro, ccwdo, pesi, peri, pedi, peso, pero, pedo, clk, polarity, rst);
	parameter DATA_WIDTH = 64;
	input cwsi, cwro, ccwsi, ccwro, pesi, pero, clk, rst;
	input [DATA_WIDTH-1:0] cwdi, ccwdi, pedi;
	output wire cwri, cwso, ccwri, ccwso, peri, peso;
	output wire [DATA_WIDTH-1:0] cwdo, ccwdo, pedo;
	output reg polarity;

	wire request_cw2cw_even, request_cw2cw_odd, request_cw2pe_even, request_cw2pe_odd, request_ccw2ccw_even, request_ccw2ccw_odd, request_ccw2pe_even, request_ccw2pe_odd, 
		 request_pe2cw_even, request_pe2cw_odd, request_pe2ccw_even, request_pe2ccw_odd;
	wire grant_cw2cw_even, grant_cw2cw_odd, grant_cw2pe_even, grant_cw2pe_odd, grant_ccw2ccw_even, grant_ccw2ccw_odd, grant_ccw2pe_even, grant_ccw2pe_odd, 
		 grant_pe2cw_even, grant_pe2cw_odd, grant_pe2ccw_even, grant_pe2ccw_odd;
	wire [DATA_WIDTH-1:0] data_cw2cw_even, data_cw2cw_odd, data_cw2pe_even, data_cw2pe_odd, data_ccw2ccw_even, data_ccw2ccw_odd, data_ccw2pe_even, data_ccw2pe_odd, 
		 data_pe2cw_even, data_pe2cw_odd, data_pe2ccw_even, data_pe2ccw_odd;

	cw_input cwi(cwsi, cwri, cwdi, 
	request_cw2cw_odd, request_cw2cw_even, request_cw2pe_odd, request_cw2pe_even, 
	grant_cw2cw_odd, grant_cw2cw_even, grant_pe2cw_odd, grant_pe2cw_even, 
	data_cw2cw_even, data_cw2cw_odd, data_cw2pe_even, data_cw2pe_odd, 
	rst, clk, polarity);
	cw_output cwo(cwso, cwro, cwdo, 
	data_cw2cw_even, data_cw2cw_odd, data_pe2cw_even, data_pe2cw_odd, 
	request_cw2cw_even, request_cw2cw_odd, request_pe2cw_even, request_pe2cw_odd, 
	grant_cw2cw_even, grant_cw2cw_odd, grant_cw2pe_even, grant_cw2pe_odd, 
	rst, clk, polarity);
	ccw_input ccwi(ccwsi, ccwri, ccwdi, 
	request_ccw2ccw_odd, request_ccw2ccw_even, request_ccw2pe_odd, request_ccw2pe_even, 
	grant_ccw2ccw_odd, grant_ccw2ccw_even, grant_pe2ccw_odd, grant_pe2ccw_even, 
	data_ccw2ccw_even, data_ccw2ccw_odd, data_ccw2pe_even, data_ccw2pe_odd, 
	rst, clk, polarity);
	ccw_output ccwo(ccwso, ccwro, ccwdo, 
	data_ccw2ccw_even, data_ccw2ccw_odd, data_pe2ccw_even, data_pe2ccw_odd, 
	request_ccw2ccw_even, request_ccw2ccw_odd, request_pe2ccw_even, request_pe2ccw_odd, 
	grant_ccw2ccw_even, grant_ccw2ccw_odd, grant_ccw2pe_even, grant_ccw2pe_odd, 
	rst, clk, polarity);
	pe_input pei(pesi, peri, pedi, 
	request_pe2cw_odd, request_pe2cw_even, request_pe2ccw_odd, request_pe2ccw_even, 
	grant_cw2pe_odd, grant_cw2pe_even, grant_ccw2pe_odd, grant_ccw2pe_even, 
	data_pe2cw_even, data_pe2cw_odd, data_pe2ccw_even, data_pe2ccw_odd, 
	rst, clk, polarity);
	pe_output peo(peso, pero, pedo, 
	data_cw2pe_even, data_cw2pe_odd, data_ccw2pe_even, data_ccw2pe_odd, 
	request_cw2pe_even, request_cw2pe_odd, request_ccw2pe_even, request_ccw2pe_odd, 
	grant_pe2cw_even, grant_pe2cw_odd, grant_pe2ccw_even, grant_pe2ccw_odd, 
	rst, clk, polarity);

	always@(posedge clk) begin
		if(rst) polarity = 0;
		else polarity <= ~polarity;
	end
	
endmodule 