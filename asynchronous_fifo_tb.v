`timescale 1ns/10ps
module asynchronous_fifo_tb ();

parameter address_bus_length = 4;
parameter data_bus_length = 8;
parameter fifo_depth = 2**address_bus_length;

parameter trans_period = 40;
parameter recv_period = 100;

reg trans_clk,recv_clk,trans_rst,recv_rst;
reg write_enable,read_enable;
reg[data_bus_length-1:0] trans_data;
wire[data_bus_length-1:0] recv_data;
wire fifo_full,fifo_empty;

asynchronous_fifo DUT(trans_clk,trans_rst,write_enable,recv_clk,recv_rst,read_enable,fifo_full,fifo_empty,trans_data,recv_data);

initial 
begin
trans_clk = 1'b0;
trans_rst = 1'b0;
write_enable = 1'b0;
repeat(2)
begin
#(trans_period/2);
trans_clk = ~trans_clk;
end
trans_rst = 1'b1;
forever
begin
#(trans_period/2);
trans_clk = ~trans_clk;
end
end

initial 
begin
recv_clk = 1'b0;
recv_rst = 1'b0;
read_enable = 1'b0;
repeat(2)
begin
#(recv_period/2);
recv_clk = ~recv_clk;
end
recv_rst = 1'b1;
forever
begin
#(recv_period/2);
recv_clk = ~recv_clk;
end
end

initial
begin
@(posedge trans_rst);
@(negedge trans_clk); write_enable = 1'b1;
@(negedge trans_clk); trans_data = 8'd17;
@(negedge trans_clk); trans_data = 8'd18;
@(negedge trans_clk); trans_data = 8'd19;
@(negedge trans_clk); trans_data = 8'd20;
@(negedge trans_clk); trans_data = 8'd21;
@(negedge trans_clk); trans_data = 8'd22;
@(negedge trans_clk); trans_data = 8'd23;
@(negedge trans_clk); trans_data = 8'd24;
@(negedge trans_clk); trans_data = 8'd25;
@(negedge trans_clk); trans_data = 8'd26;
@(negedge trans_clk); trans_data = 8'd27;
@(negedge trans_clk); trans_data = 8'd28;
@(negedge trans_clk); trans_data = 8'd29;
@(negedge trans_clk); trans_data = 8'd30;
@(negedge trans_clk); trans_data = 8'd31;
@(negedge trans_clk); trans_data = 8'd32;
@(negedge trans_clk); write_enable = 1'b0;
end

initial
begin
@(posedge recv_rst);
@(negedge recv_clk); read_enable = 1'b1;
repeat(20*recv_period) @(posedge recv_clk);
@(negedge recv_clk); read_enable = 1'b0;
end

endmodule
