
module undertale3(
    CLOCK_50, SW, KEY, PS2_CLK, PS2_DAT,
	 HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
    VGA_R, VGA_G, VGA_B,
    VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, LEDR
);
    input CLOCK_50;
    input [7:0] SW;
    input [3:0] KEY;
	 
    output[6:0]HEX0;
	 output[6:0]HEX1;
	 output[6:0]HEX2;
	 output[6:0]HEX3;
	 output[6:0]HEX4;
	 output[6:0]HEX5;
	 output[6:0]HEX6;
	 output[6:0]HEX7;
	 output [1:0] LEDR;
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_HS;
    output VGA_VS;
    output VGA_BLANK_N;
    output VGA_SYNC_N;
    output VGA_CLK;
	 inout  PS2_CLK;
	 inout  PS2_DAT;
	 
	 wire [7:0] VGA_X;
	 wire [6:0] VGA_Y;
	 wire [2:0] color_to_display;
	 wire plot;
	 
	 wire enable;
	 wire [3:0] controlkey;
	 wire [7:0] ps2_key_data;
	 wire ps2_key_pressed;
	 reg enable_plus;
	 
	 
	 assign controlkey [3:0] = KEY[3:0];
	 assign enable = SW[5];
	 /*

	 */
	 // Instantiation Displayer function SOHAWWWWD >~<
	 PS2_Demo m11(
	CLOCK_50,
	KEY,
	PS2_CLK,
	PS2_DAT,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	
	ps2_key_pressed,
	ps2_key_data
	);
	
	//Player movement Achieve
	
	wire [7:0] playerX;
	wire [6:0] playerY;
	
   moving_pixel_display move1 (
        .CLOCK_50(CLOCK_50),
        .resetn(~SW[6]),
        .enable(enable),
        .KEY(controlkey), // 控制开关
        .ps2_key_data(ps2_key_data),
        .ps2_key_pressed(ps2_key_pressed),
        .VGA_X(VGA_X),
        .VGA_Y(VGA_Y),
        .color_to_display(color_to_display),
        .plot(plot),
		  .pixel_x(playerX),
		  .pixel_y(playerY)
    );

    // Bullet Generator instantiation
    wire [7:0] bullet_x;
    wire [6:0] bullet_y;
    wire bullet_active;
    wire [2:0] bullet_color;
    
    bullet_generator bullet_gen(
        .CLOCK_50(CLOCK_50),
        .resetn(~SW[6]),
        .enable(enable),
        .player_collision(1'b0), // This could be updated with proper collision logic BUT WE DIDNTTTTT (DID IT IN COLLISION_DETECTOR()
        .bullet_x(bullet_x),
        .bullet_y(bullet_y),
        .bullet_active(bullet_active),
        .bullet_color(bullet_color)
    );
	 
	 //TESTING FOR COLLISION WITH BOOOOOOOOOOONNNNNNNNNEEEEEEEEEEEEEESSSSSSSSSSSSS
	 wire you_lose;
	 collision_detector(.CLOCK_50(CLOCK_50),
    .resetn(~SW[6]),
    .player_x(playerX),
    .player_y(playerY),
    .bullet_x(bullet_x),
    .bullet_y(bullet_y),
    .collision_detected(you_lose)
	 );
	 assign LEDR[0] = you_lose;
	

	// Draw the bullet as a BBBBBBOOOOONNNEEEEEEE
	assign bone_active = ((VGA_Y == bullet_y && VGA_X < bullet_x + 2) || (VGA_Y == bullet_y && VGA_X >= bullet_x + 6) ||
								(VGA_Y == bullet_y+3 && VGA_X < bullet_x + 2) || (VGA_Y == bullet_y+3 && VGA_X >= bullet_x + 6) ||
								(VGA_Y == bullet_y+1 && (VGA_X == bullet_x + 1 || VGA_X == bullet_x + 3 || VGA_X == bullet_x + 5)) || 
								(VGA_Y == bullet_y+2 && (VGA_X == bullet_x + 2 || VGA_X == bullet_x + 4 || VGA_X == bullet_x + 6)))
								&&VGA_X>=bullet_x&&VGA_X<bullet_x+8&&
								bullet_active;
		
		wire [2:0]end_colour;
		mif_reader nb(
			 .x(VGA_X),  // X coordinate
			 .y(VGA_Y),  // Y coordinate
			 .clock(CLOCK_50),
			 .color(end_colour) // Color from the MIF file
		);
		
	 // VGA Adapter
	 vga_adapter VGA (
        .resetn(~SW[6]),                
        .clock(CLOCK_50),
        .colour(you_lose?end_colour:((bone_active) ? bullet_color : color_to_display)),
        .x(VGA_X),
        .y(VGA_Y),
        .plot(plot),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
 
endmodule