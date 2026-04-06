`timescale 1ns / 1ps

module top_level_fpga(
    input  wire        clock, // this is the most imp clock signal
    input  wire        resetButton, //this button resets the processor
    output wire [15:0] fpga_out //this is the output that's connected to the LED
);
    reg [25:0] clockCounter; //clock cycle counter for a slower clock to ensure visibility 
    wire       clockSlow;
    always @(posedge clock or posedge resetButton) begin
        if (resetButton == 1'b1) //if reset hit set clock counter to 0
            clockCounter <= 26'd0;
        else   //else add 1 to it
            clockCounter <= clockCounter + 26'd1;
    end

    assign clockSlow = clockCounter[25];

    // Instantiate your processor
    processor_top fpgaProc (
        .clk   (clockSlow),
        .reset (resetButton)
    );

    assign fpga_out = fpgaProc.pc_current; //basically the prog counter value from my processor

endmodule