`timescale 1ns / 1ps

module PWM(
    input clk,			//input clock
    input [7:0] pwm_in, //input from switches
    output reg pwm_out 	//output of PWM	
);

reg [7:0] new_pwm=0;
reg [7:0] pwm_ramp=0; 
always @(posedge clk) 
begin
    if (pwm_ramp==0)new_pwm <= pwm_in;
    pwm_ramp <= pwm_ramp + 1'b1;
    pwm_out <= (new_pwm > pwm_ramp);
end
	
endmodule
