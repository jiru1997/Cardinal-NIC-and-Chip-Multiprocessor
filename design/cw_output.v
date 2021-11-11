//EE577b Project Phase 1 router - CW output module design
//Author: Sihao Chen
//Date: Oct.6.2021
//Add pe channel to original only supporting cw
//Add seperate request signals for even and odd vc 

module cw_output(cwso, cwro, cwdo, 
	data_in_even_cw, data_in_odd_cw, data_in_even_pe, data_in_odd_pe, 
	request_cw_even, request_cw_odd, request_pe_even, request_pe_odd, 
	grant_cw_even, grant_cw_odd, grant_pe_even, grant_pe_odd, 
	rst, clk, polarity);
	parameter DATA_WIDTH = 64;
	parameter STATE0 = 5'b00001;
	parameter STATE1 = 5'b00010;
	parameter STATE2 = 5'b00100;
	parameter STATE3 = 5'b01000;
	parameter STATE4 = 5'b10000;
	input cwro, rst, clk, request_cw_even, request_cw_odd, request_pe_even, request_pe_odd, polarity;
	output reg cwso, grant_cw_even, grant_cw_odd, grant_pe_even, grant_pe_odd;
	input [DATA_WIDTH-1:0] data_in_even_cw, data_in_odd_cw, data_in_even_pe, data_in_odd_pe;
	output reg [DATA_WIDTH-1:0] cwdo;

	reg [4:0] state_even, state_odd, next_state_even, next_state_odd;
	reg enable1_cw_even, enable1_cw_odd, enable1_pe_even, enable1_pe_odd, enable2_cw_even, enable2_cw_odd, enable2_pe_even, enable2_pe_odd;
	reg [DATA_WIDTH-1:0] data_internal_even_cw, data_internal_even_pe, data_internal_odd_cw, data_internal_odd_pe;
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

	//For pe channel
	//From input buffer to output buffer when enable1 asserted
	always@(negedge clk) begin
		if (rst) begin
			data_internal_even_pe <= 0;
		end else if (enable1_pe_even) begin
			data_internal_even_pe <= data_in_even_pe;
		end else begin
			data_internal_even_pe <= data_internal_even_pe;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_internal_odd_pe <= 0;
		end else if (enable1_pe_odd) begin
			data_internal_odd_pe <= data_in_odd_pe;
		end else begin
			data_internal_odd_pe <= data_internal_odd_pe;
		end
	end

	//From output buffer to cwdo when enable2 asserted
	always@(negedge clk) begin
		if (rst) begin
	    	cwdo <= 0;
	    	cwso <= 0;
		end else begin
			case({enable2_pe_even,enable2_pe_odd, enable2_cw_even, enable2_cw_odd})
				4'b1000 : 
					begin
						cwdo <= {data_internal_even_pe[63:56], data_internal_even_pe[55:48] >> 1, data_internal_even_pe[47:0]}; // Hop value -1
						cwso <= 1;
					end
				4'b0100 : 
					begin
						cwdo <= {data_internal_odd_pe[63:56], data_internal_odd_pe[55:48] >> 1, data_internal_odd_pe[47:0]}; // Hop value -1
						cwso <= 1;
					end
				4'b0010 : 
					begin
						cwdo <= {data_internal_even_cw[63:56], data_internal_even_cw[55:48] >> 1, data_internal_even_cw[47:0]}; // Hop value -1
						cwso <= 1;
					end
				4'b0001 : 
					begin
						cwdo <= {data_internal_odd_cw[63:56], data_internal_odd_cw[55:48] >> 1, data_internal_odd_cw[47:0]}; // Hop value -1
						cwso <= 1;
					end
				default : 
					begin
						cwdo <= cwdo;
						cwso <= 0;
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

	always@(state_even, request_cw_even, request_pe_even, cwro, polarity) begin
		case(state_even) 
			STATE0 : 
				begin
					if (request_cw_even & request_pe_even) begin //request signal of cw and pe come in the same time, then depending on the arbi signal which channel grant first
						if (!arbi) next_state_even = STATE1;
						else next_state_even = STATE3;
					end else if (request_cw_even & !request_pe_even) next_state_even = STATE1;
					else if (request_pe_even & !request_cw_even) next_state_even = STATE3;
					else next_state_even = STATE0;
				end
			STATE1 : 
				begin
					if (cwro & !polarity) next_state_even = STATE2;
					else next_state_even = STATE1;
				end
			STATE2 : 
                begin
                	if (request_pe_even) next_state_even = STATE3;
			        else next_state_even = STATE0;
			    end
			STATE3 : 
				begin
					if (cwro & !polarity) next_state_even = STATE4;
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

	always@(state_even, request_cw_even, request_pe_even, rst, cwro) begin
		case(state_even) 
			STATE0 : 
				begin
					enable1_cw_even = 0;
					enable1_pe_even = 0;
					enable2_cw_even = 0;
					enable2_pe_even = 0;
					grant_cw_even = 0;
					grant_pe_even = 0;
					if (rst) arbi = 0;
					else arbi = arbi;
				end
			STATE1 : //For cw channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_cw_even = cwro ? 1:0;
					enable2_cw_even = 0;
					grant_cw_even = cwro ? 1:0;
					enable1_pe_even = 0;
					enable2_pe_even = 0;
					grant_pe_even = 0;
					if (request_cw_even & request_pe_even) arbi = ~arbi; //Flip arbi signal to change the priority
					else arbi = arbi;
				end
			STATE2 : // For cw channel, enable data transfer from output channel to cwdo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_cw_even = 0;
					enable2_cw_even = 1;
					grant_cw_even = 0;
					enable1_pe_even = 0;
					enable2_pe_even = 0;
					grant_pe_even = 0;
					arbi = arbi;
				end
			STATE3 : //For pe channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_cw_even = 0;
					enable2_cw_even = 0;
					grant_cw_even = 0;
					enable1_pe_even = cwro ? 1:0;
					enable2_pe_even = 0;
					grant_pe_even = cwro ? 1:0;
					if (request_cw_even & request_pe_even) arbi = ~arbi; //Flip arbi signal to change the priority
					else arbi = arbi;
				end
			STATE4 : // For pe channel, enable data transfer from output channel to cwdo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_cw_even = 0;
					enable2_cw_even = 0;
					grant_cw_even = 0;
					enable1_pe_even = 0;
					enable2_pe_even = 1;
					grant_pe_even = 0;
					arbi = arbi;
				end
			default : 
				begin
					enable1_cw_even = 0;
					enable2_cw_even = 0;
					grant_cw_even = 0;
					enable1_pe_even = 0;
					enable2_pe_even = 0;
					grant_pe_even = 0;
					arbi = 0;
				end
		endcase
	end

	always@(state_odd, request_cw_odd, request_pe_odd, cwro, polarity) begin
		case(state_odd) 
			STATE0 : 
				begin
					if (request_cw_odd & request_pe_odd) begin //request signal of cw and pe come in the same time, then depending on the arbi signal which channel grant first
						if (!arbi) next_state_odd = STATE1;
						else next_state_odd = STATE3;
					end else if (request_cw_odd & !request_pe_odd) next_state_odd = STATE1;
					else if (request_pe_odd & !request_cw_odd) next_state_odd = STATE3;
					else next_state_odd = STATE0;
				end
			STATE1 : 
				begin
					if (cwro & polarity) next_state_odd = STATE2;
					else next_state_odd = STATE1;
				end
			STATE2 : 
                begin
                	if (request_pe_odd) next_state_odd = STATE3;
			        else next_state_odd = STATE0;
			    end 
			STATE3 : 
				begin
					if (cwro & polarity) next_state_odd = STATE4;
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

	always@(state_odd, request_cw_odd, request_pe_odd, rst, cwro) begin
		case(state_odd) 
			STATE0 : 
				begin
					enable1_cw_odd = 0;
					enable1_pe_odd = 0;
					enable2_cw_odd = 0;
					enable2_pe_odd = 0;
					grant_cw_odd = 0;
					grant_pe_odd = 0;
					if (rst) arbi = 0;
					else arbi = arbi;
				end
			STATE1 : //For cw channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_cw_odd = cwro ? 1:0;
					enable2_cw_odd = 0;
					grant_cw_odd = cwro ? 1:0;
					enable1_pe_odd = 0;
					enable2_pe_odd = 0;
					grant_pe_odd = 0;
					if (request_cw_odd & request_pe_odd) arbi = ~arbi; //Flip arbi signal to change the priority
					else arbi = arbi;
				end
			STATE2 : // For cw channel, enable data transfer from output channel to cwdo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_cw_odd = 0;
					enable2_cw_odd = 1;
					grant_cw_odd = 0;
					enable1_pe_odd = 0;
					enable2_pe_odd = 0;
					grant_pe_odd = 0;
					arbi = arbi;
				end
			STATE3 : //For pe channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_cw_odd = 0;
					enable2_cw_odd = 0;
					grant_cw_odd = 0;
					enable1_pe_odd = cwro ? 1:0;
					enable2_pe_odd = 0;
					grant_pe_odd = cwro ? 1:0;
					if (request_cw_odd & request_pe_odd) arbi = ~arbi; //Flip arbi signal to change the priority
					else arbi = arbi;
				end
			STATE4 : // For pe channel, enable data transfer from output channel to cwdo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_cw_odd = 0;
					enable2_cw_odd = 0;
					grant_cw_odd = 0;
					enable1_pe_odd = 0;
					enable2_pe_odd = 1;
					grant_pe_odd = 0;
					arbi = arbi;
				end
			default : 
				begin
					enable1_cw_odd = 0;
					enable2_cw_odd = 0;
					grant_cw_odd = 0;
					enable1_pe_odd = 0;
					enable2_pe_odd = 0;
					grant_pe_odd = 0;
					arbi = 0;
				end
		endcase
	end

endmodule 