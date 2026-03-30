module program_counter(
    input         clock,
    input         resetProc,
    input  [15:0] pcNext,  
    output reg [15:0] pc     
);
    always @(posedge clock or posedge resetProc) begin
        if (resetProc == 1)
            pc <= 0;
        else
            pc <= pcNext;
    end
endmodule
