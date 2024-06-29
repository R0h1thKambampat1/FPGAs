module grayscale_conversion #(
    parameter DATA_WIDTH = 24 // Assuming RGB888 format
)(
    input wire [DATA_WIDTH-1:0] rgb_data,
    output wire [DATA_WIDTH-1:0] gray_data
);

wire [7:0] r, g, b;
assign r = rgb_data[23:16];
assign g = rgb_data[15:8];
assign b = rgb_data[7:0];

wire [7:0] gray;
assign gray = (r >> 2) + (g >> 1) + (b >> 2);

assign gray_data = {gray, gray, gray};

endmodule
