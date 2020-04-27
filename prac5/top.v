`timescale 1ns / 1ps

module top(
    // These signal names are for the nexys A7. 
    // Check your constraint file to get the right names
    input  clock,
    input BTNL,
    input [7:0] switches,
    output AUD_PWM, 
    output AUD_SD,
    output [2:0] leds
    );
    
    // Toggle arpeggiator enabled/disabled
    wire arp_switch;
    reg arp_state;
    Debounce change_state (clock, BTNL, arp_switch); // ensure your button choice is correct
    
    // Memory IO
    reg ena = 1;
    reg wea = 0;
    reg [7:0] addra=0;
    reg [10:0] dina=0; //We're not putting data in, so we can leave this unassigned
    wire [10:0] douta;
    
    //------------------------
    reg arp = 1; // 1: arpegiator; 0: constant tone;
    //------------------------
    
    // Instantiate block memory here
    // Copy from the instantiation template and change signal names to the ones under "MemoryIO"
    //------------------------
    blk_mem_gen_0 bram (
        .clka(clock),
        .ena(ena),
        .wea(wea), 
        .addra(addra), 
        .dina(dina), 
        .douta(douta)
    );
    //------------------------
    
    //PWM Out - this gets tied to the BRAM
    reg [10:0] PWM;
    
    // Instantiate the PWM module
    // PWM should take in the clock, the data from memory
    // PWM should output to AUD_PWM (or whatever the constraints file uses for the audio out.
    //------------------------
    pwm_module pwmm(
        .clk(clock),
        .PWM_in(PWM),
        .PWM_out(AUD_PWM)
    );
    //------------------------

    //------------------------
    reg[12:0] f_note; // stores number of clock cycles for current note
    //------------------------
    
    // Devide our clock down
    reg [12:0] clkdiv = 0;
    
    // keep track of variables for implementation
    reg [26:0] note_switch = 0;
    reg [1:0] note = 2;
    reg [8:0] f_base = 0;
    
always @(posedge clock) begin   
    //PWM <= douta ; // tie memory output to the PWM input
    
    //------------------------
    PWM <= douta >> 7; // reduce volume
    //------------------------
    
    f_base[8:0] = 746 + switches[7:0]; // get the "base" frequency to work from 
    
    // Loop to change the output note IF we're in the arp state
    //------------------------
    // if arp_switch is pressed toggle arp_state
    if (arp_switch) begin
        arp_state <= !arp_state;
    end
    
    if (arp_state) begin
        note_switch <= note_switch + 1; // increment note_switch counter
        if (note_switch == 50000000) begin
            note <= note + 1; // increment note
            note_switch <= 0;
        end
    end else begin
        note_switch <= 0;
        note <= 0;
    end
    //------------------------

    // FSM to switch between notes, otherwise just output the base note.
    //------------------------
    // calculate period for specific note in major chord
    if (note == 0) begin
        f_note <= f_base; // tonic
    end else if (note == 1) begin
        f_note <= f_base * 4 / 5; // major third
    end else if (note == 2) begin
        f_note <= f_base * 2 / 3; // fifth
    end else if (note == 3) begin
        f_note <= f_base >> 1; // octave
    end
    
    // increment clkdiv counter
    clkdiv <= clkdiv + 1;
    
    // increment address to get next sine wave value
    if (clkdiv == f_note) begin
        clkdiv <= 0; // reset clkdiv counter
        addra <= addra + 1; // increment address
    end
    //------------------------
    
end


assign AUD_SD = 1'b1;  // Enable audio out
assign leds[1:0] = note[1:0]; // Tie FRM state to LEDs so we can see and hear changes


endmodule
