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
	output wire [15:0] xkey,
	// VGA signal
	output wire hsync, vsync,
	output wire [ 9:0] pixel_x, pixel_y,
	output reg btn_visible, explode_visible,
	output reg signed [31:0] scroll,
	output wire video_on,
	output wire btn_pos, mycar_pos, explode_pos,
	output wire obstacle_pos0, obstacle_pos1, obstacle_pos2, obstacle_pos3, obstacle_pos4,
	output wire iscollide0, iscollide1, iscollide2, iscollide3, iscollide4,
	output wire [16:0] back_addr, side_addr,
	output wire [13:0] btn_addr,
	output wire [12:0] mycar_addr,
	output wire [12:0] obstacle_addr0, obstacle_addr1, obstacle_addr2, obstacle_addr3, obstacle_addr4,
	output wire [15:0] explode_addr
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
		obstacle_pos_x[0] <= 101;
		obstacle_pos_y[0] <= 100;
		obstacle_pos_x[1] <= 197;
		obstacle_pos_y[1] <= 100;
		obstacle_pos_x[2] <= 293;
		obstacle_pos_y[2] <= 100;
		obstacle_pos_x[3] <= 389;
		obstacle_pos_y[3] <= 100;
		obstacle_pos_x[4] <= 485;
		obstacle_pos_y[4] <= 100;
		car_on_road       <= 25'b10000_01000_00100_00010_00001;
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
	wire clk25m, clk1600, clk200, clk100, clk50;

	clkdiv div_unit (.clk(clk), .clr(clr), .clk25m(clk25m), .clk1600(clk1600), .clk200(clk200), .clk100(clk100), .clk50(clk50));
	vga_sync sync_unit (
	 	.clk(clk25m), .clr(clr), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y)
	);
	// Instantiate keyboard circuit
	ps2_receiver keyboard (.clk(clk25m), .clr(clr), .ps2c(ps2c), .ps2d(ps2d), .xkey(xkey));
	
	//===========================================================================
	// Keyboard
	//===========================================================================
	// Output the signals we need according to the shift register
	reg [3:0] direction;
	
	always @ (posedge clk25m)
	begin
		if (xkey[15: 8] != 8'hF0 && xkey[ 7: 0] == 8'h29)
			btn_visible <= 1'b1;
		else if (xkey[15: 8] == 8'hF0)
			status <= activate;
			
		if (xkey[15: 8] == 8'hF0 && xkey[ 7: 0] == 8'h76 && status == activate)
			status <= pause;
		if (xkey[15: 8] == 8'hF0 && xkey[ 7: 0] == 8'h76 && status == pause)
			status <= activate;
		
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
	
	//============================================================================
	// Object's properity
	//============================================================================
	wire [9:0] back_x, back_y, btn_x, btn_y, side_x, side_y, mycar_x, mycar_y;
	wire [9:0] explode_x, explode_y;
	wire [9:0] obstacle_x [0:4], obstacle_y [0:4];
	wire [10:0] back_xrom, back_yrom, btn_xrom, btn_yrom, side_xrom, side_yrom;

	// Background's properities
	assign back_x    = pixel_x;
	assign back_y    = pixel_y;
	assign back_xrom = {1'b0, back_x[9:1]};
	assign back_yrom = {1'b0, back_y[9:1]};
	assign back_addr = back_yrom * 320 + back_xrom;
	// Start Button's properities
	assign btn_x     = pixel_x - 252;
	assign btn_y     = pixel_y - 379;
	assign btn_xrom  = {1'b0, btn_x[9:1]};
	assign btn_yrom  = {1'b0, btn_y[9:1]};
	assign btn_pos   = (pixel_x >= 252) && (pixel_x < 640) && (pixel_y >= 379) && (pixel_y < 480);
	assign btn_addr  = btn_yrom  * 200 + btn_xrom;
	// Side's properities
	assign side_x    = pixel_x;
	assign side_y    = pixel_y;
	assign side_xrom = {1'b0, side_x[9:1]};
	assign side_yrom = {1'b0, side_y[9:1]};
	assign side_addr = side_yrom * 320 + side_xrom;
	// My car's properities
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
	// Obstacles' properities
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
	// Explosion's properities
	parameter explode_width  = 60;
	parameter explode_height = 60;
	assign explode_x         = pixel_x - explode_pos_x;
	assign explode_y         = pixel_y - explode_pos_y + explode_height * num;
	assign explode_pos 		 = 	(pixel_x >= explode_pos_x) && (pixel_x < explode_pos_x + explode_width) && 
								(pixel_y >= explode_pos_y) && (pixel_y < explode_pos_y + explode_height);
	assign explode_addr      = explode_y * 60 + explode_x;
	
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
	
	always @ (posedge clk200)
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
					car_on_road[ 0] <= 1'b0;
				if (car_on_road[ 5] == 1'b1) 
					car_on_road[ 5] <= 1'b0;
				if (car_on_road[10] == 1'b1) 
					car_on_road[10] <= 1'b0;
				if (car_on_road[15] == 1'b1) 
					car_on_road[15] <= 1'b0;
				if (car_on_road[20] == 1'b1) 
					car_on_road[20] <= 1'b0;
				
				// Recreate the next position and flag signal
				if 	(cnt % 5 == 0 && 
					(car_on_road[ 4: 0] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
					 car_on_road[ 4: 0] == 5'b00000))
				begin
					obstacle_pos_x[0] <= 79 + (lane_x - police_width) / 2;
					obstacle_pos_y[0] <= 0;
					car_on_road[ 0]   <= 1'b1;
				end
				else if (cnt % 5 == 1 && 
						(car_on_road[ 9: 5] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
						 car_on_road[ 9: 5] == 5'b00000))
				begin
					obstacle_pos_x[0] <= 79 + (lane_x * 3 - police_width) / 2;
					obstacle_pos_y[0] <= 0;
					car_on_road[ 5]   <= 1'b1;
				end
				else if (cnt % 5 == 2 && 
						(car_on_road[14:10] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
						 car_on_road[14:10] == 5'b00000))
				begin 
					obstacle_pos_x[0] <= 79 + (lane_x * 5 - police_width) / 2; 
					obstacle_pos_y[0] <= 0;
					car_on_road[10]   <= 1'b1;
				end
				else if (cnt % 5 == 3 && 
						(car_on_road[19:15] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
						 car_on_road[19:15] == 5'b00000))
				begin 
					obstacle_pos_x[0] <= 79 + (lane_x * 7 - police_width) / 2; 
					obstacle_pos_y[0] <= 0;
					car_on_road[15]   <= 1'b1;
				end
				else if (car_on_road[24:20] == 5'b00010 && obstacle_pos_y[1] > police_height + police_height || 
						 car_on_road[24:20] == 5'b00000)
				begin 
					obstacle_pos_x[0] <= 79 + (lane_x * 9 - police_width) / 2; 
					obstacle_pos_y[0] <= 0;
					car_on_road[20]   <= 1'b1;
				end
			end

			if (iscollide1 || obstacle_pos_y[1] > 480 + police_height)
			begin
				// Clear the flag signal
				if (car_on_road[ 1] == 1'b1) 
					car_on_road[ 1] <= 1'b0;
				if (car_on_road[ 6] == 1'b1) 
					car_on_road[ 6] <= 1'b0;
				if (car_on_road[11] == 1'b1) 
					car_on_road[11] <= 1'b0;
				if (car_on_road[16] == 1'b1) 
					car_on_road[16] <= 1'b0;
				if (car_on_road[21] == 1'b1) 
					car_on_road[21] <= 1'b0;
				
				// Recreate the next position and flag signal
				if 	(cnt % 5 == 0 && 
					(car_on_road[ 4: 0] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
					 car_on_road[ 4: 0] == 5'b00000))
				begin 
					obstacle_pos_x[1] <= 79 + (lane_x - police_width) / 2;
					obstacle_pos_y[1] <= 0;
					car_on_road[ 1]   <= 1'b1;
				end
				else if (cnt % 5 == 1 && 
						(car_on_road[ 9 :5] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
						 car_on_road[ 9: 5] == 5'b00000))
				begin
					obstacle_pos_x[1] <= 79 + (lane_x * 3 - police_width) / 2;
					obstacle_pos_y[1] <= 0;
					car_on_road[ 6]   <= 1'b1;
				end
				else if (cnt % 5 == 2 && 
						(car_on_road[14:10] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
						 car_on_road[14:10] == 5'b00000))
				begin 
					obstacle_pos_x[1] <= 79 + (lane_x * 5 - police_width) / 2; 
					obstacle_pos_y[1] <= 0;
					car_on_road[11]   <= 1'b1;
				end
				else if (cnt % 5 == 3 && 
						(car_on_road[19:15] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
						 car_on_road[19:15] == 5'b00000))
				begin 
					obstacle_pos_x[1] <= 79 + (lane_x * 7 - police_width) / 2; 
					obstacle_pos_y[1] <= 0;
					car_on_road[16]   <= 1'b1;
				end
				else if (car_on_road[24:20] == 5'b00001 && obstacle_pos_y[0] > police_height + police_height ||
						 car_on_road[24:20] == 5'b00000)
				begin 
					obstacle_pos_x[1] <= 79 + (lane_x * 9 - police_width) / 2; 
					obstacle_pos_y[1] <= 0;
					car_on_road[21]   <= 1'b1;
				end
			end
			
			if (iscollide2 || obstacle_pos_y[2] > 480 + car_height)
			begin
				// Clear the flag signal
				if (car_on_road[ 2] == 1'b1) 
					car_on_road[ 2] <= 1'b0;
				if (car_on_road[ 7] == 1'b1) 
					car_on_road[ 7] <= 1'b0;
				if (car_on_road[12] == 1'b1) 
					car_on_road[12] <= 1'b0;
				if (car_on_road[17] == 1'b1) 
					car_on_road[17] <= 1'b0;
				if (car_on_road[22] == 1'b1) 
					car_on_road[22] <= 1'b0;
				
				// Recreate the next position and flag signal
				if 	(cnt % 5 == 0 && 
					(car_on_road[ 4: 0] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
					 car_on_road[ 4: 0] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
					 car_on_road[ 4: 0] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height || 					 
					 car_on_road[ 4: 0] == 5'b00000))
				begin 
					obstacle_pos_x[2] <= 79 + (lane_x - car_width) / 2;
					obstacle_pos_y[2] <= 0;
					car_on_road[ 2]   <= 1'b1;
				end
				else if (cnt % 5 == 1 && 
						(car_on_road[ 9: 5] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[ 9: 5] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[ 9: 5] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||						 
						 car_on_road[ 9: 5] == 5'b00000))
				begin 
					obstacle_pos_x[2] <= 79 + (lane_x * 3 - car_width) / 2;
					obstacle_pos_y[2] <= 0;
					car_on_road[ 7]   <= 1'b1;
				end
				else if (cnt % 5 == 2 && 
						(car_on_road[14:10] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[14:10] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[14:10] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||						 
						 car_on_road[14:10] == 5'b00000))
				begin
					obstacle_pos_x[2] <= 79 + (lane_x * 5 - car_width) / 2; 
					obstacle_pos_y[2] <= 0;
					car_on_road[12]   <= 1'b1;
				end
				else if (cnt % 5 == 3 && 
						(car_on_road[19:15] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[19:15] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[19:15] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||						 
						 car_on_road[19:15] == 5'b00000))
				begin 
					obstacle_pos_x[2] <= 79 + (lane_x * 7 - car_width) / 2; 
					obstacle_pos_y[2] <= 0;
					car_on_road[17]   <= 1'b1;
				end
				else if (car_on_road[24:20] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[24:20] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[24:20] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height || 						 
						 car_on_road[24:20] == 5'b00000)
				begin 
					obstacle_pos_x[2] <= 79 + (lane_x * 9 - car_width) / 2; 
					obstacle_pos_y[2] <= 0;
					car_on_road[22]   <= 1'b1;
				end
			end
			
			if (iscollide3 || obstacle_pos_y[3] > 480 + car_height)
			begin
				// Clear the flag signal
				if (car_on_road[ 3] == 1'b1) 
					car_on_road[ 3] <= 1'b0;
				if (car_on_road[ 8] == 1'b1) 
					car_on_road[ 8] <= 1'b0;
				if (car_on_road[13] == 1'b1) 
					car_on_road[13] <= 1'b0;
				if (car_on_road[18] == 1'b1) 
					car_on_road[18] <= 1'b0;
				if (car_on_road[23] == 1'b1) 
					car_on_road[23] <= 1'b0;
				
				// Recreate the next position and flag signal
				if 	(cnt % 5 == 0 && 
					(car_on_road[ 4: 0] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
					 car_on_road[ 4: 0] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
					 car_on_road[ 4: 0] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height || 					 
					 car_on_road[ 4: 0] == 5'b00000))
				begin 
					obstacle_pos_x[3] <= 79 + (lane_x - car_width) / 2;
					obstacle_pos_y[3] <= 0;
					car_on_road[ 3]   <= 1'b1;
				end
				else if (cnt % 5 == 1 && 
						(car_on_road[ 9: 5] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[ 9: 5] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[ 9: 5] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height || 						 
						 car_on_road[ 9: 5] == 5'b00000))
				begin
					obstacle_pos_x[3] <= 79 + (lane_x * 3 - car_width) / 2;
					obstacle_pos_y[3] <= 0;
					car_on_road[ 8]   <= 1'b1;
				end
				else if (cnt % 5 == 2 && 
						(car_on_road[14:10] == 5'b00001 && obstacle_pos_y[0] > car_height + police_height || 
						 car_on_road[14:10] == 5'b00010 && obstacle_pos_y[1] > car_height + police_height || 
						 car_on_road[14:10] == 5'b00100 && obstacle_pos_y[2] > car_height + police_height || 
						 car_on_road[14:10] == 5'b00000))
				begin 
					obstacle_pos_x[3] <= 79 + (lane_x * 5 - car_width) / 2; 
					obstacle_pos_y[3] <= 0;
					car_on_road[13]   <= 1'b1;
				end
				else if (cnt % 5 == 3 && 
						(car_on_road[19:15] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[19:15] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[19:15] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||						 
						 car_on_road[19:15] == 5'b00000))
				begin 
					obstacle_pos_x[3] <= 79 + (lane_x * 7 - car_width) / 2; 
					obstacle_pos_y[3] <= 0;
					car_on_road[18]   <= 1'b1;
				end
				else if (car_on_road[24:20] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[24:20] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[24:20] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height || 						 
						 car_on_road[24:20] == 5'b00000)
				begin 
					obstacle_pos_x[3] <= 79 + (lane_x * 9 - car_width) / 2; 
					obstacle_pos_y[3] <= 0;
					car_on_road[23]   <= 1'b1;
				end
			end
			
			if (iscollide4 || obstacle_pos_y[4] > 480 + car_height)
			begin
				// Clear the flag signal
				if (car_on_road[ 4] == 1'b1) 
					car_on_road[ 4] <= 1'b0;
				if (car_on_road[ 9] == 1'b1) 
					car_on_road[ 9] <= 1'b0;
				if (car_on_road[14] == 1'b1) 
					car_on_road[14] <= 1'b0;
				if (car_on_road[19] == 1'b1) 
					car_on_road[19] <= 1'b0;
				if (car_on_road[24] == 1'b1) 
					car_on_road[24] <= 1'b0;
				
				// Recreate the next position and flag signal
				if 	(cnt % 5 == 0 &&  
					(car_on_road[ 4: 0] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
					 car_on_road[ 4: 0] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
					 car_on_road[ 4: 0] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
					 car_on_road[ 4: 0] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
					 car_on_road[ 4: 0] == 5'b00000))
				begin 
					obstacle_pos_x[4] <= 79 + (lane_x - car_width) / 2;
					obstacle_pos_y[4] <= 0;
					car_on_road[ 4]   <= 1'b1;
				end
				else if (cnt % 5 == 1 && 
						(car_on_road[ 9: 5] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[ 9: 5] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[ 9: 5] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
						 car_on_road[ 9: 5] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
						 car_on_road[ 9: 5] == 5'b00000))
				begin 
					obstacle_pos_x[4] <= 79 + (lane_x * 3 - car_width) / 2;
					obstacle_pos_y[4] <= 0;
					car_on_road[ 9]   <= 1'b1;
				end
				else if (cnt % 5 == 2 && 
						(car_on_road[14:10] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[14:10] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[14:10] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
						 car_on_road[14:10] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
						 car_on_road[14:10] == 5'b00000))
				begin 
					obstacle_pos_x[4] <= 79 + (lane_x * 5 - car_width) / 2; 
					obstacle_pos_y[4] <= 0;
					car_on_road[14]   <= 1'b1;
				end
				else if (cnt % 5 == 3 && 
						(car_on_road[19:15] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[19:15] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[19:15] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
						 car_on_road[19:15] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
						 car_on_road[19:15] == 5'b00000))
				begin 
					obstacle_pos_x[4] <= 79 + (lane_x * 7 - car_width) / 2; 
					obstacle_pos_y[4] <= 0;
					car_on_road[19]   <= 1'b1;
				end
				else if (car_on_road[24:20] == 5'b00001 && obstacle_pos_y[0] > car_height + car_height || 
						 car_on_road[24:20] == 5'b00010 && obstacle_pos_y[1] > car_height + car_height ||
						 car_on_road[24:20] == 5'b00100 && obstacle_pos_y[2] > car_height + car_height ||
						 car_on_road[24:20] == 5'b01000 && obstacle_pos_y[3] > car_height + car_height ||  					 
						 car_on_road[24:20] == 5'b00000)
				begin 
					obstacle_pos_x[4] <= 79 + (lane_x * 9 - car_width) / 2; 
					obstacle_pos_y[4] <= 0;
					car_on_road[24]   <= 1'b1;
				end
			end
			
			// Move obstacles
			if (obstacle_pos_y[0] <= 480 + police_height)
				obstacle_pos_y[0] <= obstacle_pos_y[0] + 4;
			if (obstacle_pos_y[1] <= 480 + police_height)
				obstacle_pos_y[1] <= obstacle_pos_y[1] + 4;
			if (obstacle_pos_y[2] <= 480 + car_height)
				obstacle_pos_y[2] <= obstacle_pos_y[2] + 3;
			if (obstacle_pos_y[3] <= 480 + car_height)
				obstacle_pos_y[3] <= obstacle_pos_y[3] + 3;
			if (obstacle_pos_y[4] <= 480 + car_height)
				obstacle_pos_y[4] <= obstacle_pos_y[4] + 2;
		end
		
		//========================================================================
		// The explosion animation will continue to play after you're dead
		//========================================================================		
		// Set explosion position signal
		if (iscollide0)
		begin
			explode_pos_x   <= mycar_pos_x + (car_width - explode_width) / 2;
			explode_pos_y   <= mycar_pos_y + (car_height - explode_height) / 2;
			explode_visible <= 1'b1;
		end
		
		if (iscollide1)
		begin
			explode_pos_x   <= mycar_pos_x + (car_width - explode_width) / 2;
			explode_pos_y   <= mycar_pos_y + (car_height - explode_height) / 2;
			explode_visible <= 1'b1;
		end
	
		if (iscollide2)
		begin
			explode_pos_x   <= obstacle_pos_x[2] + (car_width - explode_width) / 2;
			explode_pos_y   <= obstacle_pos_y[2] + (car_height - explode_height) / 2;
			explode_visible <= 1'b1;
		end

		if (iscollide3)
		begin
			explode_pos_x   <= obstacle_pos_x[3] + (car_width - explode_width) / 2;
			explode_pos_y   <= obstacle_pos_y[3] + (car_height - explode_height) / 2;
			explode_visible <= 1'b1;
		end
		
		if (iscollide4)
		begin
			explode_pos_x   <= obstacle_pos_x[4] + (car_width - explode_width) / 2;
			explode_pos_y   <= obstacle_pos_y[4] + (car_height - explode_height) / 2;
			explode_visible <= 1'b1;
		end
		
		// Disapear the animation
		if (num == 0)
			explode_visible <= 1'b0;
	
	end
	
	//=============================================================================
	// Dynamic object's position calculation
	//=============================================================================
	// Scroll the road
	always @ (posedge clk200)
	begin
		if (status == activate)
			scroll <= scroll - 4;
	end
	
	// Move the car and EDGE detection
	always @(posedge clk1600)
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
	
	// Explosion
	always @ (posedge clk50)
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
	
endmodule
