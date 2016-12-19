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
	wire btn_pos;
	wire back_pos;
	wire [9:0] pixel_x, pixel_y;
	wire [9:0] back_x, back_y, btn_x, btn_y;
	wire [17:0] back_addr;
	wire [14:0] btn_addr;
	wire [11:0] back_data, btn_data;

	// instantiate vga_sync circuit
	clkdiv div_unit ( .clk(clk), .clr(clr), .clk25m(clk25m) );
	vga_sync sync_unit (
	 	.clk(clk25m), .clr(clr), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y)
	);

	// instantiate bmp's pixel data
	background P1 (.clka(clk), .addra(back_addr), .douta(back_data));
	startBtn   P2 (.clka(clk), .addra(btn_addr), .douta(btn_data));

	// render the test bmp
	assign back_x    = pixel_x;
	assign back_y    = pixel_y - 60;
	assign back_addr = back_y * 640 + back_x;
	assign btn_x     = pixel_x - 350;
	assign btn_y     = pixel_y - 340;
	assign btn_addr  = btn_y * 300 + btn_x;
	assign btn_pos   = (pixel_x >= 350) && (pixel_x < 650) && (pixel_y >= 340) && (pixel_y < 420);
	assign back_pos  = (pixel_y >=60) && (pixel_y < 420);
	
	//===========================================================================
	// Layer 0: background
	// Layer 1: static objects
	// Layer 2: moving objects
	always @*
	begin
	 	if(video_on)
	 	begin
	 		if (btn_pos)
	 		begin
				if (btn_data == 12'hfff)
				begin
					if (back_pos)
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
					red   <= btn_data[ 3: 0];
					green <= btn_data[ 7: 4];
					blue  <= btn_data[11: 8];
				end
			end
	 		else
	 		begin
	 			if (back_pos)
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
		end
		else
	 	begin
	 		red   <= 4'b0;
	 		green <= 4'b0;
	 		blue  <= 4'b0;
	 	end
	 end
	
	
	/* pure color display for debug
	clkdiv div_unit ( .clk(clk), .clr(clr), .clk25m(clk25m) );
	vga_sync test_unit(.clk(clk25m), .clr(clr), .hsync(hsync), .vsync(vsync), .video_on(video_on), .pixel_x(), .pixel_y());
	
	always @*
	begin
		red   <= 4'b0;
		blue  <= 4'b0;
		green <= 4'b0;
		if (video_on == 1)
		begin
			red   <= 4'b0;
			green <= 4'b1000;
			blue  <= 4'b1111;
		end
	end
	*/

endmodule
