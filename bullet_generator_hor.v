module bullet_generator_hor(
    input CLOCK_50,
    input resetn,
    input enable,
    input player_collision,
    output reg [7:0] bullet_x,
    output reg [6:0] bullet_y,
    output reg bullet_active,
    output reg [2:0] bullet_color
);
    // Parameters for screen size
    parameter SCREEN_WIDTH = 160;
    parameter SCREEN_HEIGHT = 120;
    parameter BULLET_SPEED = 2;

    // Bullet properties
    reg [19:0] spawn_counter;
	 
    reg [19:0] bullet_move_counter;
	 
    wire [1:0] random_number;

    // Instantiate LFSR module
    random_number_generator lfsr_instance (
        .CLOCK_50(CLOCK_50),
        .resetn(resetn),
        .random_num(random_number)
    );
    // Random spawn position for bullet
    wire [6:0] random_y;
    assign random_y = (spawn_counter[6:0] % SCREEN_HEIGHT); // Use part of the counter as a pseudo-random number

    // Bullet generation and movement
    always @(posedge CLOCK_50 or negedge resetn) begin
    if (!resetn) begin
        spawn_counter <= 20'd0;
        bullet_y <= 7'd71; // Fixed starting y position for bullet
        bullet_x <= 8'd0;
        bullet_active <= 1'b0;
    end else if (enable && !player_collision) begin
        // Spawn bullets at intervals
        if (spawn_counter >= 20'd25_000_000) begin // Adjust spawn rate to approximately every 0.5 seconds
            spawn_counter <= 20'd0;
            if (!bullet_active) begin

                bullet_x <= 8'd0; // Spawn from left of the screen

					if (random_number == 3) begin
								bullet_y <= 8'd71;
					end else if (random_number == 1) begin
								bullet_y <= 8'd61;
					end else if (random_number == 0) begin
								bullet_y <= 8'd81;
					end else if (random_number == 2) begin
								bullet_y <= 8'd91;
					end 
                bullet_active <= 1'b1;
            end
        end else begin
            spawn_counter <= spawn_counter + 1;
        end

        // Bullet movement
        if (bullet_active) begin
            if (bullet_move_counter >= 20'd5_000_000) begin // Move bullet every 0.1 second (10 pixels per second)
                bullet_move_counter <= 20'd0;
                if (bullet_x < SCREEN_WIDTH - 1) begin
                    bullet_x <= bullet_x + 1; // Move bullet down by 1 pixel
                end else begin
                    bullet_active <= 1'b0; // Deactivate bullet when it reaches the bottom
	
                end
            end else begin
                bullet_move_counter <= bullet_move_counter + 1;
            end
        end
    end else begin
        // Reset if player is hit or disabled
        bullet_active <= 1'b0;
        bullet_x <= 8'd0;
    end
end

    // Bullet color
    always @(posedge CLOCK_50 or negedge resetn) begin
    if (!resetn) begin
        bullet_color <= 3'b001; // Initial color, e.g., blue
    end else if (bullet_active) begin
        bullet_color <= 3'b001; // Set color to represent a bone-like shape, e.g., yellow
    end else begin
        bullet_color <= 3'b111; // Set to black when not active
    end
end

endmodule

