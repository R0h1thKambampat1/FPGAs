module async_fifo #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 4) (
    input wire wr_clk,
    input wire rd_clk,
    input wire reset,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] wr_data,
    output wire [DATA_WIDTH-1:0] rd_data,
    output wire fifo_full,
    output wire fifo_empty
);

    // Internal signals
    reg [DATA_WIDTH-1:0] fifo_mem [0:(1<<ADDR_WIDTH)-1];
    reg [ADDR_WIDTH:0] wr_ptr = 0, rd_ptr = 0;
    reg [ADDR_WIDTH:0] rd_ptr_gray = 0, wr_ptr_gray = 0;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1 = 0, rd_ptr_gray_sync2 = 0;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1 = 0, wr_ptr_gray_sync2 = 0;

    // Write pointer logic
    always @(posedge wr_clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !fifo_full) begin
            fifo_mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
            wr_ptr_gray <= (wr_ptr + 1) ^ ((wr_ptr + 1) >> 1); // Binary to Gray code
        end
    end

    // Read pointer logic
    always @(posedge rd_clk or posedge reset) begin
        if (reset) begin
            rd_ptr <= 0;
            rd_ptr_gray <= 0;
        end else if (rd_en && !fifo_empty) begin
            rd_ptr <= rd_ptr + 1;
            rd_ptr_gray <= (rd_ptr + 1) ^ ((rd_ptr + 1) >> 1); // Binary to Gray code
        end
    end

    // Synchronize write pointer to read clock domain
    always @(posedge rd_clk or posedge reset) begin
        if (reset) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // Synchronize read pointer to write clock domain
    always @(posedge wr_clk or posedge reset) begin
        if (reset) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // FIFO status flags
    assign fifo_empty = (wr_ptr_gray_sync2 == rd_ptr_gray);
    assign fifo_full = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

    // Read data output
    assign rd_data = fifo_mem[rd_ptr[ADDR_WIDTH-1:0]];

endmodule
