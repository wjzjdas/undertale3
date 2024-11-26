module boss_health_display(
    input CLOCK_50,
    input resetn,
    input enable,
    input you_lose,
    output reg [5:0] health_length,
	 output reg boss_defeated
);
    // 血条初始长度
    parameter INITIAL_HEALTH = 6'd60;

    reg [31:0] counter;

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            health_length <= INITIAL_HEALTH; // 初始化血条长度
            counter <= 32'd0;
				boss_defeated = 1'b0;
        end else if (enable && !you_lose) begin
            if (counter >= 32'd50_000_000) begin // 每隔1秒减少一次血量
                counter <= 32'd0;
                if (health_length > 0) begin
                    health_length <= health_length - 1;
                end
					 if (health_length == 1) begin
							boss_defeated = 1'b1;
					end
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
