
# Single-Cycle RISC-V CPU (RV32I Subset)

This project implements a **single-cycle RISC-V CPU** in Verilog/SystemVerilog.  
The design follows a classic single-cycle datapath and can execute a **basic subset of RV32I instructions**.

> ⚠️ Note: Instructions like `addi`, `jal`, `jalr`, etc. are **not implemented yet**.

---

## ✅ Implemented Features

- 32-bit datapath (RV32)
- Single-cycle execution
- Separate modules for:
  - PC
  - Instruction Memory
  - Register File
  - ALU
  - Immediate Extender
  - Control Unit (Main Decoder + ALU Decoder)
  - Data Memory
- Supported instruction types (subset):
  - **R-type**: `add`, `sub`, `and`, `or`, `slt`, `sll`, `srl`, `sra`
  - **Load/Store**: `lw`, `sw`
  - **Branch**: `beq`

---

## ❌ Not Implemented (Yet)

- Immediate ALU ops: `addi`, `andi`, `ori`, etc.
- Jumps: `jal`, `jalr`
- Upper immediates: `lui`, `auipc`
- Other branches: `bne`, `blt`, `bge`, etc.
- Multiply/Divide (M extension)
- CSR / exceptions / interrupts
- Pipeline / multicycle (this is strictly single-cycle)

---

## 🧠 Architecture

- Classic single-cycle RISC-V style datapath
- Control split into:
  - Main Control Decoder (opcode → high-level control)
  - ALU Decoder (aluOp + funct3 + funct7 → ALUControl)
- Immediate extraction handled by a dedicated ImmExt module
- PCSrc for branches decided in top module using `Branch & Zero`

---

## 🧪 Verification

- Simple **vector-based testbenches** for:
  - Control Decoder
  - ALU Decoder
  - ALU
  - (Others as added)

---

## 🛠️ How to Simulate

- Simulated using Xcelium on EDA Playground
