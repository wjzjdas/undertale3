module player_position(    
    input clk,
    input reset,
    input up,       
    input down,      
    input left,          
    input right,
    input [7:0] grid_starting_x,
    input [6:0] grid_starting_y,
    input [4:0] grid_size,       
    output reg [7:0] x,   
    output reg [6:0] y   
    );

    initial begin //开始位置
        x = grid_starting_x + (grid_size * 2);
        y = grid_starting_y + (grid_size * 2);
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x = grid_starting_x + (grid_size * 2);
            y = grid_starting_y + (grid_size * 2);
        end else begin
            if (up && y != (grid_starting_y))
                y <= y - grid_size;

            if (down && y != (grid_starting_y + (grid_size * 4)))
                y <= y + grid_size;

            if (left && x != (grid_starting_x))
                x <= x - grid_size;

            if (right && x != (grid_starting_x + (grid_size * 4)))
                x <= x + grid_size;
        end
    end
endmodule