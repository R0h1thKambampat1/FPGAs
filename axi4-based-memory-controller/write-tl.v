// State Machine for Write Transactions
typedef enum logic [2:0] {
    IDLE,
    WRITE_ADDR,
    WRITE_DATA,
    WRITE_RESP
} write_state_t;

write_state_t write_state;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        write_state <= IDLE;
        axi_awvalid <= 0;
        axi_wvalid <= 0;
        axi_bready <= 0;
    end else begin
        case (write_state)
            IDLE: begin
                if (start_write) begin
                    write_state <= WRITE_ADDR;
                    axi_awaddr <= write_addr;
                    axi_awlen <= write_len;
                    axi_awsize <= $clog2(DATA_WIDTH/8);
                    axi_awburst <= 2'b01; // INCR burst
                    axi_awvalid <= 1;
                end
            end
            WRITE_ADDR: begin
                if (axi_awready && axi_awvalid) begin
                    axi_awvalid <= 0;
                    write_state <= WRITE_DATA;
                    axi_wvalid <= 1;
                end
            end
            WRITE_DATA: begin
                if (axi_wready && axi_wvalid) begin
                    axi_wdata <= next_write_data; // Fetch next data word
                    axi_wlast <= (write_count == axi_awlen);
                    if (axi_wlast) begin
                        axi_wvalid <= 0;
                        write_state <= WRITE_RESP;
                        axi_bready <= 1;
                    end
                end
            end
            WRITE_RESP: begin
                if (axi_bvalid && axi_bready) begin
                    axi_bready <= 0;
                    write_state <= IDLE;
                end
            end
        endcase
    end
end
