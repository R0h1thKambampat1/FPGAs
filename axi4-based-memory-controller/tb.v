module tb_axi4_memory_controller;

// Clock and reset generation
reg clk = 0;
reg reset_n = 0;

always #5 clk = ~clk;

initial begin
    reset_n = 0;
    #10 reset_n = 1;
end

// DUT instantiation
axi4_memory_controller #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(32)
) uut (
    .clk(clk),
    .reset_n(reset_n),
    .axi_awaddr(),
    .axi_awlen(),
    .axi_awsize(),
    .axi_awburst(),
    .axi_awvalid(),
    .axi_awready(1),
    .axi_wdata(),
    .axi_wlast(),
    .axi_wvalid(),
    .axi_wready(1),
    .axi_bresp(2'b00),
    .axi_bvalid(1),
    .axi_bready(),
    .axi_araddr(),
    .axi_arlen(),
    .axi_arsize(),
    .axi_arburst(),
    .axi_arvalid(),
    .axi_arready(1),
    .axi_rdata(32'h12345678),
    .axi_rlast(1),
    .axi_rvalid(1),
    .axi_rready()
);

// Test stimulus
initial begin
    // Write transaction test
    start_write = 1;
    write_addr = 32'h00000000;
    write_len = 4;
    #100;
    start_write = 0;

    // Read transaction test
    start_read = 1;
    read_addr = 32'h00000000;
    read_len = 4;
    #100;
    start_read = 0;

    #1000 $finish;
end

endmodule
