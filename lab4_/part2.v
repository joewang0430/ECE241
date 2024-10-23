module part2 (SW, KEY, HEX3, HEX2, HEX1, HEX0);
	input [1:0] SW;
	input [0:0] KEY;
	output [6:0] HEX3, HEX2, HEX1, HEX0;
	
	wire Clock, Enable, Clear;
	wire [15:0]Count;
	assign Clock = KEY[0];
	assign Enable = SW[1]; 
	assign Clear = SW[0];
	
	bit16counter u1 (Clock, Enable, Clear, Count);
	
	hexdisplay hexdisplay0 (Count[3], Count[2], Count[1], Count[0], HEX0[0], HEX0[1], HEX0[2], HEX0[3], HEX0[4], HEX0[5], HEX0[6]);
	hexdisplay hexdisplay1 (Count[7], Count[6], Count[5], Count[4], HEX1[0], HEX1[1], HEX1[2], HEX1[3], HEX1[4], HEX1[5], HEX1[6]);
	hexdisplay hexdisplay2 (Count[11], Count[10], Count[9], Count[8], HEX2[0], HEX2[1], HEX2[2], HEX2[3], HEX2[4], HEX2[5], HEX2[6]);
	hexdisplay hexdisplay3 (Count[15], Count[14], Count[13], Count[12], HEX3[0], HEX3[1], HEX3[2], HEX3[3], HEX3[4], HEX3[5], HEX3[6]);
endmodule

//module bit16counter(Clock, Enable, Clear, Count);
//	input Clock, Enable, Clear;
//	output reg [15:0] Count;
//	
//	always @(posedge Clock)
//	begin
//		if(Enable == 1'b1)
//		begin
//			if(Clear == 1'b0)
//				Count <= 16'b0;
//			else
//				Count <= Count + 1'b1;
//		end
//	end
//endmodule

module bit16counter(Clock, Enable, Clear, Count);
	input Clock, Enable, Clear;
	output reg [15:0] Count;
	
	always @(posedge Clock)
	begin
		if(Clear == 1'b0)
			Count <= 16'b0;
		else if(Enable == 1'b1)
			Count <= Count + 1'b1;
	end
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
