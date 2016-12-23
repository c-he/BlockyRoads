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
    input wire clk,
	input wire [2:0] status
	);
	
	wire clk25m;
	reg press_down;
	
	// game status signal declaration
	localparam [1:0]
		load      = 2'b00;
		activate  = 2'b01;
		pause     = 2'b10;
		terminate = 2'b11;
	
	clkdiv div_key (.clk(clk), .clr(clr), .clk25m(clk25m));
	Renderer render_control (.
	
	// VGA controller
	always @ (posedge clk25m)
	begin
		if (status == load)
		begin
			press_down <= 1'b1;
		end
	end
		
endmodule
