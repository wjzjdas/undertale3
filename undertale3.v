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
    
    bullet_generator bullet_gen_vert(
        .CLOCK_50(CLOCK_50),
        .resetn(~SW[6]),
        .enable(enable),
        .player_collision(vert), // This could be updated with proper collision logic BUT WE DIDNTTTTT (DID IT IN COLLISION_DETECTOR()
        .bullet_x(bullet_x),
        .bullet_y(bullet_y),
        .bullet_active(bullet_active),
        .bullet_color(bullet_color)
    );
	 	 // Bullet Generator for horizontal bullets
	wire [7:0] bullet_x_hor;
	wire [6:0] bullet_y_hor;
	wire bullet_active_hor;
	wire [2:0] bullet_color_hor;

	bullet_generator_hor bullet_gen_hor (
		 .CLOCK_50(CLOCK_50),
		 .resetn(~SW[6]),
		 .enable(enable),
		 .player_collision(hor),
		 .bullet_x(bullet_x_hor),
		 .bullet_y(bullet_y_hor),
		 .bullet_active(bullet_active_hor),
		 .bullet_color(bullet_color_hor)
	);
	 	 	 // Bullet Generator for horizontal bullets
	wire [7:0] bullet_x_hor_second;
	wire [6:0] bullet_y_hor_second;
	wire bullet_active_hor_second;
	wire [2:0] bullet_color_hor_second;

	bullet_generator_hor_second bullet_gen_hor_second (
		 .CLOCK_50(CLOCK_50),
		 .resetn(~SW[6]),
		 .enable(boss_health_length <= 30? enable:1'b0),
		 .player_collision(hor),
		 .bullet_x(bullet_x_hor_second),
		 .bullet_y(bullet_y_hor_second),
		 .bullet_active(bullet_active_hor_second),
		 .bullet_color(bullet_color_hor_second)
	);
	     // Bullet Generator instantiation
    wire [7:0] bullet_x_second;
    wire [6:0] bullet_y_second;
    wire bullet_active_second;
    wire [2:0] bullet_color_second;
    
    bullet_generator_second bullet_gen_vert_second(
        .CLOCK_50(CLOCK_50),
        .resetn(~SW[6]),
        .enable(boss_health_length <= 30? enable:1'b0),
        .player_collision(vert_second), // This could be updated with proper collision logic BUT WE DIDNTTTTT (DID IT IN COLLISION_DETECTOR()
        .bullet_x(bullet_x_second),
        .bullet_y(bullet_y_second),
        .bullet_active(bullet_active_second),
        .bullet_color(bullet_color_second)
    );
	 //TESTING FOR COLLISION WITH BOOOOOOOOOOONNNNNNNNNEEEEEEEEEEEEEESSSSSSSSSSSSS
	 wire vert;
	 collision_detector ccc1(
	 .CLOCK_50(CLOCK_50),
    .resetn(~SW[6]),
    .player_x(playerX),
    .player_y(playerY),
    .bullet_x(bullet_x),
    .bullet_y(bullet_y),
    .collision_detected(vert)
	 );
	 
	 	 wire vert_second;
	 collision_detector ccc4(
	 .CLOCK_50(CLOCK_50),
    .resetn(~SW[6]),
    .player_x(playerX),
    .player_y(playerY),
    .bullet_x(bullet_x_second),
    .bullet_y(bullet_y_second),
    .collision_detected(vert_second)
	 );
	 
	 wire hor;
	 collision_detector ccc2(
	 .CLOCK_50(CLOCK_50),
    .resetn(~SW[6]),
    .player_x(playerX),
    .player_y(playerY),
    .bullet_x(bullet_x_hor),
    .bullet_y(bullet_y_hor),
    .collision_detected(hor)
	 );
	 
	 	 wire hor_second;
	 collision_detector ccc3(
	 .CLOCK_50(CLOCK_50),
    .resetn(~SW[6]),
    .player_x(playerX),
    .player_y(playerY),
    .bullet_x(bullet_x_hor_second),
    .bullet_y(bullet_y_hor_second),
    .collision_detected(hor_second)
	 );
	 
	wire you_lose = hor||vert||hor_second||vert_second;
	
// Boss 血条模块实例化
    wire [5:0] boss_health_length;
	wire boss_defeated;
    boss_health_display boss_health (
        .CLOCK_50(CLOCK_50),
        .resetn(~SW[6]),
        .enable(enable),
        .you_lose(you_lose),
        .health_length(boss_health_length),
		  .boss_defeated(boss_defeated)
    );
	 
	// Draw the bullet as a BBBBBBOOOOONNNEEEEEE
	assign bone_active_vert = (((VGA_Y == bullet_y && VGA_X < bullet_x + 2) || (VGA_Y == bullet_y && VGA_X >= bullet_x + 6) ||
								(VGA_Y == bullet_y+3 && VGA_X < bullet_x + 2) || (VGA_Y == bullet_y+3 && VGA_X >= bullet_x + 6) ||
								(VGA_Y == bullet_y+1 && (VGA_X == bullet_x + 1 || VGA_X == bullet_x + 3 || VGA_X == bullet_x + 5)) || 
								(VGA_Y == bullet_y+2 && (VGA_X == bullet_x + 2 || VGA_X == bullet_x + 4 || VGA_X == bullet_x + 6)))
								&&VGA_X>=bullet_x&&VGA_X<bullet_x+8&&bullet_active);
								
	assign bone_active_hor = (((VGA_Y == bullet_y_hor && VGA_X < bullet_x_hor + 2) || (VGA_Y == bullet_y_hor && VGA_X >= bullet_x_hor + 6) ||
								(VGA_Y == bullet_y_hor+3 && VGA_X < bullet_x_hor + 2) || (VGA_Y == bullet_y_hor+3 && VGA_X >= bullet_x_hor + 6) ||
								(VGA_Y == bullet_y_hor+1 && (VGA_X == bullet_x_hor + 1 || VGA_X == bullet_x_hor + 3 || VGA_X == bullet_x_hor + 5)) || 
								(VGA_Y == bullet_y_hor+2 && (VGA_X == bullet_x_hor + 2 || VGA_X == bullet_x_hor + 4 || VGA_X == bullet_x_hor + 6)))
								&&VGA_X>=bullet_x_hor&&VGA_X<bullet_x_hor+8&&bullet_active_hor); //Im crazy
								
		assign bone_active_vert_second = (((VGA_Y == bullet_y_second && VGA_X < bullet_x_second + 2) || (VGA_Y == bullet_y_second && VGA_X >= bullet_x_second + 6) ||
								(VGA_Y == bullet_y_second+3 && VGA_X < bullet_x_second + 2) || (VGA_Y == bullet_y_second+3 && VGA_X >= bullet_x_second + 6) ||
								(VGA_Y == bullet_y_second+1 && (VGA_X == bullet_x_second + 1 || VGA_X == bullet_x_second + 3 || VGA_X == bullet_x_second + 5)) || 
								(VGA_Y == bullet_y_second+2 && (VGA_X == bullet_x_second + 2 || VGA_X == bullet_x_second + 4 || VGA_X == bullet_x_second + 6)))
								&&VGA_X>=bullet_x_second&&VGA_X<bullet_x_second+8&&bullet_active_second);
								
								
	assign bone_active_hor_second = (((VGA_Y == bullet_y_hor_second && VGA_X < bullet_x_hor_second + 2) || (VGA_Y == bullet_y_hor_second && VGA_X >= bullet_x_hor_second + 6) ||
								(VGA_Y == bullet_y_hor_second+3 && VGA_X < bullet_x_hor_second + 2) || (VGA_Y == bullet_y_hor_second+3 && VGA_X >= bullet_x_hor_second + 6) ||
								(VGA_Y == bullet_y_hor_second+1 && (VGA_X == bullet_x_hor_second + 1 || VGA_X == bullet_x_hor_second + 3 || VGA_X == bullet_x_hor_second + 5)) || 
								(VGA_Y == bullet_y_hor_second+2 && (VGA_X == bullet_x_hor_second + 2 || VGA_X == bullet_x_hor_second + 4 || VGA_X == bullet_x_hor_second + 6)))
								&&VGA_X>=bullet_x_hor_second&&VGA_X<bullet_x_hor_second+8&&bullet_active_hor_second); //Im crazy
								
	wire [2:0]battlebackground_colour;
		battlebackground b1 (
			.address(wire_address), 
			 .clock(CLOCK_50),
			 .q(battlebackground_colour) // Color from the MIF file
		);

	wire boss_health_active = (VGA_Y == 7'd109 && VGA_X >= 8'd55 && VGA_X < 8'd55 + boss_health_length);
   // wire [2:0]final_colour = (boss_health_active ? 3'b100 : (bone_active_vert ? bullet_color : (bone_active_hor ? bullet_color_hor : (color_to_display?color_to_display:battlebackground_colour))));
	 wire [2:0]final_colour = (boss_health_active ? 3'b100 : (bone_active_vert ? bullet_color : (bone_active_hor ? bullet_color_hor : (bone_active_vert_second ? bullet_color_second : (bone_active_hor_second ? bullet_color_hor_second : (color_to_display?color_to_display:battlebackground_colour))))));
	wire [2:0]end_colour;
		wire [14:0] wire_address;
		assign wire_address = 160 * VGA_Y + VGA_X;
		endend e1 (
			 .address(wire_address), 
			 .clock(CLOCK_50),
			 .q(end_colour) // Color from the MIF file
		);
		wire [2:0]win_colour;
		winner w1 (
			.address(wire_address), 
			 .clock(CLOCK_50),
			 .q(win_colour) // Color from the MIF file
		);
		

	
	 // VGA Adapter
	 vga_adapter VGA (
        .resetn(~SW[6]),                
        .clock(CLOCK_50),
        .colour(boss_defeated? win_colour:(you_lose ? end_colour: final_colour)),
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
