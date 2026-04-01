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

/* Safe byte indices: always in [0:255] (second byte uses base when base==255) */
wire [7:0] base_idx = addr[7:0];
wire [8:0] byte_sum = {1'b0, base_idx} + 9'd1;
wire [7:0] hi_idx   = byte_sum[8] ? base_idx : byte_sum[7:0];

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
assign read_data = MemRead ? {mem[base_idx], mem[hi_idx]} : 16'b0;

/* write on rising edge of clock */
always @(posedge clk) begin
    if (MemWrite) begin
        mem[base_idx] <= write_data[15:8];
        mem[hi_idx]   <= write_data[7:0];
    end
end

endmodule