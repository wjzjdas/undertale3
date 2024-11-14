//主要的移动逻辑以及绘制战斗图像 但是现在缺失一些boss图像 但个人认为需要第三周再说 但是现在只能移动一个像素 需要考虑如何移动心脏符号

// 23:27 更正：加入了心脏图标，但不知道逻辑正确与否

module moving_pixel_display(
    input CLOCK_50,
    input resetn,
	 input enable,
    input [3:0] KEY,               // 控制开关
    output reg [7:0] VGA_X,
    output reg [6:0] VGA_Y,
    output reg [2:0] color_to_display,
    output reg plot
);
    // 屏幕尺寸
    parameter SCREEN_WIDTH = 160;
    parameter SCREEN_HEIGHT = 120;

    // 定义X和Y的计数器
    reg [7:0] x_counter;
    reg [6:0] y_counter;

    // 移动像素的初始位置 mif文件的左上角
    reg [7:0] pixel_x;
    reg [6:0] pixel_y;


    // 初始化初始位置
    initial begin
        pixel_x = 70; // 将初始位置放在其中一个格子 该像素点为心形的左上角的点
        pixel_y = 80;
    
    end

    wire [2:0] mif_color;
    wire [2:0] xc_offset, yc_offset;//读取mif文件中的信息 颜色以及宽度

    object_mem obj_mem (
        .address({yc_offset, xc_offset}), 
        .clock(CLOCK_50), 
        .q(mif_color) // 输出当前偏移位置的颜色
    );

    // X和Y计数器，用于遍历屏幕
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            x_counter <= 0;
            y_counter <= 0;
        end else begin
            if (x_counter < SCREEN_WIDTH - 1) begin
                x_counter <= x_counter + 1;
            end else begin
                x_counter <= 0;
                if (y_counter < SCREEN_HEIGHT - 1)
                    y_counter <= y_counter + 1;
                else
                    y_counter <= 0;
            end
        end
    end

    // 移动像素逻辑
    always @(negedge KEY[0] or negedge KEY[1] or negedge KEY[2] or negedge KEY[3] or negedge resetn) begin //posedge KEY[0] or posedge KEY[1] or posedge KEY[2] or posedge KEY[3]
        if (~resetn) begin                          
            pixel_x <= 70;
            pixel_y <= 80;
        end else if (~KEY[0]) begin //sw1左移
            
                if (pixel_x > 69) //控制小图像不能超过格子的边沿
                    pixel_x <= pixel_x - 10;
                else
                    pixel_x <= 60; // 重置到左边格子
            
        end else if (~KEY[3]) begin //sw4下移
            
                if (pixel_y < 89) //控制小图像不能超过格子的边沿
                    pixel_y <= pixel_y + 10;
                else
                    pixel_y <= 90; // 重置到左边格子
            
        end else if (~KEY[2]) begin //sw3上移
            
                if (pixel_y > 69) //控制小图像不能超过格子的边沿
                    pixel_y <= pixel_y - 10;
                else
                    pixel_y <= 60; // 重置到上沿格子
            
        end else if (~KEY[1]) begin //sw2右移
            
                if (pixel_x < 89) //控制小图像不能超过格子的边沿
                    pixel_x <= pixel_x + 10;
                else
                    pixel_x <= 90; // 重置到左边格子
            
        end 
    end

    // 计算MIF文件的偏移量
    assign xc_offset = x_counter - pixel_x;
    assign yc_offset = y_counter - pixel_y;

    // 更新VGA坐标和颜色
    always @(posedge CLOCK_50) begin
        VGA_X <= x_counter;
        VGA_Y <= y_counter;
        plot <= 1'b1; // 启用绘图

        // 判断当前像素是否在8x8的图案范围内
        if ((x_counter >= pixel_x && x_counter < pixel_x + 8) &&
            (y_counter >= pixel_y && y_counter < pixel_y + 8)) begin
            color_to_display <= mif_color; // 读取MIF文件中的颜色 绘制心形
        end else if ((x_counter == 59 && y_counter>=59 && y_counter<= 99) || (x_counter == 69 && y_counter>=59 && y_counter<= 99) || (x_counter == 79 && y_counter>=59 && y_counter<= 99) || (x_counter == 89 && y_counter>=59 && y_counter<= 99) || (x_counter == 99 && y_counter>=59 && y_counter<= 99)||
            (y_counter == 59 && x_counter>=59 && x_counter<= 99) || (y_counter == 69 && x_counter>=59 && x_counter<= 99) || (y_counter == 79 && x_counter>=59 && x_counter<= 99) || (y_counter == 89 && x_counter>=59 && x_counter<= 99) || (y_counter == 99 && x_counter>=59 && x_counter<= 99))begin
            color_to_display <= 3'b111; // 白色的一个4*4网格
        end else begin
            color_to_display <= 3'b000; // 黑色背景
        end
    end
endmodule
