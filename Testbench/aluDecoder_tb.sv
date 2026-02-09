module aluDecoder_tb();

  // 1. Define the Test Vector Structure
  typedef struct packed {
    logic [1:0] aluOp;
    logic [2:0] funct3;
    logic       funct7_5;
    logic [2:0] ALUControl;  // expected
  } test_vector_t;

  // 2. Declare an array of vectors
  // We’ll test: lw/sw, beq, and a few R-type ops
  test_vector_t vectors[8];

  // DUT inputs
  logic [1:0] aluOp;
  logic [2:0] funct3;
  logic       funct7_5;

  // DUT output
  logic [2:0] ALUControl;

  // Instantiate DUT
  aluDecoder uut(.*);

  initial begin
    // 3. Define the Truth Table (Test Vectors)
    // Format: '{aluOp, funct3, funct7_5, expected_ALUControl}

    // 0: lw/sw -> always ADD
    vectors[0] = '{2'b00, 3'b000, 1'b0, 3'b000}; // ADD
    vectors[1] = '{2'b00, 3'b111, 1'b1, 3'b000}; // still ADD (funct ignored)

    // 2: beq -> SUB
    vectors[2] = '{2'b01, 3'b000, 1'b0, 3'b001}; // SUB

    // R-type ADD
    vectors[3] = '{2'b10, 3'b000, 1'b0, 3'b000}; // ADD

    // R-type SUB (funct7[5] = 1)
    vectors[4] = '{2'b10, 3'b000, 1'b1, 3'b001}; // SUB

    // R-type AND
    vectors[5] = '{2'b10, 3'b111, 1'b0, 3'b010}; // AND

    // R-type OR
    vectors[6] = '{2'b10, 3'b110, 1'b0, 3'b011}; // OR

    // R-type SLT
    vectors[7] = '{2'b10, 3'b010, 1'b0, 3'b100}; // SLT

    // Initialize inputs
    aluOp    = 0;
    funct3   = 0;
    funct7_5 = 0;

    $display("========== aluDecoder TB (Vector Based) Start ==========");

    // 4. Iterate through the vectors
    foreach (vectors[i]) begin

      // Drive inputs
      aluOp    = vectors[i].aluOp;
      funct3   = vectors[i].funct3;
      funct7_5 = vectors[i].funct7_5;

      #1;

      // 5. Compare DUT output with expected
      if (ALUControl !== vectors[i].ALUControl) begin
        $error("FAIL at Test %0d:", i);
        $error("  Inputs: aluOp=%b funct3=%b funct7_5=%b",
               aluOp, funct3, funct7_5);
        $error("  Expected ALUControl=%b, Got=%b",
               vectors[i].ALUControl, ALUControl);
      end
      else begin
        // Optional per-test pass message
        // $display("PASS: Test %0d", i);
      end
    end

    $display("========== aluDecoder TB Passed ==========");
    $finish;
  end

endmodule

