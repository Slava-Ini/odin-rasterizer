package rasterizer

import "core:fmt"
import math "core:math"
import rl "vendor:raylib"


Window :: struct {
	name:          cstring,
	width:         i32,
	height:        i32,
	fps:           i32,
	control_flags: rl.ConfigFlags,
}

main :: proc() {
	window := Window{"Eyes", 512, 512, 60, rl.ConfigFlags{.WINDOW_RESIZABLE}}

	rl.InitWindow(window.width, window.height, window.name)

	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		draw_eye(150, 250)
		draw_eye(280, 250)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}

draw_eye :: proc(x, y: i32) {
	m_pos := rl.GetMousePosition()

	dx := m_pos.x - f32(x)
	dy := m_pos.y - f32(y)

	distance := math.min(math.sqrt_f32(dx * dx + dy * dy), 25)
	// TODO: research atan2 deeper:
	// - [link](https://stackoverflow.com/questions/283406/what-is-the-difference-between-atan-and-atan2-in-c)
	// - [video 1](https://www.youtube.com/watch?v=XOk0aGwZYn8)
	// - [video 2](https://www.youtube.com/watch?v=VMYk9fqXz_4)
	angle := math.atan2(dy, dx)

	pupil_x := i32(math.cos(angle) * distance) + x
	pupil_y := i32(math.sin(angle) * distance) + y

	rl.DrawCircle(x, y, 50, rl.RAYWHITE)
	rl.DrawCircle(pupil_x, pupil_y, 25, rl.DARKBLUE)

	rl.DrawLine(x, y, i32(m_pos.x), i32(m_pos.y), rl.YELLOW)
}

