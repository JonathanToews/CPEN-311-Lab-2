module flash_read_fsm (clk, start, finish, in_data, out_data, out_WE, out_RST, out_OE, out_CE, in_addr, out_addr, reset_all);

input start, reset_all, clk;
output out_WE, out_RST, out_OE, out_CE;
input [7:0] in_data;
input [20:0] in_addr;
output [20:0] out_addr;
output [7:0] out_data;
output finish;

reg [9:0] state;
reg [7:0] data_reg;
logic [9:0] next_state;
logic strobe_data_reg;

localparam idle 			= 10'b0001_011110;
localparam enable_chip	= 10'b0010_011100;
localparam enable_output= 10'b0011_011000;
localparam wait_read_1	= 10'b0100_011000;
localparam wait_read_2	= 10'b0101_011000;
localparam wait_read_3	= 10'b0110_011000;
localparam wait_read_4	= 10'b0111_011000;
localparam wait_read_5	= 10'b1000_011000;
localparam flash_read	= 10'b1001_111000;
localparam finished		= 10'b1010_011101;

assign strobe_data_reg 	= state[5];
assign out_WE				= state[4];
assign out_RST 			= state[3];
assign out_OE				= state[2];
assign out_CE				= state[1];
assign finish				= state[0];

assign out_addr = in_addr;
assign out_data = data_reg;


always_ff @(posedge strobe_data_reg or negedge reset_all)
begin
		if(~reset_all) data_reg <= 8'b0;
		else data_reg <= in_data;
end 
			


always_ff @(posedge clk or negedge reset_all)
begin
		if(~reset_all) state <= idle;
		else state <= next_state;	
end

always_comb
begin
	case(state)
			idle:				if(start) next_state = enable_chip;
								else next_state = idle;
			enable_chip:	next_state = enable_output;
			enable_output:	next_state = wait_read_1;
			wait_read_1:	next_state = wait_read_2;
			wait_read_2:	next_state = wait_read_3;
			wait_read_3:	next_state = wait_read_4;
			wait_read_4:	next_state = wait_read_5;
			wait_read_5:	next_state = flash_read;
			flash_read:		next_state = finished;
			finished:		next_state = idle;
			default:			next_state = idle;
	endcase
end

endmodule

			
			
