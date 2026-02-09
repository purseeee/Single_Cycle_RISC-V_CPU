//Hardcoded instrMem Recursive function for Fibonacci{5}
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

    // --- MAIN ---
    mem[0] = 32'h3E800113; // addi sp, zero, 1000
    mem[1] = 32'h00500513; // addi a0, zero, 5 (Calculate fib(5))
    mem[2] = 32'h008000ef; // jal ra, +8 (Call fib at addr 16)
    mem[3] = 32'h00a02023; // sw a0, 0(zero) (Store result)
    mem[4] = 32'h00000063; // beq zero, zero, 0 (Halt)

    // --- FIB FUNCTION (Addr 16 / Index 4) ---
    // Prologue
    mem[4] = 32'hff410113; // addi sp, sp, -12
    mem[5] = 32'h00112423; // sw ra, 8(sp)
    mem[6] = 32'h00a12223; // sw a0, 4(sp)
    mem[7] = 32'h00812023; // sw s0, 0(sp)

    // Base Case Check
    mem[8] = 32'h00200293; // addi t0, zero, 2
    mem[9] = 32'h00552333; // slt t1, a0, t0
    mem[10]= 32'h00000393; // addi t2, zero, 0
    mem[11]= 32'h00730463; // beq t1, t2, +8 (Jump to Index 14 if n >= 2)

    // Base Case Return
    mem[12]= 32'h00c10113; // addi sp, sp, 12
    mem[13]= 32'h00008067; // jalr zero, ra, 0

    // Recursive Step (Index 14)
    mem[14]= 32'hfff50513; // addi a0, a0, -1
    mem[15]= 32'hfd0000ef; // jal ra, -48 (Call fib at Index 4)
    mem[16]= 32'h00050433; // add s0, a0, zero

    mem[17]= 32'h00412503; // lw a0, 4(sp)
    mem[18]= 32'hffe50513; // addi a0, a0, -2
    mem[19]= 32'hfc0000ef; // jal ra, -64 (Call fib at Index 4)

    mem[20]= 32'h00850533; // add a0, a0, s0

    // Epilogue
    mem[21]= 32'h00812083; // lw ra, 8(sp)
    mem[22]= 32'h00012403; // lw s0, 0(sp)
    mem[23]= 32'h00c10113; // addi sp, sp, 12
    mem[24]= 32'h00008067; // jalr zero, ra, 0
  end

  assign instr = mem[word_addr];

endmodule