// 2-to-1 Multiplexer (16-bit)
// Owner: Neeraj Arde

module mux2to1( //module declaration (simplest is mux which basically uses a select signal to choose between two inputs)
    input  [15:0] in0,    // Input 0 (which is 16 bits wide)
    input  [15:0] in1,    // Input 1 (also a 16 bit wide)
    input         sel,    // Select signal (this is a control signal)
    output [15:0] out     // Output (also a 16 bit wide, whatever input is selected by sel will be assigned to out)
);

    assign out = sel ? in1 : in0; // if sel -> 1, out = in1 , else if sel ->0 out = in0

endmodule
