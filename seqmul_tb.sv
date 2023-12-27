module tb_SequentialMultiplier;

logic clk, reset, start, add_signal, shift_signal, mux_signal;
logic [15:0] multiplicand;
logic [15:0] accumulator; 
logic [15:0] multiplier;
logic [31:0] product;

// Instantiate the UUT
Datapath uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .add_signal(add_signal),
    .shift_signal(shift_signal),
    .mux_signal(mux_signal),
    .multiplicand(multiplicand),
    .accumulator(accumulator),
    .multiplier(multiplier),
    .product(product)
);

Controller dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .add_signal(add_signal),
    .shift_signal(shift_signal),
    .mux_signal(mux_signal),
    .multiplier(multiplier)
);


// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Initial stimulus
initial begin
    reset = 1;
    start = 0;
    multiplicand = 16'b0;
    accumulator = 16'b0;
    multiplier = 16'b0;

    #10 reset = 0;  // Release reset
    start = 1;  // Start the multiplication process

    multiplicand = 16'h0001;
    multiplier = 16'h0001;

    #100 $finish;  // Finish simulation after some time
end

endmodule
