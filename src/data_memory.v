// Data Memory
// Byte-addressed, 256 bytes, big-endian word access
// Owner: Prasanna Sairam Govindarajulu

module data_memory(clk, MemRead, MemWrite, addr, write_data, read_data);

input clk;
input MemRead;
input MemWrite;
input [15:0] addr;
input [15:0] write_data;
output [15:0] read_data;

/* 256-byte data memory */
reg [7:0] mem [0:255];
integer i;

/* initialize memory to 0 */
initial begin
    for (i = 0; i < 256; i = i + 1)
        mem[i] = 8'b0;
end

/* big-endian 16-bit read:
   high byte at mem[addr], low byte at mem[addr+1] */
assign read_data = MemRead ? {mem[addr], mem[addr + 1]} : 16'b0;

/* write on rising edge of clock */
always @(posedge clk) begin
    if (MemWrite) begin
        mem[addr]     <= write_data[15:8];
        mem[addr + 1] <= write_data[7:0];
    end
end

endmodule