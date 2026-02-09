module dataMemory #(
    parameter WIDTH = 32,
    parameter DEPTH = 1024
)(
    input  logic             clk,
    input  logic             we,
    input  logic [WIDTH-1:0] addr, 
    input  logic [WIDTH-1:0] wd,
    output logic [WIDTH-1:0] rd
);

    localparam ADDR_BITS = $clog2(DEPTH);
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    wire [ADDR_BITS-1:0] word_addr = addr[ADDR_BITS+1:2];

    // --- PRE-LOAD DATA ---
    initial begin
        // Initialize all to 0
        for (int i = 0; i < DEPTH; i++) mem[i] = 0;

        // Load Test Values
        mem[0] = 32'd10; // Value A (at byte address 0)
        mem[1] = 32'd3;  // Value B (at byte address 4)
    end

    always_ff @(posedge clk) begin
        if (we) mem[word_addr] <= wd;
    end
    
    // Asynchronous Read (Required for Single Cycle lw)
    assign rd = mem[word_addr];

endmodule