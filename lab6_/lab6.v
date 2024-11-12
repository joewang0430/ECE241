module lab6(
	 input CLOCK_50,
	 input [3:0] KEY,
	 input [9:0] SW,
	 output [9:0] LEDR,
	 output [7:0] VGA_R,
	 output [7:0] VGA_G,
	 output [7:0] VGA_B,
	 output VGA_HS,
	 output VGA_VS,
	 output VGA_BLANK_N,
	 output VGA_SYNC_N,
	 output VGA_CLK
	);

	// Color of all elements 
	parameter COLOR_BODY_A = 9'b000_000_111;           
   parameter COLOR_BODY_B = 9'b111_000_000;           
	parameter COLOR_GUN_A = 9'b000_000_111;
	parameter COLOR_GUN_B = 9'b111_000_000;
	parameter COLOR_CENTER_A = 9'b000_000_111;
	parameter COLOR_CENTER_B = 9'b111_000_000;
	parameter COLOR_TIRE_A = 9'b000_000_000;
	parameter COLOR_TIRE_B = 9'b000_000_000;
	
	parameter COLOR_BULLET_A = 9'b000_000_000;
	parameter COLOR_BULLET_B = 9'b000_000_000; // black bullet
	
	parameter COLOR_GROUND = 9'b111_111_111; // white road
	parameter COLOR_WALL = 9'b111_010_000;	// brown walls
	
	reg [8:0] VGA_COLOR;
	
   // init centeral position of tank A and B
	parameter X0_A = 8'd6, Y0_A = 7'd6;
	parameter X0_B = 8'd155, Y0_B = 7'd115;
	
	parameter IDLE = 4'b0000, UP = 4'b0001, DOWN = 4'b0010, LEFT = 4'b0100, RIGHT = 4'b1000;
	 
	/*
	// All pixels of tank A
	reg [7:0] Xc_A, Xb1_A, Xb2_A, Xb3_A, Xb4_A, Xb5_A, Xb6_A, Xb7_A, Xb8_A, Xg1_A, Xg2_A, 
				 Xw1_A, Xw2_A, Xw3_A, Xw4_A, Xw5_A, Xw6_A, Xw7_A, Xw8_A;
	reg [6:0] Yc_A, Yb1_A, Yb2_A, Yb3_A, Yb4_A, Yb5_A, Yb6_A, Yb7_A, Yb8_A, Yg1_A, Yg2_A, 
				 Yw1_A, Yw2_A, Yw3_A, Yw4_A, Yw5_A, Yw6_A, Yw7_A, Yw8_A;
				 
	// All pixels of tank B
	reg [7:0] Xc_B, Xb1_B, Xb2_B, Xb3_B, Xb4_B, Xb5_B, Xb6_B, Xb7_B, Xb8_B, Xg1_B, Xg2_B, 
				 Xw1_B, Xw2_B, Xw3_B, Xw4_B, Xw5_B, Xw6_B, Xw7_B, Xw8_B;
	reg [6:0] Yc_B, Yb1_B, Yb2_B, Yb3_B, Yb4_B, Yb5_B, Yb6_B, Yb7_B, Yb8_B, Yg1_B, Yg2_B, 
				 Yw1_B, Yw2_B, Yw3_B, Yw4_B, Yw5_B, Yw6_B, Yw7_B, Yw8_B;
	*/

	reg [7:0] Xc_A, Xc_B;
	reg [6:0] Yc_A, Yc_B;
	// Milestone 1: position of bullets are just fixed, will be changed later
	reg [7:0] Xb_A = 8'd20;
	reg [6:0] Yb_A = 8'd20;
	reg [7:0] Xb_B = 8'd30;
	reg [6:0] Yb_B = 8'd20;

   // VGA traversing signal
   reg [7:0] x;
	reg [6:0] y;
	
	// Fsm states
	reg [3:0] y_Q_A, y_Q_B;	// y_Q = current state, Y_D = next state
	wire [3:0] Y_D_A, Y_D_B;
	 
	// Cosider change plot later
	wire plot = 1'b1;
	
	// Reset & init
	wire resetn;
	wire init;
	assign resetn = KEY[0];
	assign init = ~KEY[1];
	
	// Handle directions & bolcking issues
   wire dash_up_A, dash_down_A, dash_left_A, dash_right_A;
	wire dash_up_B, dash_down_B, dash_left_B, dash_right_B;
	
	assign dash_up_A = SW[8];
	assign dash_down_A = SW[7];
	assign dash_left_A = SW[9];
	assign dash_right_A = SW[6];
	
	assign dash_up_B = SW[2];
	assign dash_down_B = SW[1];
	assign dash_left_B = SW[3];
	assign dash_right_B = SW[0];
	
	reg [3:0] dash_status_A, dash_status_B;
	wire [3:0] blocked_status_A, blocked_status_B;
	/* reg is_move_A, is_move_B; */
	reg is_killed_A,is_killed_B;
	
	// Check if tank is killed
	always @(*) begin
		is_killed_A = (Xb_B + 2 >= Xc_A && Xb_B <= Xc_A + 2) && (Yb_B <= Yc_A + 2 && Yb_B + 2>= Yc_A);
		is_killed_B = (Xb_A + 2 >= Xc_B && Xb_A <= Xc_B + 2) && (Yb_A <= Yc_B + 2 && Yb_A + 2>= Yc_B);
	end
	
	always @(*) begin
		if (dash_up_A) begin
			dash_status_A = UP;
		end else if (dash_down_A) begin 
			dash_status_A = DOWN;
		end else if (dash_left_A) begin 
			dash_status_A = LEFT;
		end else if (dash_right_A) begin 
			dash_status_A = RIGHT;
		end else begin 
			dash_status_A = IDLE;
		end
	end
	
	always @(*) begin
		if (dash_up_B) begin
			dash_status_B = UP;
		end else if (dash_down_B) begin 
			dash_status_B = DOWN;
		end else if (dash_left_B) begin 
			dash_status_B = LEFT;
		end else if (dash_right_B) begin 
			dash_status_B = RIGHT;
		end else begin 
			dash_status_B = IDLE;
		end
	end
	/*
	always @(*) begin
		is_move_A = dash_up_A || dash_down_A || dash_left_A || dash_right_A;
	end
	always @(*) begin
		is_move_B = dash_up_B || dash_down_B || dash_left_B || dash_right_B;
	end
	*/
	check_blocked_direcrtiom cbd_A (Xc_A, Yc_A, dash_status_A, blocked_status_A);
	check_blocked_direcrtiom cbd_B (Xc_B, Yc_B, dash_status_B, blocked_status_B);

   // Use tank_clk to move tanks. Speed: 25 pixels/sec
	wire tank_clk;
   tank_counter tank_counter1(CLOCK_50, tank_clk, resetn);
	
	// FSM of tank A & B
	fsm_A fsma (tank_clk, y_Q_A, resetn, init, is_killed_A, dash_status_A, Y_D_A);
	fsm_B fsmb (tank_clk, y_Q_B, resetn, init, is_killed_B, dash_status_B, Y_D_B);
	
	// Update fsm
	always @(posedge tank_clk) begin
		if (!resetn) begin
			y_Q_A <= IDLE;
			y_Q_B <= IDLE;
		end else if (init) begin
			y_Q_A <= DOWN;
			y_Q_B <= UP;
		end else begin
			y_Q_A <= Y_D_A;
			y_Q_B <= Y_D_B;
		end
	end
	// Assign LEDR to check status, delete later
	assign LEDR[9:6] = y_Q_A;
	assign LEDR[3:0] = y_Q_B;
	//assign LEDR[9:6] = dash_status_A;
	//assign LEDR[3:0] = dash_status_B;
	//wire is_blocked_A, is_blocked_B;
	//assign is_blocked_A = (blocked_status_A == UP) || (blocked_status_A == DOWN) || (blocked_status_A == LEFT) || (blocked_status_A == RIGHT);
	//assign is_blocked_B = (blocked_status_B == UP) || (blocked_status_B == DOWN) || (blocked_status_B == LEFT) || (blocked_status_B == RIGHT);
	assign LEDR[4] = is_killed_A;
	assign LEDR[5] = is_killed_B;
	
   // Handle movement tank A
	always @(posedge tank_clk or negedge resetn) begin
		if (!resetn) begin
			Xc_A <= X0_A;
			Yc_A <= Y0_A;
		end else if (init) begin
			Xc_A <= X0_A;
			Yc_A <= Y0_A;
		end else if (is_killed_A || is_killed_B) begin 
			Xc_A <= X0_A;
			Yc_A <= Y0_A;
		end else if (blocked_status_A == IDLE) begin
			case (dash_status_A)
				UP: Yc_A <= Yc_A - 1;
				DOWN: Yc_A <= Yc_A + 1;
				LEFT: Xc_A <= Xc_A - 1;
				RIGHT: Xc_A <= Xc_A + 1;
			endcase
		end
	end
	// Handle movement tank B
	always @(posedge tank_clk or negedge resetn) begin
	
		if (!resetn) begin
			Xc_B <= X0_B;
			Yc_B <= Y0_B;
		end else if (init) begin
			Xc_B <= X0_B;
			Yc_B <= Y0_B;
		end else if (is_killed_A || is_killed_B) begin 
			Xc_B <= X0_B;
			Yc_B <= Y0_B;
		end else if (blocked_status_B == IDLE) begin
			case (dash_status_B)
				UP: Yc_B <= Yc_B - 1;
				DOWN: Yc_B <= Yc_B + 1;
				LEFT: Xc_B <= Xc_B - 1;
				RIGHT: Xc_B <= Xc_B + 1;
			endcase
		end
	end
	 
   // Handle Displaying the pixels
	// MILESTONE1 only, changed later
	/*
	always @(posedge CLOCK_50 or negedge resetn) begin
		if (!resetn) begin
			x <= 0;
			y <= 0;
		end else begin //**
			if (x == 8'd159) begin
				x <= 0;
				if (y == 7'd119) 
					y <= 0;
				else
					y <= y + 1;
			end else 
            x <= x + 1;
         
			// Print testing wall
			if (y == 10 && x >= 20 && x <= 30) begin
				VGA_COLOR <= COLOR_WALL;
			// Print testing bullet A
			end else if (x == Xb_A && y == Yb_A) begin
				VGA_COLOR <= COLOR_BULLET_A;
			// Print testing bullet B
			end else if (x == Xb_B && y == Yb_B) begin
				VGA_COLOR <= COLOR_BULLET_B;
			// Print tank A
			end else if (x == Xc_A && y == Yc_A) begin
				VGA_COLOR <= COLOR_CENTER_A; 
			// Print tank B
			end else if (x == Xc_B && y == Yc_B) begin
				VGA_COLOR <= COLOR_CENTER_B; 
			// Print background (road)
			end else begin
				VGA_COLOR <= COLOR_GROUND;
			end
		end
   end
	 */
	// Handle VGA color assignment for all objects and tanks
	
	
	
  always @(posedge CLOCK_50 or negedge resetn) begin
		if (!resetn) begin
			x <= 0;
			y <= 0;
		end else if (y_Q_A != IDLE && y_Q_B != IDLE) begin 
			if (x == 8'd159) begin
				x <= 0;
				if (y == 7'd119) 
					y <= 0;
				else
					y <= y + 1;
			end else begin
            x <= x + 1;
			end
		end
	end
	
	
  always @(*) begin
    // 默认设置为背景颜色
    VGA_COLOR = COLOR_GROUND;
    
    // Print environment objects
    if (y == 10 && x >= 20 && x <= 30) begin
        VGA_COLOR = COLOR_WALL;
    end else if (x == Xb_A && y == Yb_A) begin
        VGA_COLOR = COLOR_BULLET_A;
    end else if (x == Xb_B && y == Yb_B) begin
        VGA_COLOR = COLOR_BULLET_B;
    end else if (x == Xc_A && y == Yc_A) begin
        VGA_COLOR = COLOR_CENTER_A;
    end else if (x == Xc_B && y == Yc_B) begin
        VGA_COLOR = COLOR_CENTER_B;
    
    // Print tank A parts based on its direction (y_Q_A)
    end else begin
        case (y_Q_A)
            UP: begin
                if ((x == Xc_A) && (y == Yc_A - 1 || y == Yc_A - 2)) VGA_COLOR = COLOR_GUN_A;
                else if ((x == Xc_A - 1 && y >= Yc_A && y <= Yc_A + 2) || 
                         (x == Xc_A && y >= Yc_A + 1 && y <= Yc_A + 2) || 
                         (x == Xc_A + 1 && y >= Yc_A && y <= Yc_A + 2)) 
                         VGA_COLOR = COLOR_BODY_A;
                else if ((x == Xc_A - 2 && y >= Yc_A - 1 && y <= Yc_A + 2) || 
                         (x == Xc_A + 2 && y >= Yc_A - 1 && y <= Yc_A + 2)) 
                         VGA_COLOR = COLOR_TIRE_A;
            end
            DOWN: begin
                if ((x == Xc_A) && (y == Yc_A + 1 || y == Yc_A + 2)) VGA_COLOR = COLOR_GUN_A;
                else if ((x == Xc_A - 1 && y >= Yc_A - 2 && y <= Yc_A) || 
                         (x == Xc_A && y >= Yc_A - 2 && y <= Yc_A - 1) || 
                         (x == Xc_A + 1 && y >= Yc_A - 2 && y <= Yc_A)) 
                         VGA_COLOR = COLOR_BODY_A;
                else if ((x == Xc_A - 2 && y >= Yc_A - 2 && y <= Yc_A + 1) || 
                         (x == Xc_A + 2 && y >= Yc_A - 2 && y <= Yc_A + 1)) 
                         VGA_COLOR = COLOR_TIRE_A;
            end
            LEFT: begin
                if (y == Yc_A && (x == Xc_A - 1 || x == Xc_A - 2)) VGA_COLOR = COLOR_GUN_A;
                else if ((y == Yc_A - 1 && x >= Xc_A && x <= Xc_A + 2) || 
                         (y == Yc_A && x >= Xc_A + 1 && x <= Xc_A + 2) || 
                         (y == Yc_A + 1 && x >= Xc_A && x <= Xc_A + 2)) 
                         VGA_COLOR = COLOR_BODY_A;
                else if ((y == Yc_A - 2 && x >= Xc_A - 1 && x <= Xc_A + 2) || 
                         (y == Yc_A + 2 && x >= Xc_A - 1 && x <= Xc_A + 2)) 
                         VGA_COLOR = COLOR_TIRE_A;
            end
            RIGHT: begin
                if ((y == Yc_A) && (x == Xc_A + 1 || x == Xc_A + 2)) VGA_COLOR = COLOR_GUN_A;
                else if ((y == Yc_A - 1 && x >= Xc_A - 2 && x <= Xc_A) || 
                         (y == Yc_A && x >= Xc_A - 2 && x <= Xc_A - 1) || 
                         (y == Yc_A + 1 && x >= Xc_A - 2 && x <= Xc_A)) 
                         VGA_COLOR = COLOR_BODY_A;
                else if ((y == Yc_A - 2 && x >= Xc_A - 2 && x <= Xc_A + 1) || 
                         (y == Yc_A + 2 && x >= Xc_A - 2 && x <= Xc_A + 1)) 
                         VGA_COLOR = COLOR_TIRE_A;
            end
        endcase

        // Print tank B parts based on its direction (y_Q_B)
        case (y_Q_B)
            UP: begin
                if ((x == Xc_B) && (y == Yc_B - 1 || y == Yc_B - 2)) VGA_COLOR = COLOR_GUN_B;
                else if ((x == Xc_B - 1 && y >= Yc_B && y <= Yc_B + 2) || 
                         (x == Xc_B && y >= Yc_B + 1 && y <= Yc_B + 2) || 
                         (x == Xc_B + 1 && y >= Yc_B && y <= Yc_B + 2)) 
                         VGA_COLOR = COLOR_BODY_B;
                else if ((x == Xc_B - 2 && y >= Yc_B - 1 && y <= Yc_B + 2) || 
                         (x == Xc_B + 2 && y >= Yc_B - 1 && y <= Yc_B + 2)) 
                         VGA_COLOR = COLOR_TIRE_B;
            end
            DOWN: begin
                if ((x == Xc_B) && (y == Yc_B + 1 || y == Yc_B + 2)) VGA_COLOR = COLOR_GUN_B;
                else if ((x == Xc_B - 1 && y >= Yc_B - 2 && y <= Yc_B) || 
                         (x == Xc_B && y >= Yc_B - 2 && y <= Yc_B - 1) || 
                         (x == Xc_B + 1 && y >= Yc_B - 2 && y <= Yc_B)) 
                         VGA_COLOR = COLOR_BODY_B;
                else if ((x == Xc_B - 2 && y >= Yc_B - 2 && y <= Yc_B + 1) || 
                         (x == Xc_B + 2 && y >= Yc_B - 2 && y <= Yc_B + 1)) 
                         VGA_COLOR = COLOR_TIRE_B;
            end
            LEFT: begin
                if (y == Yc_B && (x == Xc_B - 1 || x == Xc_B - 2)) VGA_COLOR = COLOR_GUN_B;
                else if ((y == Yc_B - 1 && x >= Xc_B && x <= Xc_B + 2) || 
                         (y == Yc_B && x >= Xc_B + 1 && x <= Xc_B + 2) || 
                         (y == Yc_B + 1 && x >= Xc_B && x <= Xc_B + 2)) 
                         VGA_COLOR = COLOR_BODY_B;
                else if ((y == Yc_B - 2 && x >= Xc_B - 1 && x <= Xc_B + 2) || 
                         (y == Yc_B + 2 && x >= Xc_B - 1 && x <= Xc_B + 2)) 
                         VGA_COLOR = COLOR_TIRE_B;
            end
            RIGHT: begin
                if ((y == Yc_B) && (x == Xc_B + 1 || x == Xc_B + 2)) VGA_COLOR = COLOR_GUN_B;
                else if ((y == Yc_B - 1 && x >= Xc_B - 2 && x <= Xc_B) || 
                         (y == Yc_B && x >= Xc_B - 2 && x <= Xc_B - 1) || 
                         (y == Yc_B + 1 && x >= Xc_B - 2 && x <= Xc_B)) 
                         VGA_COLOR = COLOR_BODY_B;
                else if ((y == Yc_B - 2 && x >= Xc_B - 2 && x <= Xc_B + 1) || 
                         (y == Yc_B + 2 && x >= Xc_B - 2 && x <= Xc_B + 1)) 
                         VGA_COLOR = COLOR_TIRE_B;
            end
        endcase
    end
  end


   // assign the x and y value to VGA
   wire [7:0] VGA_X = x;
   wire [6:0] VGA_Y = y;

   // Connect to VGA controller
   vga_adapter VGA (
        .resetn(resetn),
        .clock(CLOCK_50),
        .colour(VGA_COLOR),
        .x(VGA_X),
        .y(VGA_Y),
        .plot(plot),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );

   // VGA parameter settings
   defparam VGA.RESOLUTION = "160x120";
   defparam VGA.MONOCHROME = "FALSE";
   defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
   //defparam VGA.BACKGROUND_IMAGE = "black.mif"; 
endmodule


// Milestone1: a single layer wall from (20,10) to (30,10)
module check_blocked_direcrtiom (Xc, Yc, dash_status, block_status);

	input [7:0] Xc;
	input [7:0] Yc;
	input [3:0] dash_status;
	output reg [3:0] block_status;
	
	// Size: 160x120
	parameter XMIN = 8'd1, XMAX = 8'd159;
	parameter YMIN = 7'd1, YMAX = 7'd119;
	
	parameter IDLE = 4'b0000, UP = 4'b0001, DOWN = 4'b0010, LEFT = 4'b0100, RIGHT = 4'b1000;

	always @(*) begin
	case (dash_status)
		IDLE: block_status = IDLE;
		DOWN:
			if ((Yc + 3) >= YMAX) begin
				block_status = DOWN;
			end else if ((Yc + 3) == 10 && Xc >= 18 && Xc <= 32) begin
				block_status = DOWN;
			end else begin
				block_status = IDLE;
			end
		UP: 
			if (Yc <= YMIN + 3) begin	// UP bound of screen
				block_status = UP;
			end else if ((Yc == 10 + 3) && Xc >= 18 && Xc <= 32) begin	// UP touch the wall
				block_status = UP;
			end else begin
				block_status = IDLE;
			end
		LEFT:
			if	(Xc <= XMIN + 3) begin 
				block_status = LEFT;
			end else if ((Xc == 30 + 3) && Yc >= 8 && Yc <= 12) begin 
				block_status = LEFT;
			end else begin
				block_status = IDLE;
			end
		RIGHT:
			if	((Xc + 3) >= XMAX) begin 
				block_status = RIGHT;
			end else if ((Xc + 3 == 20) && Yc >= 8 && Yc <= 12) begin 
				block_status = RIGHT;
			end else begin
				block_status = IDLE;
			end
			
			default: block_status = IDLE;
	endcase
	end
endmodule


// slow counter for moving tank: 25 pixels per second
module tank_counter(
    input CLOCK_50,
    output reg clk,
    input resetn
);
    reg [20:0] slow_count;
	
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin 
            slow_count <= 21'b0;
            clk <= 0;
        end else begin
            if (slow_count == 1000000) begin
                clk <= ~clk;
                slow_count <= 21'b0;
            end else begin
                slow_count <= slow_count + 1;
            end
        end
    end
endmodule


module fsm_A (tank_clk, y_Q_A, resetn, init, is_killed_A, dash_status_A, Y_D_A);

	parameter NONE = 4'b0000, HEAD_UP = 4'b0001, HEAD_DOWN = 4'b0010, HEAD_LEFT = 4'b0100, HEAD_RIGHT = 4'b1000;
	
	input tank_clk;
	input resetn, init, is_killed_A;
	input [3:0] dash_status_A;
	input [3:0] y_Q_A;
	output reg [3:0] Y_D_A;
	
	always @(posedge tank_clk) begin
	if (!resetn) begin
		Y_D_A = NONE;
	end else begin
		case (y_Q_A) 
			NONE:
				if (init) Y_D_A = HEAD_DOWN;
			HEAD_UP: 
				if (is_killed_A) Y_D_A = NONE;
				else if (dash_status_A == HEAD_DOWN) Y_D_A = HEAD_DOWN;
				else if (dash_status_A == HEAD_LEFT) Y_D_A = HEAD_LEFT;
				else if (dash_status_A == HEAD_RIGHT) Y_D_A = HEAD_RIGHT;
				else Y_D_A = HEAD_UP;
			HEAD_DOWN:
				if (is_killed_A) Y_D_A = NONE;
				else if (dash_status_A == HEAD_UP) Y_D_A = HEAD_UP;
				else if (dash_status_A == HEAD_LEFT) Y_D_A = HEAD_LEFT;
				else if (dash_status_A == HEAD_RIGHT) Y_D_A = HEAD_RIGHT;
				else Y_D_A = HEAD_DOWN;
			HEAD_LEFT:
				if (is_killed_A) Y_D_A = NONE;
				else if (dash_status_A == HEAD_UP) Y_D_A = HEAD_UP;
				else if (dash_status_A == HEAD_DOWN) Y_D_A = HEAD_DOWN;
				else if (dash_status_A == HEAD_RIGHT) Y_D_A = HEAD_RIGHT;
				else Y_D_A = HEAD_LEFT;
			HEAD_RIGHT:
				if (is_killed_A) Y_D_A = NONE;
				else if (dash_status_A == HEAD_UP) Y_D_A = HEAD_UP;
				else if (dash_status_A == HEAD_DOWN) Y_D_A = HEAD_DOWN;
				else if (dash_status_A == HEAD_LEFT) Y_D_A = HEAD_LEFT;
				else Y_D_A = HEAD_RIGHT;
				
			default: Y_D_A = NONE;
		endcase
	end
	end
endmodule


module fsm_B (tank_clk, y_Q_B, resetn, init, is_killed_B, dash_status_B, Y_D_B);

	parameter NONE = 4'b0000, HEAD_UP = 4'b0001, HEAD_DOWN = 4'b0010, HEAD_LEFT = 4'b0100, HEAD_RIGHT = 4'b1000;
	
	input tank_clk;
	input resetn, init, is_killed_B;
	input [3:0] dash_status_B;
	input [3:0] y_Q_B;
	output reg [3:0] Y_D_B;
	
	always @(posedge tank_clk) begin
	if (!resetn) begin
		Y_D_B = NONE;
	end else begin
		case (y_Q_B) 
			NONE:
				if (init) Y_D_B = HEAD_UP;
			HEAD_UP: 
				if (is_killed_B) Y_D_B = NONE;
				else if (dash_status_B == HEAD_DOWN) Y_D_B = HEAD_DOWN;
				else if (dash_status_B == HEAD_LEFT) Y_D_B = HEAD_LEFT;
				else if (dash_status_B == HEAD_RIGHT) Y_D_B = HEAD_RIGHT;
				else Y_D_B = HEAD_UP;
			HEAD_DOWN:
				if (is_killed_B) Y_D_B = NONE;
				else if (dash_status_B == HEAD_UP) Y_D_B = HEAD_UP;
				else if (dash_status_B == HEAD_LEFT) Y_D_B = HEAD_LEFT;
				else if (dash_status_B == HEAD_RIGHT) Y_D_B = HEAD_RIGHT;
				else Y_D_B = HEAD_DOWN;
			HEAD_LEFT:
				if (is_killed_B) Y_D_B = NONE;
				else if (dash_status_B == HEAD_UP) Y_D_B = HEAD_UP;
				else if (dash_status_B == HEAD_DOWN) Y_D_B = HEAD_DOWN;
				else if (dash_status_B == HEAD_RIGHT) Y_D_B = HEAD_RIGHT;
				else Y_D_B = HEAD_LEFT;
			HEAD_RIGHT:
				if (is_killed_B) Y_D_B = NONE;
				else if (dash_status_B == HEAD_UP) Y_D_B = HEAD_UP;
				else if (dash_status_B == HEAD_DOWN) Y_D_B = HEAD_DOWN;
				else if (dash_status_B == HEAD_LEFT) Y_D_B = HEAD_LEFT;
				else Y_D_B = HEAD_RIGHT;
				
			default: Y_D_B = NONE;
		endcase
	end
	end
endmodule


/*
module lab6(
    input CLOCK_50,
    input [3:0] KEY,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output VGA_CLK
);
    // 定义两个点的坐标和颜色
    parameter Xc_A = 8'd6;           // 点A的X坐标
    reg [6:0] Yc_A;                   // 将Yc_A定义为reg，允许动态修改
    parameter Xc_B = 8'd79, Yc_B = 7'd59; // 点B的坐标
    parameter COLOR_A = 9'b000_000_111;           // 点A的颜色（蓝色）
    parameter COLOR_B = 9'b111_000_000;           // 点B的颜色（红色）

    // VGA 坐标信号和颜色信号
    reg [7:0] x;
    reg [6:0] y;
	 
    reg [8:0] VGA_COLOR;
    wire plot;
    wire resetn;
    wire up_test;
    wire tank_clk;

    // 设置复位信号
    assign resetn = KEY[0];
    
    // 激活绘制信号
    assign plot = 1'b1;

    // 定义up_test为wire
    assign up_test = ~KEY[3];

    // 控制点A移动时钟，25像素/秒
    tank_counter tank_counter1(CLOCK_50, tank_clk, resetn);

    // 移动逻辑，使用 tank_clk 控制移动
    always @(posedge tank_clk or negedge resetn) begin
        if (!resetn) begin
            Yc_A <= 7'd59; // 重置Yc_A位置
        end else if (up_test && Yc_A < 7'd119) begin
            Yc_A <= Yc_A + 1; // 点A向上移动
        end
    end

	 
    // 扫描显示像素的逻辑
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            x <= 0;
            y <= 0;
        end else begin 
            if (x == 8'd159) begin
                x <= 0;
                if (y == 7'd119)
                    y <= 0;
                else
                    y <= y + 1;
            end else begin
                x <= x + 1;
            end

            // 判断是否为点A或点B的位置，设置相应颜色
            if ((x == Xc_A && y == Yc_A)) begin
                VGA_COLOR <= COLOR_A; // 蓝色
            end else if ((x == Xc_B && y == Yc_B)) begin
                VGA_COLOR <= COLOR_B; // 红色
            end else begin
                VGA_COLOR <= 3'b000; // 背景色（黑色）
            end
        end
    end
	 

    // 将 x 和 y 赋值给 VGA 控制器
    wire [7:0] VGA_X = x;
    wire [6:0] VGA_Y = y;

    // 连接到VGA控制器
    vga_adapter VGA (
        .resetn(resetn),
        .clock(CLOCK_50),
        .colour(VGA_COLOR),
        .x(VGA_X),
        .y(VGA_Y),
        .plot(plot),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );

    // VGA 参数设置
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
    defparam VGA.BACKGROUND_IMAGE = "black.mif"; 
endmodule



// slow counter for moving tank: 25 pixels per second
module tank_counter(
    input CLOCK_50,
    output reg clk,
    input resetn
);
    reg [20:0] slow_count;
	
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin // 复位
            slow_count <= 21'b0;
            clk <= 0;
        end else begin
            if (slow_count == 1000000) begin
                clk <= ~clk;
                slow_count <= 21'b0;
            end else begin
                slow_count <= slow_count + 1;
            end
        end
    end
endmodule
*/