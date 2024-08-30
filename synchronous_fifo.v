module synchronous_fifo(clk,reset,write_enable,read_enable,trans_data,recv_data,fifo_full,fifo_empty);

parameter address_bus_length = 4;
parameter data_bus_length = 8;
parameter fifo_depth = 2**address_bus_length;

input clk,reset;
input write_enable,read_enable;
input[data_bus_length-1:0] trans_data;
output[data_bus_length-1:0] recv_data;
output fifo_full,fifo_empty;

reg[data_bus_length-1:0] fifo[fifo_depth-1:0];

reg[address_bus_length:0] wptr,rptr;

always@(posedge clk)
begin
if(reset)
begin
wptr <= 5'b00000;
rptr <= 5'b00000;
end
else
if((~fifo_full) & write_enable)
begin
fifo[wptr[address_bus_length-1:0]] <= trans_data;
wptr <= wptr+1;
end
if((~fifo_empty) & read_enable)
rptr <= rptr+1;
end
assign recv_data = fifo[rptr[address_bus_length-1:0]];

assign  fifo_full  = ((wptr[address_bus_length-1:0] == rptr[address_bus_length-1:0]) && (wptr[address_bus_length] ^ rptr[address_bus_length]));
assign  fifo_empty = ((rptr[address_bus_length-1:0] == wptr[address_bus_length-1:0]) && (~(rptr[address_bus_length]^wptr[address_bus_length])));

endmodule
