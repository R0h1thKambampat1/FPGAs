module top (
    input wire clk,        // System clock
    input wire reset,      // Asynchronous reset
    input wire rx,         // UART receive data line
    output wire hsync,     // VGA horizontal sync
    output wire vsync,     // VGA vertical sync
    output wire [3:0] red, // VGA red signal
    output wire [3:0] green,// VGA green signal
    output wire [3:0] blue // VGA blue signal
);

    wire [7:0] rx_data;
    wire rx_data_ready;
    wire [9:0] x;
    wire [9:0] y;
    wire [7:0] char;

    uart_rx #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) uart (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(rx_data),
        .data_ready(rx_data_ready)
    );

    vga_controller vga (
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .x(x),
        .y(y)
    );

    text_buffer buffer (
        .clk(clk),
        .reset(reset),
        .data_in(rx_data),
        .data_ready(rx_data_ready),
        .x(x),
        .y(y),
        .char(char)
    );

    assign red = (char != 8'h20) ? 4'b1111 : 4'b0000;   // Display white text
    assign green = (char != 8'h20) ? 4'b1111 : 4'b0000; // on black background
    assign blue = (char != 8'h20) ? 4'b1111 : 4'b0000;

endmodule
