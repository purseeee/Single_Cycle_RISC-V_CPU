module regFile_tb();
    parameter WIDTH = 32;
    
    logic clk, rst_n, we;
    logic [4:0] a1, a2, a3;
    logic [WIDTH-1:0] wd3;
    logic [WIDTH-1:0] rd1, rd2;

    // Golden Model array to check against
    logic [WIDTH-1:0] shadow_rf [31:0];

    regFile #(.WIDTH(WIDTH)) uut (.*);

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // --- Step 1: Initialize and Reset ---
        clk = 0; rst_n = 0; we = 0; 
        a1 = 0; a2 = 0; a3 = 0; wd3 = 0;
        for(int i=0; i<32; i++) shadow_rf[i] = 0; // Reset golden model
        
        #15 rst_n = 1; // Release reset
        
        // --- Step 2: Randomised Write Phase ---
        $display("Starting Random Write Phase...");
        for (int i = 0; i < 50; i++) begin
            @(posedge clk);
            we  = $urandom_range(0, 1);
            a3  = $urandom_range(0, 31);
            wd3 = $urandom();
            
            // Wait for the end of the clock cycle before updating shadow
            // This ensures we don't 'outrun' the hardware
            #1; 
          if (we && a3 != 0) shadow_rf[a3] = wd3;
        end

        // --- Step 3: Self-Checking Read Phase ---
        $display("Starting Self-Checking Read Phase...");
        we = 0;
        for (int i = 0; i < 32; i++) begin
            a1 = i;
            a2 = 31 - i; // Check a different register on port 2
            #1; // Wait for async read logic
            
            // Port 1 Check
            if (rd1 !== shadow_rf[a1]) begin
                $error("Mismatch Port 1 at Reg %0d! HW: %h, Expected: %h", a1, rd1, shadow_rf[a1]);
            end
            
            // Port 2 Check
            if (rd2 !== shadow_rf[a2]) begin
                $error("Mismatch Port 2 at Reg %0d! HW: %h, Expected: %h", a2, rd2, shadow_rf[a2]);
            end
        end

        $display("Simulation Finished. If no errors shown above, you passed!");
        $finish;
    end
endmodule