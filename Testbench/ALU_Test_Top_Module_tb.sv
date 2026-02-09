`timescale 1ns / 1ps

module cpu_tb;

  logic clk;
  logic rst_n;
  
  // Instantiate Top Module
  top_module dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // Clock Generation (10ns period)
  always #5 clk = ~clk;

  initial begin
    // 1. Initialize
    clk = 0;
    rst_n = 0; 
    $display("==========================================================");
    $display(" Simulation Started ");
    $display("==========================================================");

    // --- FIX: Release reset earlier ---
    #2;       // Wait 2ns
    rst_n = 1; // Release reset BEFORE the first clock edge (which is at 5ns)
    
    // 3. Monitor signals..
    // This prints whenever a value is written to a register
    $monitor("Time: %0t | PC: %h | RegWrite: %b | WriteData: %d", 
             $time, dut.PC, dut.regWrite, dut.wd3);

    // 4. Run Simulation
    // We expect 6 instructions. 
    // 6 instrs * 1 cycle/instr * 10ns/cycle = 60ns. 
    // Adding extra time for safety.
    repeat(10) @(posedge clk);
    
    // 5. Verify & Print Registers
    print_results();
    
    $display("==========================================================");
    $display(" Simulation Complete ");
    $display("==========================================================");
    $finish;
  end

  // --- Task to Print Register Values ---
  task print_results;
    begin
      $display("\n----------------------------------------------------------");
      $display(" FINAL REGISTER STATE");
      $display("----------------------------------------------------------");
      
      // Print specific test registers
      $display("x1 (Loaded 10) : %0d (Hex: %h)", dut.rf_inst.rf[1], dut.rf_inst.rf[1]);
      $display("x2 (Loaded 3)  : %0d (Hex: %h)", dut.rf_inst.rf[2], dut.rf_inst.rf[2]);
      $display("x3 (10 + 3)    : %0d (Hex: %h)", dut.rf_inst.rf[3], dut.rf_inst.rf[3]);
      $display("x4 (10 - 3)    : %0d (Hex: %h)", dut.rf_inst.rf[4], dut.rf_inst.rf[4]);
      $display("x5 (10 & 3)    : %0d (Hex: %h)", dut.rf_inst.rf[5], dut.rf_inst.rf[5]);
      $display("x6 (10 | 3)    : %0d (Hex: %h)", dut.rf_inst.rf[6], dut.rf_inst.rf[6]);
      
      $display("\n--- Dump of All Non-Zero Registers ---");
      for (int i = 0; i < 32; i++) begin
        if (dut.rf_inst.rf[i] !== 0) begin
           $display("x%02d = %0d", i, dut.rf_inst.rf[i]);
        end
      end
    end
  endtask

endmodule