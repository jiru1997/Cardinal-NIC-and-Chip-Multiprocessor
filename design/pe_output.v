//EE577b Project Phase 1 router - PE output module design
//Author: Sihao Chen
//Date: Oct.6.2021

module pe_output(peso, pero, pedo, 
	data_in_even_cw, data_in_odd_cw, data_in_even_ccw, data_in_odd_ccw, 
	request_cw_even, request_cw_odd, request_ccw_even, request_ccw_odd, 
	grant_cw_even, grant_cw_odd, grant_ccw_even, grant_ccw_odd, 
	rst, clk, polarity);
	parameter DATA_WIDTH = 64;
	parameter STATE0 = 5'b00001;
	parameter STATE1 = 5'b00010;
	parameter STATE2 = 5'b00100;
	parameter STATE3 = 5'b01000;
	parameter STATE4 = 5'b10000;
	input pero, rst, clk, request_cw_even, request_cw_odd, request_ccw_even, request_ccw_odd, polarity;
	output reg peso, grant_cw_even, grant_cw_odd, grant_ccw_even, grant_ccw_odd;
	input [DATA_WIDTH-1:0] data_in_even_cw, data_in_odd_cw, data_in_even_ccw, data_in_odd_ccw;
	output reg [DATA_WIDTH-1:0] pedo;

	reg [4:0] state_even, state_odd, next_state_even, next_state_odd;
	reg enable1_cw_even, enable1_cw_odd, enable1_ccw_even, enable1_ccw_odd, enable2_cw_even, enable2_cw_odd, enable2_ccw_even, enable2_ccw_odd;
	reg [DATA_WIDTH-1:0] data_internal_even_cw, data_internal_even_ccw, data_internal_odd_cw, data_internal_odd_ccw;
	reg arbi; //Trace priority, cw first pe later, then change order

	//For cw channel
	//From input buffer to output buffer when enable1 asserted
	always@(negedge clk) begin
		if (rst) begin
			data_internal_even_cw <= 0;
		end else if (enable1_cw_even) begin
			data_internal_even_cw <= data_in_even_cw;
		end else begin
			data_internal_even_cw <= data_internal_even_cw;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_internal_odd_cw <= 0;
		end else if (enable1_cw_odd) begin
			data_internal_odd_cw <= data_in_odd_cw;
		end else begin
			data_internal_odd_cw <= data_internal_odd_cw;
		end
	end

	//For ccw channel
	//From input buffer to output buffer when enable1 asserted
	always@(negedge clk) begin
		if (rst) begin
			data_internal_even_ccw <= 0;
		end else if (enable1_ccw_even) begin
			data_internal_even_ccw <= data_in_even_ccw;
		end else begin
			data_internal_even_ccw <= data_internal_even_ccw;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_internal_odd_ccw <= 0;
		end else if (enable1_ccw_odd) begin
			data_internal_odd_ccw <= data_in_odd_ccw;
		end else begin
			data_internal_odd_ccw <= data_internal_odd_ccw;
		end
	end

	//From output buffer to pedo when enable2 asserted
	always@(negedge clk) begin
		if (rst) begin
	    	pedo <= 0;
	    	peso <= 0;
		end else begin
			case({enable2_ccw_even,enable2_ccw_odd, enable2_cw_even, enable2_cw_odd})
				4'b1000 : 
					begin
						pedo <= data_internal_even_ccw;
						peso <= 1;
					end
				4'b0100 : 
					begin
						pedo <= data_internal_odd_ccw;
						peso <= 1;
					end
				4'b0010 : 
					begin
						pedo <= data_internal_even_cw;
						peso <= 1;
					end
				4'b0001 : 
					begin
						pedo <= data_internal_odd_cw;
						peso <= 1;
					end
				default : 
					begin
						pedo <= pedo;
						peso <= 0;
					end
			endcase
		end
	end

	always@(posedge clk) begin
		if (rst) begin
			state_even <= STATE0;
			state_odd <= STATE0;
		end else begin
			state_even <= next_state_even;
			state_odd <= next_state_odd;
		end
	end

	always@(state_even, request_cw_even, request_ccw_even, pero, polarity) begin
		case(state_even) 
			STATE0 : 
				begin
					if (request_cw_even & request_ccw_even) begin //request signal of cw and pe come in the same time, then depending on the arbi signal which channel grant first
						if (!arbi) next_state_even = STATE1;
						else next_state_even = STATE3;
					end else if (request_cw_even & !request_ccw_even) next_state_even = STATE1;
					else if (request_ccw_even & !request_cw_even) next_state_even = STATE3;
					else next_state_even = STATE0;
				end
			STATE1 : 
				begin
					if (pero & !polarity) next_state_even = STATE2;
					else next_state_even = STATE1;
				end
			STATE2 : 
                begin
                	if (request_ccw_even) next_state_even = STATE3;
			        else next_state_even = STATE0;
			    end
			STATE3 : 
				begin
					if (pero & !polarity) next_state_even = STATE4;
					else next_state_even = STATE3;
				end
			STATE4 : 
                begin
			        if(request_cw_even) next_state_even = STATE1;
			        else next_state_even = STATE0;
			    end
			default : next_state_even = STATE0;
		endcase
	end

	always@(state_even, request_cw_even, request_ccw_even, rst, pero) begin
		case(state_even) 
			STATE0 : 
				begin
					enable1_cw_even = 0;
					enable1_ccw_even = 0;
					enable2_cw_even = 0;
					enable2_ccw_even = 0;
					grant_cw_even = 0;
					grant_ccw_even = 0;
					if (rst) arbi = 0;
					else arbi = arbi;
				end
			STATE1 : //For cw channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_cw_even = (pero == 1'b1) ? 1'b1 : 1'b0;
					enable2_cw_even = 0;
					grant_cw_even = (pero == 1'b1) ? 1'b1 : 1'b0;
					enable1_ccw_even = 0;
					enable2_ccw_even = 0;
					grant_ccw_even = 0;
					if (request_cw_even & request_ccw_even) arbi = ~arbi; //Flip arbi signal to change the priority
					else arbi = arbi;
				end
			STATE2 : // For cw channel, enable data transfer from output channel to pedo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_cw_even = 0;
					enable2_cw_even = 1;
					grant_cw_even = 0;
					enable1_ccw_even = 0;
					enable2_ccw_even = 0;
					grant_ccw_even = 0;
					arbi = arbi;
				end
			STATE3 : //For ccw channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_cw_even = 0;
					enable2_cw_even = 0;
					grant_cw_even = 0;
					enable1_ccw_even = (pero == 1'b1) ? 1'b1 : 1'b0;
					enable2_ccw_even = 0;
					grant_ccw_even = (pero == 1'b1) ? 1'b1 : 1'b0;
					if (request_cw_even & request_ccw_even) arbi = ~arbi; //Flip arbi signal to change the priority
					else arbi = arbi;
				end
			STATE4 : // For ccw channel, enable data transfer from output channel to pedo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_cw_even = 0;
					enable2_cw_even = 0;
					grant_cw_even = 0;
					enable1_ccw_even = 0;
					enable2_ccw_even = 1;
					grant_ccw_even = 0;
					arbi = arbi;
				end
			default : 
				begin
					enable1_cw_even = 0;
					enable2_cw_even = 0;
					grant_cw_even = 0;
					enable1_ccw_even = 0;
					enable2_ccw_even = 0;
					grant_ccw_even = 0;
					arbi = 0;
				end
		endcase
	end

	always@(state_odd, request_cw_odd, request_ccw_odd, pero, polarity) begin
		case(state_odd) 
			STATE0 : 
				begin
					if (request_cw_odd & request_ccw_odd) begin //request signal of cw and pe come in the same time, then depending on the arbi signal which channel grant first
						if (!arbi) next_state_odd = STATE1; // cw has higher priority at beginning
						else next_state_odd = STATE3;
					end else if (request_cw_odd & !request_ccw_odd) next_state_odd = STATE1;
					else if (request_ccw_odd & !request_cw_odd) next_state_odd = STATE3;
					else next_state_odd = STATE0;
				end
			STATE1 : 
				begin
					if (pero & polarity) next_state_odd = STATE2;
					else next_state_odd = STATE1;
				end
			STATE2 : 
                begin
                	if (request_ccw_odd) next_state_odd = STATE3;
			        else next_state_odd = STATE0;
			    end 
			STATE3 : 
				begin
					if (pero & polarity) next_state_odd = STATE4;
					else next_state_odd = STATE3;
				end
			STATE4 :
			    begin
			        if(request_cw_odd) next_state_odd = STATE1;
			        else next_state_odd = STATE0;
			    end
			default : next_state_odd = STATE0;
		endcase
	end

	always@(state_odd, request_cw_odd, request_ccw_odd, rst, pero) begin
		case(state_odd) 
			STATE0 : 
				begin
					enable1_cw_odd = 0;
					enable1_ccw_odd = 0;
					enable2_cw_odd = 0;
					enable2_ccw_odd = 0;
					grant_cw_odd = 0;
					grant_ccw_odd = 0;
					if (rst) arbi = 0;
					else arbi = arbi;
				end
			STATE1 : //For cw channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_cw_odd = (pero == 1'b1) ? 1'b1 : 1'b0;
					enable2_cw_odd = 0;
					grant_cw_odd = (pero == 1'b1) ? 1'b1 : 1'b0;
					enable1_ccw_odd = 0;
					enable2_ccw_odd = 0;
					grant_ccw_odd = 0;
					if (request_cw_odd & request_ccw_odd) arbi = ~arbi; //Flip arbi signal to change the priority
					else arbi = arbi;
				end
			STATE2 : // For cw channel, enable data transfer from output channel to pedo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_cw_odd = 0;
					enable2_cw_odd = 1;
					grant_cw_odd = 0;
					enable1_ccw_odd = 0;
					enable2_ccw_odd = 0;
					grant_ccw_odd = 0;
					arbi = arbi;
				end
			STATE3 : //For ccw channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_cw_odd = 0;
					enable2_cw_odd = 0;
					grant_cw_odd = 0;
					enable1_ccw_odd = (pero == 1'b1) ? 1'b1 : 1'b0;
					enable2_ccw_odd = 0;
					grant_ccw_odd = (pero == 1'b1) ? 1'b1 : 1'b0;
					if (request_cw_odd & request_ccw_odd) arbi = ~arbi; //Flip arbi signal to change the priority
					else arbi = arbi;
				end
			STATE4 : // For ccw channel, enable data transfer from output channel to pedo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_cw_odd = 0;
					enable2_cw_odd = 0;
					grant_cw_odd = 0;
					enable1_ccw_odd = 0;
					enable2_ccw_odd = 1;
					grant_ccw_odd = 0;
					arbi = arbi;
				end
			default : 
				begin
					enable1_cw_odd = 0;
					enable2_cw_odd = 0;
					grant_cw_odd = 0;
					enable1_ccw_odd = 0;
					enable2_ccw_odd = 0;
					grant_ccw_odd = 0;
					arbi = 0;
				end
		endcase
	end

endmodule 