module programCounter_tb;

  parameter WIDTH = 32;

  logic clk;
  logic [WIDTH-1:0] PCNext;
  logic [WIDTH-1:0] PC;
  logic [WIDTH-1:0] expected;

  // Instantiate DUT
  programCounter #(.WIDTH(WIDTH)) uut(.*);

  // Clock: 10 time-unit period
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    PCNext = 0;

    $display("PC TB Started");

    // ---- Test 1: Basic update ----
    expected = 32'h0000_0004;
    PCNext   = expected;
    @(posedge clk);
    #1;
    if (PC !== expected)
      $error("FAIL: PC=%h Expected=%h", PC, expected);

    // ---- Test 2: Another value ----
    expected = 32'h0000_0010;
    PCNext   = expected ;
    @(posedge clk);
    #1;
    if (PC !== expected)
      $error("FAIL: PC=%h Expected=%h", PC, expected);

    // ---- Test 3: Random values ----
    repeat (5) begin
      expected = $urandom();
      PCNext   = expected;
      @(posedge clk);
      #1;
      if (PC !== expected)
        $error("FAIL: PC=%h Expected=%h", PC, expected);
    end

    $display("PC TB Finished (no errors = pass)");
    $finish;
  end

endmodule
