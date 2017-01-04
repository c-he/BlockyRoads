`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:33:33 01/01/2017 
// Design Name: 
// Module Name:    Detector 
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
module Detector(
    input wire [9:0] mycar_pos_x, mycar_pos_y,
	input wire [9:0] obstacle_pos_x0, obstacle_pos_x1, obstacle_pos_x2, obstacle_pos_x3, obstacle_pos_x4,
	input wire [9:0] obstacle_pos_y0, obstacle_pos_y1, obstacle_pos_y2, obstacle_pos_y3, obstacle_pos_y4,
	output wire iscollide0, iscollide1, iscollide2, iscollide3, iscollide4
	);
	
	//============================================================================
	// Const declaration
	//============================================================================
	parameter car_width           = 60;
	parameter car_height          = 100;
	parameter car_offset_left     = 15;
	parameter car_offset_right    = 5;
	parameter car_offset_front    = 10;
	parameter car_offset_bottom   = 5;
	parameter police_width        = 64;
	parameter police_height       = 100;
	parameter police_offset_left  = 5;
	parameter police_offset_right = 5;
	
	//============================================================================
	// Declare some signals to make the code more understandable
	//============================================================================
	wire [9:0] mycar_x_left, mycar_x_right, mycar_y_front, mycar_y_bottom;
	wire [9:0] obstacle_x_left[0:4], obstacle_x_right[0:4], obstacle_y_front[0:4], obstacle_y_bottom[0:4];
	
	assign mycar_x_left = mycar_pos_x + car_offset_left;
	assign mycar_x_right = mycar_pos_x + car_width - car_offset_right;
	assign mycar_y_front = mycar_pos_y + car_offset_front;
	assign mycar_y_bottom = mycar_pos_y + car_height- car_offset_bottom;
	
	assign obstacle_x_left[0]   = obstacle_pos_x0 + police_offset_left;
	assign obstacle_x_right[0]  = obstacle_pos_x0 + police_width - police_offset_right;
	assign obstacle_y_front[0]  = {obstacle_pos_y0 > police_height ? obstacle_pos_y0 - police_height : 0};
	assign obstacle_y_bottom[0] = obstacle_pos_y0;
	
	assign obstacle_x_left[1]   = obstacle_pos_x1 + police_offset_left;
	assign obstacle_x_right[1]  = obstacle_pos_x1 + police_width - police_offset_right;
	assign obstacle_y_front[1]  = {obstacle_pos_y1 > police_height ? obstacle_pos_y1 - police_height : 0};
	assign obstacle_y_bottom[1] = obstacle_pos_y1;
	
	assign obstacle_x_left[2]   = obstacle_pos_x2 + car_offset_left;
	assign obstacle_x_right[2]  = obstacle_pos_x2 + car_width - car_offset_right;
	assign obstacle_y_front[2]  = {obstacle_pos_y2 + car_offset_front > car_height ? obstacle_pos_y2 + car_offset_front - car_height : 0};
	assign obstacle_y_bottom[2] = obstacle_pos_y2 - car_offset_bottom;
	
	assign obstacle_x_left[3]   = obstacle_pos_x3 + car_offset_left;
	assign obstacle_x_right[3]  = obstacle_pos_x3 + car_width - car_offset_right;
	assign obstacle_y_front[3]  = {obstacle_pos_y3 + car_offset_front > car_height ? obstacle_pos_y3 + car_offset_front - car_height : 0};
	assign obstacle_y_bottom[3] = obstacle_pos_y3 - car_offset_bottom;
	
	assign obstacle_x_left[4]   = obstacle_pos_x4 + car_offset_left;
	assign obstacle_x_right[4]  = obstacle_pos_x4 + car_width - car_offset_right;
	assign obstacle_y_front[4]  = {obstacle_pos_y4 + car_offset_front > car_height ? obstacle_pos_y4 + car_offset_front - car_height : 0};
	assign obstacle_y_bottom[4] = obstacle_pos_y4 - car_offset_bottom;
	
	//=============================================================================
	// Detection
	//=============================================================================
	assign iscollide0 = (mycar_x_left <= obstacle_x_right[0] && mycar_x_right >= obstacle_x_right[0] && mycar_y_front <= obstacle_y_bottom [0] && mycar_y_bottom >= obstacle_y_bottom[0]) ||
						(mycar_x_left <= obstacle_x_right[0] && mycar_x_right >= obstacle_x_right[0] && mycar_y_bottom >= obstacle_y_front[0] && mycar_y_front <= obstacle_y_front[0]) ||
						(mycar_x_right >= obstacle_x_left[0] && mycar_x_left <= obstacle_x_left[0] && mycar_y_front <= obstacle_y_bottom[0] && mycar_y_bottom >= obstacle_y_bottom[0]) ||
						(mycar_x_right >= obstacle_x_left[0] && mycar_x_left <= obstacle_x_left[0] && mycar_y_bottom >= obstacle_y_front[0] && mycar_y_front <= obstacle_y_front[0]) ||
						(mycar_x_left >= obstacle_x_left[0] && mycar_x_right <= obstacle_x_right[0] && mycar_y_front <= obstacle_y_bottom[0] && mycar_y_bottom >= obstacle_y_bottom[0]);
	
	assign iscollide1 = (mycar_x_left <= obstacle_x_right[1] && mycar_x_right >= obstacle_x_right[1] && mycar_y_front <= obstacle_y_bottom [1] && mycar_y_bottom >= obstacle_y_bottom[1]) ||
						(mycar_x_left <= obstacle_x_right[1] && mycar_x_right >= obstacle_x_right[1] && mycar_y_bottom >= obstacle_y_front[1] && mycar_y_front <= obstacle_y_front[1]) ||
						(mycar_x_right >= obstacle_x_left[1] && mycar_x_left <= obstacle_x_left[1] && mycar_y_front <= obstacle_y_bottom[1] && mycar_y_bottom >= obstacle_y_bottom[1]) ||
						(mycar_x_right >= obstacle_x_left[1] && mycar_x_left <= obstacle_x_left[1] && mycar_y_bottom >= obstacle_y_front[1] && mycar_y_front <= obstacle_y_front[1]) ||
						(mycar_x_left >= obstacle_x_left[1] && mycar_x_right <= obstacle_x_right[1] && mycar_y_front <= obstacle_y_bottom[1] && mycar_y_bottom >= obstacle_y_bottom[1]);
	
	assign iscollide2 = (mycar_x_left <= obstacle_x_right[2] && mycar_x_right >= obstacle_x_right[2] && mycar_y_front <= obstacle_y_bottom [2] && mycar_y_bottom >= obstacle_y_bottom[2]) ||
						(mycar_x_left <= obstacle_x_right[2] && mycar_x_right >= obstacle_x_right[2] && mycar_y_bottom >= obstacle_y_front[2] && mycar_y_front <= obstacle_y_front[2]) ||
						(mycar_x_right >= obstacle_x_left[2] && mycar_x_left <= obstacle_x_left[2] && mycar_y_front <= obstacle_y_bottom[2] && mycar_y_bottom >= obstacle_y_bottom[2]) ||
						(mycar_x_right >= obstacle_x_left[2] && mycar_x_left <= obstacle_x_left[2] && mycar_y_bottom >= obstacle_y_front[2] && mycar_y_front <= obstacle_y_front[2]) ||
						(mycar_x_left >= obstacle_x_left[2] && mycar_x_right <= obstacle_x_right[2] && mycar_y_front <= obstacle_y_bottom[2] && mycar_y_bottom >= obstacle_y_bottom[2]);
						
	assign iscollide3 = (mycar_x_left <= obstacle_x_right[3] && mycar_x_right >= obstacle_x_right[3] && mycar_y_front <= obstacle_y_bottom [3] && mycar_y_bottom >= obstacle_y_bottom[3]) ||
						(mycar_x_left <= obstacle_x_right[3] && mycar_x_right >= obstacle_x_right[3] && mycar_y_bottom >= obstacle_y_front[3] && mycar_y_front <= obstacle_y_front[3]) ||
						(mycar_x_right >= obstacle_x_left[3] && mycar_x_left <= obstacle_x_left[3] && mycar_y_front <= obstacle_y_bottom[3] && mycar_y_bottom >= obstacle_y_bottom[3]) ||
						(mycar_x_right >= obstacle_x_left[3] && mycar_x_left <= obstacle_x_left[3] && mycar_y_bottom >= obstacle_y_front[3] && mycar_y_front <= obstacle_y_front[3]) ||
						(mycar_x_left >= obstacle_x_left[3] && mycar_x_right <= obstacle_x_right[3] && mycar_y_front <= obstacle_y_bottom[3] && mycar_y_bottom >= obstacle_y_bottom[3]);
						
	assign iscollide4 = (mycar_x_left <= obstacle_x_right[4] && mycar_x_right >= obstacle_x_right[4] && mycar_y_front <= obstacle_y_bottom [4] && mycar_y_bottom >= obstacle_y_bottom[4]) ||
						(mycar_x_left <= obstacle_x_right[4] && mycar_x_right >= obstacle_x_right[4] && mycar_y_bottom >= obstacle_y_front[4] && mycar_y_front <= obstacle_y_front[4]) ||
						(mycar_x_right >= obstacle_x_left[4] && mycar_x_left <= obstacle_x_left[4] && mycar_y_front <= obstacle_y_bottom[4] && mycar_y_bottom >= obstacle_y_bottom[4]) ||
						(mycar_x_right >= obstacle_x_left[4] && mycar_x_left <= obstacle_x_left[4] && mycar_y_bottom >= obstacle_y_front[4] && mycar_y_front <= obstacle_y_front[4]) ||
						(mycar_x_left >= obstacle_x_left[4] && mycar_x_right <= obstacle_x_right[4] && mycar_y_front <= obstacle_y_bottom[4] && mycar_y_bottom >= obstacle_y_bottom[4]);

endmodule
