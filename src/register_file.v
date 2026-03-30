module register_file(
    input         clock,
    input         registerWrite,    
    input  [3:0]  rs,          
    input  [3:0]  rtrd,       
    input  [15:0] writeData,  
    output [15:0] readData1,  
    output [15:0] readData2   
);
    integer i; // declaring i for the loop
    reg [15:0] registers [0:15]; // declaring an array of 16 regs, each being 16 bitswide

    initial begin // from the slides 
    for (i = 0; i < 16; i = i + 1) begin
        registers[i] = 16'b0;
    end //looping to set all registers to 0 at the start
    end

    assign readData1 = registers[rtrd];   
    assign readData2 = registers[rs];
    always @(posedge clock) begin // when rising edge of the clock -> we check the regwrite signal
        if (registerWrite == 1) begin //if regwrite is true, we write data to the reg file at the index 
            registers[rtrd] <= writeData;
        end 
    end
endmodule
