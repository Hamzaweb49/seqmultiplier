module AddModule(
    input logic clk,
    input logic [15:0] multiplicand,
    input logic [15:0] accumulator,
    input logic add_signal,
    output logic [15:0] accumulator_out
);
always @(posedge clk) begin
    accumulator_out <= add_signal ? (multiplicand ^ accumulator) : accumulator;
end

endmodule

module ShiftModule(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic [15:0] accumulator,
    input logic [15:0] multiplier,
    input logic [0:0] carry,
    output logic [15:0] accumulator_out,
    output reg [15:0] multiplier_out,
    output logic [0:0] carry_out
);

reg [15:0] shift_reg;
reg carry_reg;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        shift_reg <= 16'b0;
        carry_reg <= 1'b0;
    end else if (enable) begin
        carry_reg <= carry_reg >> 1;
        shift_reg <= accumulator >> 1;
        multiplier_out <= multiplier >> 1;
    end
end

assign accumulator_out = shift_reg;
assign carry_out = carry_reg;

endmodule

module MuxModule(
    input logic [15:0] multiplicand,
    input logic [15:0] zeros,
    input logic mux_signal,
    output logic [15:0] selected_input
);

assign selected_input = mux_signal ? multiplicand : zeros;

endmodule

module Datapath(
    input logic clk,
    input logic reset,
    input logic start,
    input logic add_signal,
    input logic shift_signal,
    input logic mux_signal,
    input logic [15:0] multiplicand,
    input logic [15:0] accumulator,
    input logic [15:0] multiplier,
    output logic [31:0] product
);

logic [15:0] shift_reg_shift;
reg [15:0] shift_reg_mux;
reg [15:0] intermediate_accumulator;
logic [15:0] shift_multiplier; 
reg carry;


// Mux Module instantiation
MuxModule mux_inst(
    .multiplicand(multiplicand), 
    .zeros(16'b0),
    .mux_signal(mux_signal), 
    .selected_input(shift_reg_mux)
);

always @(posedge reset) begin

end


// // Add Module instantiation
AddModule add_inst(.clk(clk), .multiplicand(shift_reg_mux), .accumulator(accumulator),
                  .add_signal(add_signal), .accumulator_out(intermediate_accumulator));

// Shift Module instantiation
ShiftModule shift_inst(
    .clk(clk), 
    .reset(reset), 
    .enable(shift_signal),
    .accumulator(intermediate_accumulator), 
    .multiplier(multiplier),
    .carry(carry), 
    .accumulator_out(shift_reg_shift),
    .multiplier_out(shift_multiplier), 
    .carry_out(carry)
);

// Output product
assign product = {shift_reg_shift, shift_multiplier};

endmodule

module Controller(
    input logic clk,
    input logic reset,
    input logic start,
    input logic [15:0] multiplier,
    output reg add_signal,
    output reg shift_signal,
    output reg mux_signal
);

parameter IDLE = 2'b00;
parameter ADD = 2'b01;
parameter SHIFT = 2'b10;
parameter FINISH = 2'b11;

reg [1:0] state;
reg [3:0] count;


always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        count <= 4'b0;
        add_signal <= 1'b0;
        shift_signal <= 1'b0;
        mux_signal <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= ADD;
                    count <= 4'b0;
                    add_signal <= 1'b0;
                    shift_signal <= 1'b0;
                    mux_signal <= 1'b0;
                end
            end
            ADD: begin
                mux_signal = multiplier[0];
                add_signal = 1'b1;
                state <= SHIFT;
            end
            SHIFT: begin
                if (count < 16) begin
                    count <= count + 1;
                    shift_signal <= 1'b1;
                    state <= ADD;
                end else begin
                    state <= FINISH;
                end
            end
            FINISH: begin
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

endmodule

// always @(posedge clk) begin
// $display("The values of intermediate accumulator is %b:", intermediate_accumulator);
// end
