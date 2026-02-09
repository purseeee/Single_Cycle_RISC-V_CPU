module ALU_tb;

    parameter WIDTH = 32;
    localparam NUM_OPS    = 5;
    localparam NUM_CORNER = 5;

    // DUT interface signals
    logic [WIDTH-1:0] srcA, srcB;
    logic [WIDTH-1:0] ALUResult;
    logic [2:0]       ALUControl;
    logic             zero;

    // Golden reference
    logic [WIDTH-1:0] shadow_result;

    // Corner case values
    logic [WIDTH-1:0] corner_vals [0:NUM_CORNER-1];

    // Instantiate DUT
    ALU #(.WIDTH(WIDTH)) uut (.*);

    initial begin
        // -----------------------------
        // Initialize corner cases
        // -----------------------------
        corner_vals[0] = 32'h0000_0000;
        corner_vals[1] = 32'hFFFF_FFFF;
        corner_vals[2] = 32'h7FFF_FFFF;
        corner_vals[3] = 32'h8000_0000;
        corner_vals[4] = 32'h0000_0001;

        // Initialize signals
        srcA = 0;
        srcB = 0;
        ALUControl = 0;
        shadow_result = 0;

        $display("========== ALU TB START ==========");

        // -----------------------------
        // Test each ALU operation
        // -----------------------------
        for (int op = 0; op < NUM_OPS; op++) begin
            ALUControl = op;

            // ---- Random tests ----
            repeat (10) begin
                srcA = $urandom();
                srcB = $urandom();

                case (op)
                    0: shadow_result = srcA + srcB;                     // ADD
                    1: shadow_result = srcA - srcB;                     // SUB
                    2: shadow_result = srcA & srcB;                     // AND
                    3: shadow_result = srcA | srcB;                     // OR
                    4: shadow_result = ($signed(srcA) < $signed(srcB)); // SLT
                    default: shadow_result = 0;
                endcase

                #1;

                if (ALUResult !== shadow_result) begin
                    $error("FAIL: op=%0d A=%h B=%h HW=%h EXP=%h",
                           op, srcA, srcB, ALUResult, shadow_result);
                end
            end

            // ---- Corner tests ----
            for (int i = 0; i < NUM_CORNER; i++) begin
                for (int j = 0; j < NUM_CORNER; j++) begin
                    srcA = corner_vals[i];
                    srcB = corner_vals[j];

                    case (op)
                        0: shadow_result = srcA + srcB;
                        1: shadow_result = srcA - srcB;
                        2: shadow_result = srcA & srcB;
                        3: shadow_result = srcA | srcB;
                        4: shadow_result = ($signed(srcA) < $signed(srcB));
                        default: shadow_result = 0;
                    endcase

                    #1;

                    if (ALUResult !== shadow_result) begin
                        $error("CORNER FAIL: op=%0d A=%h B=%h HW=%h EXP=%h",
                               op, srcA, srcB, ALUResult, shadow_result);
                    end
                end
            end
        end

        $display("========== ALU TB PASSED ==========");
        $finish;
    end

endmodule
