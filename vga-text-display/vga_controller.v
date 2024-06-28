module vga_controller (
    input wire clk,               // System clock
    input wire reset,             // Asynchronous reset
    output wire hsync,            // Horizontal sync signal
    output wire vsync,            // Vertical sync signal
    output wire [3:0] red,        // Red color signal
    output wire [3:0] green,      // Green color signal
    output wire [3:0] blue,       // Blue color signal
    output wire [9:0] x,          // Current pixel X position
    output wire [9:0] y           // Current pixel Y position
);

    parameter H_ACTIVE = 640;     // Horizontal active pixels
    parameter H_FRONT = 16;       // Horizontal front porch
    parameter H_SYNC = 96;        // Horizontal sync pulse
    parameter H_BACK = 48;        // Horizontal back porch
    parameter H_TOTAL = 800;      // Total horizontal pixels

    parameter V_ACTIVE = 480;     // Vertical active pixels
    parameter V_FRONT = 10;       // Vertical front porch
    parameter V_SYNC = 2;         // Vertical sync pulse
    parameter V_BACK = 33;        // Vertical back porch
    parameter V_TOTAL = 525;      // Total vertical pixels

    reg [9:0] h_count;            // Horizontal counter
    reg [9:0] v_count;            // Vertical counter

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1) begin
                    v_count <= 0;
                end else begin
                    v_count <= v_count + 1;
                end
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    assign hsync = (h_count >= H_ACTIVE + H_FRONT && h_count < H_ACTIVE + H_FRONT + H_SYNC) ? 0 : 1;
    assign vsync = (v_count >= V_ACTIVE + V_FRONT && v_count < V_ACTIVE + V_FRONT + V_SYNC) ? 0 : 1;
    assign x = (h_count < H_ACTIVE) ? h_count : 10'd0;
    assign y = (v_count < V_ACTIVE) ? v_count : 10'd0;
    assign red = (h_count < H_ACTIVE && v_count < V_ACTIVE) ? 4'b1111 : 4'b0000;
    assign green = (h_count < H_ACTIVE && v_count < V_ACTIVE) ? 4'b1111 : 4'b0000;
    assign blue = (h_count < H_ACTIVE && v_count < V_ACTIVE) ? 4'b1111 : 4'b0000;

endmodule
