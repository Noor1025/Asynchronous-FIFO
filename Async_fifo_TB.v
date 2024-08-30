async_fifo DUT(tx_clk, tx_rst_n, wr_en, rx_clk, rx_rst_n, rd_en, fifo_full_o, fifo_empty_o, tx_data_i, rx_data_o);

initial 
begin
    tx_clk = 1'b0;
    tx_rst_n = 1'b0;
    wr_en = 1'b0;
    repeat(2)
    begin
        #(TX_CLK_PERIOD/2);
        tx_clk = ~tx_clk;
    end
    tx_rst_n = 1'b1;
    forever
    begin
        #(TX_CLK_PERIOD/2);
        tx_clk = ~tx_clk;
        #1000000 $finish;
    end
end

initial 
begin
    rx_clk = 1'b0;
    rx_rst_n = 1'b0;
    rd_en = 1'b0;
    repeat(2)
    begin
        #(RX_CLK_PERIOD/2);
        rx_clk = ~rx_clk;
    end
    rx_rst_n = 1'b1;
    forever
    begin
        #(RX_CLK_PERIOD/2);
        rx_clk = ~rx_clk;
        #1000000 $finish;
    end
end

initial
begin
    @(posedge tx_rst_n);
    @(negedge tx_clk); wr_en = 1'b1;
    @(negedge tx_clk); tx_data_i = 8'd17;
    @(negedge tx_clk); tx_data_i = 8'd18;
    @(negedge tx_clk); tx_data_i = 8'd19;
    @(negedge tx_clk); tx_data_i = 8'd20;
    @(negedge tx_clk); tx_data_i = 8'd21;
    @(negedge tx_clk); tx_data_i = 8'd22;
    @(negedge tx_clk); tx_data_i = 8'd23;
    @(negedge tx_clk); tx_data_i = 8'd24;
    @(negedge tx_clk); tx_data_i = 8'd25;
    @(negedge tx_clk); tx_data_i = 8'd26;
    @(negedge tx_clk); tx_data_i = 8'd27;
    @(negedge tx_clk); tx_data_i = 8'd28;
    @(negedge tx_clk); tx_data_i = 8'd29;
    @(negedge tx_clk); tx_data_i = 8'd30;
    @(negedge tx_clk); tx_data_i = 8'd31;
    @(negedge tx_clk); tx_data_i = 8'd32;
    @(negedge tx_clk); wr_en = 1'b0;
end

initial
begin
    @(posedge rx_rst_n);
    @(negedge rx_clk); rd_en = 1'b1;
    repeat(20*RX_CLK_PERIOD) @(posedge rx_clk);
    @(negedge rx_clk); rd_en = 1'b0;
end

endmodule
