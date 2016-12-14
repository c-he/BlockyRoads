`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:06:46 12/12/2016 
// Design Name: 
// Module Name:    Renderer 
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
module Renderer(
    input wire clk, clr,
	output wire hsync, vsync,
	output wire [3:0] red, green, blue
	);
	
	// vga_test module
	vga_test debug_unit ( .clk(clk), .clr(clr), .hsync(hsync), .vsync(vsync), .red(red), .green(green), .blue(blue) );

endmodule
