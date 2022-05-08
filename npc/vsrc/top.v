module top(
	input clk,
	input rst,
	input a,
	input b,
	output f,
	output reg [15:0] led
);

switch switch0(
	.clk(clk),
	.rst(rst),
	.a(a),
	.b(b),
	.f(f)
);

light light0(
	.clk(clk),
	.rst(rst),
	.led(led)
);


endmodule
