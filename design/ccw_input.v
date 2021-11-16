//EE577b Project Phase 1 router - ccw input module design
//Author: Sihao Chen
//Date: Oct.6.2021
//Add pe channel to original only supporting ccw
//Add seperate request signals for even and odd vc 

module ccw_input(ccwsi, ccwri, ccwdi, 
	request_ccw_odd, request_ccw_even, request_pe_odd, request_pe_even, 
	grant_ccw_odd, grant_ccw_even, grant_pe_odd, grant_pe_even, 
	data_out_even_ccw, data_out_odd_ccw, data_out_even_pe, data_out_odd_pe, 
	rst, clk, polarity);
	parameter DATA_WIDTH = 64;
	parameter STATE0 = 2'b01;
	parameter STATE1 = 2'b10;
	input ccwsi, grant_ccw_odd, grant_ccw_even, grant_pe_odd, grant_pe_even, rst, clk, polarity;
	output reg ccwri, request_ccw_odd, request_ccw_even, request_pe_odd, request_pe_even;
	input [DATA_WIDTH-1:0] ccwdi;
	output reg [DATA_WIDTH-1:0] data_out_even_ccw, data_out_odd_ccw, data_out_even_pe, data_out_odd_pe;

	reg [1:0] state_even, state_odd, next_state_even, next_state_odd;

	reg ccwri_odd, ccwri_even;
	reg enable_ccw_even, enable_ccw_odd, enable_pe_even, enable_pe_odd;

    
    reg [63:0] MEM_ccw_EVEN[0:7]; 
    reg [63:0] MEM_ccw_ODD[0:7];

    reg[0:2] even_head, even_tail;
    reg[0:2] odd_head, odd_tail;

    always@(posedge clk) begin
      if(rst) begin
        even_head <= 0;
        even_tail <= 0;
        odd_head  <= 0;
        odd_tail  <= 0;      
      end else if(ccwsi & polarity & (odd_tail != 7)) begin
      	odd_tail  <= odd_tail + 1;
      	even_tail <= even_tail;
      	odd_head  <= odd_head;
      	even_head <= even_head;
      end else if(ccwsi & !polarity & (even_tail != 7)) begin
      	even_tail <= even_tail + 1;
      	odd_head  <= odd_head;
      	even_head <= even_head;
      	odd_tail  <= odd_tail;
      end else if((grant_ccw_odd | grant_pe_odd) & (state_odd == STATE1)) begin
      	odd_head  <= odd_head + 1;
      	even_head <= even_head;
      	odd_tail  <= odd_tail;
      	even_tail <= even_tail;
      end else if((grant_ccw_even | grant_pe_even) & (state_even == STATE1)) begin
      	even_head <= even_head + 1;
      	odd_tail  <= odd_tail;
      	even_tail <= even_tail;
      	odd_head  <= odd_head;
      end
      else begin
      	even_head <= even_head;
      	odd_tail  <= odd_tail;
      	even_tail <= even_tail;
      	odd_head  <= odd_head;
      end
    end

    //buffer data for ccw channel
	always@(posedge clk) begin
		if (ccwsi & polarity & (odd_tail != 7)) begin
			MEM_ccw_ODD[odd_tail] <= ccwdi;
		end else begin
			MEM_ccw_ODD[odd_tail] <= MEM_ccw_ODD[odd_tail];
		end
	end

	always@(posedge clk) begin
        if (ccwsi & !polarity & (even_tail != 7)) begin
	        MEM_ccw_EVEN[even_tail] <= ccwdi;
		end else begin
			MEM_ccw_EVEN[even_tail] <= MEM_ccw_EVEN[even_tail];
		end
	end


	always@(*) begin
		//if (polarity) ccwri = ccwri_odd;
		//else ccwri = ccwri_even;
		ccwri = ccwri_even & ccwri_odd;
	end

	always@(posedge clk) begin
		if(rst) begin
			ccwri_odd <=1;
		end 
		else if(odd_tail == 7) begin
			ccwri_odd <= 0;
		end 
		else begin
			ccwri_odd <= 1;
		end 
	end 

	always@(posedge clk) begin
		if(rst) begin
			ccwri_even <=1;
		end 
		else if(even_tail == 7) begin
			ccwri_even <= 0;
		end 
		else begin
			ccwri_even <= 1;
		end 
	end 

	always@(*) begin
		if(rst) begin
			data_out_even_ccw <= 0;
			data_out_odd_ccw  <= 0;
			data_out_even_pe <= 0;
			data_out_odd_pe  <= 0;
		end 
		else if(request_ccw_odd) begin
			data_out_even_ccw <= data_out_even_ccw;
			data_out_odd_ccw  <= MEM_ccw_ODD[odd_head];
			data_out_even_pe <= data_out_even_pe;
			data_out_odd_pe  <= data_out_odd_pe;
		end 
		else if(request_pe_odd) begin
			data_out_even_ccw <= data_out_even_ccw;
			data_out_odd_ccw  <= data_out_odd_ccw;
			data_out_even_pe <= data_out_even_pe;
			data_out_odd_pe  <= MEM_ccw_ODD[odd_head];
		end
		else if(request_ccw_even) begin
			data_out_even_ccw <= MEM_ccw_EVEN[even_head];
			data_out_odd_ccw  <= data_out_odd_ccw;
			data_out_even_pe <= data_out_even_pe;
			data_out_odd_pe  <= data_out_odd_pe;
		end 
		else if(request_pe_even) begin
			data_out_even_ccw <= data_out_even_ccw;
			data_out_odd_ccw  <= data_out_odd_ccw;
			data_out_even_pe <= MEM_ccw_EVEN[even_head];
			data_out_odd_pe  <= data_out_odd_pe;
		end 
	    else begin
			data_out_even_ccw <= data_out_even_ccw;
			data_out_odd_ccw  <= data_out_odd_ccw;
			data_out_even_pe <= data_out_even_pe;
			data_out_odd_pe  <= data_out_odd_pe;
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

	// For odd vc, only when ccwsi and polarity both asserted, we use two state machines to indicated seperated vc channels
	always@(state_odd, grant_ccw_odd, grant_pe_odd, polarity) begin
		case(state_odd)
			STATE0 : 
				begin
					if ((odd_head != odd_tail) & polarity) next_state_odd = STATE1;
					else next_state_odd = STATE0;
				end
			STATE1 : 
				begin
					if (grant_ccw_odd | grant_pe_odd) next_state_odd = STATE0; // either one of grant signal is asserted
					else next_state_odd = STATE1;
				end
			default : next_state_odd = STATE0;
		endcase
	end

	always@(state_even, grant_ccw_even, grant_pe_even, polarity) begin
		case(state_even)
			STATE0 : 
				begin
					if ((even_head != even_tail) & !polarity) next_state_even = STATE1;
					else next_state_even = STATE0;
				end
			STATE1 : 
				begin
					if (grant_ccw_even | grant_pe_even) next_state_even = STATE0; // either one of grant signal is asserted
					else next_state_even = STATE1;
				end
			default : next_state_even = STATE0;
		endcase
	end
	// As long as ccwsi is asserted, generate enable signal for input buffer get packect from ccwdi and generate request signal to let output buffer know data is ready 
	always@(state_odd, grant_ccw_odd, grant_pe_odd) begin
		case(state_odd)
			STATE0 : 
				begin
					if ((odd_head != odd_tail) & polarity) begin
						if (MEM_ccw_ODD[odd_head][55:48] == 8'b00000000) begin
							request_pe_odd = 1;
							request_ccw_odd = 0;
						end else begin
							request_pe_odd = 0;
							request_ccw_odd = 1;
						end
					end else begin
						request_pe_odd = 0;
						request_ccw_odd = 0;
					end
				end
			STATE1 : 
				begin
					if (!grant_ccw_odd & !grant_pe_odd) begin
						if (MEM_ccw_ODD[odd_head][55:48] == 8'b00000000) begin
							request_pe_odd = 1;
							request_ccw_odd = 0;
						end else begin
							request_pe_odd = 0;
							request_ccw_odd = 1;
						end
					end else begin
						request_pe_odd = 0;
						request_ccw_odd = 0;
					end
				end
			default : 
				begin
					request_pe_odd = 0;
					request_ccw_odd = 0;
				end
		endcase
	end

	always@(state_even, grant_pe_even, grant_ccw_even) begin
		case(state_even)
			STATE0 : 
				begin
					if ((even_head != even_tail) & !polarity) begin
						if (MEM_ccw_EVEN[even_head][55:48] == 8'b00000000) begin
							request_pe_even = 1;
							request_ccw_even = 0;
						end else begin
							request_pe_even = 0;
							request_ccw_even = 1;
						end
					end else begin
						request_pe_even = 0;
						request_ccw_even = 0;
					end
				end
			STATE1 : 
				begin
					if (!grant_ccw_even & !grant_pe_even) begin
						if (MEM_ccw_EVEN[even_head][55:48] == 8'b00000000) begin
							request_pe_even = 1;
							request_ccw_even = 0;
						end else begin
							request_pe_even = 0;
							request_ccw_even = 1;
						end
					end else begin
						//enable_pe_even = 0;
						request_pe_even = 0;
						//enable_ccw_even = 0;
						request_ccw_even = 0;
					end
				end
			default : 
				begin
					request_pe_even = 0;
					request_ccw_even = 0;
				end
		endcase
	end




endmodule // ccw_input






