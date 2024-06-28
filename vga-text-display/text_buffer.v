module text_buffer (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    input wire data_ready,
    input wire [9:0] x,
    input wire [9:0] y,
    output wire [7:0] char
);

    reg [7:0] buffer[0:79][0:59]; // 80x60 character buffer

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            integer i, j;
            for (i = 0; i < 80; i = i + 1) begin
                for (j = 0; j < 60; j = j + 1) begin
                    buffer[i][j] <= 8'h20; // Initialize buffer with spaces
                end
            end
        end else if (data_ready) begin
            integer i, j;
            for (i = 0; i < 80; i = i + 1) begin
                for (j = 0; j < 60; j = j + 1) begin
                    if (buffer[i][j] == 8'h20) begin
                        buffer[i][j] <= data_in;
                        i = 80;
                        j = 60;
                    end
                end
            end
        end
    end

    assign char = buffer[x / 8][y / 8]; // 8x8 character cell size

endmodule
