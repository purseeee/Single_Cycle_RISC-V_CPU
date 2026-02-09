module instructionMemory #(
  parameter WIDTH = 32,
  parameter DEPTH = 1024
)(
  input  logic [WIDTH-1:0] addr,
  output logic [WIDTH-1:0] instr
);

  localparam ADDR_BITS = $clog2(DEPTH);
  logic [WIDTH-1:0] mem [0:DEPTH-1];
  wire [ADDR_BITS-1:0] word_addr = addr[ADDR_BITS+1:2];

  // --- HARDCODED TEST PROGRAM ---
  initial begin
    // Init everything to 0 first (NOPs)
    for (int i = 0; i < DEPTH; i++) mem[i] = 0;

    // 1. lw x1, 0(x0)   -> Load 10 from Mem[0]
    mem[0] = 32'h00002083; 
    
    // 2. lw x2, 4(x0)   -> Load 3 from Mem[1]
    mem[1] = 32'h00402103; 

    // 3. add x3, x1, x2 -> 10 + 3 = 13 (0xD)
    mem[2] = 32'h002081B3; 

    // 4. sub x4, x1, x2 -> 10 - 3 = 7
    mem[3] = 32'h40208233; 

    // 5. and x5, x1, x2 -> 10 & 3 = 2
    mem[4] = 32'h0020F2B3; 

    // 6. or x6, x1, x2  -> 10 | 3 = 11 (0xB)
    mem[5] = 32'h0020E333; 

    // Program effectively ends here, followed by NOPs (0x00000000)
  end

  assign instr = mem[word_addr];

endmodule