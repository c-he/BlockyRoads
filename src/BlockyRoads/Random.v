`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:13:57 01/01/2017 
// Design Name: 
// Module Name:    Random 
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
module Random(
    input wire clk,
	input wire [3:0] direction,
	input wire [4:0] road_on, car_on,
	output reg [4:0] path,
	output reg [1:0] speed_data0, speed_data1, speed_data2, speed_data3, speed_data4,
	output reg [2:0] obstacle_num
	);
	
	reg [ 2:0] x;
	reg [10:0] cnt;
	wire [2:0] temp_num;
	
	initial
	begin
		x   <= 3'b0;
		cnt <= 11'b0;
	end
	
	assign temp_num = (path + 233) % 5;
	
	always @ (posedge clk)
	begin
		if (direction != 4'b0)
		begin
			x   <= (x + 1023) % 5;
			cnt <= cnt + 1023;
		end
		else
		begin
			x   <= (x + 1) % 5;
			cnt <= cnt + 1;
		end
		
		case (temp_num)
			3'b000:
			begin
				if (car_on[0] != 1'b1)
				begin
					obstacle_num <= temp_num;
				end
			end
			3'b001:
			begin
				if (car_on[1] != 1'b1)
				begin
					obstacle_num <= temp_num;
				end
			end
			3'b010:
			begin
				if (car_on[2] != 1'b1)
				begin
					obstacle_num <= temp_num;
				end
			end
			3'b011:
			begin
				if (car_on[3] != 1'b1)
				begin
					obstacle_num <= temp_num;
				end
			end
			3'b100:
			begin
				if (car_on[4] != 1'b1)
				begin
					obstacle_num <= temp_num;
				end
			end
		endcase
		
		case (x)
			3'b000:
			begin
				if (road_on[0] != 1'b1)
				begin
					path <= 5'b00001;
				end
			end
			3'b001:
			begin
				if (road_on[1] != 1'b1)
				begin
					path <= 5'b00010;
				end
			end
			3'b010:
			begin
				if (road_on[2] != 1'b1)
				begin
					path <= 5'b00100;
				end
			end
			3'b011:
			begin
				if (road_on[3] != 1'b1)
				begin
					path <= 5'b01000;
				end
			end
			3'b100:
			begin
				if (road_on[4] != 1'b1)
				begin
					path <= 5'b10000;
				end
			end
		endcase
		
		case (obstacle_num)
			3'b000:
			begin
				speed_data0 <= 1;
			end
			3'b001:
			begin
				speed_data1 <= 2;
			end
			3'b010:
			begin
				speed_data2 <= 2;
			end
			3'b011:
			begin
				speed_data3 <= 3;
			end
			3'b100:
			begin
				speed_data4 <= 3;
			end
		endcase
	end
		
endmodule
