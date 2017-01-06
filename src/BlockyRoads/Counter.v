`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:07:47 01/05/2017 
// Design Name: 
// Module Name:    Counter 
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
module Counter(
    input wire clk, clr,
	input wire plus,
	output wire [3:0] score0, score1, score2, score3, high_score0, high_score1, high_score2, high_score3
	);
	
	reg [9:0] score, high_score;
	reg [1:0] filter_plus, filter_rst;
	
	initial
	begin
		score       <= 10'b0;
		high_score  <= 10'b0;
		filter_plus <= 2'b0;
		filter_rst  <= 2'b0;
	end
	
	always @ (posedge clk)
	begin
		filter_plus <= {filter_plus[0], plus};
		filter_rst  <= {filter_rst[0], clr};
		if (filter_rst == 2'b01)
		begin
			score <= 10'b0;
		end
		else
		begin
			if (filter_plus == 2'b01)
				score <= score + 10;
			if (high_score < score)
				high_score <= score;
		end
	end
	
	//===========================================================
	// Change the score into BCD codes
	//===========================================================
	assign score0 = score % 10;
	assign score1 = (score / 10) % 10;
	assign score2 = (score / 100) % 10;
	assign score3 = score / 1000;
	
	assign high_score0 = high_score % 10;
	assign high_score1 = (high_score / 10) % 10;
	assign high_score2 = (high_score / 100) % 10;
	assign high_score3 = high_score / 1000;

endmodule
