`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:12 12/12/2016 
// Design Name: 
// Module Name:    Controller 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Controller(
    input wire clk, clr,
	// Keyboard Signal
	input wire ps2c, ps2d,
	output reg  [ 3:0] status,
	// VGA signal
	output wire hsync, vsync,
	output wire [ 9:0] pixel_x, pixel_y,
	output reg btn_visible, explode_visible,
	output reg signed [31:0] scroll,
	output wire video_on,
	output wire btn_pos, mycar_pos, explode_pos, game_over_pos, score_pos,
	output wire obstacle_pos0, obstacle_pos1, obstacle_pos2, obstacle_pos3, obstacle_pos4,
	output wire digit_pos0, digit_pos1, digit_pos2, digit_pos3,
	output wire iscollide0, iscollide1, iscollide2, iscollide3, iscollide4,
	output wire [16:0] back_addr, side_addr,
	output wire [15:0] explode_addr,
	output wire [14:0] game_over_addr,
	output wire [13:0] btn_addr, score_addr,
	output wire [13:0] digit_addr0, digit_addr1, digit_addr2, digit_addr3,
	output wire [12:0] mycar_addr,
	output wire [12:0] obstacle_addr0, obstacle_addr1, obstacle_addr2, obstacle_addr3, obstacle_addr4,
	output wire [3: 0] high_score0, high_score1, high_score2, high_score3
	);

	// Game status signal declaration
	localparam [3:0]
		prepare   = 4'b1000,
		activate  = 4'b0100,
		pause     = 4'b0010,
		terminate = 4'b0001;
	
	reg [9:0] mycar_pos_x, mycar_pos_y, explode_pos_x, explode_pos_y;
	reg [9:0] obstacle_pos_x [0:4], obstacle_pos_y [0:4];
	reg [4:0] num;
	reg [31:0] cnt;
	reg [24:0] car_on_road;
	//=========================================================================
	// Reg content: x x x x x _ x x x x x _ x x x x x _ x x x x x _ x x x x x
	// Road number:     0     |     1     |     2     |     3     |     4
	// Car number : 4 3 2 1 0 | 4 3 2 1 0 | 4 3 2 1 0 | 4 3 2 1 0 | 4 3 2 1 0
	//=========================================================================
	
	initial
	begin
		status            <= prepare;
		btn_visible       <= 1'b0;
		explode_visible   <= 1'b0;
		scroll		      <= 32'b0;
		mycar_pos_x       <= 289;
		mycar_pos_y       <= 384;
		num               <= 1'b0;
		obstacle_pos_x[0] = 101;
		obstacle_pos_y[0] = 100;
		obstacle_pos_x[1] = 485;
		obstacle_pos_y[1] = 100;
		obstacle_pos_x[2] = 197;
		obstacle_pos_y[2] = 100;
		obstacle_pos_x[3] = 293;
		obstacle_pos_y[3] = 100;
		obstacle_pos_x[4] = 389;
		obstacle_pos_y[4] = 100;
		car_on_road       = 25'b00001_00100_01000_10000_00010;
		cnt               <= 32'b0;
	end
	
	//============================================================================
	// vga_test module
	//============================================================================
	// vga_test debug_unit ( .clk(clk), .clr(clr), .hsync(hsync), .vsync(vsync), .red(red), .green(green), .blue(blue) );
	
	//============================================================================
	// Instantiation
	//============================================================================
	// Instantiate vga_sync circuit
	wire clk25m, clk6400, clk200, clk100, clk50;

	clkdiv div_unit (.clk(clk), .clr(clr), .clk25m(clk25m), .clk800(clk800), .clk200(clk200), .clk100(clk100), .clk50(clk50));
	vga_sync sync_unit (
	 	.clk(clk25m), .clr(clr), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y)
	);
	// Instantiate keyboard circuit
	wire [15:0] xkey;
	ps2_receiver keyboard (.clk(clk25m), .clr(clr), .ps2c(ps2c), .ps2d(ps2d), .xkey(xkey));
	
	//===========================================================================
	// Keyboard
	//===========================================================================
	// Output the signals we need according to the shift register
	reg [3:0] direction;
	
	always @ (posedge clk25m or posedge clr)
	begin
		if (clr)
		begin
			status      <= prepare;
			direction   <= 4'b0;
			btn_visible <= 1'b0;
		end
		else
		begin
			// prepare -> activate
			if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h29)
				btn_visible <= 1'b1;
			else if (xkey[15: 8] == 8'hF0 && xkey[ 7: 0] == 8'h29)
				status <= activate;									
			// activate -> pause
			if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h76 && status == activate)
				status <= pause;									
			// pause -> activate
			if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h29 && status == pause)
				status <= activate;									
			// activate -> terminate
			if (iscollide0 || iscollide1)
				status <= terminate;
			
			if (status == activate)
			begin
				if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h1d)
					direction <= 4'b1000;								// Up
				else if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h1b)
					direction <= 4'b0100;								// Down
				else if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h1c)
					direction <= 4'b0010;								// Left
				else if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h23)
					direction <= 4'b0001;								// Right
				else if (xkey[15: 8] == 8'hF0)
					direction <= 4'b0000;
			end
		end
	end
	
	//============================================================================
	// Object's properity
	//============================================================================
	wire [9:0] back_x, back_y, btn_x, btn_y, side_x, side_y, mycar_x, mycar_y, game_over_x, game_over_y, score_x, score_y;
	wire [9:0] explode_x, explode_y;
	wire [9:0] obstacle_x [0:4], obstacle_y [0:4];
	wire [9:0] digit_x [0:3], digit_y [0:3];
	wire [10:0] back_xrom, back_yrom, btn_xrom, btn_yrom, side_xrom, side_yrom;

	// Background's properties
	assign back_x    = pixel_x;
	assign back_y    = pixel_y;
	assign back_xrom = {1'b0, back_x[9:1]};
	assign back_yrom = {1'b0, back_y[9:1]};
	assign back_addr = back_yrom * 320 + back_xrom;
	// Start Button's properties
	assign btn_x     = pixel_x - 252;
	assign btn_y     = pixel_y - 379;
	assign btn_xrom  = {1'b0, btn_x[9:1]};
	assign btn_yrom  = {1'b0, btn_y[9:1]};
	assign btn_pos   = (pixel_x >= 252) && (pixel_x < 640) && (pixel_y >= 379) && (pixel_y < 480);
	assign btn_addr  = btn_yrom  * 200 + btn_xrom;
	// Side's properties
	assign side_x    = pixel_x;
	assign side_y    = pixel_y;
	assign side_xrom = {1'b0, side_x[9:1]};
	assign side_yrom = {1'b0, side_y[9:1]};
	assign side_addr = side_yrom * 320 + side_xrom;
	// My car's properties
	parameter car_width         = 60;
	parameter car_height        = 100;
	parameter car_offset_left   = 15;
	parameter car_offset_right  = 5;
	assign mycar_x              = pixel_x - mycar_pos_x;
	assign mycar_y              = pixel_y - mycar_pos_y;
	assign mycar_pos            = 	(pixel_x >= mycar_pos_x + car_offset_left) && 
									(pixel_x < mycar_pos_x + car_width - car_offset_right) && 
									(pixel_y >= mycar_pos_y) && 
									(pixel_y < mycar_pos_y + car_height);
	assign mycar_addr           = mycar_y * 60 + mycar_x;
	// Obstacles' properties
	parameter police_width        = 64;
	parameter police_height       = 100;
	parameter police_offset_left  = 5;
	parameter police_offset_right = 5;
	assign obstacle_x[0]          = pixel_x - obstacle_pos_x[0];
	assign obstacle_y[0]          = pixel_y - obstacle_pos_y[0] + police_height;
	assign obstacle_pos0          = (pixel_x >= obstacle_pos_x[0] + police_offset_left) &&
									(pixel_x < obstacle_pos_x[0] + police_width - police_offset_right) &&
									(pixel_y >= {obstacle_pos_y[0] > police_height ? obstacle_pos_y[0] - police_height : 0}) &&
									(pixel_y < obstacle_pos_y[0]);
	assign obstacle_addr0   = obstacle_y[0] * 64 + obstacle_x[0];
	
	assign obstacle_x[1]          = pixel_x - obstacle_pos_x[1];
	assign obstacle_y[1]          = pixel_y - obstacle_pos_y[1] + police_height;
	assign obstacle_pos1          = (pixel_x >= obstacle_pos_x[1] + police_offset_left) &&
									(pixel_x < obstacle_pos_x[1] + police_width - police_offset_right) &&
									(pixel_y >= {obstacle_pos_y[1] > police_height ? obstacle_pos_y[1] - police_height : 0}) &&
									(pixel_y < obstacle_pos_y[1]);
	assign obstacle_addr1   = obstacle_y[1] * 64 + obstacle_x[1];
	
	assign obstacle_x[2]          = pixel_x - obstacle_pos_x[2];
	assign obstacle_y[2]          = pixel_y - obstacle_pos_y[2] + car_height;
	assign obstacle_pos2          = (pixel_x >= obstacle_pos_x[2] + car_offset_left) &&
									(pixel_x < obstacle_pos_x[2] + car_width - car_offset_right) &&
									(pixel_y >= {obstacle_pos_y[2] > car_height ? obstacle_pos_y[2] - car_height : 0}) &&
									(pixel_y < obstacle_pos_y[2]);
	assign obstacle_addr2   = obstacle_y[2] * 60 + obstacle_x[2];
	
	assign obstacle_x[3]          = pixel_x - obstacle_pos_x[3];
	assign obstacle_y[3]          = pixel_y - obstacle_pos_y[3] + car_height;
	assign obstacle_pos3          = (pixel_x >= obstacle_pos_x[3] + car_offset_left) &&
									(pixel_x < obstacle_pos_x[3] + car_width - car_offset_right) &&
									(pixel_y >= {obstacle_pos_y[3] > car_height ? obstacle_pos_y[3] - car_height : 0}) &&
									(pixel_y < obstacle_pos_y[3]);
	assign obstacle_addr3   = obstacle_y[3] * 60 + obstacle_x[3];
	
	assign obstacle_x[4]          = pixel_x - obstacle_pos_x[4];
	assign obstacle_y[4]          = pixel_y - obstacle_pos_y[4] + car_height;
	assign obstacle_pos4          = (pixel_x >= obstacle_pos_x[4] + car_offset_left) &&
									(pixel_x < obstacle_pos_x[4] + car_width - car_offset_right) &&
									(pixel_y >= {obstacle_pos_y[4] > car_height ? obstacle_pos_y[4] - car_height : 0}) &&
									(pixel_y < obstacle_pos_y[4]);
	assign obstacle_addr4   = obstacle_y[4] * 60 + obstacle_x[4];
	// Explosion's properties
	parameter explode_width  = 60;
	parameter explode_height = 60;
	assign explode_x         = pixel_x - explode_pos_x;
	assign explode_y         = pixel_y - explode_pos_y + explode_height * num;
	assign explode_pos 		 = 	(pixel_x >= explode_pos_x) && (pixel_x < explode_pos_x + explode_width) && 
								(pixel_y >= explode_pos_y) && (pixel_y < explode_pos_y + explode_height);
	assign explode_addr      = explode_y * 60 + explode_x;
	// Game-Over prompt's properties
	assign game_over_x    = pixel_x - 160;
	assign game_over_y    = pixel_y - 120;
	assign game_over_pos  = (pixel_x >= 160) && (pixel_x < 480) && (pixel_y >= 120) && (pixel_y < 180);
	assign game_over_addr = game_over_y * 320 + game_over_x;
	// Score's properties
	assign score_x    = pixel_x - 120;
	assign score_y    = pixel_y - 240;
	assign score_pos  = (pixel_x >= 120) && (pixel_x < 320) && (pixel_y >= 240) && (pixel_y < 300);
	assign score_addr = score_y * 200 + score_x;
	// Digit's properties
	wire [3:0] score [0:3];
	parameter digit_width  = 32;
	parameter digit_height = 32;
	assign digit_x[0]  = pixel_x - (330 + digit_width * 3);
	assign digit_y[0]  = pixel_y - 260 + digit_height * score[0];
	assign digit_pos0  = (pixel_x >= 330 + digit_width * 3) && (pixel_x < 330 + digit_width * 4) && (pixel_y >= 260) && (pixel_y < 260 + digit_height);
	assign digit_addr0 = digit_y[0] * 32 + digit_x[0];
	
	assign digit_x[1]  = pixel_x - (330 + digit_width * 2);
	assign digit_y[1]  = pixel_y - 260 + digit_height * score[1];
	assign digit_pos1  = (pixel_x >= 330 + digit_width * 2) && (pixel_x < 330 + digit_width * 3) && (pixel_y >= 260) && (pixel_y < 260 + digit_height);
	assign digit_addr1 = digit_y[1] * 32 + digit_x[1];

	assign digit_x[2]  = pixel_x - (330 + digit_width);
	assign digit_y[2]  = pixel_y - 260 + digit_height * score[2];
	assign digit_pos2  = (pixel_x >= 330 + digit_width) && (pixel_x < 330 + digit_width * 2) && (pixel_y >= 260) && (pixel_y < 260 + digit_height);
	assign digit_addr2 = digit_y[2] * 32 + digit_x[2];
	
	assign digit_x[3]  = pixel_x - 330;
	assign digit_y[3]  = pixel_y - 260 + digit_height * score[3];
	assign digit_pos3  = (pixel_x >= 330) && (pixel_x < 330 + digit_width) && (pixel_y >= 260) && (pixel_y < 260 + digit_height);
	assign digit_addr3 = digit_y[3] * 32 + digit_x[3];
	//=============================================================================
	//Collision detector
	//=============================================================================
	Detector collision_detector (.mycar_pos_x(mycar_pos_x), .mycar_pos_y(mycar_pos_y), 
								.obstacle_pos_x0(obstacle_pos_x[0]), 
								.obstacle_pos_x1(obstacle_pos_x[1]), 
								.obstacle_pos_x2(obstacle_pos_x[2]), 
								.obstacle_pos_x3(obstacle_pos_x[3]), 
								.obstacle_pos_x4(obstacle_pos_x[4]), 
								.obstacle_pos_y0(obstacle_pos_y[0]), 
								.obstacle_pos_y1(obstacle_pos_y[1]), 
								.obstacle_pos_y2(obstacle_pos_y[2]), 
								.obstacle_pos_y3(obstacle_pos_y[3]), 
								.obstacle_pos_y4(obstacle_pos_y[4]), 
								.iscollide0(iscollide0), 
								.iscollide1(iscollide1), 
								.iscollide2(iscollide2), 
								.iscollide3(iscollide3), 
								.iscollide4(iscollide4)
								);
	
	//=============================================================================
	// Procedure to deal with the random generation and collision
	//=============================================================================
	parameter lane_x = 96;
	
	always @ (posedge clk100 or posedge clr)
	begin
		if (clr)
		begin
			obstacle_pos_x[0] = 101;
			obstacle_pos_y[0] = 100;
			obstacle_pos_x[1] = 485;
			obstacle_pos_y[1] = 100;
			obstacle_pos_x[2] = 197;
			obstacle_pos_y[2] = 100;
			obstacle_pos_x[3] = 293;
			obstacle_pos_y[3] = 100;
			obstacle_pos_x[4] = 389;
			obstacle_pos_y[4] = 100;
			car_on_road       = 25'b00001_00100_01000_10000_00010;
			cnt               <= 32'b0;	
			explode_visible   <= 1'b0;
		end
		else
		begin
			if (status == activate)
			begin
				//=============================================================================
				// Random generator
				//=============================================================================			
				if (direction != 4'b0)
					cnt <= cnt + 1023;
				else
					cnt <= cnt + 1;
			
				if (iscollide0 || obstacle_pos_y[0] > 480 + police_height)
				begin
					// Clear the flag signal
					if (car_on_road[ 0] == 1'b1) 
						car_on_road[ 0] = 1'b0;
					if (car_on_road[ 5] == 1'b1) 
						car_on_road[ 5] = 1'b0;
					if (car_on_road[10] == 1'b1) 
						car_on_road[10] = 1'b0;
					if (car_on_road[15] == 1'b1) 
						car_on_road[15] = 1'b0;
					if (car_on_road[20] == 1'b1) 
						car_on_road[20] = 1'b0;
			
					// Set explosion position signal
					if (iscollide0)
					begin
						explode_pos_x   <= mycar_pos_x + (car_width - explode_width) / 2;
						explode_pos_y   <= mycar_pos_y + (car_height - explode_height) / 2;
						explode_visible <= 1'b1;
					end
				
					// Recreate the next position and flag signal
					if 	(cnt % 5 == 0 && 
						(car_on_road[ 4: 0] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
						 car_on_road[ 4: 0] == 5'b00000))
					begin
						obstacle_pos_x[0] = 79 + (lane_x - police_width) / 2;
						obstacle_pos_y[0] = 0;
						car_on_road[ 0]   = 1'b1;
					end
					else if (cnt % 5 == 1 && 
							(car_on_road[ 9: 5] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
							 car_on_road[ 9: 5] == 5'b00000))
					begin
						obstacle_pos_x[0] = 79 + (lane_x * 3 - police_width) / 2;
						obstacle_pos_y[0] = 0;
						car_on_road[ 5]   = 1'b1;
					end
					else if (cnt % 5 == 2 && 
							(car_on_road[14:10] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
							 car_on_road[14:10] == 5'b00000))
					begin 
						obstacle_pos_x[0] = 79 + (lane_x * 5 - police_width) / 2; 
						obstacle_pos_y[0] = 0;
						car_on_road[10]   = 1'b1;
					end
					else if (cnt % 5 == 3 && 
							(car_on_road[19:15] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
							 car_on_road[19:15] == 5'b00000))
					begin 
						obstacle_pos_x[0] = 79 + (lane_x * 7 - police_width) / 2; 
						obstacle_pos_y[0] = 0;
						car_on_road[15]   = 1'b1;
					end
					else if (car_on_road[24:20] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
							 car_on_road[24:20] == 5'b00000)
					begin 
						obstacle_pos_x[0] = 79 + (lane_x * 9 - police_width) / 2; 
						obstacle_pos_y[0] = 0;
						car_on_road[20]   = 1'b1;
					end
				end

				if (iscollide1 || obstacle_pos_y[1] > 480 + police_height)
				begin
					// Clear the flag signal
					if (car_on_road[ 1] == 1'b1) 
						car_on_road[ 1] = 1'b0;
					if (car_on_road[ 6] == 1'b1) 
						car_on_road[ 6] = 1'b0;
					if (car_on_road[11] == 1'b1) 
						car_on_road[11] = 1'b0;
					if (car_on_road[16] == 1'b1) 
						car_on_road[16] = 1'b0;
					if (car_on_road[21] == 1'b1) 
						car_on_road[21] = 1'b0;

					// Set explosion position signal
					if (iscollide1)
					begin
						explode_pos_x   <= mycar_pos_x + (car_width - explode_width) / 2;
						explode_pos_y   <= mycar_pos_y + (car_height - explode_height) / 2;
						explode_visible <= 1'b1;
					end
					
					// Recreate the next position and flag signal
					if 	(cnt % 5 == 0 && 
						(car_on_road[ 4: 0] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
						 car_on_road[ 4: 0] == 5'b00000))
					begin 
						obstacle_pos_x[1] = 79 + (lane_x - police_width) / 2;
						obstacle_pos_y[1] = 0;
						car_on_road[ 1]   = 1'b1;
					end
					else if (cnt % 5 == 1 && 
							(car_on_road[ 9 :5] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
							 car_on_road[ 9: 5] == 5'b00000))
					begin
						obstacle_pos_x[1] = 79 + (lane_x * 3 - police_width) / 2;
						obstacle_pos_y[1] = 0;
						car_on_road[ 6]   = 1'b1;
					end
					else if (cnt % 5 == 2 && 
							(car_on_road[14:10] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
							 car_on_road[14:10] == 5'b00000))
					begin 
						obstacle_pos_x[1] = 79 + (lane_x * 5 - police_width) / 2; 
						obstacle_pos_y[1] = 0;
						car_on_road[11]   = 1'b1;
					end
					else if (cnt % 5 == 3 && 
							(car_on_road[19:15] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
							 car_on_road[19:15] == 5'b00000))
					begin 
						obstacle_pos_x[1] = 79 + (lane_x * 7 - police_width) / 2; 
						obstacle_pos_y[1] = 0;
						car_on_road[16]   = 1'b1;
					end
					else if (car_on_road[24:20] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
							 car_on_road[24:20] == 5'b00000)
					begin 
						obstacle_pos_x[1] = 79 + (lane_x * 9 - police_width) / 2; 
						obstacle_pos_y[1] = 0;
						car_on_road[21]   = 1'b1;
					end
				end
				
				if (iscollide2 || obstacle_pos_y[2] > 480 + car_height)
				begin
					// Clear the flag signal
					if (car_on_road[ 2] == 1'b1) 
						car_on_road[ 2] = 1'b0;
					if (car_on_road[ 7] == 1'b1) 
						car_on_road[ 7] = 1'b0;
					if (car_on_road[12] == 1'b1) 
						car_on_road[12] = 1'b0;
					if (car_on_road[17] == 1'b1) 
						car_on_road[17] = 1'b0;
					if (car_on_road[22] == 1'b1) 
						car_on_road[22] = 1'b0;
			
					// Set explosion position signal
					if (iscollide2)
					begin
						explode_pos_x   <= obstacle_pos_x[2] + (car_width - explode_width) / 2;
						explode_pos_y   <= obstacle_pos_y[2] + (car_height - explode_height) / 2;
						explode_visible <= 1'b1;
					end

					// Recreate the next position and flag signal
					if 	(cnt % 5 == 0 && 
						(car_on_road[ 4: 0] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[ 4: 0] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[ 4: 0] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height || 					 
						 car_on_road[ 4: 0] == 5'b00000))
					begin 
						obstacle_pos_x[2] = 79 + (lane_x - car_width) / 2;
						obstacle_pos_y[2] = 0;
						car_on_road[ 2]   = 1'b1;
					end
					else if (cnt % 5 == 1 && 
							(car_on_road[ 9: 5] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[ 9: 5] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[ 9: 5] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||						 
							 car_on_road[ 9: 5] == 5'b00000))
					begin 
						obstacle_pos_x[2] = 79 + (lane_x * 3 - car_width) / 2;
						obstacle_pos_y[2] = 0;
						car_on_road[ 7]   = 1'b1;
					end
					else if (cnt % 5 == 2 && 
							(car_on_road[14:10] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[14:10] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[14:10] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||						 
							 car_on_road[14:10] == 5'b00000))
					begin
						obstacle_pos_x[2] = 79 + (lane_x * 5 - car_width) / 2; 
						obstacle_pos_y[2] = 0;
						car_on_road[12]   = 1'b1;
					end
					else if (cnt % 5 == 3 && 
							(car_on_road[19:15] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[19:15] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[19:15] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||						 
							 car_on_road[19:15] == 5'b00000))
					begin 
						obstacle_pos_x[2] = 79 + (lane_x * 7 - car_width) / 2; 
						obstacle_pos_y[2] = 0;
						car_on_road[17]   = 1'b1;
					end
					else if (car_on_road[24:20] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[24:20] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[24:20] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height || 						 
							 car_on_road[24:20] == 5'b00000)
					begin 
						obstacle_pos_x[2] = 79 + (lane_x * 9 - car_width) / 2; 
						obstacle_pos_y[2] = 0;
						car_on_road[22]   = 1'b1;
					end
				end
				
				if (iscollide3 || obstacle_pos_y[3] > 480 + car_height)
				begin
					// Clear the flag signal
					if (car_on_road[ 3] == 1'b1) 
						car_on_road[ 3] = 1'b0;
					if (car_on_road[ 8] == 1'b1) 
						car_on_road[ 8] = 1'b0;
					if (car_on_road[13] == 1'b1) 
						car_on_road[13] = 1'b0;
					if (car_on_road[18] == 1'b1) 
						car_on_road[18] = 1'b0;
					if (car_on_road[23] == 1'b1) 
						car_on_road[23] = 1'b0;

					// Set explosion position signal
					if (iscollide3)
					begin
						explode_pos_x   <= obstacle_pos_x[3] + (car_width - explode_width) / 2;
						explode_pos_y   <= obstacle_pos_y[3] + (car_height - explode_height) / 2;
						explode_visible <= 1'b1;
					end
					
					// Recreate the next position and flag signal
					if 	(cnt % 5 == 0 && 
						(car_on_road[ 4: 0] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[ 4: 0] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[ 4: 0] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height || 					 
						 car_on_road[ 4: 0] == 5'b00000))
					begin 
						obstacle_pos_x[3] = 79 + (lane_x - car_width) / 2;
						obstacle_pos_y[3] = 0;
						car_on_road[ 3]   = 1'b1;
					end
					else if (cnt % 5 == 1 && 
							(car_on_road[ 9: 5] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[ 9: 5] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[ 9: 5] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height || 						 
							 car_on_road[ 9: 5] == 5'b00000))
					begin
						obstacle_pos_x[3] = 79 + (lane_x * 3 - car_width) / 2;
						obstacle_pos_y[3] = 0;
						car_on_road[ 8]   = 1'b1;
					end
					else if (cnt % 5 == 2 && 
							(car_on_road[14:10] == 5'b00001 && obstacle_pos_y[0] > car_height + police_height || 
							 car_on_road[14:10] == 5'b00010 && obstacle_pos_y[1] > car_height + police_height || 
							 car_on_road[14:10] == 5'b00100 && obstacle_pos_y[2] > car_height + police_height || 
							 car_on_road[14:10] == 5'b00000))
					begin 
						obstacle_pos_x[3] = 79 + (lane_x * 5 - car_width) / 2; 
						obstacle_pos_y[3] = 0;
						car_on_road[13]   = 1'b1;
					end
					else if (cnt % 5 == 3 && 
							(car_on_road[19:15] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[19:15] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[19:15] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||						 
							 car_on_road[19:15] == 5'b00000))
					begin 
						obstacle_pos_x[3] = 79 + (lane_x * 7 - car_width) / 2; 
						obstacle_pos_y[3] = 0;
						car_on_road[18]   = 1'b1;
					end
					else if (car_on_road[24:20] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[24:20] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[24:20] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height || 						 
							 car_on_road[24:20] == 5'b00000)
					begin 
						obstacle_pos_x[3] = 79 + (lane_x * 9 - car_width) / 2; 
						obstacle_pos_y[3] = 0;
						car_on_road[23]   = 1'b1;
					end
				end
				
				if (iscollide4 || obstacle_pos_y[4] > 480 + car_height)
				begin
					// Clear the flag signal
					if (car_on_road[ 4] == 1'b1) 
						car_on_road[ 4] = 1'b0;
					if (car_on_road[ 9] == 1'b1) 
						car_on_road[ 9] = 1'b0;
					if (car_on_road[14] == 1'b1) 
						car_on_road[14] = 1'b0;
					if (car_on_road[19] == 1'b1) 
						car_on_road[19] = 1'b0;
					if (car_on_road[24] == 1'b1) 
						car_on_road[24] = 1'b0;
					
					// Set explosion position signal
					if (iscollide4)
					begin
						explode_pos_x   <= obstacle_pos_x[4] + (car_width - explode_width) / 2;
						explode_pos_y   <= obstacle_pos_y[4] + (car_height - explode_height) / 2;
						explode_visible <= 1'b1;
					end

					// Recreate the next position and flag signal
					if 	(cnt % 5 == 0 &&  
						(car_on_road[ 4: 0] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[ 4: 0] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[ 4: 0] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
						 car_on_road[ 4: 0] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
						 car_on_road[ 4: 0] == 5'b00000))
					begin 
						obstacle_pos_x[4] = 79 + (lane_x - car_width) / 2;
						obstacle_pos_y[4] = 0;
						car_on_road[ 4]   = 1'b1;
					end
					else if (cnt % 5 == 1 && 
							(car_on_road[ 9: 5] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[ 9: 5] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[ 9: 5] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
							 car_on_road[ 9: 5] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
							 car_on_road[ 9: 5] == 5'b00000))
					begin 
						obstacle_pos_x[4] = 79 + (lane_x * 3 - car_width) / 2;
						obstacle_pos_y[4] = 0;
						car_on_road[ 9]   = 1'b1;
					end
					else if (cnt % 5 == 2 && 
							(car_on_road[14:10] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[14:10] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[14:10] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
							 car_on_road[14:10] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
							 car_on_road[14:10] == 5'b00000))
					begin 
						obstacle_pos_x[4] = 79 + (lane_x * 5 - car_width) / 2; 
						obstacle_pos_y[4] = 0;
						car_on_road[14]   = 1'b1;
					end
					else if (cnt % 5 == 3 && 
							(car_on_road[19:15] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[19:15] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[19:15] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
							 car_on_road[19:15] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
							 car_on_road[19:15] == 5'b00000))
					begin 
						obstacle_pos_x[4] = 79 + (lane_x * 7 - car_width) / 2; 
						obstacle_pos_y[4] = 0;
						car_on_road[19]   = 1'b1;
					end
					else if (car_on_road[24:20] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
							 car_on_road[24:20] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
							 car_on_road[24:20] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
							 car_on_road[24:20] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
							 car_on_road[24:20] == 5'b00000)
					begin 
						obstacle_pos_x[4] = 79 + (lane_x * 9 - car_width) / 2; 
						obstacle_pos_y[4] = 0;
						car_on_road[24]   = 1'b1;
					end
				end
				
				// Move obstacles
				if (obstacle_pos_y[0] <= 480 + police_height)
					obstacle_pos_y[0] = obstacle_pos_y[0] + 4;
				if (obstacle_pos_y[1] <= 480 + police_height)
					obstacle_pos_y[1] = obstacle_pos_y[1] + 4;
				if (obstacle_pos_y[2] <= 480 + car_height)
					obstacle_pos_y[2] = obstacle_pos_y[2] + 3;
				if (obstacle_pos_y[3] <= 480 + car_height)
					obstacle_pos_y[3] = obstacle_pos_y[3] + 3;
				if (obstacle_pos_y[4] <= 480 + car_height)
					obstacle_pos_y[4] = obstacle_pos_y[4] + 2;
			end
			
			//========================================================================
			// The explosion animation
			//========================================================================		
			// Disapear the animation
			if (num == 0)
				explode_visible <= 1'b0;
		end
	end
	
	//=============================================================================
	// Dynamic object's position calculation
	//=============================================================================
	// Scroll the road
	always @ (posedge clk200 or posedge clr)
	begin
		if (clr)
		begin
			scroll <= 32'b0;
		end
		else
		begin
			if (status == activate)
				scroll <= scroll - 2;
		end
	end
	
	// Move the car and EDGE detection
	always @(posedge clk800 or posedge clr)
	begin
		if (clr)
		begin
			mycar_pos_x       <= 289;
			mycar_pos_y       <= 384;
		end
		else
		begin
			if (status == activate)
			begin
				if (direction == 4'b1000)
				begin
					if (mycar_pos_y >= 1)
						mycar_pos_y <= mycar_pos_y - 1 ;
				end
				else if (direction == 4'b0100)
				begin
					if (mycar_pos_y < 380)
						mycar_pos_y <= mycar_pos_y + 1;
				end
				else if (direction == 4'b0010)
				begin
					if (mycar_pos_x >= 79 - car_offset_left)
						mycar_pos_x <= mycar_pos_x - 1;
				end
				else if (direction == 4'b0001)
				begin
					if (mycar_pos_x < 500 + car_offset_right)
						mycar_pos_x <= mycar_pos_x + 1;
				end
			end
		end
	end
	
	// Explosion
	always @ (posedge clk50 or posedge clr)
	begin
		if (clr)
		begin
			num <= 4'b0;
		end
		else
		begin
			if (status == activate)
			begin
				num <= (num + 1) % 14;
				if (iscollide0 || iscollide1 || iscollide2 || iscollide3 || iscollide4)
				begin
					num <= 1;
				end
			end
		end
	end
	
	//==============================================================================
	// Score Counter
	//==============================================================================
	wire plus;
	
	Counter score_counter (
						.clk(clk), 
						.clr(clr), 
						.plus(plus), 
						.score0(score[0]), .score1(score[1]), .score2(score[2]), .score3(score[3]), 
						.high_score0(high_score0), .high_score1(high_score1), .high_score2(high_score2), .high_score3(high_score3)
						);
	
	assign plus = iscollide2 || iscollide3 || iscollide4;
	
endmodule
