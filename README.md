# Single-Cycle RISC-V CPU (RV32I Subset)

This project implements a **single-cycle RISC-V CPU** in SystemVerilog.  
The design follows a classic single-cycle datapath and has been extended to support **recursive function calls** and **stack operations**.

---

## ✅ Implemented Features

- **Core Architecture:**
  - 32-bit RISC-V Datapath
  - Single-cycle execution (Fetch, Decode, Execute, Memory, Writeback in 1 clock)
  - Harvard Architecture (Separate Instruction and Data Memory)

- **Supported Instructions (RV32I Subset):**
  - **Arithmetic (R-type):** `add`, `sub`, `and`, `or`, `slt`, `xor`
  - **Arithmetic (I-type):** `addi`, `andi`, `ori`, `xori`, `slti`
  - **Load/Store:** `lw`, `sw`
  - **Branching:** `beq`
  - **Jumps:** `jal` (Jump and Link), `jalr` (Jump and Link Register)

- **Key Modules:**
  - **Control Unit:** Fully decoded Main and ALU control logic.
  - **PC Logic:** Supports `PC+4`, Branch Targets (`PC+Imm`), and Jump Targets (`ALUResult` for `jalr`).
  - **ALU:** Supports Add, Sub, And, Or, Xor, Slt.
  - **Data Memory:** Supports asynchronous reads for single-cycle compliance.

---

## 🚀 Verification & Tests

The CPU has been verified with complex algorithmic tests:

1.  **Recursive Fibonacci:**
    - Calculates `fib(5) = 5` using a recursive algorithm.
    - Verifies **Stack Pointer (`sp`)** management (`addi sp, sp, -12`).
    - Verifies **Function Calls (`jal`)** and **Returns (`jalr`)**.
    - Verifies **Nested Scope** handling (saving `ra`, `s0` to stack).

2.  **Loop & Branching Test:**
    - Calculates sum of numbers (3 + 2 + 1) using a decrementing loop.
    - Verifies `beq` logic (forward and backward branching).

---

## 🧠 Architecture Details

- **Control Path:**
  - **Main Decoder:** Generates control signals including `jump`, `jalr`, and 2-bit `resultSrc`.
  - **ALU Decoder:** Maps `funct3` and `funct7` to specific ALU operations (handling both R-type and I-type logic).

- **Datapath Features:**
  - **Writeback Mux:** 3-way selection between ALU Result, Memory Data, and PC+4 (for linking).
  - **PC Mux:** Priority logic to handle `jalr` (Jump to Register) vs standard Branches/Jumps.

---

## 🛠️ How to Simulate

The project includes a top-level testbench (`cpu_tb.sv`) pre-configured to run the Recursive Fibonacci program.

1.  **Compile:** Load all `.sv` files (Top, ALU, Decoders, Memories, etc.).
2.  **Run:** Execute the `cpu_tb` module.
3.  **Check Output:** The simulation will run for ~500 cycles and check:
    - **Memory[0]:** Should contain `5` (Result of fib(5)).
    - **Register x2 (SP):** Should return to `1000` (Stack balanced).
