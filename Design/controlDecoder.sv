module controlDecoder(
  input  logic [6:0] opcode,
  input  logic       zero,
  
  output logic       branch,
  output logic       resultSrc,
  output logic       memWrite,
  output logic [1:0] aluOp, 
  output logic       aluSrc,
  output logic [1:0] immSrc,
  output logic       regWrite
);

  // pcSrc should be computed in top module as:
  // pcSrc = branch & zero;

  always_comb begin
    // Default values (safe)
    branch    = 1'b0;
    resultSrc = 1'b0;
    memWrite  = 1'b0;
    aluOp     = 2'b00;
    aluSrc    = 1'b0;
    immSrc    = 2'b00;
    regWrite  = 1'b0;

    case(opcode)

      // lw
      7'b0000011 : begin
        branch    = 1'b0;
        resultSrc = 1'b1;
        memWrite  = 1'b0;
        aluOp     = 2'b00;
        aluSrc    = 1'b1;
        immSrc    = 2'b00;
        regWrite  = 1'b1;
      end

      // sw
      7'b0100011 : begin
        branch    = 1'b0;
        resultSrc = 1'b0; // don't care
        memWrite  = 1'b1;
        aluOp     = 2'b00;
        aluSrc    = 1'b1;
        immSrc    = 2'b01;
        regWrite  = 1'b0;
      end

      // R-type
      7'b0110011 : begin
        branch    = 1'b0;   // MUST be 0
        resultSrc = 1'b0;
        memWrite  = 1'b0;
        aluOp     = 2'b10;
        aluSrc    = 1'b0;
        immSrc    = 2'b00;  // don't care
        regWrite  = 1'b1;
      end

      // beq
      7'b1100011 : begin
        branch    = 1'b1;   // only branch instruction asserts this
        resultSrc = 1'b0;   // don't care
        memWrite  = 1'b0;
        aluOp     = 2'b01;
        aluSrc    = 1'b0;
        immSrc    = 2'b10;
        regWrite  = 1'b0;
      end
      
      7'b1101111 : begin
        branch    = 1'b0;
        resultSrc = 1'b1;
        memWrite  = 1'b0;
        aluOp     = 2'b00; //don't care
        aluSrc    = 1'b1;
        immSrc    = 2'b00;
        regWrite  = 1'b1;
      end

      default: begin
        // keep defaults
      end

    endcase
  end

endmodule
