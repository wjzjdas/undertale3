module undertale3(CLOCK_50, SW, KEY, HEX3, HEX2, HEX1, HEX0,
                VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
    
    input CLOCK_50;    
    input [7:0] SW;          // Switches for controlling color (R, G, B)
    input [3:0] KEY;         // Keypad buttons for controlling X, Y positions
    output [6:0] HEX3, HEX2, HEX1, HEX0;  // 7-segment displays for coordinates
    output [7:0] VGA_R;      // VGA red signal
    output [7:0] VGA_G;      // VGA green signal
    output [7:0] VGA_B;      // VGA blue signal
    output VGA_HS;           // VGA horizontal sync signal
    output VGA_VS;           // VGA vertical sync signal
    output VGA_BLANK_N;      // VGA blanking signal
    output VGA_SYNC_N;       // VGA sync signal
    output VGA_CLK;          // VGA clock signal
    
    wire [2:0] colour;       // Color input based on switches
    wire [7:0] X;            // X-coordinate
    wire [6:0] Y;            // Y-coordinate
    
    // Color logic from switches (SW[2:0])
    assign colour = SW[2:0];

    // Registering X and Y values
    regn UY (SW[6:0], KEY[0], ~KEY[1], CLOCK_50, Y);  // Register for Y-coordinate
    regn UX (SW[7:0], KEY[0], ~KEY[2], CLOCK_50, X);  // Register for X-coordinate
	defparam UY.n = 7;
	
    // 7-segment displays to show X and Y coordinates
    hex7seg H3 (X[7:4], HEX3);  // High 4 bits of X
    hex7seg H2 (X[3:0], HEX2);  // Low 4 bits of X
    hex7seg H1 ({1'b0, Y[6:4]}, HEX1);  // High 3 bits of Y
    hex7seg H0 (Y[3:0], HEX0);  // Low 4 bits of Y

    // VGA adapter instantiation
    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .colour(colour),
        .x(X),
        .y(Y),
        .plot(~KEY[3]),  // Plot signal from KEY[3] (active low)
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

// Register Module (For storing X and Y coordinates)
module regn(R, Resetn, E, Clock, Q);
    parameter n = 8;
    input [n-1:0] R;
    input Resetn, E, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (E)
            Q <= R;
endmodule


// 7-Segment Display Decoder (to convert hex to 7-segment display format)
module hex7seg (hex, display);
    input [3:0] hex;     // 4-bit hex input
    output [6:0] display;  // 7-segment display output

    reg [6:0] display;  // Register to hold the 7-segment display pattern

    always @ (hex)
        case (hex)
            4'h0: display = 7'b1000000;
            4'h1: display = 7'b1111001;
            4'h2: display = 7'b0100100;
            4'h3: display = 7'b0110000;
            4'h4: display = 7'b0011001;
            4'h5: display = 7'b0010010;
            4'h6: display = 7'b0000010;
            4'h7: display = 7'b1111000;
            4'h8: display = 7'b0000000;
            4'h9: display = 7'b0011000;
            4'hA: display = 7'b0001000;
            4'hB: display = 7'b0000011;
            4'hC: display = 7'b1000110;
            4'hD: display = 7'b0100001;
            4'hE: display = 7'b0000110;
            4'hF: display = 7'b0001110;
        endcase
endmodule
