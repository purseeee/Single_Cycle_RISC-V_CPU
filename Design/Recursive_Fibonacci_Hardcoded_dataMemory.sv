//Hardcoded dataMem for recursive fibonacci(5) 
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

    initial begin
        // Clean memory
        for (int i = 0; i < DEPTH; i++) mem[i] = 0;
    end

    always_ff @(posedge clk) begin
        if (we) mem[word_addr] <= wd;
    end
    
    assign rd = mem[word_addr];

endmodule