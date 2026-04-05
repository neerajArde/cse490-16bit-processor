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
            "t=%0t | PC=%04h | INSTR=%04h | ALU=%04h | DMEM_RD=%04h | RF_WD=%04h | MemRead=%b | MemWrite=%b | Branch=%b | Jump=%b | Zero=%b",
            $time, proc_inst.pc_current, proc_inst.instruction, proc_inst.alu_result, proc_inst.mem_read_data, proc_inst.wbdata, proc_inst.RegWrite,proc_inst.MemRead,proc_inst.MemWrite,proc_inst.Branch,
            proc_inst.Jump,
            proc_inst.zero
);
       
       // THIS IS THE VERIFICATION PART OF TGE TEST BENCH
        #5 // tesing for addi $s1, $s0, 5 
        $display("checking addi : RF_WD=%04h (expected is 0005) %s",
            proc_inst.wbdata,
            (proc_inst.wbdata == 16'h0005) ? "passed addi $s1, $s0, 5" : "failed addi $s1, $s0, 5");
        #10;        // addi $s2, $s0, 3 progCounter=0002
        $display("checking 2nd addi : RF_WD=%04h (expected is 0003) %s",
            proc_inst.wbdata,
            (proc_inst.wbdata == 16'h0003) ? "passed addi $s2, $s0, 3" : "failed addi $s2, $s0, 3");

        
        #10; // add  progCounter=0004
        $display("checking  add  : RF_WD=%04h (expected is 0008) %s",
            proc_inst.wbdata,
            (proc_inst.wbdata == 16'h0008) ? "passed add" : "failed add");

        // sub progCounter=0006
        #10;
        $display("checking  sub  : ALU=%04h   (expected is fffb) %s",
            proc_inst.alu_result,
            (proc_inst.alu_result == 16'hfffb) ? "passed sub" : "failed sub");


        // and  progCounter=0008
        #10;
        $display("checking  and  : RF_WD=%04h (expected is 0003) %s",
            proc_inst.wbdata,
            (proc_inst.wbdata == 16'h0003) ? "passed and" : "failed and");
        
        // sll  progCounter=000a
        #10;
        $display("checking sll  : RF_WD=%04h (expected is 0018) %s",
            proc_inst.wbdata,
            (proc_inst.wbdata == 16'h0018) ? "passed sll" : "failed sll");
 
        // load and store word 
        #10;
        $display("checking sw   : MemWr=%b (expected is 1) %s",
            proc_inst.MemWrite,
            (proc_inst.MemWrite == 1'b1) ? "passed sw" : "failed sw");
         #10;
        $display("checking lw   : DMEM_RD=%04h (expected is 0018) %s",
            proc_inst.mem_read_data,
            (proc_inst.mem_read_data == 16'h0018) ? "passed lw" : "failed lw");
         
        #10; // now testing beq
        $display("checking beq  : Branch=%b Zero=%b BranchDec=%b (expected is Branch=1 Zero=0 BranchDec=0) %s",
            proc_inst.Branch,
            proc_inst.zero,
            proc_inst.branchDecision,
        (proc_inst.Branch == 1'b1 && proc_inst.zero == 1'b1 && proc_inst.branchDecision == 1'b1) ? "passed beq" : "failed beq");        
        #10;
        $display("checking addi skipped : RF_WD=%04h (expected is 0000 - skipped by beq) %s",
            proc_inst.wbdata,
            (proc_inst.wbdata == 16'h0000) ? "passed addi skipped" : "failed addi skipped");
        $display("checking jump : Jump=%b    (expected is 1)    %s",
            proc_inst.Jump,
            (proc_inst.Jump == 1'b1) ? "passed jump" : "failed jump");
        #10; //final check to ensure prgcount back to 0 affter jump
        $display("checking jump landing: PC=%04h (expected is 0000) %s",
            proc_inst.pc_current,
            (proc_inst.pc_current == 16'h0000) ? "passed jump landing" : "failed jump landing");

        #450;
        $display("Done at t=%0t", $time);
        $finish;
    end

endmodule
