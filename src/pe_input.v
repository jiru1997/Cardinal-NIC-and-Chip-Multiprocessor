//EE577b Project Phase 1 router - PE input module design
//Author: Sihao Chen
//Date: Oct.6.2021


module pe_input(pesi, peri, pedi, 
	request_cw_odd, request_cw_even, request_ccw_odd, request_ccw_even, 
	grant_cw_odd, grant_cw_even, grant_ccw_odd, grant_ccw_even, 
	data_out_even_cw, data_out_odd_cw, data_out_even_ccw, data_out_odd_ccw, 
	rst, clk, polarity);
	parameter DATA_WIDTH = 64;
	parameter STATE0 = 2'b01;
	parameter STATE1 = 2'b10;
	input pesi, grant_cw_odd, grant_cw_even, grant_ccw_odd, grant_ccw_even, rst, clk, polarity;
	output reg peri, request_cw_odd, request_cw_even, request_ccw_odd, request_ccw_even;
	input [DATA_WIDTH-1:0] pedi;
	output reg [DATA_WIDTH-1:0] data_out_even_cw, data_out_odd_cw, data_out_even_ccw, data_out_odd_ccw;

	reg [1:0] state_even, state_odd, next_state_even, next_state_odd;
	reg enable_cw_even, enable_cw_odd, enable_ccw_even, enable_ccw_odd;

	reg peri_odd, peri_even;
	always@(*) begin
		//if (polarity) peri = peri_odd;
		//else peri = peri_even;
		peri = peri_even & peri_odd;
	end

	//buffer data for cw channel
	always@(negedge clk) begin
		if (rst) begin
			data_out_odd_cw <= 0;
		end else if (enable_cw_odd) begin
				data_out_odd_cw <= pedi;
		end else begin
			data_out_odd_cw <= data_out_odd_cw;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_out_even_cw <= 0;
		end else if (enable_cw_even) begin
				data_out_even_cw <= pedi;
		end else begin
			data_out_even_cw <= data_out_even_cw;
		end
	end
	//buffer data for ccw channel
	always@(negedge clk) begin
		if (rst) begin
			data_out_odd_ccw <= 0;
		end else if (enable_ccw_odd) begin
				data_out_odd_ccw <= pedi;
		end else begin
			data_out_odd_ccw <= data_out_odd_ccw;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_out_even_ccw <= 0;
		end else if (enable_ccw_even) begin
				data_out_even_ccw <= pedi;
		end else begin
			data_out_even_ccw <= data_out_even_ccw;
		end
	end

	//State transistion
	always@(posedge clk) begin
		if (rst) begin
			state_odd <= STATE0;
			state_even <= STATE0;
		end else begin 
			state_odd <= next_state_odd;
			state_even <= next_state_even;
		end
	end


	// For odd vc, only when pesi and polarity both asserted, we use two state machines to indicated seperated vc channels
	always@(state_odd, pesi, grant_cw_odd, grant_ccw_odd) begin
		case(state_odd)
			STATE0 : 
				begin
					if (pesi & polarity) next_state_odd = STATE1;
					else next_state_odd = STATE0;
				end
			STATE1 : 
				begin
					if (grant_cw_odd | grant_ccw_odd) next_state_odd = STATE0; // either one of grant signal is asserted
					else next_state_odd = STATE1;
				end
			default : next_state_odd = STATE0;
		endcase
	end

	always@(state_even, pesi, grant_cw_even, grant_ccw_even) begin
		case(state_even)
			STATE0 : 
				begin
					if (pesi & !polarity) next_state_even = STATE1;
					else next_state_even = STATE0;
				end
			STATE1 : 
				begin
					if (grant_cw_even | grant_ccw_even) next_state_even = STATE0; // either one of grant signal is asserted
					else next_state_even = STATE1;
				end
			default : next_state_even = STATE0;
		endcase
	end

	// As long as pesi is asserted, generate enable signal for input buffer get packect from pedi and generate request signal to let output buffer know data is ready 
	always@(state_odd, pesi, grant_cw_odd, grant_ccw_odd) begin
		case(state_odd)
			STATE0 : 
				begin
					if (pesi & polarity) begin
						if (pedi[62]) begin //direction bit == 1, counter clock wise
							enable_ccw_odd = 1;
							request_ccw_odd = 1;
							enable_cw_odd = 0;
							request_cw_odd = 0;
						end else begin // direction bit == 0, clock wise
							enable_ccw_odd = 0;
							request_ccw_odd = 0;
							enable_cw_odd = 1;
							request_cw_odd = 1;
						end
						peri_odd = 0;
					end else begin
						enable_ccw_odd = 0;
						request_ccw_odd = 0;
						enable_cw_odd = 0;
						request_cw_odd = 0;
						peri_odd = 1;
					end
				end
			STATE1 : 
				begin
					if (pesi | (!grant_cw_odd & !grant_ccw_odd)) begin
						if (pedi[62]) begin
							//enable_ccw_odd = 1;
							request_ccw_odd = 1;
							//enable_cw_odd = 0;
							request_cw_odd = 0;
						end else begin
							//enable_ccw_odd = 0;
							request_ccw_odd = 0;
							//enable_cw_odd = 1;
							request_cw_odd = 1;
						end
						peri_odd = 0;
					end else begin
						//enable_ccw_odd = 0;
						request_ccw_odd = 0;
						//enable_cw_odd = 0;
						request_cw_odd = 0;
						peri_odd = 1;
					end
					/*if (pesi) begin
						if (pedi[62]) begin
							enable_ccw_odd = 1;
							//request_ccw_odd = 1;
							enable_cw_odd = 0;
							//request_cw_odd = 0;
						end else begin
							enable_ccw_odd = 0;
							//request_ccw_odd = 0;
							enable_cw_odd = 1;
							//request_cw_odd = 1;
						end
						peri_odd = 0;
					end else begin
						enable_ccw_odd = 0;
						//request_ccw_odd = 0;
						enable_cw_odd = 0;
						//request_cw_odd = 0;
						peri_odd = 1;
					end*/
					if (pedi[62]) begin
						enable_ccw_odd = 1;
						//request_ccw_odd = 1;
						enable_cw_odd = 0;
						//request_cw_odd = 0;
					end else begin
						enable_ccw_odd = 0;
						//request_ccw_odd = 0;
						enable_cw_odd = 1;
						//request_cw_odd = 1;
					end
				end
			default : 
				begin
					enable_ccw_odd = 0;
					request_ccw_odd = 0;
					enable_cw_odd = 0;
					request_cw_odd = 0;
					peri_odd = 1;
				end
		endcase
	end

	always@(state_even, pesi, grant_ccw_even, grant_cw_even) begin
		case(state_even)
			STATE0 : 
				begin
					if (pesi & !polarity) begin
						if (pedi[62]) begin
							enable_ccw_even = 1;
							request_ccw_even = 1;
							enable_cw_even = 0;
							request_cw_even = 0;
						end else begin
							enable_ccw_even = 0;
							request_ccw_even = 0;
							enable_cw_even = 1;
							request_cw_even = 1;
						end
						peri_even = 0;
					end else begin
						enable_ccw_even = 0;
						request_ccw_even = 0;
						enable_cw_even = 0;
						request_cw_even = 0;
						peri_even = 1;
					end
				end
			STATE1 : 
				begin
					if (pesi | (!grant_cw_even & !grant_ccw_even)) begin
						if (pedi[62]) begin
							//enable_ccw_even = 1;
							request_ccw_even = 1;
							//enable_cw_even = 0;
							request_cw_even = 0;
						end else begin
							//enable_ccw_even = 0;
							request_ccw_even = 0;
							//enable_cw_even = 1;
							request_cw_even = 1;
						end
						peri_even = 0;
					end else begin
						//enable_ccw_even = 0;
						request_ccw_even = 0;
						//enable_cw_even = 0;
						request_cw_even = 0;
						peri_even = 1;
					end
					/*if (pesi) begin
						if (pedi[62]) begin
							enable_ccw_even = 1;
							//request_ccw_even = 1;
							enable_cw_even = 0;
							//request_cw_even = 0;
						end else begin
							enable_ccw_even = 0;
							//request_ccw_even = 0;
							enable_cw_even = 1;
							//request_cw_even = 1;
						end
						peri_even = 0;
					end else begin
						enable_ccw_even = 0;
						//request_ccw_even = 0;
						enable_cw_even = 0;
						//request_cw_even = 0;
						peri_even = 1;
					end*/
					if (pedi[62]) begin
						enable_ccw_even = 1;
						//request_ccw_even = 1;
						enable_cw_even = 0;
						//request_cw_even = 0;
					end else begin
						enable_ccw_even = 0;
						//request_ccw_even = 0;
						enable_cw_even = 1;
						//request_cw_even = 1;
					end
				end
			default : 
				begin
					enable_ccw_even = 0;
					request_ccw_even = 0;
					enable_cw_even = 0;
					request_cw_even = 0;
					peri_even = 1;
				end
		endcase
	end

endmodule // cw_input






