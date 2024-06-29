module tb_axi4_stream_video_processing;

reg clk = 0;
reg reset_n = 0;
reg [23:0] s_axis_tdata;
reg s_axis_tvalid;
reg s_axis_tlast;
wire s_axis_tready;

wire [23:0] m_axis_tdata;
wire m_axis_tvalid;
reg m_axis_tready;
wire m_axis_tlast;

// Clock generation
always #5 clk = ~clk;

// DUT instantiation
axi4_stream_video_processing #(
    .DATA_WIDTH(24)
) uut (
    .clk(clk),
    .reset_n(reset_n),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast)
);

// Test stimulus
initial begin
    reset_n = 0;
    #20 reset_n = 1;
    #10;

    // Simulate a frame of data
    s_axis_tvalid = 1;
    m_axis_tready = 1;
    for (integer i = 0; i < 10; i = i + 1) begin
        s_axis_tdata = $random;
        s_axis_tlast = (i == 9);
        #10;
    end

    s_axis_tvalid = 0;
    s_axis_tlast = 0;
    #100 $finish;
end

endmodule
