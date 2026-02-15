module ALU #(
  parameter WIDTH = 32
)(
  input  logic [WIDTH-1:0] srcA, srcB, 
  output logic [WIDTH-1:0] ALUResult,
  input  logic [2:0]       ALUControl,
  output logic             zero
);
  
  always_comb begin
      case(ALUControl)
          3'b000: ALUResult = srcA + srcB;       // ADD
          3'b001: ALUResult = srcA - srcB;       // SUB
          3'b010: ALUResult = srcA & srcB;       // AND
          3'b011: ALUResult = srcA | srcB;       // OR
          3'b100: ALUResult = {{(WIDTH-1){1'b0}}, ($signed(srcA) < $signed(srcB))}; // SLT
          
          // --- NEW: XOR Operation ---
          3'b101: ALUResult = srcA ^ srcB;       // XOR

          default: ALUResult = '0;
      endcase 
  end
  
  assign zero = (ALUResult == '0);
  
endmodule  