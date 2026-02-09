module controlDecoder_tb();

  // 1. Define the Test Vector Structure
  // This bundles the input (opcode) with all expected outputs
  typedef struct packed {
    logic [6:0] opcode;
    logic       branch;
    logic       resultSrc;
    logic       memWrite;
    logic [1:0] aluOp;
    logic       aluSrc;
    logic [1:0] immSrc;
    logic       regWrite;
  } test_vector_t;

  // 2. Declare an array of vectors
  // 4 valid instructions + 1 invalid/garbage instruction = 5 tests
  test_vector_t vectors[5];

  // DUT inputs
  logic [6:0] opcode;
  logic       zero;

  // DUT outputs
  logic       branch;
  logic       resultSrc;
  logic       memWrite;
  logic [1:0] aluOp;
  logic       aluSrc;
  logic [1:0] immSrc;
  logic       regWrite;

  // Instantiate DUT
  controlDecoder uut(.*);

  initial begin
    // 3. Define the Truth Table (Test Vectors)
    // Format: '{opcode, branch, resultSrc, memWrite, aluOp, aluSrc, immSrc, regWrite}
    
    // Test 0: lw (Load Word)
    vectors[0] = '{7'b0000011, 1'b0, 1'b1, 1'b0, 2'b00, 1'b1, 2'b00, 1'b1};
    
    // Test 1: sw (Store Word)
    vectors[1] = '{7'b0100011, 1'b0, 1'b0, 1'b1, 2'b00, 1'b1, 2'b01, 1'b0};
    
    // Test 2: R-type (add, sub, etc.)
    vectors[2] = '{7'b0110011, 1'b0, 1'b0, 1'b0, 2'b10, 1'b0, 2'b00, 1'b1};
    
    // Test 3: beq (Branch if Equal)
    vectors[3] = '{7'b1100011, 1'b1, 1'b0, 1'b0, 2'b01, 1'b0, 2'b10, 1'b0};

    // Test 4: Invalid/Garbage Opcode (Check default behavior)
    // We expect all control signals to be 0 (safe state)
    vectors[4] = '{7'b1111111, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 2'b00, 1'b0};

    // Initialize inputs
    opcode = 0;
    zero   = 0;

    $display("========== controlDecoder TB (Vector Based) Start ==========");

    // 4. Iterate through the vectors
    foreach (vectors[i]) begin
      
      // Drive Inputs from Vector
      opcode = vectors[i].opcode;
      
      // Randomize 'zero' to ensure it doesn't affect control signals
      // (Even though the decoder logic ignores it, this verifies that assumption)
      zero = $urandom_range(0, 1); 

      // Wait for logic to settle
      #1;

      // 5. Compare DUT outputs with Expected Vector values
      if ((branch    !== vectors[i].branch)    ||
          (resultSrc !== vectors[i].resultSrc) ||
          (memWrite  !== vectors[i].memWrite)  ||
          (aluOp     !== vectors[i].aluOp)     ||
          (aluSrc    !== vectors[i].aluSrc)    ||
          (immSrc    !== vectors[i].immSrc)    ||
          (regWrite  !== vectors[i].regWrite)) begin
        
        $error("FAIL at Test %0d (Opcode: %b):", i, opcode);
        $error("  Expected: br=%b rs=%b mw=%b aluOp=%b aluSrc=%b immSrc=%b rw=%b",
               vectors[i].branch, vectors[i].resultSrc, vectors[i].memWrite, 
               vectors[i].aluOp, vectors[i].aluSrc, vectors[i].immSrc, vectors[i].regWrite);
        $error("  Actual:   br=%b rs=%b mw=%b aluOp=%b aluSrc=%b immSrc=%b rw=%b",
               branch, resultSrc, memWrite, aluOp, aluSrc, immSrc, regWrite);
      end 
      else begin
        // Optional: Print pass for each case
        // $display("PASS: Test %0d (Opcode: %b)", i, opcode);
      end
    end

    $display("========== controlDecoder TB Passed ==========");
    $finish;
  end

endmodule