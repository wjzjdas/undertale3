module undertale3(
    CLOCK_50, SW, KEY,
    VGA_R, VGA_G, VGA_B,
    VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);
    input CLOCK_50;
    input [7:0] SW;
    input [3:0] KEY;
   
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_HS;
    output VGA_VS;
    output VGA_BLANK_N;
    output VGA_SYNC_N;
    output VGA_CLK;
	 
	 wire [7:0] VGA_X;
	 wire [6:0] VGA_Y;
	 wire [2:0] color_to_display;
	 wire plot;
	 
	 wire enable;
	 wire [4:0] controlkey;
	 
	 assign controlkey [3:0] = KEY[3:0];
	 assign enable = SW[5];
	 
	 
   moving_pixel_display move1 (CLOCK_50,
    ~SW[6],
	 enable,
    controlkey,               // 控制开关
	 VGA_X,
    VGA_Y,
    color_to_display,
    plot);
	
    // VGA Adapter
    vga_adapter VGA (
        .resetn(~SW[6]),                
        .clock(CLOCK_50),
        .colour(color_to_display),
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
        .VGA_CLK(VGA_CLK));
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
endmodule

