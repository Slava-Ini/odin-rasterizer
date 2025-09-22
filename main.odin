#+feature dynamic-literals

package rasterizer

import "core:crypto"
import "core:fmt"
import "core:os"

import rl "vendor:raylib"

Color :: distinct [4]u8
Triangle :: struct {
	a, b, c: Vec2,
}

// W, H :: 8, 8
// W, H :: 16, 16
// W, H :: 32, 32
W, H :: 64, 64
// W, H :: 128, 128
// W, H :: 256, 256

main :: proc() {
	rl.InitWindow(1_000, 1_000, "Odin Rasterizer")
	texture := rl.LoadTextureFromImage(rl.GenImageColor(W, H, rl.BLACK))
	rl.SetTextureFilter(texture, rl.TextureFilter.BILINEAR)

	scene := new_scene({})
	text_byte_arr := scene_to_pixels(scene)

	src := rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)}
	dst := rl.Rectangle{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
	origin := rl.Vector2{0, 0}

	for !rl.WindowShouldClose() {
		rl.UpdateTexture(texture, &text_byte_arr)
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		// rl.DrawTexture(texture, 0, 0, rl.WHITE)
		rl.DrawTexturePro(texture, src, dst, origin, 0, rl.WHITE)
		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}

Model :: struct {
	coord: Vec3,
	color: Vec3,
}

Scene :: struct {
	colors: [W * H]Vec3,
}

new_scene :: proc(models: []Model) -> Scene {
	colors := [W * H]Vec3{}

	// TODO: change to models
	blue: Vec3 = {0, 0, 1}
	black: Vec3 = {0, 0, 0}

	triangle := Triangle {
		a = Vec2{0.2 * W, 0.2 * H},
		b = Vec2{0.9 * W, 0.4 * H},
		c = Vec2{0.4 * W, 0.8 * H},
	}

	for i := 0; i < W * H; i += 1 {
		x := i % W
		y := i / W

		if point_in_triangle(triangle, Vec2{f32(x), f32(y)}) {
			colors[i] = blue
		} else {
			colors[i] = black
		}
	}

	return Scene{colors}
}

scene_to_pixels :: proc(using scene: Scene) -> (tb_arr: [W * H * 4]byte) {
	for i, j := 0, 0; i < len(colors); i, j = i + 1, j + 4 {
		col := colors[i]
		r, g, b := byte(col.r * 255), byte(col.g * 255), byte(col.b * 255)
		tb_arr[j] = r
		tb_arr[j + 1] = g
		tb_arr[j + 2] = b
		tb_arr[j + 3] = 255
	}

	return
}

