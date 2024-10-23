module part1 (SW, KEY, HEX1, HEX0);
	input [1:0] SW ;
	input [0:0] KEY ;
	output [6:0] HEX1, HEX0;

	wire Clock, Enable, Clear;
	wire [7:0]T;
	wire [7:0]Count;

	assign Clock = KEY[0];
	assign Enable = SW[1];
	assign Clear = SW[0];
	assign T[0] = SW[1];

	assign T[1] = Enable & Count[0];             
	assign T[2] = Enable & Count[1] & Count[0];      
	assign T[3] = Enable & Count[2] & Count[1] & Count[0]; 
	assign T[4] = Enable & Count[3] & Count[2] & Count[1] & Count[0];
	assign T[5] = Enable & Count[4] & Count[3] & Count[2] & Count[1] & Count[0];
	assign T[6] = Enable & Count[5] & Count[4] & Count[3] & Count[2] & Count[1] & Count[0];
	assign T[7] = Enable & Count[6] & Count[5] & Count[4] & Count[3] & Count[2] & Count[1] & Count[0];
	
	t_ff t_ff0(T[0], Clock, Clear, Count[0]);
	t_ff t_ff1(T[1], Clock, Clear, Count[1]);
	t_ff t_ff2(T[2], Clock, Clear, Count[2]);
	t_ff t_ff3(T[3], Clock, Clear, Count[3]);
	t_ff t_ff4(T[4], Clock, Clear, Count[4]);
	t_ff t_ff5(T[5], Clock, Clear, Count[5]);
	t_ff t_ff6(T[6], Clock, Clear, Count[6]);
	t_ff t_ff7(T[7], Clock, Clear, Count[7]);
	
	hexdisplay hexdisplay0 (Count[3], Count[2], Count[1], Count[0], HEX0[0], HEX0[1], HEX0[2], HEX0[3], HEX0[4], HEX0[5], HEX0[6]);
	hexdisplay hexdisplay1 (Count[7], Count[6], Count[5], Count[4], HEX1[0], HEX1[1], HEX1[2], HEX1[3], HEX1[4], HEX1[5], HEX1[6]);
endmodule


module t_ff (T, Clock, Clear, Q);
	input T, Clock, Clear;
	output reg Q;
	
	always @ (posedge Clock)
	begin
		if(Clear == 1'b0)
			Q<=1'b0;
		else if(T == 1'b1)
			Q <= ~Q;
		else if(T == 1'b0)
			Q <= Q;
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