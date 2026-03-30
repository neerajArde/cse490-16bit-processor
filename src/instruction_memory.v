// Instruction memory
// 256 bytes total = 128 instructions
// PC gives a byte address
// Each instruction is 16 bits, so two bytes are read at a time

module instruction_memory(addr, instruction);

input [15:0] addr;
output [15:0] instruction;

/* 256-byte instruction memory */
reg [7:0] mem [0:255];
integer i;

/* instruction stored in two bytes */
assign instruction = {mem[addr], mem[addr + 1]};

initial begin
    /* clear memory */
    for (i = 0; i < 256; i = i + 1)
        mem[i] = 8'b0;

    /* sample program */

    /* addi $s1, $s0, 5 */
    mem[0]  = 8'h31;
    mem[1]  = 8'h05;

    /* addi $s2, $s0, 3 */
    mem[2]  = 8'h32;
    mem[3]  = 8'h03;

    /* add */
    mem[4]  = 8'h01;
    mem[5]  = 8'h20;

    /* sub */
    mem[6]  = 8'h01;
    mem[7]  = 8'h21;

    /* and */
    mem[8]  = 8'h01;
    mem[9]  = 8'h23;

    /* sll */
    mem[10] = 8'h01;
    mem[11] = 8'h22;

    /* sw */
    mem[12] = 8'h21;
    mem[13] = 8'h00;

    /* lw */
    mem[14] = 8'h17;
    mem[15] = 8'h00;

    /* beq */
    mem[16] = 8'h47;
    mem[17] = 8'h11;

    /* addi $s0, $s0, 1 */
    mem[18] = 8'h30;
    mem[19] = 8'h01;

    /* jump */
    mem[20] = 8'h6F;
    mem[21] = 8'hF5;
end

endmodule