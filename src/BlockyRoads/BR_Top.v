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
	
	// game status signal declaration
	localparam [1:0]
		load      = 2'b00,
		activate  = 2'b01,
		pause     = 2'b10,
		terminate = 2'b11;
	wire [1:0] status;
	
	Renderer render_unit (.clk(clk), .clr(clr), .status(status), .hsync(hsync), .vsync(vsync), .red(red), .green(green), .blue(blue) );
	Model model_unit (.clk(clk), .clr(clr), .ps2c(ps2c), .ps2d(ps2d), .segment(segment), .an(an), .status(status));

endmodule
