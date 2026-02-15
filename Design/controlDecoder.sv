module controlDecoder(
  input  logic [6:0] opcode,
  input  logic       zero,
  
  output logic       branch,
  output logic [1:0] resultSrc, // Expanded to 2 bits
  output logic       memWrite,
  output logic [1:0] aluOp, 
  output logic       aluSrc,
  output logic [1:0] immSrc,
  output logic       regWrite,
  output logic       jump,     // Added Jump signal
  output logic       jalr
);

  always_comb begin
    // Defaults
    branch    = 0;
    resultSrc = 2'b00;
    memWrite  = 0;
    aluOp     = 2'b00;
    aluSrc    = 0;
    immSrc    = 2'b00;
    regWrite  = 0;
    jump      = 0;
    jalr      = 0;

    case(opcode)
      // lw
      7'b0000011 : begin
        resultSrc = 2'b01; // Select Data Memory
        aluSrc    = 1;
        regWrite  = 1;
      end

      // sw
      7'b0100011 : begin
        resultSrc = 2'b00; // x (don't care)
        memWrite  = 1;
        aluSrc    = 1;
        immSrc    = 2'b01; // S-Type
      end

      // R-type
      7'b0110011 : begin
        resultSrc = 2'b00; // Select ALU Result
        aluOp     = 2'b10;
        regWrite  = 1;
      end

      // beq
      7'b1100011 : begin
        branch    = 1;
        resultSrc = 2'b00; // x
        aluOp     = 2'b01;
        immSrc    = 2'b10; // B-Type
      end
      
      // addi (I-Type ALU) - NEW
      7'b0010011 : begin
        resultSrc = 2'b00; // Select ALU Result
        aluOp     = 2'b11; // Special I-Type Op
        aluSrc    = 1;     // Use Immediate
        immSrc    = 2'b00; // I-Type
        regWrite  = 1;
      end

      // jal - NEW/FIXED
      7'b1101111 : begin
        jump      = 1;
        resultSrc = 2'b10; // Select PC+4
        immSrc    = 2'b11; // J-Type
        regWrite  = 1;
      end
      
      
      // jalr - NEW
      7'b1100111 : begin
        jalr      = 1;     // Select ALUResult for PC
        resultSrc = 2'b10; // Write PC+4 to Reg (Link)
        aluSrc    = 1;     // Use Imm (rs1 + Imm)
        immSrc    = 2'b00; // I-Type Imm
        regWrite  = 1;
        aluOp     = 2'b11; // Force ADD (rs1 + Imm)
      end

      default: begin end
    endcase
  end
endmodule