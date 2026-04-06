module processor_top( // declaration of processor module which will instantiate all the components of the processor and connect them
    input clk, 
    input reset 
    output [15:0] pc_out
);

    wire [15:0] instruction; //15:0 means 16 bits, wire declaration to hold the current insturction
    wire [15:0] pc_current; //current val of the program counter
    wire [15:0] pc_next; // next val of program counter

    wire [3:0] opcode = instruction[15:12]; //opcode the top 4 bits of the instruction
    wire [3:0] rs     = instruction[7:4]; //the source reg1ister, bits 7:4 of the instruction
    wire [3:0] rtrd   = instruction[11:8]; //the destination reg1ister, bits 11:8 of the instruction
    wire [3:0] imm4   = instruction[3:0]; //the immediate value, bits 3:0 of the instruction

    wire [15:0] imm_ext; //sign extended immediate value
    wire [15:0] alu_result; // result from the ALU operation
    wire [15:0] alu_in_b; //second input to the alu, either the val frm reg1ister or the sign extended immediate
    wire [15:0] mem_read_data;
    

    wire [15:0] reg1; //holds the value from source register
    wire [15:0] reg2; //holds the value frm destination register
    wire [15:0] wbdata;
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemToReg, Branch, BranchNE, Jump;
    wire [3:0] ALUCtrl;
    wire zero;
    wire branchDecision;

    wire [15:0] pcplus2;
    wire [15:0] branchTarget;
    wire [15:0] jumpTarget;
    wire [15:0] PCBranchTarget;
    wire [15:0] jumpsignExt;
    wire [11:0] jumpAddr = instruction[11:0];
    wire [3:0]  funct = instruction[3:0];

    assign pcplus2       = pc_current + 2;
    assign branchTarget  = pcplus2 + (imm_ext << 1); // here we are calculating branchTaken
                                                      //address by adding sign extnd imm to pc+2
    assign jumpTarget    = pcplus2 + (jumpsignExt << 1); //same but for jump
    assign branchDecision = Branch & ((~BranchNE & zero) | (BranchNE & ~zero)); // we are basically calculating
                                                                                // whether branch will be taken or not based on the zero flag and branch signals



    control_unit cntrlunt ( //takes opcode (+funct if needed ) and generates control signal
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

    register_file regfile (
    .clock(clk),
    .registerWrite(RegWrite),
    .rs(rs),
    .rtrd(rtrd),
    .writeData(wbdata),
    .readData1(reg1),
    .readData2(reg2)
    );

    

    program_counter pc ( //module declaration for program counter
        .clock(clk),
        .resetProc(reset),
        .pcNext(pc_next),
        .pc(pc_current)
    );

    instruction_memory imem ( //module declaration for instruction memory
        .addr(pc_current),
        .instruction(instruction)
    );

    sign_extend se ( //module declaration for sign extension for immediate value
        .imm_in(imm4),
        .imm_out(imm_ext)
    );

    sign_extend_12 se_jump ( // used for jump addr calculation
    .addr_in(jumpAddr),
    .addr_out(jumpsignExt)
    );

    mux2to1 alu_mux ( //module declaration for mux to select between reg value and immediate value for second input to ALU
        .in0(reg1),
        .in1(imm_ext),
        .sel(ALUSrc),
        .out(alu_in_b)
    );

    alu alu_unit ( // module declaration for ALU, takes the opcode as control signal to determine the operation to perform on the inputs
        .A(reg2),
        .B(alu_in_b),
        .ALUCtrl(ALUCtrl),
        .Result(alu_result),
        .Zero(zero)
    );

    data_memory dmem (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(alu_result),
        .write_data(reg1),
        .read_data(mem_read_data)
    );

    mux2to1 wbmux (
    .in0(alu_result),
    .in1(mem_read_data),
    .sel(MemToReg),
    .out(wbdata)
    );

    mux2to1 branchmux (
    .in0(pcplus2),
    .in1(branchTarget),
    .sel(branchDecision),
    .out(PCBranchTarget)
);

    mux2to1 jumpmux (
    .in0(PCBranchTarget),
    .in1(jumpTarget),
    .sel(Jump),
    .out(pc_next)
    );

    assign pcValFPGA = pc_current; //this basically gives acces of the current prog counter to the top level 
endmodule
