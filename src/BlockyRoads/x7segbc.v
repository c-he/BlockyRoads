`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:05:49 12/16/2016 
// Design Name: 
// Module Name:    x7segbc 
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
module x7segbc(
    input wire clk,
	input wire [31:0] x,
	output reg [ 6:0] a_to_g,
	output reg [ 7:0] an,
	output wire dp
	);
	
	wire [ 2:0] s;
	reg  [ 4:0] digit;
	wire [ 7:0] aen;
	reg  [19:0] clkdiv;

	assign dp = 1;
	assign s  = clkdiv[19:17];
	
	// Set aen[7:0] for leading blanks
	assign aen[7] = x[31] | x[30] | x[29] | x[28];
	assign aen[6] = x[31] | x[30] | x[29] | x[28] |
					x[27] | x[26] | x[25] | x[24];
	assign aen[5] = x[31] | x[30] | x[29] | x[28] |
					x[27] | x[26] | x[25] | x[24] |
					x[23] | x[22] | x[21] | x[20];
	assign aen[4] = x[31] | x[30] | x[29] | x[28] |
					x[27] | x[26] | x[25] | x[24] |
					x[23] | x[22] | x[21] | x[20] |
					x[19] | x[18] | x[17] | x[16];
	assign aen[3] = x[31] | x[30] | x[29] | x[28] |
					x[27] | x[26] | x[25] | x[24] |
					x[23] | x[22] | x[21] | x[20] |
					x[19] | x[18] | x[17] | x[16] |
					x[15] | x[14] | x[13] | x[12];
	assign aen[2] = x[31] | x[30] | x[29] | x[28] |
					x[27] | x[26] | x[25] | x[24] |
					x[23] | x[22] | x[21] | x[20] |
					x[19] | x[18] | x[17] | x[16] |
					x[15] | x[14] | x[13] | x[12] |
					x[11] | x[10] | x[ 9] | x[ 8];
	assign aen[1] = x[31] | x[30] | x[29] | x[28] |
					x[27] | x[26] | x[25] | x[24] |
					x[23] | x[22] | x[21] | x[20] |
					x[19] | x[18] | x[17] | x[16] |
					x[15] | x[14] | x[13] | x[12] |
					x[11] | x[10] | x[ 9] | x[ 8] |
					x[ 7] | x[ 6] | x[ 5] | x[ 4];
	assign aen[0] = 1;	// Digit 0 always on
	
	// MUX 8 to 1
	always @*
		case (s)
			0: digit       = {1'b0, x[ 3: 0]};
			1: digit       = {1'b0, x[ 7: 4]};
			2: digit       = {1'b0, x[11: 8]};
			3: digit       = {1'b0, x[15:12]};
			4: digit       = 5'b1_0000;
			5: digit       = 5'b1_0001;
			6: digit       = 5'b1_0010;
			7: digit       = 5'b1_0011;
			default: digit = {1'b0, x[ 3: 0]};
		endcase
	
	// hex7seg
	always @*
		case (digit)
			0: a_to_g       = 7'b1000000;
			1: a_to_g       = 7'b1111001;
			2: a_to_g       = 7'b0100100;
			3: a_to_g       = 7'b0110000;
			4: a_to_g       = 7'b0011001;
			5: a_to_g       = 7'b0010010;
			6: a_to_g       = 7'b0000010;
			7: a_to_g       = 7'b1111000;
			8: a_to_g       = 7'b0000000;
			9: a_to_g       = 7'b0010000;
			'hA: a_to_g     = 7'b0001000;
			'hB: a_to_g     = 7'b0000011;
			'hC: a_to_g     = 7'b1000110;
			'hD: a_to_g     = 7'b0100001;
			'hE: a_to_g     = 7'b0000110;
			'hF: a_to_g     = 7'b0001110;
			// User defined character
			'h10: a_to_g    = 7'b0001011;	// h
			'h11: a_to_g    = 7'b0010000;	// g
			'h12: a_to_g    = 7'b1111001;	// I
			'h13: a_to_g    = 7'b0001001;	// H
		endcase
	
	// Digit select
	always @*
	begin
		an = 8'b1111_1111;
		if (aen[s] == 1)
			an[s] = 0;
	end
	
	// Clock divider
	always @ (posedge clk)
	begin
		clkdiv <= clkdiv + 1;
	end
	
endmodule
