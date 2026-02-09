module instructionMemory_tb;

  parameter WIDTH = 32;
  parameter DEPTH = 1024;

  logic [WIDTH-1:0] addr;
  logic [WIDTH-1:0] instr;

  logic [WIDTH-1:0] rand_instr; //declare here as the compiler sometimes declares only once, so doing it inside the loop will lead to random value being generated only once

  // Shadow memory (Golden Model)
  logic [WIDTH-1:0] shadow_mem [0:DEPTH-1];

  // Instantiate DUT
  instructionMemory #(.WIDTH(WIDTH), .DEPTH(DEPTH)) uut (.*);

  //here it initialises only once in the beginning
  initial begin
    $display("TB Started: Initializing Memory...");
    
    // --- STEP 1: Backdoor Initialization ---
    for (int i = 0; i < DEPTH; i++) begin
       rand_instr = $urandom();
      
      // 1. Write to Shadow Memory
      shadow_mem[i] = rand_instr;
      
      // 2. Write directly into DUT memory (Backdoor Access)
      uut.mem[i] = rand_instr; 
    end

    // --- STEP 2: Verification Loop ---
    $display("Starting Verification...");
    
    for (int i = 0; i < DEPTH; i++) begin
      // Apply Byte Address (PC)
      addr = i * 4; 
      
      // Wait for combinational logic to settle
      #10; 
      
      if (i < 7) begin // Only print the first few to avoid spam
          $display("Check PC %0d: Expected(Index %0d)=%h | Got(HW Index ?)=%h", 
                   addr, i, shadow_mem[i], instr);
      end
      
      
      //shadow_mem[4] = 32'b0; //tried to break the module, throws error as expected


    
      // Check Result
      if (instr !== shadow_mem[i]) begin
        $error("Mismatch at PC %0d! HW: %h, Expected: %h", 
               addr, instr, shadow_mem[i]);
      end
    end

    $display("Simulation Finished. If no errors shown above, you passed!");
    $finish;
  end

endmodule