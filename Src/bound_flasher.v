`timescale 1ns / 1ps

module boundFlasher( 
    input clk, flick, rst,
    output [15:0] lamps
);

    // Define states
    parameter S0 = 0;
    parameter S1 = 1;
    parameter S2 = 2;
    parameter S3 = 3;
    parameter S4 = 4;
    parameter S5 = 5;
    parameter S6 = 6;
    parameter S7 = 7;
	
    // Internal signals
    parameter TIMER = 200;
    integer counter = 0;
    reg [3:0] state = S0;
    reg [15:0] temp;
	
    // State machine
    always @(posedge clk) begin
		if(rst) begin 
			state <= S0;
		end
		else begin
			case(state)
				S0:
					begin
						temp <= 16'h0000;
						if(flick == 0) state <= S0;
						else state <= S1;
					end
				S1:
					begin
						counter <= counter + 1;
						if(counter == TIMER) begin
							temp <= (temp << 1) + 1;
							counter <= 0;
						end
						if(temp == 16'h003F) begin
							state <= S2;
							counter <= 0;
						end
					end
				S2:
					begin
						counter <= counter + 1;
						if (counter == TIMER) begin
							temp <= temp >> 1;
							counter <= 0;
						end
						if (temp == 16'h0000) begin
							state <= S3;
							counter <= 0;
						end
					end
				S3:
					begin
						counter <= counter + 1;
						if (counter == TIMER) begin
							temp <= (temp << 1) + 1;
							counter <= 0;
						end
						// Case flick
						if(flick == 1 && temp <= 16'h07FF) begin
							if(temp == 16'h003F || temp == 16'h07FF) begin
								counter <= 0;
								state <= S2;
							end
						end
						// Case no flick
						else begin
							if(temp == 16'h07FF) begin
								counter <= 0;
								state <= S4;
							end
						end
					end
				S4:
					begin
						counter <= counter + 1;
						if (counter == TIMER) begin
							temp <= temp >> 1;
							counter <= 0;
						end
						if (temp == 16'h001F) begin
							counter <= 0;
							state <= S5;
						end
					end
				S5:
					begin
						counter <= counter + 1;
						if(counter == TIMER) begin
							temp <= (temp << 1) + 1;
							counter <= 0;
						end
						// Case flick
						if(flick == 1 && temp <= 16'h07FF) begin
							if(temp == 16'h003F || temp == 16'h07FF) begin
								counter <= 0;
								state <= S4;
							end
						end
						// Case no flick
						else begin
							if(temp == 16'hFFFF) begin
								counter <= 0; 
								state <= S6;
							end
						end
					end
				S6:
					begin
						counter <= counter + 1;
						if(counter == TIMER) begin
							temp <= temp >> 1;
							counter <= 0;
						end
						if (temp == 16'h0000) begin
							counter <= 0;
							state <= S7;
						end
					end
				S7:
					begin
						temp <= 16'hFFFF;
						counter <= counter + 1;
						if(counter == TIMER) begin
							state <= S0;
							counter <= 0;
						end
					end
				endcase
			end
        end
    // Assign output
    assign lamps = temp;

endmodule
