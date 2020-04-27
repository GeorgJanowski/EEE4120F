module Debounce(
    input clk, 
    input button,
    output reg out //output reg output 
);

reg previous_state;
reg [21:0]Count; //assume count is null on FPGA configuration

//--------------------------------------------
always @(posedge clk) begin 
    // implement your logic here
    //------------------------------
    // activate every clock cycle
//    if (button != previous_state && Count == 0)
    // if state change and cooldown reached
//    begin
//        previous_state = !previous_state;   // update state
//        out = previous_state;               // update output
//    end else if (Count != 0)
//    // let cooldown occur
//    begin
//        Count <= Count + 1'b1;
//    end
    //------------------------------
    
    //previous_state <= Button;		// localise the reset signal
   if (button && button != previous_state && &Count) begin		// reset block
     out <= 1'b1;					// reset the output to 1
	 Count <= 0;
	 previous_state <= 1;
  end 
  else if (button && button != previous_state) begin
	 out <= 1'b0;
	 Count <= Count + 1'b1;
  end 
  else begin
	 out <= 1'b0;
	 previous_state <= button;
  end
end 


endmodule

