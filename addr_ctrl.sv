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
localparam IDLE			= 6'b00000_000;
localparam CONTINUE		= 6'b00001_000;
localparam FLASH_LOWER	= 6'b00010_100;
localparam INC_ADDR		= 6'b00011_001;
localparam FLASH_UPPER	= 6'b00100_100;
localparam DEC_ADDR		= 6'b00101_010;
localparam OUTPUT			= 6'b00110_000;
localparam INC_BY_2		= 6'b00111_000;
localparam DEC_BY_2		= 6'b01000_000;
localparam FINISH			= 6'b01001_000;


assign read_start = state[2];
assign upper_audio_enable = state[1];
assign upper_audio_enable = state[0];

logic [5:0] next_state;
reg [5:0] state;


always_ff(posedge clk or negedge reset_all)
begin
	audio_in_1 <= audio_in;



always_ff(posedge clk or negedge reset_all)
begin
	if(reset_all) state <= IDLE;
	else state <= next_state;
end

always_comb
begin




endmodule
	