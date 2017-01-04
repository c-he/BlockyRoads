`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:34 12/12/2016 
// Design Name: 
// Module Name:    Model 
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
module Model(
    input wire clk, clr,
	input wire [15:0] xkey,
	output wire [7:0] segment,
	output wire [7:0] an
	);

	wire [ 6:0] a_to_g;
	wire dp;

	assign segment = {dp, a_to_g};
	
	// Use segment tube to display the scan code of keyboard
	x7segbc seg_disp (.x({16'b0, xkey}), .clk(clk), .clr(clr), .a_to_g(a_to_g), .an(an), .dp(dp));
	


endmodule
