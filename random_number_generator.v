module random_number_generator(
    input CLOCK_50,
    input resetn,
    output reg [1:0] random_num
);

    reg [15:0] lfsr;
    reg feedback;

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            lfsr <= 16'hACE1; // Seed value for LFSR
            random_num <= 2'b00;
        end else begin
            feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];
            lfsr <= {lfsr[14:0], feedback};
            random_num <= lfsr[1:0]; // Take the lower 2 bits as the random number (0-3)
        end
    end

endmodule