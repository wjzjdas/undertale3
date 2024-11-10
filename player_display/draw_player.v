module draw_player(
    input [7:0] x,               // Center X of the heart
    input [6:0] y,               // Center Y of the heart
    input [7:0] current_x,       // Current pixel X position from VGA
    input [6:0] current_y,       // Current pixel Y position from VGA
    output reg [7:0] red,        // Red color component
    output reg [7:0] green,      // Green color component
    output reg [7:0] blue        // Blue color component
);

    // Heart shape pattern in a 5x5 grid
    reg [4:0] heart_shape [4:0];

    initial begin
        heart_shape[0] = 5'b01010;
        heart_shape[1] = 5'b11111;
        heart_shape[2] = 5'b11111;
        heart_shape[3] = 5'b01110;
        heart_shape[4] = 5'b00100;
    end

    wire [3:0] dx = current_x - x + 2;
    wire [3:0] dy = current_y - y + 2;

    always @(*) begin
        if (dx >= 0 && dx < 5 && dy >= 0 && dy < 5 && heart_shape[dy][dx] == 1'b1) begin
            red = 8'hFF;    // Red color for heart pixels
            green = 8'h00;
            blue = 8'h00;
        end else begin
            red = 8'h00;    // Background color
            green = 8'h00;
            blue = 8'h00;
        end
    end
endmodule
