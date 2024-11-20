module moving_pixel_display(
    input CLOCK_50,
    input resetn,
    input enable,
    input [3:0] KEY,               // 控制开关，低电平有效
	 input [7:0] ps2_key_data,
	 input ps2_key_pressed,                                                                                                                                                                                                                                                                             
    output reg [7:0] VGA_X,
    output reg [6:0] VGA_Y,
    output reg [2:0] color_to_display,
    output reg plot,
	 output reg [7:0] pixel_x,
    output reg [6:0] pixel_y
);
    // 屏幕尺寸
    parameter SCREEN_WIDTH = 160;
    parameter SCREEN_HEIGHT = 120;

    // 定义X和Y的计数器
    reg [7:0] x_counter;
    reg [6:0] y_counter;


    // 初始化初始位置
    initial begin
        pixel_x = 60; // 将初始位置放在其中一个格子 该像素点为心形的左上角的点
        pixel_y = 60;
    end

    wire [2:0] mif_color;
    wire [2:0] xc_offset, yc_offset; // 读取mif文件中的信息 颜色以及宽度

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
	 
	
	 // 按键状态寄存器
    reg w_key_down;
    reg a_key_down;
    reg s_key_down;
    reg d_key_down;

    // 键盘扫描码处理
    reg [1:0] recv_state;
    reg [7:0] last_ps2_data;
	 
	 reg [7:0] ps2_key_data_sync1, ps2_key_data_sync2;
	reg ps2_key_pressed_sync1, ps2_key_pressed_sync2;

	always @(posedge CLOCK_50 or negedge resetn) begin
		 if (!resetn) begin
			  ps2_key_data_sync1 <= 8'h00;
			  ps2_key_data_sync2 <= 8'h00;
			  ps2_key_pressed_sync1 <= 1'b0;
			  ps2_key_pressed_sync2 <= 1'b0;
		 end else begin
			  ps2_key_data_sync1 <= ps2_key_data; // 第一级同步
			  ps2_key_data_sync2 <= ps2_key_data_sync1; // 第二级同步
			  ps2_key_pressed_sync1 <= ps2_key_pressed; // 同步按键按下信号
			  ps2_key_pressed_sync2 <= ps2_key_pressed_sync1; // 第二级同步
		 end
	end
	 

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            w_key_down <= 1'b0;
            a_key_down <= 1'b0;
            s_key_down <= 1'b0;
            d_key_down <= 1'b0;
            recv_state <= 2'b00;
            last_ps2_data <= 8'h00;
        end else begin
            if (ps2_key_pressed_sync2) begin
                case (recv_state)
                    2'b00: begin
                        if (ps2_key_data_sync2 == 8'hF0) begin
                            recv_state <= 2'b01; // 收到F0，表示按键释放
                        end else begin
                            // 按键按下
                            last_ps2_data <= ps2_key_data_sync2;
                            case (ps2_key_data_sync2)
                                8'h1D: w_key_down <= 1'b1; // W键按下
                                8'h1C: a_key_down <= 1'b1; // A键按下
                                8'h1B: s_key_down <= 1'b1; // S键按下
                                8'h23: d_key_down <= 1'b1; // D键按下
                                default: ;
                            endcase
									 
                        end
                    end
                    2'b01: begin
                        // 接收按键释放的扫描码
                        case (ps2_key_data_sync2)
                            8'h1D: w_key_down <= 1'b0; // W键释放
                            8'h1C: a_key_down <= 1'b0; // A键释放
                            8'h1B: s_key_down <= 1'b0; // S键释放
                            8'h23: d_key_down <= 1'b0; // D键释放
                            default: ;
                        endcase
                        recv_state <= 2'b00; // 回到初始状态
                    end
                    default: recv_state <= 2'b00;
                endcase
            end
        end
    end


	 reg [19:0] debounce_counter_w, debounce_counter_a, debounce_counter_s, debounce_counter_d;
	 reg w_key_stable, a_key_stable, s_key_stable, d_key_stable;

	always @(posedge CLOCK_50 or negedge resetn) begin
		 if (!resetn) begin
			  debounce_counter_w <= 20'd0;
			  debounce_counter_a <= 20'd0;
			  debounce_counter_s <= 20'd0;
			  debounce_counter_d <= 20'd0;
			  w_key_stable <= 1'b0;
			  a_key_stable <= 1'b0;
			  s_key_stable <= 1'b0;
			  d_key_stable <= 1'b0;
		 end else begin
			  // W键消抖处理
			  if (w_key_down == w_key_stable) begin
					debounce_counter_w <= 20'd0; // 状态没有变化，计数器清零
			  end else begin
					debounce_counter_w <= debounce_counter_w + 20'd1;
					if (debounce_counter_w == 20'hFFFFF) begin // 达到消抖时间
						 w_key_stable <= w_key_down;
						 debounce_counter_w <= 20'd0; // 清零计数器
					end
			  end

			  // A键消抖处理
			  if (a_key_down == a_key_stable) begin
					debounce_counter_a <= 20'd0;
			  end else begin
					debounce_counter_a <= debounce_counter_a + 20'd1;
					if (debounce_counter_a == 20'hFFFFF) begin
						 a_key_stable <= a_key_down;
						 debounce_counter_a <= 20'd0;
					end
			  end

			  // S键消抖处理
			  if (s_key_down == s_key_stable) begin
					debounce_counter_s <= 20'd0;
			  end else begin
					debounce_counter_s <= debounce_counter_s + 20'd1;
					if (debounce_counter_s == 20'hFFFFF) begin
						 s_key_stable <= s_key_down;
						 debounce_counter_s <= 20'd0;
					end
			  end

			  // D键消抖处理
			  if (d_key_down == d_key_stable) begin
					debounce_counter_d <= 20'd0;
			  end else begin
					debounce_counter_d <= debounce_counter_d + 20'd1;
					if (debounce_counter_d == 20'hFFFFF) begin
						 d_key_stable <= d_key_down;
						 debounce_counter_d <= 20'd0;
					end
			  end
		 end
	end
	
	// 记录上一次的按键状态
reg [3:0] key_state_prev;
always @(posedge CLOCK_50 or negedge resetn) begin
    if (!resetn) begin
        key_state_prev <= 4'b1111;
    end else begin
        key_state_prev <= {w_key_stable, a_key_stable, s_key_stable, d_key_stable};
    end
end

// 检测按键按下（下降沿）
wire [3:0] key_press_signal;
assign key_press_signal = key_state_prev & (~{w_key_stable, a_key_stable, s_key_stable, d_key_stable}); // 当按键从高变低时，key_press对应位为1


    // 移动像素逻辑
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin                          
            pixel_x <= 70;
            pixel_y <= 80;
        end else begin
            // 左移（KEY[0]）
            if (key_press_signal[2]) begin
                if (pixel_x > 69) // 控制小图像不能超过格子的边沿
                    pixel_x <= pixel_x - 10;
                else
                    pixel_x <= 60; // 重置到左边格子
            end
            // 右移（KEY[1]）
            if (key_press_signal[0]) begin
                if (pixel_x < 89) // 控制小图像不能超过格子的边沿
                    pixel_x <= pixel_x + 10;
                else
                    pixel_x <= 90; // 重置到右边格子
            end
            // 上移（KEY[2]）
            if (key_press_signal[3]) begin
                if (pixel_y > 69) // 控制小图像不能超过格子的边沿
                    pixel_y <= pixel_y - 10;
                else
                    pixel_y <= 60; // 重置到上沿格子
            end
            // 下移（KEY[3]）
            if (key_press_signal[1]) begin
                if (pixel_y < 89) // 控制小图像不能超过格子的边沿
                    pixel_y <= pixel_y + 10;
                else
                    pixel_y <= 90; // 重置到下边格子
            end
        end
    end

    // 计算MIF文件的偏移量
    assign xc_offset = x_counter - pixel_x;
    assign yc_offset = y_counter - pixel_y;

    // 更新VGA坐标和颜色
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            VGA_X <= 0;
            VGA_Y <= 0;
            plot <= 1'b0;
        end else if (enable) begin
            // 开始绘制游戏画面
            if (VGA_X < SCREEN_WIDTH - 1) begin
                VGA_X <= VGA_X + 1;
            end else begin
                VGA_X <= 0;
                if (VGA_Y < SCREEN_HEIGHT - 1)
                    VGA_Y <= VGA_Y + 1;
                else
                    VGA_Y <= 0;
            end

            plot <= 1'b1; // 启用绘图

            // 判断当前像素是否在8x8的图案范围内
            if ((VGA_X >= pixel_x && VGA_X < pixel_x + 8) &&
                (VGA_Y >= pixel_y && VGA_Y < pixel_y + 8)) begin
                color_to_display <= mif_color; // 读取MIF文件中的颜色，绘制心形
            end else if ((x_counter == 59 && y_counter>=59 && y_counter<= 99) || (x_counter == 69 && y_counter>=59 && y_counter<= 99) || (x_counter == 79 && y_counter>=59 && y_counter<= 99) || (x_counter == 89 && y_counter>=59 && y_counter<= 99) || (x_counter == 99 && y_counter>=59 && y_counter<= 99)||
            (y_counter == 59 && x_counter>=59 && x_counter<= 99) || (y_counter == 69 && x_counter>=59 && x_counter<= 99) || (y_counter == 79 && x_counter>=59 && x_counter<= 99) || (y_counter == 89 && x_counter>=59 && x_counter<= 99) || (y_counter == 99 && x_counter>=59 && x_counter<= 99)) begin
                color_to_display <= 3'b111; // 白色的网格线
            end else begin
                color_to_display <= 3'b000; // 黑色背景
            end
        end else begin
            // 当enable为0时，不进行绘图，保持plot为0
            VGA_X <= VGA_X;
            VGA_Y <= VGA_Y;
            plot <= 1'b0;
            color_to_display <= 3'b000;
        end
    end

endmodule