// Top-level 16-bit processor
// Structural Verilog: connects all required components together

module processor_top(
    input clk,
    input reset
);

    // =========================
    // Instruction fields
    // =========================
    wire [15:0] instruction;
    wire [3:0]  opcode;
    wire [3:0]  rtrd;
    wire [3:0]  rs;
    wire [3:0]  funct;
    wire [3:0]  imm4;
    wire [11:0] jaddr12;

    assign opcode  = instruction[15:12];
    assign rtrd    = instruction[11:8];
    assign rs      = instruction[7:4];
    assign funct   = instruction[3:0];
    assign imm4    = instruction[3:0];
    assign jaddr12 = instruction[11:0];

    // =========================
    // PC path
    // =========================
    wire [15:0] pc_current;
    wire [15:0] pc_plus2;
    wire [15:0] pc_next;
    wire [15:0] branch_target;
    wire [15:0] jump_target;
    wire [15:0] pc_after_branch;

    // =========================
    // Register file path
    // =========================
    wire [15:0] rf_read1;
    wire [15:0] rf_read2;
    wire [15:0] reg_rs_value;
    wire [15:0] reg_rtrd_value;
    wire [15:0] write_back_data;

    // Your register_file module reads:
    // readData1 = registers[rtrd]
    // readData2 = registers[rs]
    // So rename them here to match processor meaning
    assign reg_rtrd_value = rf_read1;
    assign reg_rs_value   = rf_read2;

    // =========================
    // Immediate / jump extension
    // =========================
    wire [15:0] imm_ext;
    wire [15:0] jump_ext;
    wire [15:0] branch_offset;
    wire [15:0] jump_offset;

    // =========================
    // ALU / memory path
    // =========================
    wire [15:0] alu_in_b;
    wire [15:0] alu_result;
    wire [15:0] mem_read_data;
    wire        zero;

    // =========================
    // Control signals
    // =========================
    wire        RegWrite;
    wire        ALUSrc;
    wire        MemRead;
    wire        MemWrite;
    wire        MemToReg;
    wire        Branch;
    wire        BranchNE;
    wire        Jump;
    wire [3:0]  ALUCtrl;

    wire take_branch;

    // =========================
    // Program Counter
    // =========================
    program_counter pc_unit (
        .clock(clk),
        .resetProc(reset),
        .pcNext(pc_next),
        .pc(pc_current)
    );

    assign pc_plus2 = pc_current + 16'd2;

    // =========================
    // Instruction Memory
    // =========================
    instruction_memory imem (
        .addr(pc_current),
        .instruction(instruction)
    );

    // =========================
    // Control Unit
    // =========================
    control_unit cu (
        .opcode(opcode),
        .funct(funct),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .Branch(Branch),
        .BranchNE(BranchNE),
        .Jump(Jump),
        .ALUCtrl(ALUCtrl)
    );

    // =========================
    // Register File
    // =========================
    register_file rf (
        .clock(clk),
        .registerWrite(RegWrite),
        .rs(rs),
        .rtrd(rtrd),
        .writeData(write_back_data),
        .readData1(rf_read1),
        .readData2(rf_read2)
    );

    // =========================
    // Sign Extension
    // =========================
    sign_extend se_imm (
        .imm_in(imm4),
        .imm_out(imm_ext)
    );

    sign_extend_12 se_jump (
        .addr_in(jaddr12),
        .addr_out(jump_ext)
    );

    assign branch_offset = imm_ext << 1;
    assign jump_offset   = jump_ext << 1;

    assign branch_target = pc_plus2 + branch_offset;
    assign jump_target   = pc_plus2 + jump_offset;

    // =========================
    // ALU input mux
    // For R-type: use R[rt/rd]
    // For I-type/lw/sw: use sign-extended immediate
    // =========================
    mux2to1 alu_src_mux (
        .in0(reg_rtrd_value),
        .in1(imm_ext),
        .sel(ALUSrc),
        .out(alu_in_b)
    );

    // =========================
    // ALU
    // A should be R[rs]
    // B should be R[rt/rd] or immediate
    // =========================
    alu alu_unit (
        .A(reg_rs_value),
        .B(alu_in_b),
        .ALUCtrl(ALUCtrl),
        .Result(alu_result),
        .Zero(zero)
    );

    // =========================
    // Data Memory
    // For sw, value written is R[rt/rd]
    // =========================
    data_memory dmem (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(alu_result),
        .write_data(reg_rtrd_value),
        .read_data(mem_read_data)
    );

    // =========================
    // Write-back mux
    // R-type/addi -> ALU result
    // lw           -> memory data
    // =========================
    mux2to1 mem_to_reg_mux (
        .in0(alu_result),
        .in1(mem_read_data),
        .sel(MemToReg),
        .out(write_back_data)
    );

    // =========================
    // Branch / Jump PC selection
    // beq: branch if Zero = 1
    // bne: branch if Zero = 0
    // =========================
    assign take_branch = Branch & ((~BranchNE & zero) | (BranchNE & ~zero));

    mux2to1 branch_mux (
        .in0(pc_plus2),
        .in1(branch_target),
        .sel(take_branch),
        .out(pc_after_branch)
    );

    mux2to1 jump_mux (
        .in0(pc_after_branch),
        .in1(jump_target),
        .sel(Jump),
        .out(pc_next)
    );

endmodule