module processor_top( // declaration of processor module which will instantiate all the components of the processor and connect them
    input clk, 
    input reset 
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
    

    wire [15:0] reg1 = 16'b0; //holds the value from source register
    wire [15:0] reg2 = 16'b0; //holds the value frm destination register

   
    assign pc_next = pc_current + 16'd2;

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

    mux2to1 alu_mux ( //module declaration for mux to select between reg value and immediate value for second input to ALU
        .in0(reg2),
        .in1(imm_ext),
        .sel(1'b1),
        .out(alu_in_b)
    );

    alu alu_unit ( // module declaration for ALU, takes the opcode as control signal to determine the operation to perform on the inputs
        .A(reg1),
        .B(alu_in_b),
        .ALUCtrl(opcode),
        .Result(alu_result),
        .Zero()
    );

    data_memory dmem (
        .clk(clk),
        .MemRead(1'b0),
        .MemWrite(1'b0),
        .addr(alu_result),
        .write_data(reg2),
        .read_data(mem_read_data)
    );
endmodule
