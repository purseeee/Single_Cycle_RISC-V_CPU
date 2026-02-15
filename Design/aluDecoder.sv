module aluDecoder(
  input  logic [1:0] aluOp,       // from main control
  input  logic [2:0] funct3,      // instr[14:12]
  input  logic       funct7_5,    // instr[30]
  output logic [2:0] ALUControl
);

  always_comb begin
    case (aluOp)

      // 00: lw/sw -> ADD
      2'b00: ALUControl = 3'b000;

      // 01: beq -> SUB
      2'b01: ALUControl = 3'b001;

      // 10: R-type (Uses funct7 bit 5 to distinguish ADD/SUB)
      2'b10: begin
        case (funct3)
          3'b000: ALUControl = (funct7_5) ? 3'b001 : 3'b000; // SUB / ADD
          3'b010: ALUControl = 3'b100; // SLT
          3'b100: ALUControl = 3'b101; // XOR
          3'b110: ALUControl = 3'b011; // OR
          3'b111: ALUControl = 3'b010; // AND
          default: ALUControl = 3'b000;
        endcase
      end

      // 11: I-Type ALU (Immediate) - The "ALL" Case
      2'b11: begin
        case (funct3)
          3'b000: ALUControl = 3'b000; // ADDI (Always ADD, ignores funct7)
          3'b010: ALUControl = 3'b100; // SLTI
          3'b100: ALUControl = 3'b101; // XORI
          3'b110: ALUControl = 3'b011; // ORI
          3'b111: ALUControl = 3'b010; // ANDI
          
          // Note: Shifts (SLLI, SRLI) require expanded ALUControl
          default: ALUControl = 3'b000;
        endcase
      end

      default: ALUControl = 3'b000;
    endcase
  end

endmodule