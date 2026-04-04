`timescale 1ns / 1ps

module processor_tb;

    reg clock; // clock signal that will be generated in the testbench and connected to the processor module. It will toggle between 0 and 1 to simulate the clock cycles for the processor's operation.
    reg reset; //reset signal set to 1 at the beginning to initiate the processor's state, and 0 when the prcsr is ready to start executing.

    processor_top proc_inst ( // generates instance of the processor.v module, which connects the clock and reset signals to the module.
        .clk(clock), 
        .reset(reset)
    );

    
    initial clock = 1'b0; // at time=0, set clock =0
    initial forever #5 clock = ~clock; // at every 5 time units, flip the clock signal, and do this forever

    //the above code creates a clock signal that keeps flipping between 0 and 1 every 5 time units so the processor can run

    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, processor_tb);

        reset = 1'b1; //at time=0, set reset to 1 to initialize the processor's state. This will typically cause the processor to start in a known state, such as setting the program counter to 0 and clearing registers.
        #10 reset = 1'b0;//at time =10, set reset to 0 , which allows the processor to start executing the instructions.

        // Signals: see wires in processor.v (wbdata = register file write data)
        $monitor(
            "t=%0t | PC=%04h | INSTR=%04h | ALU=%04h | DMEM_RD=%04h | RF_WD=%04h",
            $time, proc_inst.pc_current, proc_inst.instruction, proc_inst.alu_result, proc_inst.mem_read_data, proc_inst.wbdata);

        #450;
        $display("Done at t=%0t", $time);
        $finish;
    end

endmodule
