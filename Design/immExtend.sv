module immExtend(
  // Input: Bits 31 down to 7 of the instruction
  input  logic [31:7] instr, 
  input  logic [1:0]  immSrc,
  output logic [31:0] immExt
);

  always_comb begin
    case(immSrc)
      // I-Type: {{20{Sign}}, Inst[31:20]}
      2'b00 : immExt = { {20{instr[31]}}, instr[31:20] }; 

      // S-Type: {{20{Sign}}, Inst[31:25], Inst[11:7]}
      2'b01 : immExt = { {20{instr[31]}}, instr[31:25], instr[11:7] }; 

      // B-Type: {{19{Sign}}, Sign, Inst[7], Inst[30:25], Inst[11:8], 0}
      2'b10 : immExt = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 }; 
      
      // J-Type (JAL): {{11{Sign}}, Inst[31], Inst[19:12], Inst[20], Inst[30:21], 0}
      2'b11 : immExt = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };
      
      default : immExt = '0; // Fixed missing colon
    endcase
  end

endmodule