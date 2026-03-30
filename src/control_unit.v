module control_unit(
    input  [3:0] opcode,       // this gets the opcode for the instruction type
    input  [3:0] funct,        // func for distinguishing r-type instr
    output reg       RegWrite, // signal to indicate write to reg
    output reg       ALUSrc,   // alusrc decides if the second operand is immediate or not
    output reg       MemRead,  // indicates read from mem
    output reg       MemWrite, //indicares write to mem
    output reg       MemToReg, // if data is written to reg from mem
    output reg       Branch,   // in case of branch
    output reg       BranchNE, // branch not equal
    output reg       Jump,     // in case of jump
    output reg [3:0] ALUCtrl   // fir ALU operations (+, - etc.)
);

    //the op and func codes are fixed as per the document
    parameter opcodeR =0;
    parameter opcodeLW = 1;
    parameter opcodeSW = 2;
    parameter opcodeI = 3;
    parameter opcodeBEQ =4;
    parameter opcodeBNE = 5;
    parameter opcodeJMP =6;

    // func codes (ONLY for r-type)
    parameter fnAdd = 0;
    parameter fnSub = 1;
    parameter fnSll =2;
    parameter fnAnd = 3;

    //aluctrl cide for alu operatuins
    parameter aluAdd =0;
    parameter aluSub =1;
    parameter aluSll = 2;
    parameter aluAnd =  3;

    always @(*) begin //setting all signals to 0 (default)
        RegWrite = 0;
        ALUSrc   = 0;
        MemRead  = 0;
        MemWrite = 0;
        MemToReg = 0;
        Branch   = 0;
        BranchNE = 0;
        Jump     = 0;
        ALUCtrl  = aluAdd;

        case (opcode)
            opcodeR: begin
                RegWrite = 1;
                case (funct)
                    fnAdd: ALUCtrl = aluAdd;
                    fnSub: ALUCtrl = aluSub;
                    fnSll: ALUCtrl = aluSll;
                    fnAnd: ALUCtrl = aluAnd;
                    default: ALUCtrl = aluAdd;
                endcase
            end

            opcodeLW: begin
                RegWrite = 1;
                ALUSrc   = 1;
                MemRead  = 1;
                MemToReg = 1;
                ALUCtrl  = aluAdd;
            end

            opcodeSW: begin
                ALUSrc   = 1;
                MemWrite = 1;
                ALUCtrl  = aluAdd;
            end

            opcodeI: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ALUCtrl  = aluAdd;
            end

            opcodeBEQ: begin
                Branch   = 1;
                ALUCtrl  = aluSub; //alu is sent the sub signal for comparision
            end

            
            opcodeBNE: begin
                RegWrite = 0;
                ALUSrc   = 0;
                Branch   = 1;
                BranchNE = 1;
                ALUCtrl  = aluSub;
            end

            opcodeJMP: begin
                Jump = 1;
            end


            default: begin
                //if no opcode is matched, nothing happens
            end
        endcase
    end

endmodule
