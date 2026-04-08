package bleacher

import rl "vendor:raylib"
import "core:fmt"

WINDOWSIZE :: 1000
CANVAS_SIZE :: 320 

Colors :: enum{RED, GREEN, BLUE}

red: u16
green: u16
blue: u16

red_added: u16
green_added: u16
blue_added: u16

available_points: u32

red_pos: rl.Vector2
blue_pos: rl.Vector2
green_pos: rl.Vector2

game_over: bool

init::proc() {
    blue = random_color_value()
    red = random_color_value()
    green = random_color_value()

    red_pos = {4, CANVAS_SIZE/2 + 29}
    blue_pos = {58, CANVAS_SIZE/2 + 29}
    green_pos = {112, CANVAS_SIZE/2 + 29}
    
    available_points = 255*3 - u32(blue) - u32(red) - u32(green)
}

restart::proc() {
    init()
    game_over = false
}

random_color_value::proc() -> u16 {
    return u16(rl.GetRandomValue(0, 255))
}

draw_color_rect::proc(color: rl.Color, x: f32, y: f32, value: u16) {
    rect := rl.Rectangle {
        x, y, 
        50, 70
    }
    
    rl.DrawRectangleRec(rect, color)
    
    number_str := fmt.ctprintf("%v", value)
    rl.DrawText(number_str ,i32(x)+20, i32(y)+35, 20, rl.BLACK)
}

color_is_addable::proc(color: Colors) -> bool {

    if available_points == 0 {
        return false
    }

    switch color {
        case .RED:
            return red_added < 255
        case .GREEN:
            return green_added < 255
        case .BLUE:
            return blue_added < 255
    }
    return false
}

main::proc() {
    rl.InitWindow(WINDOWSIZE, WINDOWSIZE, "Bleacher")
    init()

    for !rl.WindowShouldClose() {
        if !game_over {
            switch {
                case rl.IsKeyPressed(.W) || rl.IsKeyPressedRepeat(.W):
                    if color_is_addable(.RED) {
                        available_points -= 1
                        red_added += 1
                    }
            
                case rl.IsKeyPressed(.E) || rl.IsKeyPressedRepeat(.E):
                    if color_is_addable(.BLUE) {
                        available_points -= 1
                        blue_added += 1
                    }
    
                case rl.IsKeyPressed(.R) || rl.IsKeyPressedRepeat(.R):
                    if color_is_addable(.GREEN) {
                        available_points -= 1
                        green_added += 1
                    }
    
                case rl.IsKeyPressed(.G):
                    if available_points == 0 {
                        game_over = true
                    }
                    red = min(red+red_added, 255)
                    blue = min(blue+blue_added, 255) 
                    green = min(green+green_added, 255)
                    red_added = 0
                    blue_added = 0
                    green_added = 0
            }
    
        } else {
            if rl.IsKeyDown(.ENTER) {
                restart()
            }
        }
        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        camera := rl.Camera2D {
            zoom = f32(WINDOWSIZE) / CANVAS_SIZE,
        }

        rl.BeginMode2D(camera)


        color_rect := rl.Rectangle {
            4, 4,
            f32(CANVAS_SIZE) - 8, 
            f32(CANVAS_SIZE) / 2, 
        }
        
        rl.DrawRectangleRec(color_rect, {u8(red), u8(green), u8(blue), 255})

        available_text := fmt.ctprintf("Points to give: %v", available_points)
        scroe_text := fmt.ctprintf("Score: %v", red + blue + green)

        rl.DrawText(available_text, 4, (CANVAS_SIZE/2) + 14 , 10, rl.BLACK )
        rl.DrawText(scroe_text, CANVAS_SIZE - 60, (CANVAS_SIZE/2) + 14 , 10, rl.BLACK )

        draw_color_rect(rl.RED, red_pos.x, red_pos.y, red_added)
        draw_color_rect(rl.BLUE, blue_pos.x, blue_pos.y, blue_added)
        draw_color_rect(rl.GREEN, green_pos.x, green_pos.y, green_added)

        if game_over {
            rl.DrawText("Game Over!", 6, 6, 25, rl.BLACK)
            rl.DrawText("Press ENTER to restart", 6, 34, 12, rl.BLACK)
        }

        rl.EndMode2D()
        rl.EndDrawing()
    }


    rl.CloseWindow()
}
