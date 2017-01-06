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
    input wire clk,
	input wire [3:0] high_score0, high_score1, high_score2, high_score3,
	output wire [7:0] segment,
	output wire [7:0] an
	);

	wire [ 6:0] a_to_g;
	wire dp;
	wire [15:0] High = 16'b0001_0000_0010_0100;

	assign segment = {dp, a_to_g};
	
	// Use segment tube to display the highest score
	x7segbc seg_disp (.x({High, high_score3, high_score2, high_score1, high_score0}), .clk(clk), .a_to_g(a_to_g), .an(an), .dp(dp));
	


endmodule
