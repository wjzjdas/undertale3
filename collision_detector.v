module collision_detector(
    input CLOCK_50,
    input resetn,
    input [7:0] player_x,
    input [6:0] player_y,
    input [7:0] bullet_x,
    input [6:0] bullet_y,
    output reg collision_detected
);

    // 定义玩家和子弹的宽度和高度
    parameter PLAYER_WIDTH = 8;
    parameter PLAYER_HEIGHT = 8;
    parameter BULLET_WIDTH = 8;
    parameter BULLET_HEIGHT = 4;

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            collision_detected <= 1'b0;
        end else begin
            // 碰撞检测逻辑：判断两个矩形是否有重叠区域
            if ((player_x < bullet_x + BULLET_WIDTH) && (player_x + PLAYER_WIDTH > bullet_x) &&
                (player_y < bullet_y + BULLET_HEIGHT) && (player_y + PLAYER_HEIGHT > bullet_y)) begin
                collision_detected <= 1'b1;
            end 
        end
    end

endmodule