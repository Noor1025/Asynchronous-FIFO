module async_fifo(
    tx_clk, tx_rst_n, wr_en, rx_clk, rx_rst_n, rd_en, fifo_full_o, fifo_empty_o, tx_data_i, rx_data_o
);

parameter ADDR_WIDTH = 4;
parameter DATA_WIDTH = 8;
parameter FIFO_DEPTH = 2**ADDR_WIDTH;

input tx_clk, rx_clk, tx_rst_n, rx_rst_n;
input wr_en, rd_en;
input [DATA_WIDTH-1:0] tx_data_i;
output [DATA_WIDTH-1:0] rx_data_o;
output fifo_full_o, fifo_empty_o;

reg [DATA_WIDTH-1:0] fifo_mem[FIFO_DEPTH-1:0];

reg [ADDR_WIDTH:0] wr_ptr, rd_ptr;
wire [ADDR_WIDTH:0] wr_ptr_gray_tx, rd_ptr_gray_rx;
reg [ADDR_WIDTH:0] wr_ptr_meta_rx, rd_ptr_meta_tx;
reg [ADDR_WIDTH:0] wr_ptr_gray_rx, rd_ptr_gray_tx;
wire [ADDR_WIDTH:0] wr_ptr_bin_rx, rd_ptr_bin_tx;

always @(posedge tx_clk or negedge tx_rst_n)
begin
    if (~tx_rst_n)
        wr_ptr <= 5'b00000;
    else if ((~fifo_full_o) & wr_en)
    begin
        fifo_mem[wr_ptr[ADDR_WIDTH-1:0]] <= tx_data_i;
        wr_ptr <= wr_ptr + 1;
    end
end

assign rx_data_o = fifo_mem[rd_ptr[ADDR_WIDTH-1:0]];

always @(posedge rx_clk or negedge rx_rst_n)
begin
    if (~rx_rst_n)
        rd_ptr <= 5'b00000;
    else if ((~fifo_empty_o) & rd_en)
        rd_ptr <= rd_ptr + 1;
end

assign wr_ptr_gray_tx = wr_ptr ^ (wr_ptr >> 1);
assign rd_ptr_gray_rx = rd_ptr ^ (rd_ptr >> 1);

always @(posedge tx_clk)
begin
    if (~tx_rst_n)
    begin
        rd_ptr_meta_tx <= 5'b00000;
        rd_ptr_gray_tx <= 5'b00000;
    end
    else
    begin
        rd_ptr_meta_tx <= rd_ptr_gray_rx;
        rd_ptr_gray_tx <= rd_ptr_meta_tx;
    end
end

always @(posedge rx_clk)
begin
    if (~rx_rst_n)
    begin
        wr_ptr_meta_rx <= 5'b00000;
        wr_ptr_gray_rx <= 5'b00000;
    end
    else
    begin
        wr_ptr_meta_rx <= wr_ptr_gray_tx;
        wr_ptr_gray_rx <= wr_ptr_meta_rx;
    end
end

assign wr_ptr_bin_rx = wr_ptr_gray_rx ^ (wr_ptr_gray_rx >> 1) ^ (wr_ptr_gray_rx >> 2) ^ (wr_ptr_gray_rx >> 3);
assign rd_ptr_bin_tx = rd_ptr_gray_tx ^ (rd_ptr_gray_tx >> 1) ^ (rd_ptr_gray_tx >> 2) ^ (rd_ptr_gray_tx >> 3);

assign fifo_full_o = ((wr_ptr[ADDR_WIDTH-1:0] == rd_ptr_bin_tx[ADDR_WIDTH-1:0]) && (wr_ptr[ADDR_WIDTH] ^ rd_ptr_bin_tx[ADDR_WIDTH]));
assign fifo_empty_o = ((rd_ptr[ADDR_WIDTH-1:0] == wr_ptr_bin_rx[ADDR_WIDTH-1:0]) && (~(rd_ptr[ADDR_WIDTH] ^ wr_ptr_bin_rx[ADDR_WIDTH])));

endmodule
