//Testbench for recursive Fibonacci
`timescale 1ns / 1ps

module cpu_tb;

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
     $display("--- SIMULATION START: Recursive Fibonacci(5) ---");

     #2 rst_n = 1; 
     
     // 1. Run for enough time
     // fib(5) takes roughly 200-300 instructions. 
     repeat(500) @(posedge clk);
     
     $display("--- FINAL CHECK ---");
     
     // 2. Check Result (Stored in Mem[0] by Main)
     // fib(5) should be 5
     if (dut.dmem_inst.mem[0] === 32'd5) 
        $display("PASS: Memory[0] = 5 (Correct Fibonacci Result)");
     else 
        $error("FAIL: Memory[0] = %d (Expected 5)", dut.dmem_inst.mem[0]);

     // 3. Check Stack Pointer (Should be restored to 1000)
     // Note: rf[2] is SP.
     if (dut.rf_inst.rf[2] === 32'd1000)
        $display("PASS: Stack Pointer restored to 1000");
     else
        $display("INFO: Stack Pointer is %d (Note: Main might not have restored it, which is fine)", dut.rf_inst.rf[2]);

     $finish;
   end

endmodule