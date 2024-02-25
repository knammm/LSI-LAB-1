module boundFlasher_tb;
	reg clk;
	reg flick;
	wire [15:0] lamps;
	
	boundFlasher UUT (
		.clk(clk),
		.flick(flick),
		.lamps(lamps)
    );
    
	// Create clock
	always #1 clk = !clk;
	initial begin
		// Reset the thing
		clk = 0;
		flick = 0;
		#4;

		// Normal test
		flick = 1;
		#4;
		flick = 0;

		// Slide flick waveform test
		//@(UUT.state == 3) begin 
		//	#3500;
		//	flick = 1;
		//end
		//@(UUT.state == 2) flick = 0;

		// Myself flick waveform test
		@(UUT.state == 5) flick = 1;
		@(UUT.state == 4) flick = 0;
		@(UUT.state == 5) begin
			#2000; 
			flick = 1;
		end
		@(UUT.state == 4) flick = 0;

		#40000;

		$finish;
	end
	initial begin
		$recordfile ("waves");
		$recordvars ("depth=0", boundFlasher_tb);
	end 
endmodule
