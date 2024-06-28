module tb_axis_rotate;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter TUSER_WIDTH = 8;

    // Testbench signals
    reg aclk;
    reg aresetn;
    reg [DATA_WIDTH-1:0] s_axis_tdata;
    reg [TUSER_WIDTH-1:0] s_axis_tuser;
    reg s_axis_tvalid;
    wire s_axis_tready;
    reg s_axis_tlast;
    wire [DATA_WIDTH-1:0] m_axis_tdata;
    wire [TUSER_WIDTH-1:0] m_axis_tuser;
    wire m_axis_tvalid;
    reg m_axis_tready;
    wire m_axis_tlast;

    // Instantiate the module
    axis_rotate #(
        .DATA_WIDTH(DATA_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH)
    ) uut (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tuser(s_axis_tuser),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tuser(m_axis_tuser),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );

    // Clock generation
    always #5 aclk = ~aclk;

    initial begin
        // Initialize signals
        aclk = 0;
        aresetn = 0;
        s_axis_tdata = 0;
        s_axis_tuser = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        m_axis_tready = 0;

        // Reset
        #10 aresetn = 1;

        // Apply test vectors
        #10 s_axis_tdata = 32'h12345678;
            s_axis_tuser = 8'h02;  // Rotate by 2 bytes
            s_axis_tvalid = 1;
            s_axis_tlast = 1;
            m_axis_tready = 1;

        #20 s_axis_tdata = 32'hAABBCCDD;
            s_axis_tuser = 8'h82;  // Rotate right by 2 bytes
            s_axis_tvalid = 1;
            s_axis_tlast = 1;

        #20 s_axis_tvalid = 0;

        #50 $stop;
    end

    initial begin
        $monitor("At time %t, s_axis_tdata = %h, s_axis_tuser = %h, m_axis_tdata = %h, m_axis_tuser = %h",
                 $time, s_axis_tdata, s_axis_tuser, m_axis_tdata, m_axis_tuser);
    end

endmodule
