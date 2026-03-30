// Sign Extension Module for Jump (12-bit address)
// Extends 12-bit address to 16-bit signed integer
// Owner: Neeraj Arde

module sign_extend_12( //module declaration for sign extension for jump instruction, takes a 12 bit input and produces a 16 bit output
    input  [11:0] addr_in,   // 12-bit jump address as an input
    output [15:0] addr_out   // 16-bit sign-extended output
);

    assign addr_out = {{4{addr_in[11]}}, addr_in}; // sign extension logic basically takes the msb and extends it 4 times and concatenates it with the original input to produce the output

endmodule
