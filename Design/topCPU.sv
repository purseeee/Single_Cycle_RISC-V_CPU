// Code your design here
`include "regFile.sv"
`include "dataMem.sv"
`include "instructionMem.sv"
`include "immExtend.sv"
`include "ALU.sv"
`include "aluDecoder.sv"
`include "controlDecoder.sv"
`include "programCounter.sv"

`timescale 1ns / 1ps

module top_module(
    input logic clk,
    input logic rst_n,       // Needed for Register File
    output logic [31:0] test_result // Optional: Expose ALU Result for testbench checking
);

    // =========================================================================
    // Internal Wires / Interconnects
    // =========================================================================
    
    // Program Counter Signals
    logic [31:0] PC, PCNext, PCPlus4, PCTarget;
    logic        PCSrc; // Selector for PC Mux

    // Instruction Memory Signals
    logic [31:0] instr;

    // Decoder Signals
    logic        branch, memWrite, aluSrc, regWrite;
    logic        jump, jalr;       // <--- NEW: Control signals for Jumps
    logic [1:0]  resultSrc;        // <--- UPDATED: Changed to 2 bits
    logic [1:0]  aluOp, immSrc;
    logic [2:0]  aluControl;

    // Register File Signals
    logic [31:0] rd1, rd2;   // Read Data 1 & 2
    logic [31:0] wd3;        // Write Data 3 (Result)

    // Immediate Extender Signals
    logic [31:0] immExt;

    // ALU Signals
    logic [31:0] srcB;       // Mux output (RegB vs Imm)
    logic [31:0] aluResult;
    logic        zero;

    // Data Memory Signals
    logic [31:0] readData;

    // =========================================================================
    // Logic Implementation
    // =========================================================================

    // -------------------------------------------------------------------------
    // 1. Instruction Fetch (PC & Instruction Memory)
    // -------------------------------------------------------------------------
    
    // PC + 4 Adder
    assign PCPlus4 = PC + 32'd4;
    assign PCTarget = PC + immExt; // Branch/JAL Target

    // PC Mux Logic (Updated for JALR)
    // Priority: 
    // 1. JALR -> Jump to ALUResult (masked)
    // 2. Branch/JAL -> Jump to PCTarget
    // 3. Normal -> PC+4
    always_comb begin
        if (jalr) 
            PCNext = aluResult & 32'hFFFFFFFE; // Clear LSB for JALR compliance
        else if ((branch & zero) | jump)
            PCNext = PCTarget;
        else
            PCNext = PCPlus4;
    end

    // Program Counter Instance
    // Note: Your PC module lacks a reset. Using an initial block to fix start state for sim.
    programCounter pc_inst (
        .clk(clk),
        .PCNext(PCNext),
        .PC(PC)
    );
    
    // Hack to initialize PC if no reset exists in the PC module
    initial begin
        force pc_inst.PC = 32'b0;
        #1 release pc_inst.PC;
    end

    // Instruction Memory Instance
    instructionMemory instr_mem_inst (
        .addr(PC),
        .instr(instr)
    );

    // -------------------------------------------------------------------------
    // 2. Decode (Control, Registers, Sign Extend)
    // -------------------------------------------------------------------------

    // Control Decoder
    controlDecoder control_inst (
        .opcode(instr[6:0]),
        .zero(zero),         // Fed back from ALU
        .branch(branch),
        .resultSrc(resultSrc), // 2 bits
        .memWrite(memWrite),
        .aluOp(aluOp),
        .aluSrc(aluSrc),
        .immSrc(immSrc),
        .regWrite(regWrite),
        .jump(jump),           // <--- Connected
        .jalr(jalr)            // <--- Connected
    );

    // Register File
    regFile rf_inst (
        .clk(clk),
        .rst_n(rst_n),
        .we(regWrite),
        .a1(instr[19:15]),   // rs1
        .a2(instr[24:20]),   // rs2
        .a3(instr[11:7]),    // rd
        .wd3(wd3),           // Data coming from Writeback Mux
        .rd1(rd1),
        .rd2(rd2)
    );

    // Immediate Extender
    immExtend ext_inst (
        .instr(instr[31:7]), // Top bits of instruction
        .immSrc(immSrc),
        .immExt(immExt)
    );

    // -------------------------------------------------------------------------
    // 3. Execute (ALU & Address Calculation)
    // -------------------------------------------------------------------------

    // ALU Source B Mux
    // If ALUSrc is 1, use Immediate. If 0, use Register Read Data 2.
    assign srcB = (aluSrc) ? immExt : rd2;

    // ALU Decoder
    aluDecoder alu_dec_inst (
        .aluOp(aluOp),
        .funct3(instr[14:12]),
        .funct7_5(instr[30]),
        .ALUControl(aluControl)
    );

    // ALU Instance
    ALU alu_inst (
        .srcA(rd1),
        .srcB(srcB),
        .ALUControl(aluControl),
        .ALUResult(aluResult),
        .zero(zero)
    );

    // -------------------------------------------------------------------------
    // 4. Memory Stage (Data Memory)
    // -------------------------------------------------------------------------

    dataMemory dmem_inst (
        .clk(clk),
        .we(memWrite),
        .addr(aluResult),    // Memory Address calculated by ALU
        .wd(rd2),            // Write Data comes from Reg File (rs2)
        .rd(readData)
    );

    // -------------------------------------------------------------------------
    // 5. Writeback Stage
    // -------------------------------------------------------------------------

    // Result Mux (Updated for JAL/JALR support)
    // 00: ALU Result (R-type, I-type)
    // 01: Memory Data (lw)
    // 10: PC+4 (jal, jalr linking)
    always_comb begin
        case (resultSrc)
            2'b00: wd3 = aluResult;
            2'b01: wd3 = readData;
            2'b10: wd3 = PCPlus4;
            default: wd3 = 32'b0;
        endcase
    end

    // Output for Testbench/Debugging
    assign test_result = wd3;

endmodule