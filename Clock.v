`timescale 1ns / 1ps



module WallClock(
	//inputs - these will depend on your board's constraint files
    input clock,            // clock, frequency might need to be changed
    input minutes_phys,     // physical button to increment minutes
    input hours_phys,       // physical button to increment hours
    input reset,            // physical button for reset
    input [7:0]switches,    // switches used to dim display
    
	//outputs - these will depend on your board's constraint files
	output [5:0]leds,       // leds
	output reg[7:0] sseg,   // seven segment display
	output reg[7:0] sseg_an // 
);

	//Add the reset
    wire Reset_wire;
    reg Reset;
    Delay_Reset delay_reset(.Clk(clock), .BTNS(reset), .Reset(Reset_wire));

	//Add and debounce the buttons
	wire MButton;
	wire HButton;
	
	// Instantiate Debounce modules here
	Debounce debounce_mins(.clk(clock), .button(minutes_phys), .out(MButton));
	Debounce debounce_hrs(.clk(clock), .button(hours_phys), .out(HButton));
	
	// registers for storing the time
    reg [3:0]hours1=4'd0;
	reg [3:0]hours2=4'd0;
	reg [3:0]mins1=4'd0;
	reg [3:0]mins2=4'd0;
    
	//Initialize seven segment
	// You will need to change some signals depending on you constraints
	wire[3:0] sseg_an_wire;
	wire[7:0] sseg_wire;
	SS_Driver SS_Driver1(
		.Clk(clock), .Reset(Reset), //<clock_signal>, <reset_signal>,
		.BCD0(mins2), .BCD1(mins1), .BCD2(hours2), .BCD3(hours1), // Use temporary test values before adding hours2, hours1, mins2, mins1
		.SegmentDrivers(sseg_an_wire),
		.SevenSegment(sseg_wire)
	);
	
	// Clock timer
	reg [24:0]clkdiv = 0; // change to change length of a 'second'
	reg [5:0]seconds = 0;
	
	// Initialise PWM module
	wire pwm_out;
	PWM pwm(
	   .clk(clock),
	   .pwm_in(switches),
	   .pwm_out(pwm_out)
	);
	
	//The main logic
	always @(posedge clock) begin
		// implement your logic here
        Reset <= !Reset_wire; // reset active low
		
		sseg_an <= {sseg_an_wire, 4'b1111};
		
		if (pwm_out) begin
		  sseg <= sseg_wire;
		end else begin
		  sseg <= 8'b11111111;
		end
		
		// reset everything to default
		if (Reset) begin
		  clkdiv = 0;
	      seconds = 0;
          hours1=4'd0;
          hours2=4'd0;
          mins1=4'd0;
          mins2=4'd0;
		end
		
		// minute increment button pushed
		if (MButton) begin
		  if (mins2 == 9) begin
		      if (mins1 == 5) begin
		        mins1 <= 0;
		      end else begin
		        mins1 <= mins1 + 1;
		      end
		      mins2 <= 0;
		    end else begin
		      mins2 <= mins2 + 1;
		    end
		end
		
		// hour iincrement button pushed
		if (HButton) begin
		    // end of day
            if (hours1 == 2 && hours2 == 3) begin
              hours2 <= 0;
              hours1 <= 0;
            end
            
            // end of 10 hours
            else if (hours2 == 9) begin
              hours1 <= hours1 + 1;
              hours2 <= 0;
            end
            
            // end of hour
            else begin
              hours2 <= hours2 + 1;
            end
        end
            
            
            // increment clock
		clkdiv <= clkdiv + 1;
		if (clkdiv == 0) begin
		  if (seconds == 59) begin
		    if (mins2 == 9) begin
		      if (mins1 == 5) begin
		        
		        // end of day
		        if (hours1 == 2 && hours2 == 3) begin
		          hours2 <= 0;
		          hours1 <= 0;
		        end
		        
		        // end of 10 hours
		        else if (hours2 == 9) begin
		          hours1 <= hours1 + 1;
		          hours2 <= 0;
		        end
		        
		        // end of hour
		        else begin
		          hours2 <= hours2 + 1;
		        end
		        
		        mins1 <= 0;
		      end else begin
		        mins1 <= mins1 + 1;
		      end
		      mins2 <= 0;
		    end else begin
		      mins2 <= mins2 + 1;
		    end
		    seconds <= 0;
		  end else begin
		    seconds <= seconds + 1;
		  end
	    end
		
		//---------------------------
	end
	
	assign leds[5:0] = seconds[5:0];
	
endmodule  
