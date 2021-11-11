module cardinal_nic(
  input             clk, 
  input             reset, 
  input [1:0]       addr, 
  input [63:0]      d_in,
  input             nicEn, 
  input             nicWrEn, 
  input             net_ro, 
  input             net_polarity, 
  input             net_si, 
  input [63:0]      net_di, 
  output reg        net_ri, 
  output reg        net_so, 
  output reg [63:0] net_do,
  output reg [63:0] d_out
);

parameter INPUT_CHANNEL_BUFFER             = 2'b00;
parameter INPUT_CHANNEL_STATUE_REGISTER    = 2'b01;
parameter OUTPUT_CHANNEL_BUFFER            = 2'b10;
parameter OUTPUT_CHANNEL_STATUE_REGISTER   = 2'b11;

reg input_statue_reg;
reg output_statue_reg;
reg[63:0] input_buffer;
reg[63:0] output_buffer;

//send data to router
always @(posedge clk) begin
  if(reset) begin
    net_do <= 64'b0;
    net_so <= 1'b0;
  end 
  else begin
    if(output_statue_reg == 1'b1 && net_ro == 1'b1 && net_polarity == output_buffer[63]) begin
       net_do <= output_buffer;
       net_so            <= 1'b1;
       //$display("NIC -> %h -> router", net_do);
    end 
    else begin
       net_do <= net_do;
       net_so            <= 1'b0;
       //$display("NIC -> x -> router");
    end
  end
end

//receive data from processor
always @(posedge clk) begin 
  if(reset) begin
    output_buffer <= 64'b0;
  end 
  else begin
    if(nicEn && nicWrEn && addr == OUTPUT_CHANNEL_BUFFER) begin
      output_buffer <= d_in;
      //$display("processor -> %h -> NIC", output_buffer);
    end 
    else begin
      output_buffer <= output_buffer;
      //$display("processor -> x -> NIC");
    end
  end 
end

//value of output register
always @(posedge clk) begin
  if(reset) begin
    output_statue_reg <= 1'b0;
    //net_so <= 1'b0;
  end 
  else begin
    if(output_statue_reg == 1'b1 && net_ro == 1'b1 && net_polarity == output_buffer[63]) begin
      output_statue_reg <= 1'b0;
      //net_so            <= 1'b0;
      //$display("NIC -> %d -> router", output_statue_reg);
    end 
    else if(nicEn && nicWrEn && addr == OUTPUT_CHANNEL_BUFFER) begin
      output_statue_reg <= 1'b1;
      //net_so            <= 1'b1;
      //$display("processor -> %d -> NIC", output_statue_reg);
    end 
    else begin
      output_statue_reg <= output_statue_reg;
      //net_so            <= net_so;
      //$display("no data commnuication between PROCESSOR -> ROUTER");
    end
  end
end 

//store data from router
always @(posedge clk) begin
  if(reset) begin
    input_buffer <= 64'b0;
  end 
  else begin
    if(net_ri == 1'b1 && net_si == 1'b1) begin
      input_buffer <= net_di;
      //$display("router -> %h -> NIC", input_buffer);
    end 
    else begin
      input_buffer <= input_buffer;
      //$display("router -> x -> NIC");
    end 
  end
end

//send data to processor
always @(posedge clk) begin
  if(reset) begin
    d_out <= 64'b0;
  end 
  else begin
    if(nicEn && !nicWrEn) begin
      case(addr)
        INPUT_CHANNEL_BUFFER:            d_out <= input_buffer;        
        INPUT_CHANNEL_STATUE_REGISTER:   d_out <= {input_statue_reg, 63'b0};  
        //OUTPUT_CHANNEL_BUFFER:           d_out <= output_buffer;
        OUTPUT_CHANNEL_STATUE_REGISTER:  d_out <= {output_statue_reg, 63'b0};  
        default:                         d_out <= 64'b0;
      endcase
      //$display("NIC -> %h -> processor", d_out);
    end 
    else begin
      d_out <= d_out;
      //$display("NIC -> x -> processor");
    end
  end
end

//value of input register
always @(posedge clk) begin
  if(reset) begin
    input_statue_reg <= 1'b0;
    net_ri           <= 1'b1;
  end 
  else begin
    if(nicEn && !nicWrEn && addr == INPUT_CHANNEL_BUFFER) begin
      input_statue_reg <= 1'b0;
      net_ri           <= 1'b1;
      //$display("NIC -> %d ->  processor", input_statue_reg);
    end 
    else if(net_ri == 1'b1 && net_si == 1'b1) begin
      input_statue_reg <= 1'b1;
      net_ri           <= 1'b0;
      //$display("router -> %d -> NIC", input_statue_reg);
    end 
    else begin
      input_statue_reg <= input_statue_reg;
      net_ri           <= net_ri;
      //$display("---no data commnuication from ROUTER -> PROCESSOR---");
    end
  end
end

endmodule

