// 2^26 = 67,108,864
module part3 (KEY, CLOCK_50, HEX0);
	input [0:0] KEY;
	input CLOCK_50;
	output [6:0] HEX0;
	
	wire reset;
	assign reset = KEY[0];
	
	reg [25:0] slow_count;
	reg [3:0] digit;
	
	always @(posedge CLOCK_50)
	begin
	if(reset == 1'b0)
		begin
			slow_count <= 26'b0;
			digit <= 4'b0;
		end
	else
		if(slow_count == 50000000)
		begin
			slow_count <= 26'b0;
			digit <= digit + 1;
			if(digit == 9)
			digit <= 0;
		end
		else
			slow_count <= slow_count + 1;	
	end
	
	hexdisplay hex0 (digit[3], digit[2], digit[1], digit[0], HEX0[0], HEX0[1], HEX0[2], HEX0[3], HEX0[4], HEX0[5], HEX0[6]);
	
endmodule


module hexdisplay(a, b, c, d, h0, h1, h2, h3, h4, h5, h6);
	input a, b, c, d;
	output h0, h1, h2, h3, h4, h5, h6;
	
	assign h0 = (~a & b & ~c & ~d) | (~a & ~b & ~c & d) | (a & b & ~c & d) | (a & ~b & c & d);
	assign h1 = (a & c & d) | (b & c & ~d) | (a & b & ~d) | (~a & b & ~c & d);
	assign h2 = (a & b & c) | (a & b & ~d) | (~a & ~b & c & ~d);
	assign h3 = (~b & ~c & d) | (b & c & d) | (~a & b & ~c & ~d) | (a & ~b & c & ~d);
	assign h4 = (~a & d) | (~a & b & ~c) | (~b & ~c & d);
	assign h5 = (~a & ~b & d) | (~a & c & d) | (~a & ~b & c) | (a & b & ~c & d);
	assign h6 = (~a & ~b & ~c) | (a & b & ~c & ~d) | (~a & b & c & d);
endmodule


