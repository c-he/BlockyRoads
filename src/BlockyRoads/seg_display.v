`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:39:09 12/16/2016 
// Design Name: 
// Module Name:    seg_display 
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
module seg_display(
    input wire clk,
	output wire [3:0] AN,
	output wire [7:0] SEGMENT
	);
	
	reg [15:0] disp_num;
	
	initial disp_num <= 16'b1010_1011_1100_1101;
		
	x7segbc seg_unit (clk, 1'b0, disp_num, 4'b1111, AN, SEGMENT);

endmodule
