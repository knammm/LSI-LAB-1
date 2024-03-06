cd ~/vlsi/

# Declare variables
folder_name="2153599_cp"

# Create directory
mkdir -p $folder_name
mkdir -p $folder_name/work
mkdir -p $folder_name/output
mkdir -p $folder_name/output/design
mkdir -p $folder_name/output/doc
mkdir -p $folder_name/work/lec_env
mkdir -p $folder_name/work/simulation_env
mkdir -p $folder_name/work/synthesis_env

cd $folder_name/work/simulation_env/

# Create bound_flasher module
touch bound_flasher.v
cat <<EOT > bound_flasher.v
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
EOT

# Create test_bench
touch test_bench.v
echo 'module boundFlasher_tb;
	reg clk;
	reg flick;
	reg rst;
	wire [15:0] lamps;
	
	boundFlasher UUT (
		.clk(clk),
		.flick(flick),
		.rst(rst),
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
		
		// Rst signal test
		#500
		rst = 1;
		#20;
		rst = 0;
		flick = 1;
		#20;
		flick = 0;
		
		#40000;

		$finish;
	end
	initial begin
		$recordfile("waves");
		$recordvars("depth=0", boundFlasher_tb);
	end 
endmodule' > test_bench.v

# Create go_sim
touch go_sim.sh
cat <<EOT > go_sim.sh
#!/bin/bash -f

cd /home/share_file/cadence/
source add_path
source add_license
cd -

xrun -access rw -licqueue -64BIT -l run.log bound_flasher.v test_bench.v
EOT
chmod +x go_sim.sh

# Create go_gui
touch go_gui.sh
cat <<EOT > go_gui.sh
#!/bin/bash

cd /home/share_file/cadence/
source add_path
source add_license
cd -

simvision -64 &
EOT

chmod +x go_gui.sh

# Execute shell scripts
./go_sim.sh
./go_gui.sh
