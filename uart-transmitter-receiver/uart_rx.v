module uart_rx (
    input wire clk,               // System clock
    input wire reset,             // Asynchronous reset
    input wire rx,                // UART receive data line
    output reg [7:0] data_out,    // Received data
    output reg data_ready         // Data ready flag
);

    parameter CLK_FREQ = 50000000; // 50 MHz clock frequency
    parameter BAUD_RATE = 9600;    // 9600 baud rate
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [15:0] clk_count;          // Clock counter
    reg [3:0] bit_count;           // Bit counter
    reg [7:0] shift_reg;           // Shift register for received data
    reg receiving;                 // Receiving flag

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_count <= 0;
            bit_count <= 0;
            shift_reg <= 0;
            receiving <= 0;
            data_ready <= 0;
        end else begin
            if (!receiving && !rx) begin
                // Start bit detected
                receiving <= 1;
                clk_count <= 0;
                bit_count <= 0;
                data_ready <= 0;
            end else if (receiving) begin
                if (clk_count < BIT_PERIOD - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    if (bit_count < 8) begin
                        bit_count <= bit_count + 1;
                        shift_reg <= {rx, shift_reg[7:1]};
                    end else begin
                        data_out <= shift_reg;
                        data_ready <= 1;
                        receiving <= 0;
                    end
                end
            end
        end
    end
endmodule
