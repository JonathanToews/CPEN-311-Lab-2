module addr_ctrl (clock_start, clk, key_start, finish_read, audio_in, audio_out, 
												addr_out, read_start, read direction, restart_read, reset_all);

input clock_start, clk, key_start, read_direction, restart_read, finish_read, reset_all;
input [7:0] audio_in;
output [20:0] addr_out;
output [15:0] audio_out;
output read_start;
/*
bit 0: lower_audio_enable;
bit 1: upper_audio_enable;
bit 2: read_start
bit 3-6: state bits
bit 7: future expansion

*/
localparam IDLE			= 8'b00000_0000;
localparam CONTINUE		= 8'b00001_0000;
localparam FLASH_LOWER	= 8'b00010_1000;
localparam INC_ADDR		= 8'b00011_0010;
localparam FLASH_UPPER	= 8'b00100_1000;
localparam DEC_ADDR		= 8'b00101_0100;
localparam OUTPUT			= 8'b00110_0001;
localparam INC_BY_2		= 8'b00111_0000;
localparam DEC_BY_2		= 8'b01000_0000;
localparam FINISH			= 8'b01001_0000;


assign read_start = state[3];
assign upper_audio_enable = state[2];
assign upper_audio_enable = state[1];
assign merge_audio_enable = state[0];

logic [7:0] next_state;
reg [7:0] state;
reg [7:0] upper_audio;
reg [7:0] lower_audio;

// audio registers
always_ff(posedge clk or negedge reset_all)
begin
	if(upper_audio_enable) upper_audio <= audio_in;
	else upper_audio <= upper_audio;
	
	if(lower_audio_enable) lower_audio <= audio_in;
	else lower_audio <= lower_audio;
	
	if(merge_audio_enable) audio_out <= {upper_audio, lower_audio};
	else audio_out <= audio_out;
end



always_ff(posedge clk or negedge reset_all)
begin
	if(reset_all) state <= FINISH;
	else state <= next_state;
end

always_comb
begin
	case(state)
		IDLE: 			if (key_start) 	next_state = CONTINUE;
							else					next_state = IDLE;
		CONTINUE: 		if (clock_start) 	next_state = FLASH_LOWER;
							else					next_state = CONTINUE;
		FLASH_LOWER: 	if (finish_read)	next_state = INC_ADDR;
							else					next_state = FLASH_LOWER;
		INC_ADDR:								next_state = FLASH_UPPER;
		
		FLASH_UPPER:	if (finish_read)	next_state = DEC_ADDR;
							else					next_state = FLASH_UPPER;
		DEC_ADDR:								next_state = OUTPUT;
		
		OUTPUT: if ()
		
end



endmodule
	