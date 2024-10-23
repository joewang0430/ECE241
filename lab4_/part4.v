module part4 (KEY, CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [0:0] KEY;
	input CLOCK_50;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	
	wire reset;
	assign reset = KEY[0];
	
	reg [25:0] slow_count;
	reg [2:0] digit;
	
	always @(posedge CLOCK_50)
	begin
	if(reset == 1'b0)
		begin
			slow_count <= 26'b0;
			digit <= 3'b0;
		end
	else
		if(slow_count == 50000000)
		begin
			slow_count <= 26'b0;
			digit <= digit + 1;
			if(digit == 5)
			digit <= 0;
		end
		else
			slow_count <= slow_count + 1;	
	end
	
	wire [1:0]c0;
	wire [1:0]c1;
	wire [1:0]c2;
	wire [1:0]c3;
	wire [1:0]c4;
	wire [1:0]c5;
	
	mux0 m0 (digit, c0);
	mux1 m1 (digit, c1);
	mux2 m2 (digit, c2);
	mux3 m3 (digit, c3);
	mux4 m4 (digit, c4);
	mux5 m5 (digit, c5);
	
	hex h0 (c0, HEX0[0], HEX0[1], HEX0[2], HEX0[3], HEX0[4], HEX0[5], HEX0[6]);
	hex h1 (c1, HEX1[0], HEX1[1], HEX1[2], HEX1[3], HEX1[4], HEX1[5], HEX1[6]);
	hex h2 (c2, HEX2[0], HEX2[1], HEX2[2], HEX2[3], HEX2[4], HEX2[5], HEX2[6]);
	hex h3 (c3, HEX3[0], HEX3[1], HEX3[2], HEX3[3], HEX3[4], HEX3[5], HEX3[6]);
	hex h4 (c4, HEX4[0], HEX4[1], HEX4[2], HEX4[3], HEX4[4], HEX4[5], HEX4[6]);
	hex h5 (c5, HEX5[0], HEX5[1], HEX5[2], HEX5[3], HEX5[4], HEX5[5], HEX5[6]);
	
endmodule


module mux0(digit, c);
	input [2:0] digit;
	output reg [1:0] c;
	
	always @(*)
	begin
		if(digit == 0)
		begin
			c[0] <=0;
			c[1] <=1;
		end
		else if(digit ==4)
		begin
			c[0] <=0;
			c[1] <=0;
		end
		else if(digit ==5)
		begin
			c[0] <=1;
			c[1] <=0;
		end
		else
		begin
			c[0] <=1;
			c[1] <=1;
		end
	end
endmodule


module mux1(digit, c);
	input [2:0] digit;
	output reg [1:0] c;
	
	always @(*)
	begin
		if(digit ==0)
		begin
			c[0] <=1;
			c[1] <=0;
		end
		else if(digit ==1)
		begin
			c[0] <=0;
			c[1] <=1;
		end
		else if(digit ==5)
		begin
			c[0] <=0;
			c[1] <=0;
		end
		else
		begin
			c[0] <=1;
			c[1] <=1;
		end
	end
endmodule


module mux2(digit, c);
	input [2:0] digit;
	output reg [1:0] c;
	
	always @(*)
	begin
		if(digit ==0)
		begin
			c[0] <=0;
			c[1] <=0;
		end
		else if(digit ==1)
		begin
			c[0] <=1;
			c[1] <=0;
		end
		else if(digit ==2)
		begin
			c[0] <=0;
			c[1] <=1;
		end
		else
		begin
			c[0] <=1;
			c[1] <=1;
		end
	end
endmodule


module mux3(digit, c);
	input [2:0] digit;
	output reg [1:0] c;
	
	always @(*)
	begin
		if(digit ==1)
		begin
			c[0] <=0;
			c[1] <=0;
		end
		else if(digit ==2)
		begin
			c[0] <=1;
			c[1] <=0;
		end
		else if(digit ==3)
		begin
			c[0] <=0;
			c[1] <=1;
		end
		else
		begin
			c[0] <=1;
			c[1] <=1;
		end
	end
endmodule


module mux4(digit, c);
	input [2:0] digit;
	output reg [1:0] c;
	
	always @(*)
	begin
		if(digit ==2)
		begin
			c[0] <=0;
			c[1] <=0;
		end
		else if(digit ==3)
		begin
			c[0] <=1;
			c[1] <=0;
		end
		else if(digit ==4)
		begin
			c[0] <=0;
			c[1] <=1;
		end
		else
		begin
			c[0] <=1;
			c[1] <=1;
		end
	end
endmodule


module mux5(digit, c);
	input [2:0] digit;
	output reg [1:0] c;
	
	always @(*)
	begin
		if(digit ==3)
		begin
			c[0] <=0;
			c[1] <=0;
		end
		else if(digit ==4)
		begin
			c[0] <=1;
			c[1] <=0;
		end
		else if(digit ==5)
		begin
			c[0] <=0;
			c[1] <=1;
		end
		else
		begin
			c[0] <=1;
			c[1] <=1;
		end
	end
endmodule


module hex (c, h0, h1, h2, h3, h4, h5, h6);
	input [1:0] c;
	output h0, h1, h2, h3, h4, h5, h6;
	
	assign h0 = ~c[0] | c[1];
	assign h1 = c[0];
	assign h2 = c[0];
	assign h3 = c[1];
	assign h4 = c[1];
	assign h5 = ~c[0] | c[1];
	assign h6 = c[1];
endmodule

