module addr_ctrl (clock_start, clk, key_start, key_pause, finish_read, audio_in, audio_out, 
												addr_out, read_start, read_direction, restart_read, reset_all);

input clock_start, clk, key_start, key_pause, read_direction, restart_read, finish_read, reset_all;
input [7:0] audio_in;
output [20:0] addr_out;
output [15:0] audio_out;
output read_start;

// constant definitions
localparam ENDOF_FLASH 		= 21'h1FFFFF;
localparam STARTOF_FLASH 	= 21'h000000;
localparam FORWARD			= 1'b0;
localparam BACKWARD			= 1'b1;

/*
bit 0: audio_en;
bit 1: merge_audio_en;
bit 2: lower_audio_en;
bit 3: upper_audio_en;
bit 4: read_start
bit 5-8: state bits
bit 9: future expansion
*/
localparam IDLE			= 10'b00000_00000;
localparam CONTINUE		= 10'b00001_00001;
localparam FLASH_LOWER	= 10'b00010_10001;
localparam INC_ADDR		= 10'b00011_00101;
localparam FLASH_UPPER	= 10'b00100_10001;
localparam DEC_ADDR		= 10'b00101_01001;
localparam OUTPUT			= 10'b00110_00011;
localparam INC_BY_2		= 10'b00111_00001;
localparam DEC_BY_2		= 10'b01000_00001;
localparam FINISH			= 10'b01001_00001;



// state bit outputs
assign read_start 		= state[4];

// internal wires dependant on state bits
wire upper_audio_en, lower_audio_en, merge_audio_en, audio_en;

assign upper_audio_en 	= state[3];
assign upper_audio_en 	= state[2];
assign merge_audio_en 	= state[1];
assign audio_en			= state[0];

// state and audio registers
logic [9:0] next_state;
reg [9:0] state;
reg [7:0] upper_audio;
reg [7:0] lower_audio;

// audio registers
always_ff @(posedge clk or negedge reset_all)
begin
	if(read_direction)
	
	if(upper_audio_en) upper_audio <= audio_in;
	else upper_audio <= upper_audio;
	
	if(lower_audio_en) lower_audio <= audio_in;
	else lower_audio <= lower_audio;
	
	if(audio_en == 0) audio_out <= 0;
	else if(merge_audio_en) audio_out <= {upper_audio, lower_audio}; 
	else audio_out <= audio_out;
end


// state register
always_ff @(posedge clk or negedge reset_all)
begin
	if(reset_all) state <= FINISH;
	else state <= next_state;
end

// next state logic
always_comb
begin
	case(state)
		IDLE: 			if(key_start) 		next_state = CONTINUE;
							else					next_state = IDLE;
		CONTINUE: 		if(clock_start) 	next_state = FLASH_LOWER;
							else					next_state = CONTINUE;
		FLASH_LOWER: 	if(finish_read)	next_state = INC_ADDR;
							else					next_state = FLASH_LOWER;
		INC_ADDR:								next_state = FLASH_UPPER;
		FLASH_UPPER:	if(finish_read)	next_state = DEC_ADDR;
							else					next_state = FLASH_UPPER;
		DEC_ADDR:								next_state = OUTPUT;
		OUTPUT:			if((read_direction == FORWARD) & !(addr_out == (ENDOF_FLASH - 1'b1))) 	
													next_state = INC_BY_2;
							else if((read_direction == BACKWARD) & !(addr_out == STARTOF_FLASH))
													next_state = DEC_BY_2;
							else 					next_state = FINISH;
		INC_BY_2:		if(key_pause)		next_state = IDLE;
							else					next_state = CONTINUE;
		DEC_BY_2:		if(key_pause)		next_state = IDLE;
							else					next_state = CONTINUE;
		FINISH:									next_state = IDLE;	
		default:									next_state = IDLE;
	endcase
end



endmodule
	