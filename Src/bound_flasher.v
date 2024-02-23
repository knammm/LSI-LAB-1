`timescale 1ns / 1ps

module boundFlasher( 
    input clk, flick,
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
    parameter S8 = 8;
    parameter S9 = 9;
    parameter S10 = 10;
	
	// Internal signals
    parameter TIMER = 200;
    integer counter = 0;
    reg [3:0] state = S0;
	reg [15:0] temp;

    // State machine
    always @(posedge clk) begin
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
                    if (temp == 16'h003F) begin
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
                    if (temp == 16'h003F) begin
                        counter <= 0;
                        if(flick == 1) state <= S2;
                        else state <= S4;
                    end
                end
            S4:
                begin
                    counter <= counter + 1;
                    if (counter == TIMER) begin
                        temp <= (temp << 1) + 1;
                        counter <= 0;
                    end
                    if (temp == 16'h07FF) begin
                        counter <= 0;
                        if(flick == 1) state <= S2;
                        else state <= S5;
                    end
                end
            S5:
                begin
                    counter <= counter + 1;
                    if (counter == TIMER) begin
                        temp <= temp >> 1;
                        counter <= 0;
                    end
                    if (temp == 16'h001F) begin
                        counter <= 0;
                        state <= S6;
                    end
                end
            S6:
                begin
                    counter <= counter + 1;
                    if (counter == TIMER) begin
                        temp <= (temp << 1) + 1;
                        counter <= 0;
                    end
                    if (temp == 16'h003F) begin
                        counter <= 0;
                        if(flick == 1) state <= S5;
                        else state <= S7;
                    end
                end
            S7:
                begin
                    counter <= counter + 1;
                    if (counter == TIMER) begin
                        temp <= (temp << 1) + 1;
                        counter <= 0;
                    end
                    if (temp == 16'h07FF) begin
                        counter <= 0;
                        if(flick == 1) state <= S5;
                        else state <= S8;
                    end
                end
            S8:
                begin
                    counter <= counter + 1;
                    if (counter == TIMER) begin
                        temp <= (temp << 1) + 1;
                        counter <= 0;
                    end
                    if (temp == 16'hFFFF) begin
                        counter <= 0;
                        state <= S9;
                    end
                end
            S9:
                begin
                    counter <= counter + 1;
                    if (counter == TIMER) begin
                        temp <= temp >> 1;
                        counter <= 0;
                    end
                    if (temp == 16'h0000) begin
                        counter <= 0;
                        state <= S10;
                    end
                end
            S10:
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
    // Assign output
    assign lamps = temp;

endmodule

