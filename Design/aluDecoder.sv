module aluDecoder(
  input  logic [1:0] aluOp,      // from main control
  input  logic [2:0] funct3,      // instr[14:12]
  input  logic       funct7_5,    // instr[30] (only bit we care about)
  output logic [2:0] ALUControl
);

  always_comb begin
    // default = ADD
    ALUControl = 3'b000;

    case (aluOp)

      // 00: load/store -> always ADD
      2'b00: begin
        ALUControl = 3'b010; // ADD  //changed 3'b000
      end

      // 01: branch (beq) -> SUB for comparison
      2'b01: begin
        ALUControl = 3'b001; // SUB
      end

      // 10: R-type (and later I-type ALU ops)
      2'b10: begin
        case (funct3)
          3'b000: begin
            // ADD or SUB depending on funct7[5]
            if (funct7_5)
              ALUControl = 3'b001; // SUB
            else
              ALUControl = 3'b000; // ADD
          end

          3'b111: ALUControl = 3'b010; // AND
          3'b110: ALUControl = 3'b011; // OR
          3'b010: ALUControl = 3'b100; // SLT

          default: ALUControl = 3'b000; // default ADD
        endcase
      end

      default: begin
        ALUControl = 3'b000; // safe default
      end

    endcase
  end

endmodule

