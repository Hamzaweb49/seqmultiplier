module tb_seq_multiplier;

  reg clk;
  reg rst;
  reg start;
  reg [15:0] multiplicand;
  reg [15:0] multiplier;
  reg [31:0] product;

  // Instantiate the sequential multiplier components
  controller ctrl_unit (.clk(clk), .rst(rst), .start(start), .enable_multiply(enable_multiply));
  datapath dp_unit (.clk(clk), .rst(rst), .multiplicand(multiplicand), .multiplier(multiplier), .product(product));

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    // Initialize inputs
    rst = 1;
    start = 0;
    multiplicand = 16'b0;
    multiplier = 16'b0;

    // Apply reset
    #10 rst = 0;

    // Start multiplication
    #20 start = 1;

    multiplicand = 16'h5678;
    multiplier = 16'h1234;

    #100;

    $stop;
  end
endmodule