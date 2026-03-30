// ALU Module
// Supports: add, sub, sll, and (R-type), addi (I-type)
// Owner: Neeraj Arde

module alu( //declaration of ALU module : takes two 16 bit inputs, one 4 bit control signal and produces a 16 bit output and a zero flag
// ALU performs arithmetic, logic, shift, and comparison operations
// Control signal selects which operation to execute
    input  [15:0] A,        // First operand (R[rs])
    input  [15:0] B,        // Second operand (R[rt/rd] or sign-extended immediate)
    input  [3:0]  ALUCtrl,  // ALU control signal
    output reg [15:0] Result,
    output  Zero      // Zero flag (used by beq/bne)
);
    // we will use these following alu control codes to determine which operation to perform
    // ALU Control Codes
    // 0000 = add
    // 0001 = sub
    // 0010 = sll
    // 0011 = and

    always @(*) begin
        case (ALUCtrl)
        //binary notation : 4'b0000 means 4 bit binary number with value 0000
            4'b0000: Result = A + B;          // add / addi / lw/sw (since lw/sw also uses add to calculate address)
            4'b0001: Result = A - B;          // sub / beq/bne (since beq/bne also uses sub to compare values)
            4'b0010: Result = B << A;         // sll: shift R[rt/rd] by R[rs] bits
            4'b0011: Result = A & B;          // and
            default: Result = 16'b0;
        endcase
    end

     assign Zero = (Result == 16'b0); // zero flag is set if the result of ALU operation is zero, i.e. 1 if zero , else 0 if result is not zero

endmodule
