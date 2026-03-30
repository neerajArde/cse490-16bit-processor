// Sign Extension Module
// Extends 4-bit immediate to 16-bit signed integer
// Owner: Neeraj Arde

module sign_extend( // module declaration for sign extension, takes a 4 bit input and produces a 16 bit output
    input  [3:0]  imm_in,    // 4-bit immediate from instruction
    output [15:0] imm_out    // 16-bit sign-extended output
);

    assign imm_out = {{12{imm_in[3]}}, imm_in}; // sign extension: i.e. to just extend the msb of the input 12 times and concatenate it with the original input 

endmodule
