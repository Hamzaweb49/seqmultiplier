module controller (
  input wire clk,
  input wire rst,
  input wire start,
  output reg enable_multiply
);

  // Instantiate datapath
  datapath dp_unit (.clk(clk), .rst(rst), .multiplicand(multiplicand), .multiplier(multiplier), .product());

  reg [3:0] state;
  parameter IDLE = 4'b0000;
  parameter CHECK_LSB = 4'b0010;
  parameter SELECT_MUL = 4'b0011;
  parameter SELECT_ZERO = 4'b0100;
  parameter ADD = 4'b0101;
  parameter SHIFT = 4'b0110;

  reg [3:0] count;  // Counter for shifting

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      enable_multiply <= 1'b0;
      count <= 4'b0;
    end
    else begin
      case (state)
        IDLE: begin
          if (start) begin
            count <= 4'b0;  // Reset count
            enable_multiply <= 1'b1;
            state <= CHECK_LSB;
          end
        end
        CHECK_LSB: begin
          if (dp_unit.Q[0])
            state <= SELECT_MUL;
          else
            state <= SELECT_ZERO;
        end
        SELECT_MUL: begin
          dp_unit.mux_out <= dp_unit.multiplier;  // Select multiplicand at mux output
          state <= ADD;
        end
        SELECT_ZERO: begin
          dp_unit.mux_out <= 16'b0;       // Select 0 at mux output
          state <= ADD;
        end
        ADD: begin
          {dp_unit.adder_out, dp_unit.carry} <= dp_unit.accumulator + dp_unit.mux_out + dp_unit.carry;  // Addition logic
          dp_unit.accumulator <= dp_unit.adder_out;
          state <= SHIFT;
        end
        SHIFT: begin
          {dp_unit.accumulator, dp_unit.Q} <= {dp_unit.carry, dp_unit.accumulator, dp_unit.Q};  // Shift logic
          count <= count + 1;

          if (count > 15)  // Assuming 16 shifts for a 16-bit multiplier
            state <= IDLE;
          else
            state <= CHECK_LSB;
        end
      endcase
    end
  end
endmodule



module datapath (
  input wire clk,
  input wire rst,
  input wire [15:0] multiplicand,
  input wire [15:0] multiplier,
  output reg [31:0] product
);
  reg [15:0] accumulator;
  reg [15:0] Q;
  reg Q_lsb;
  reg [15:0] mux_out;
  reg [15:0] adder_out;
  reg carry;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      accumulator <= 16'b0;
      Q <= 16'b0;
      Q_lsb <= 1'b0;
      mux_out <= 16'b0;
      adder_out <= 16'b0;
      carry <= 1'b0;
      product <= {accumulator, Q};
    end
    else begin
      // Multiplexer
      if (Q_lsb)
        mux_out <= multiplier;
      else
        mux_out <= 16'b0;

      // Adder
      {adder_out, carry} <= accumulator + mux_out + carry;  // Addition logic
      accumulator <= adder_out;

      // Right shift operation
      {accumulator, Q} <= {carry, accumulator, Q};  // Shift logic

      // Update Q and Q_lsb
      Q_lsb <= Q[0];
      Q <= Q >> 1;

      // Output the product
      product <= {accumulator, Q};
    end
  end
endmodule