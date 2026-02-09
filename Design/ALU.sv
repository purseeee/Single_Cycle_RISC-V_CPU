module ALU #(
  parameter WIDTH = 32
)(
  input  logic  [WIDTH-1:0]srcA, srcB, 
  output logic  [WIDTH-1:0]ALUResult,
  input  logic  [2:0]ALUControl,
  output logic  zero
);
  
  //we will keep ALUSource mux in top_module and not here
  
  always_comb
    begin
      case(ALUControl)
      3'b000 : ALUResult = srcA + srcB;
      3'b001 : ALUResult = srcA - srcB;
      3'b010 : ALUResult = srcA & srcB;
      3'b011 : ALUResult = srcA | srcB;
      3'b100: ALUResult = {{(WIDTH-1){1'b0}}, ($signed(srcA) < $signed(srcB))};

      default : ALUResult = '0;
        
      endcase 
    end
  
  assign zero = (ALUResult == '0);//zero flag whenever result is 0
  
endmodule
      
  
  
  
  
  
  
  
  
  
  
