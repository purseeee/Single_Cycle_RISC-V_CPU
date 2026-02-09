//Hardcoded loop test
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

  initial begin
    for (int i = 0; i < DEPTH; i++) mem[i] = 0;

    // 1. lw x1, 0(x0)   -> x1 = 3
    mem[0] = 32'h00002083; 
    
    // 2. lw x2, 4(x0)   -> x2 = 1
    mem[1] = 32'h00402103; 

    // 3. add x3, x0, x0 -> x3 = 0 (Init Sum)
    mem[2] = 32'h000001B3; 

    // --- LOOP START (PC = 12 / Word 3) ---
    // 4. beq x1, x0, +16 -> If x1=0, Jump to End (PC+16 -> Target 28)
    // Imm=16 (0x10) -> Encoded B-Type
    mem[3] = 32'h00008863; 

    // 5. add x3, x3, x1 -> Sum += x1
    mem[4] = 32'h001181B3; 

    // 6. sub x1, x1, x2 -> x1 -= 1
    mem[5] = 32'h402080B3; 

    // 7. beq x0, x0, -12 -> Jump back to Loop (PC-12 -> Target 12)
    // Imm=-12 (0xFF4) -> Encoded B-Type
    mem[6] = 32'hFE000AE3; 

    // --- END LABEL (PC = 28 / Word 7) ---
    // 8. sw x3, 8(x0)   -> Store Result (6) to Mem[8]
    mem[7] = 32'h00302423; 

  end

  assign instr = mem[word_addr];

endmodule