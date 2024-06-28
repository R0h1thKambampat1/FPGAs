// State Machine for Read Transactions
typedef enum logic [2:0] {
    READ_IDLE,
    READ_ADDR,
    READ_DATA
} read_state_t;

read_state_t read_state;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        read_state <= READ_IDLE;
        axi_arvalid <= 0;
        axi_rready <= 0;
    end else begin
        case (read_state)
            READ_IDLE: begin
                if (start_read) begin
                    read_state <= READ_ADDR;
                    axi_araddr <= read_addr;
                    axi_arlen <= read_len;
                    axi_arsize <= $clog2(DATA_WIDTH/8);
                    axi_arburst <= 2'b01; // INCR burst
                    axi_arvalid <= 1;
                end
            end
            READ_ADDR: begin
                if (axi_arready && axi_arvalid) begin
                    axi_arvalid <= 0;
                    read_state <= READ_DATA;
                    axi_rready <= 1;
                end
            end
            READ_DATA: begin
                if (axi_rvalid && axi_rready) begin
                    read_data_buffer <= axi_rdata; // Store read data
                    if (axi_rlast) begin
                        axi_rready <= 0;
                        read_state <= READ_IDLE;
                    end
                end
            end
        endcase
    end
end
