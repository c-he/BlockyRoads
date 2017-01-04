`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:00:19 12/14/2016 
// Design Name: 
// Module Name:    BR_Top 
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
module BR_Top(
    input wire clk, clr,
	input wire ps2c, ps2d,
	output wire hsync, vsync,
	output wire [3:0] red, green, blue,
	output wire [7:0] an,
	output wire [7:0] segment
	);
	
	// Keyboard signal
	wire [ 3: 0] status;
	wire [15: 0] xkey;
	// VGA signal
	wire signed [31:0] scroll;
	wire video_on;
	wire [ 9: 0] pixel_x, pixel_y;
	wire btn_pos, mycar_pos, explode_pos;
	wire btn_visible, explode_visible;
	wire obstacle_pos [0:4];
	wire iscollide [0:4];
	wire [16:0] back_addr, side_addr;
	wire [13:0] btn_addr;
	wire [12:0] mycar_addr;
	wire [12: 0] obstacle_addr [0:4];
	wire [15:0] explode_addr;
	
	Renderer render_unit (.clk(clk), .clr(clr), 
						.status(status),
						.video_on(video_on),
						.pixel_x(pixel_x), .pixel_y(pixel_y),
						.scroll(scroll),
						.btn_pos(btn_pos), .mycar_pos(mycar_pos), .explode_pos(explode_pos), 
						.btn_visible(btn_visible), .explode_visible(explode_visible),
						.obstacle_pos0(obstacle_pos[0]), .obstacle_pos1(obstacle_pos[1]), .obstacle_pos2(obstacle_pos[2]), .obstacle_pos3(obstacle_pos[3]), .obstacle_pos4(obstacle_pos[4]),
						.iscollide0(iscollide[0]), .iscollide1(iscollide[1]), .iscollide2(iscollide[2]), .iscollide3(iscollide[3]), .iscollide4(iscollide[4]),
						.back_addr(back_addr), .side_addr(side_addr), .btn_addr(btn_addr), .mycar_addr(mycar_addr), .explode_addr(explode_addr), 
						.obstacle_addr0(obstacle_addr[0]), .obstacle_addr1(obstacle_addr[1]), .obstacle_addr2(obstacle_addr[2]), .obstacle_addr3(obstacle_addr[3]), .obstacle_addr4(obstacle_addr[4]),
						.red(red), .green(green), .blue(blue)
						);

	Controller control_unit (.clk(clk), .clr(clr), 
							.ps2c(ps2c), .ps2d(ps2d), 
							.status(status),
							.xkey(xkey), 
							.hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y),
							.btn_pos(btn_pos), .mycar_pos(mycar_pos), .explode_pos(explode_pos),
							.btn_visible(btn_visible), .explode_visible(explode_visible),
							.obstacle_pos0(obstacle_pos[0]), .obstacle_pos1(obstacle_pos[1]), .obstacle_pos2(obstacle_pos[2]), .obstacle_pos3(obstacle_pos[3]), .obstacle_pos4(obstacle_pos[4]),
							.iscollide0(iscollide[0]), .iscollide1(iscollide[1]), .iscollide2(iscollide[2]), .iscollide3(iscollide[3]), .iscollide4(iscollide[4]),
							.scroll(scroll),
							.back_addr(back_addr), .side_addr(side_addr), .btn_addr(btn_addr), .mycar_addr(mycar_addr),
							.obstacle_addr0(obstacle_addr[0]), .obstacle_addr1(obstacle_addr[1]), .obstacle_addr2(obstacle_addr[2]), .obstacle_addr3(obstacle_addr[3]), .obstacle_addr4(obstacle_addr[4]),
							.explode_addr(explode_addr)
							);
	
	Model model_unit (.clk(clk), .clr(clr), .xkey(xkey), .segment(segment), .an(an));
	
endmodule
