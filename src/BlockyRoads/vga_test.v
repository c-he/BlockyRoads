`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:46:41 12/12/2016 
// Design Name: 
// Module Name:    vga_test 
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
module vga_test(
    input wire clk, clr,
	output wire hsync, vsync,
	output reg [3:0] red, green, blue
	);
	
	// signal declaration
	wire clk25m;
	wire video_on;
	wire [9:0] pixel_x, pixel_y;
	wire [9:0] x, y;
	wire [14:0] back_addr;
	wire [15:0] back_data;
	
	// instantiate vga_sync circuit
	clkdiv div_unit ( .clk(clk), .clr(clr), .clk25m(clk25m) );
	vga_sync sync_unit (
		.clk(clk25m), .clr(clr), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y)
	);
	
	// instantiate bmp's pixel data
	background B1 (.clka(clk), .addra(back_addr), .douta(back_data));
	
	// render the test bmp
	assign x = pixel_x - 240;
	assign y = pixel_y - 180;
	assign back_addr = (120 - y) * 160 + x;
	
	always @*
	begin
		if(video_on)
		begin
			if( (pixel_x > 239) && (pixel_x < 400) )
			begin
				if( (pixel_y > 179) && (pixel_y < 300) )
				begin
					red   <= back_data[ 3: 0];
					green <= back_data[ 7: 4];
					blue  <= back_data[11: 8];
				end
				else
				begin
					red   <= 4'b0;
					green <= 4'b1000;
					blue  <= 4'b1111;
				end
			end
			else
			begin
				red   <= 4'b0;
				green <= 4'b1000;
				blue  <= 4'b1111;
			end
		end
		else
		begin
			red   <= 4'b0;
			green <= 4'b0;
			blue  <= 4'b0;
		end
	end
	
endmodule
