





//looping test testbench

`timescale 1ns / 1ps

module complex_cpu_tb;

  logic clk;
  logic rst_n;
  
  top_module dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0; 
    
    $display("--- SIMULATION START: Loop Test (Sum 3..1) ---");

    // Release Reset
    #2 rst_n = 1;

    // Monitor critical values
    // Watch x1 (Counter) and x3 (Sum) changing in real time
    $monitor("Time: %2t | PC: %h | x1(Count): %d | x3(Sum): %d | Op: %h", 
             $time, dut.PC, dut.rf_inst.rf[1], dut.rf_inst.rf[3], dut.instr);

    // Run enough cycles for the loop to complete
    // 3 iterations * ~3 instrs per loop = ~15 cycles. 
    // Let's run 25 to be safe.
    repeat(25) @(posedge clk);
    
    $display("\n--- FINAL RESULTS ---");
    
    // Check Register x3 (Sum)
    if (dut.rf_inst.rf[3] === 32'd6)
        $display("PASS: Register x3 contains 6 (Correct Sum)");
    else
        $error("FAIL: Register x3 contains %d (Expected 6)", dut.rf_inst.rf[3]);

    // Check Data Memory [2] (Address 8)
    // Note: We access internal memory array. Addr 8 is word index 2.
    if (dut.dmem_inst.mem[2] === 32'd6)
        $display("PASS: Memory Address 8 contains 6 (Store Successful)");
    else
        $error("FAIL: Memory Address 8 contains %d (Expected 6)", dut.dmem_inst.mem[2]);

    $finish;
  end
endmodule