module asynchronous_fifo(trans_clk,trans_rst,write_enable,recv_clk,recv_rst,read_enable,fifo_full,fifo_empty,trans_data,recv_data);

parameter address_bus_length = 4;
parameter data_bus_length = 8;
parameter fifo_depth = 2**address_bus_length;

input trans_clk,recv_clk,trans_rst,recv_rst;
input write_enable,read_enable;
input[data_bus_length-1:0] trans_data;
output[data_bus_length-1:0] recv_data;
output fifo_full,fifo_empty;

reg[data_bus_length-1:0] fifo[fifo_depth-1:0];

reg[address_bus_length:0] wptr,rptr;
wire[address_bus_length:0] wptr_trans_grey,rptr_recv_grey;
reg[address_bus_length:0] wptr_metarecv,rptr_metatrans;
reg[address_bus_length:0] wptr_recv_grey,rptr_trans_grey;
wire[address_bus_length:0] wptr_recv,rptr_trans;


always@(posedge trans_clk or negedge trans_rst)
begin
if(~trans_rst)
wptr <=  5'b00000;
else if((~fifo_full) & write_enable)
begin
fifo[wptr[address_bus_length-1:0]] <=  trans_data;
wptr <=  wptr+1;
end
end

assign  recv_data  = fifo[rptr[address_bus_length-1:0]];
always@(posedge recv_clk or negedge recv_rst)
begin
if(~recv_rst)
rptr <=  5'b00000;
else if((~fifo_empty) & read_enable)
rptr <=  rptr+1;
end

assign  wptr_trans_grey = wptr^(wptr>>1);
assign  rptr_recv_grey  = rptr^(rptr>>1);

always@(posedge trans_clk)
begin
if(~trans_rst)
begin
rptr_metatrans <=  5'b00000;
rptr_trans_grey <=  5'b00000;
end
else
begin
rptr_metatrans <=  rptr_recv_grey;
rptr_trans_grey <=  rptr_metatrans;
end
end

always@(posedge recv_clk)
begin
if(~recv_rst)
begin
wptr_metarecv <=  5'b00000;
wptr_recv_grey <=  5'b00000;
end
else
begin
wptr_metarecv <=  wptr_trans_grey;
wptr_recv_grey <=  wptr_metarecv;
end
end

assign  wptr_recv  = wptr_recv_grey^(wptr_recv_grey>>1)^(wptr_recv_grey>>2)^(wptr_recv_grey>>3);
assign  rptr_trans = rptr_trans_grey^(rptr_trans_grey>>1)^(rptr_trans_grey>>2)^(rptr_trans_grey>>3);

assign  fifo_full  = ((wptr[address_bus_length-1:0] == rptr_trans[address_bus_length-1:0]) && (wptr[address_bus_length] ^ rptr_trans[address_bus_length]));
assign  fifo_empty = ((rptr[address_bus_length-1:0] == wptr_recv[address_bus_length-1:0]) && (~(rptr[address_bus_length]^wptr_recv[address_bus_length])));

endmodule
