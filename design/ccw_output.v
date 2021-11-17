//EE577b Project Phase 1 router - ccw output module design
//Author: Sihao Chen
//Date: Oct.6.2021
//Add pe channel to original only supporting ccw
//Add seperate request signals for even and odd vc 

module ccw_output(ccwso, ccwro, ccwdo, 
	data_in_even_ccw, data_in_odd_ccw, data_in_even_pe, data_in_odd_pe, 
	request_ccw_even, request_ccw_odd, request_pe_even, request_pe_odd, 
	grant_ccw_even, grant_ccw_odd, grant_pe_even, grant_pe_odd, 
	rst, clk, polarity);
	parameter DATA_WIDTH = 64;
	parameter STATE0 = 5'b00001;
	parameter STATE1 = 5'b00010;
	parameter STATE2 = 5'b00100;
	parameter STATE3 = 5'b01000;
	parameter STATE4 = 5'b10000;
	input ccwro, rst, clk, request_ccw_even, request_ccw_odd, request_pe_even, request_pe_odd, polarity;
	output reg ccwso, grant_ccw_even, grant_ccw_odd, grant_pe_even, grant_pe_odd;
	input [DATA_WIDTH-1:0] data_in_even_ccw, data_in_odd_ccw, data_in_even_pe, data_in_odd_pe;
	output reg [DATA_WIDTH-1:0] ccwdo;

	reg [4:0] state_even, state_odd, next_state_even, next_state_odd;
	reg enable1_ccw_even, enable1_ccw_odd, enable1_pe_even, enable1_pe_odd, enable2_ccw_even, enable2_ccw_odd, enable2_pe_even, enable2_pe_odd;
	reg [DATA_WIDTH-1:0] data_internal_even_ccw, data_internal_even_pe, data_internal_odd_ccw, data_internal_odd_pe;
	reg arbi_even, arbi_odd, arbi; //Trace priority, ccw first pe later, then change order

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

	//From output buffer to ccwdo when enable2 asserted
	always@(negedge clk) begin
		if (rst) begin
	    	ccwdo <= 0;
	    	ccwso <= 0;
		end else begin
			case({enable2_pe_even,enable2_pe_odd, enable2_ccw_even, enable2_ccw_odd})
				4'b1000 : 
					begin
						ccwdo <= {data_internal_even_pe[63:56], data_internal_even_pe[55:48] >> 1, data_internal_even_pe[47:0]}; // Hop value -1
						ccwso <= 1;
					end
				4'b0100 : 
					begin
						ccwdo <= {data_internal_odd_pe[63:56], data_internal_odd_pe[55:48] >> 1, data_internal_odd_pe[47:0]}; // Hop value -1
						ccwso <= 1;
					end
				4'b0010 : 
					begin
						ccwdo <= {data_internal_even_ccw[63:56], data_internal_even_ccw[55:48] >> 1, data_internal_even_ccw[47:0]}; // Hop value -1
						ccwso <= 1;
					end
				4'b0001 : 
					begin
						ccwdo <= {data_internal_odd_ccw[63:56], data_internal_odd_ccw[55:48] >> 1, data_internal_odd_ccw[47:0]}; // Hop value -1
						ccwso <= 1;
					end
				default : 
					begin
						ccwdo <= ccwdo;
						ccwso <= 0;
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

	always@(*) begin
      if(polarity == 1) begin
        arbi = arbi_even;
      end else begin
        arbi = arbi_odd;
      end
	end

	always@(state_even, request_ccw_even, request_pe_even, ccwro, polarity) begin
		case(state_even) 
			STATE0 : 
				begin
					if (request_ccw_even & request_pe_even) begin //request signal of ccw and pe come in the same time, then depending on the arbi signal which channel grant first
						if (!arbi) next_state_even = STATE1;
						else next_state_even = STATE3;
					end else if (request_ccw_even & !request_pe_even) next_state_even = STATE1;
					else if (request_pe_even & !request_ccw_even) next_state_even = STATE3;
					else next_state_even = STATE0;
				end
			STATE1 : 
				begin
					if (ccwro & !polarity) next_state_even = STATE2;
					else next_state_even = STATE1;
				end
			STATE2 : 
                begin
                	if (request_pe_even) next_state_even = STATE3;
			        else next_state_even = STATE0;
			    end
			STATE3 : 
				begin
					if (ccwro & !polarity) next_state_even = STATE4;
					else next_state_even = STATE3;
				end
			STATE4 : 
                begin
			        if(request_ccw_even) next_state_even = STATE1;
			        else next_state_even = STATE0;
			    end
			default : next_state_even = STATE0;
		endcase
	end

	always@(state_even, request_ccw_even, request_pe_even, rst, ccwro) begin
		case(state_even) 
			STATE0 : 
				begin
					enable1_ccw_even = 0;
					enable1_pe_even = 0;
					enable2_ccw_even = 0;
					enable2_pe_even = 0;
					grant_ccw_even = 0;
					grant_pe_even = 0;
					if (rst) arbi_even = 0;
					else arbi_even = arbi_even;
				end
			STATE1 : //For ccw channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_ccw_even = (ccwro == 1'b1) ? 1'b1 : 1'b0;
					enable2_ccw_even = 0;
					grant_ccw_even = (ccwro == 1'b1) ? 1'b1 : 1'b0;
					enable1_pe_even = 0;
					enable2_pe_even = 0;
					grant_pe_even = 0;
					if (request_ccw_even & request_pe_even) arbi_even = ~arbi_even; //Flip arbi_even signal to change the priority
					else arbi_even = arbi_even;
				end
			STATE2 : // For ccw channel, enable data transfer from output channel to ccwdo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_ccw_even = 0;
					enable2_ccw_even = 1;
					grant_ccw_even = 0;
					enable1_pe_even = 0;
					enable2_pe_even = 0;
					grant_pe_even = 0;
					arbi_even = arbi_even;
				end
			STATE3 : //For pe channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_ccw_even = 0;
					enable2_ccw_even = 0;
					grant_ccw_even = 0;
					enable1_pe_even = (ccwro == 1'b1) ? 1'b1 : 1'b0;
					enable2_pe_even = 0;
					grant_pe_even = (ccwro == 1'b1) ? 1'b1 : 1'b0;
					if (request_ccw_even & request_pe_even) arbi_even = ~arbi_even; //Flip arbi_even signal to change the priority
					else arbi_even = arbi_even;
				end
			STATE4 : // For pe channel, enable data transfer from output channel to ccwdo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_ccw_even = 0;
					enable2_ccw_even = 0;
					grant_ccw_even = 0;
					enable1_pe_even = 0;
					enable2_pe_even = 1;
					grant_pe_even = 0;
					arbi_even = arbi_even;
				end
			default : 
				begin
					enable1_ccw_even = 0;
					enable2_ccw_even = 0;
					grant_ccw_even = 0;
					enable1_pe_even = 0;
					enable2_pe_even = 0;
					grant_pe_even = 0;
					arbi_even = 0;
				end
		endcase
	end

	always@(state_odd, request_ccw_odd, request_pe_odd, ccwro, polarity) begin
		case(state_odd) 
			STATE0 : 
				begin
					if (request_ccw_odd & request_pe_odd) begin //request signal of ccw and pe come in the same time, then depending on the arbi signal which channel grant first
						if (!arbi) next_state_odd = STATE1;
						else next_state_odd = STATE3;
					end else if (request_ccw_odd & !request_pe_odd) next_state_odd = STATE1;
					else if (request_pe_odd & !request_ccw_odd) next_state_odd = STATE3;
					else next_state_odd = STATE0;
				end
			STATE1 : 
				begin
					if (ccwro & polarity) next_state_odd = STATE2;
					else next_state_odd = STATE1;
				end
			STATE2 : 
                begin
                	if (request_pe_odd) next_state_odd = STATE3;
			        else next_state_odd = STATE0;
			    end 
			STATE3 : 
				begin
					if (ccwro & polarity) next_state_odd = STATE4;
					else next_state_odd = STATE3;
				end
			STATE4 :
			    begin
			        if(request_ccw_odd) next_state_odd = STATE1;
			        else next_state_odd = STATE0;
			    end
			default : next_state_odd = STATE0;
		endcase
	end

	always@(state_odd, request_ccw_odd, request_pe_odd, rst, ccwro) begin
		case(state_odd) 
			STATE0 : 
				begin
					enable1_ccw_odd = 0;
					enable1_pe_odd = 0;
					enable2_ccw_odd = 0;
					enable2_pe_odd = 0;
					grant_ccw_odd = 0;
					grant_pe_odd = 0;
					if (rst) arbi_odd = 0;
					else arbi_odd = arbi_odd;
				end
			STATE1 : //For ccw channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_ccw_odd = (ccwro == 1'b1) ? 1'b1 : 1'b0;
					enable2_ccw_odd = 0;
					grant_ccw_odd = (ccwro == 1'b1) ? 1'b1 : 1'b0;
					enable1_pe_odd = 0;
					enable2_pe_odd = 0;
					grant_pe_odd = 0;
					if (request_ccw_odd & request_pe_odd) arbi_odd = ~arbi_odd; //Flip arbi_odd signal to change the priority
					else arbi_odd = arbi_odd;
				end
			STATE2 : // For ccw channel, enable data transfer from output channel to ccwdo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_ccw_odd = 0;
					enable2_ccw_odd = 1;
					grant_ccw_odd = 0;
					enable1_pe_odd = 0;
					enable2_pe_odd = 0;
					grant_pe_odd = 0;
					arbi_odd = arbi_odd;
				end
			STATE3 : //For pe channel, enable data transfer from input buffer to output buffer and assert grant signal to indicate output buffer got data
				begin
					enable1_ccw_odd = 0;
					enable2_ccw_odd = 0;
					grant_ccw_odd = 0;
					enable1_pe_odd = (ccwro == 1'b1) ? 1'b1 : 1'b0;
					enable2_pe_odd = 0;
					grant_pe_odd = (ccwro == 1'b1) ? 1'b1 : 1'b0;
					if (request_ccw_odd & request_pe_odd) arbi_odd = ~arbi_odd; //Flip arbi_odd signal to change the priority
					else arbi_odd = arbi_odd;
				end
			STATE4 : // For pe channel, enable data transfer from output channel to ccwdo, dessert the grant signal to indicate output buffer is ready for new data
				begin
					enable1_ccw_odd = 0;
					enable2_ccw_odd = 0;
					grant_ccw_odd = 0;
					enable1_pe_odd = 0;
					enable2_pe_odd = 1;
					grant_pe_odd = 0;
					arbi_odd = arbi_odd;
				end
			default : 
				begin
					enable1_ccw_odd = 0;
					enable2_ccw_odd = 0;
					grant_ccw_odd = 0;
					enable1_pe_odd = 0;
					enable2_pe_odd = 0;
					grant_pe_odd = 0;
					arbi_odd = 0;
				end
		endcase
	end

endmodule 

