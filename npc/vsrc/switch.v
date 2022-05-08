module switch(
	input clk,
	input rst,
	input a,
	input b,
	output f
);

reg led;

always @(posedge clk) begin
	if (rst) begin 
		led <= 0;
	end
	else begin 
		led <= a^b;
	end
end

assign f = led;
endmodule
