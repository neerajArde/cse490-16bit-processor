// Testbench for processor_top in processor.v only (hierarchical refs match that file)
`timescale 1ns / 1ps

module processor_tb;

    reg clk;
    reg reset;

    processor_top uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock: half-period 5 time units
    initial clk = 1'b0;
    initial forever #5 clk = ~clk;

    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, processor_tb);

        reset = 1'b1;
        #10 reset = 1'b0;

        // Signals: see wires in processor.v (wbdata = register file write data)
        $monitor(
            "t=%0t | PC=%04h | INSTR=%04h | ALU=%04h | DMEM_RD=%04h | RF_WD=%04h",
            $time,
            uut.pc_current,
            uut.instruction,
            uut.alu_result,
            uut.mem_read_data,
            uut.wbdata
        );

        #450;
        $display("Done at t=%0t", $time);
        $finish;
    end

endmodule
