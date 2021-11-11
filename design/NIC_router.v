module nic_router(
  input             clk,
  input             reset,
  input      [1:0]  addr_nic0,
  input      [63:0] d_in0,
  input             nicEn0,
  input             nicWrEn0,
  input      [1:0]  addr_nic1,
  input      [63:0] d_in1,
  input             nicEn1,
  input             nicWrEn1,
  input      [1:0]  addr_nic2,
  input      [63:0] d_in2,
  input             nicEn2,
  input             nicWrEn2,
  input      [1:0]  addr_nic3,
  input      [63:0] d_in3,
  input             nicEn3,
  input             nicWrEn3,
  output [63:0] d_out0,
  output [63:0] d_out1,
  output [63:0] d_out2,
  output [63:0] d_out3
);

  wire net_so0, net_so1, net_so2, net_so3;
  wire net_ri0, net_ri1, net_ri2, net_ri3;
  wire [63:0] net_do0, net_do1, net_do2, net_do3;
  wire net_ro0, net_ro1, net_ro2, net_ro3;
  wire net_si0, net_si1, net_si2, net_si3;
  wire [63:0] net_di0, net_di1, net_di2, net_di3;
  wire net_polarity_0, net_polarity_1, net_polarity_2, net_polarity_3;


  cardinal_nic nic0(clk, reset, addr_nic0, d_in0, nicEn0, nicWrEn0, net_ro0, net_polarity0, net_si0, net_di0, net_ri0, net_so0, net_do0, d_out0);
  cardinal_nic nic1(clk, reset, addr_nic1, d_in1, nicEn1, nicWrEn1, net_ro1, net_polarity1, net_si1, net_di1, net_ri1, net_so1, net_do1, d_out1);
  cardinal_nic nic2(clk, reset, addr_nic2, d_in2, nicEn2, nicWrEn2, net_ro2, net_polarity2, net_si2, net_di2, net_ri2, net_so2, net_do2, d_out2);
  cardinal_nic nic3(clk, reset, addr_nic3, d_in3, nicEn3, nicWrEn3, net_ro3, net_polarity3, net_si3, net_di3, net_ri3, net_so3, net_do3, d_out3);

  gold_ring router_ring(net_so0, net_so1, net_so2, net_so3,//pesi_1, pesi_2, pesi_3, pesi_4, //pesi -> net_so
  	                    net_ri0, net_ri1, net_ri2, net_ri3,//pero_1, pero_2, pero_3, pero_4, //pero -> net_ri
				        net_do0, net_do1, net_do2, net_do3,//pedi_1, pedi_2, pedi_3, pedi_4, //pedi -> net_do
				        net_ro0, net_ro1, net_ro2, net_ro3,//peri_1, peri_2, peri_3, peri_4, //peri -> net_ro 
				        net_si0, net_si1, net_si2, net_si3,//peso_1, peso_2, peso_3, peso_4, //peso -> net_si
				        net_di0, net_di1, net_di2, net_di3,//pedo_1, pedo_2, pedo_3, pedo_4, //pedo -> net_di
				        clk, reset, net_polarity0, net_polarity1, net_polarity2, net_polarity3
				        );


endmodule