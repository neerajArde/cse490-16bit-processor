module processor_top(
    input clk,
    input reset
);


    wire [15:0] pc_out;
    wire [15:0] instruction;

    wire [15:0] reg_data1;
    wire [15:0] reg_data2;

    wire [15:0] sign_ext_out;
    wire [15:0] alu_result;

    wire zero;



    program_counter pc (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out)
    );


    instruction_memory imem (
        .addr(pc_out),
        .instruction(instruction)
    );


    register_file rf (
        .clk(clk),
        .rs(instruction[11:8]),
        .rt(instruction[7:4]),
        .rd(instruction[3:0]),
        .write_data(alu_result),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );


    sign_extend se (
        .imm_in(instruction[3:0]),
        .imm_out(sign_ext_out)
    );

    alu alu_inst (
        .A(reg_data1),
        .B(reg_data2),   // keep simple (no mux yet unless required)
        .ALUCtrl(instruction[15:12]), // opcode directly controls ALU
        .Result(alu_result),
        .Zero(zero)
    );


    data_memory dmem (
        .clk(clk),
        .addr(alu_result),
        .write_data(reg_data2),
        .read_data()
    );

endmodule