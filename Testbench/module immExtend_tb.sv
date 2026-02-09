module immExtend_tb();
  
  localparam NUM_IMMS = 4;
  
  //DUT ports
  logic [31:7] instr;
  logic [1:0]  immSrc;
  logic [31:0] immExt;
  
  //Golden reference
  logic [31:0]shadow_immExt; 
  
  //Instantiate DUT
  immExtend uut(.*);
  
  
  initial begin
    //Initialise signals
    instr = 0; immSrc = 0; immExt = 0; shadow_immExt = 0;

    $display("==========immExtend TB Start==========");

    //random tests
    for(int i = 0; i < NUM_IMMS; i++)begin
      immSrc = i;

      repeat (50) begin
        instr = $urandom();

        case(immSrc)
          // I-Type: {{20{Sign}}, Inst[31:20]}
          2'b00 : shadow_immExt = { {20{instr[31]}}, instr[31:20] }; 

          // S-Type: {{20{Sign}}, Inst[31:25], Inst[11:7]}
          2'b01 : shadow_immExt = { {20{instr[31]}}, instr[31:25], instr[11:7] }; 

          // B-Type: {{19{Sign}}, Sign, Inst[7], Inst[30:25], Inst[11:8], 0}
          2'b10 : shadow_immExt= { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 }; 

          // J-Type (JAL): {{11{Sign}}, Inst[31], Inst[19:12], Inst[20], Inst[30:21], 0}
          2'b11 : shadow_immExt = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };

          default : shadow_immExt = '0; 
        endcase

        #1;

//   		//if you want to display and see the cases      
//         $display("immSrc=%0d instr=%h immExt(DUT)=%h immExt(REF)=%h",
//          immSrc, instr, immExt, shadow_immExt);

        if(immExt != shadow_immExt)begin
          $error("FAIL: immSrc=%0d instr=%h DUT=%h REF=%h",
       immSrc, instr, immExt, shadow_immExt);
        end
      end
    end

    $display("==========immExtend TB Passed==========");
    $finish;    
  end
endmodule
      
      
      
  
  
  
  