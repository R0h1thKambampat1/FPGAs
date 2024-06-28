module axis_rotate #(
    parameter DATA_WIDTH = 32,   // Width of the data bus in bits
    parameter TUSER_WIDTH = 8    // Width of the tuser signal in bits
)(
    input  wire                     aclk,
    input  wire                     aresetn,

    // Slave AXI-Stream interface
    input  wire [DATA_WIDTH-1:0]    s_axis_tdata,
    input  wire [TUSER_WIDTH-1:0]   s_axis_tuser,
    input  wire                     s_axis_tvalid,
    output reg                      s_axis_tready,
    input  wire                     s_axis_tlast,

    // Master AXI-Stream interface
    output reg  [DATA_WIDTH-1:0]    m_axis_tdata,
    output reg  [TUSER_WIDTH-1:0]   m_axis_tuser,
    output reg                      m_axis_tvalid,
    input  wire                     m_axis_tready,
    output reg                      m_axis_tlast
);

    // Internal signals
    reg [DATA_WIDTH-1:0] rotated_data;
    wire [3:0] rotate_amount;
    wire direction;

    // Number of bytes to rotate (assuming 4 LSBs of tuser signal for rotation amount)
    assign rotate_amount = s_axis_tuser[3:0];

    // Rotation direction (MSB of tuser signal)
    assign direction = s_axis_tuser[TUSER_WIDTH-1];

    // Rotate function
    function automatic [DATA_WIDTH-1:0] rotate;
        input [DATA_WIDTH-1:0] data_in;
        input [3:0] amount;
        input dir;
        reg [DATA_WIDTH-1:0] result;
    begin
        if (dir == 1'b0) begin
            // Left rotate
            result = (data_in << (amount * 8)) | (data_in >> (DATA_WIDTH - amount * 8));
        end else begin
            // Right rotate
            result = (data_in >> (amount * 8)) | (data_in << (DATA_WIDTH - amount * 8));
        end
        rotate = result;
    end
    endfunction

    // Rotation logic
    always @(posedge aclk) begin
        if (~aresetn) begin
            s_axis_tready <= 1'b0;
            m_axis_tdata  <= {DATA_WIDTH{1'b0}};
            m_axis_tuser  <= {TUSER_WIDTH{1'b0}};
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
        end else begin
            if (s_axis_tvalid && m_axis_tready) begin
                rotated_data <= rotate(s_axis_tdata, rotate_amount, direction);
                m_axis_tdata <= rotated_data;
                m_axis_tuser <= s_axis_tuser;
                m_axis_tvalid <= 1'b1;
                m_axis_tlast <= s_axis_tlast;
                s_axis_tready <= 1'b1;
            end else if (m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
                s_axis_tready <= 1'b0;
            end
        end
    end

endmodule
