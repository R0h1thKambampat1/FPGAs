module uart_tb;

    reg clk;
    reg reset;
    reg [7:0] tx_data;
    reg start_tx;
    wire tx;
    wire [7:0] rx_data;
    wire rx_data_ready;

    // Instantiate UART transmitter
    uart_tx #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) uut_tx (
        .clk(clk),
        .reset(reset),
        .data_in(tx_data),
        .start(start_tx),
        .tx(tx),
        .busy()
    );

    // Instantiate UART receiver
    uart_rx #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) uut_rx (
        .clk(clk),
        .reset(reset),
        .rx(tx),
        .data_out(rx_data),
        .data_ready(rx_data_ready)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        tx_data = 8'h55;
        start_tx = 0;

        // Release reset
        #100 reset = 0;

        // Start transmission
        #200 start_tx = 1;
        #20 start_tx = 0;

        // Wait for reception
        wait (rx_data_ready);

        // Check received data
        if (rx_data == tx_data) begin
            $display("Test passed: received data = %h", rx_data);
        end else begin
            $display("Test failed: received data = %h", rx_data);
        end

        $stop;
    end

    // Clock generation
    always #10 clk = ~clk; // 50 MHz clock

endmodule
