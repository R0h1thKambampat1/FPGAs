module uart_tx (
    input wire clk,              // System clock
    input wire reset,            // Asynchronous reset
    input wire [7:0] data_in,    // Data to transmit
    input wire start,            // Start transmission signal
    output reg tx,               // UART transmit data line
    output reg busy              // Busy flag
);

    parameter CLK_FREQ = 50000000; // 50 MHz clock frequency
    parameter BAUD_RATE = 9600;    // 9600 baud rate
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [15:0] clk_count;          // Clock counter
    reg [3:0] bit_count;           // Bit counter
    reg [9:0] shift_reg;           // Shift register including start, data, and stop bits

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_count <= 0;
            bit_count <= 0;
            busy <= 0;
            tx <= 1; // Idle state is high
        end else begin
            if (start && !busy) begin
                // Initialize transmission
                shift_reg <= {1'b1, data_in, 1'b0}; // {Stop bit, data, Start bit}
                clk_count <= 0;
                bit_count <= 0;
                busy <= 1;
                tx <= 0; // Start bit
            end else if (busy) begin
                if (clk_count < BIT_PERIOD - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    if (bit_count < 9) begin
                        bit_count <= bit_count + 1;
                        shift_reg <= shift_reg >> 1;
                        tx <= shift_reg[0];
                    end else begin
                        busy <= 0;
                        tx <= 1; // Idle state
                    end
                end
            end
        end
    end
endmodule
