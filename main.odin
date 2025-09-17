#+feature dynamic-literals

package main

import "core:crypto"
import "core:fmt"
import "core:os"

import rl "vendor:raylib"

Color :: distinct [4]u8
Triangle :: struct {
	a, b, c: Vec2,
}

WIDTH, HEIGHT :: 64, 64

main :: proc() {
	rl.InitWindow(1_000, 1_000, "Odin Rasterizer")
	texture := rl.LoadTextureFromImage(rl.GenImageColor(WIDTH, HEIGHT, rl.BLACK))
	rl.SetTextureFilter(texture, rl.TextureFilter.BILINEAR)
	text_byte_array := [WIDTH * HEIGHT * 4]byte{}
	img := create_triangle_image()

	// 1. new_render_target(w, h) -> creates new RenderTarget struct  
	// 2. new_scene(models) -> creates a new scene
	// 3. scene_to_pixels(scene) -> converts scene to pixels

	i := 0

	for y := 0; y < len(img); y += 1 {
		for x := 0; x < len(img[0]); x += 1 {
			col := img[x][y]
			r, g, b := byte(col.r * 255), byte(col.g * 255), byte(col.b * 255)
			// TODO: to improve and refactor
			text_byte_array[i] = r
			text_byte_array[i + 1] = g
			text_byte_array[i + 2] = b
			text_byte_array[i + 3] = 255
			i += 4
		}
	}

	src := rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)}
	dst := rl.Rectangle{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
	origin := rl.Vector2{0, 0}

	for !rl.WindowShouldClose() {
		rl.UpdateTexture(texture, &text_byte_array)
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		// rl.DrawTexture(texture, 0, 0, rl.WHITE)
		rl.DrawTexturePro(texture, src, dst, origin, 0, rl.WHITE)
		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}

RenderTarget :: struct {
	width:  u16,
	height: u16,
}
Model :: struct {}
Scene :: struct {
	colors: [WIDTH][HEIGHT]Vec3,
}

// TODO: play with polymorphysm here
new_render_target :: proc(width, height: u16) -> RenderTarget {
	return RenderTarget{width = width, height = height}
}
new_scene :: proc(target: RenderTarget) -> Scene {
	return Scene{}
}
// TODO: think what to do with `dynamic`
scene_to_pixels :: proc(scene: Scene) -> [dynamic]byte {
	return {}
}

create_triangle_image :: proc() -> (image: [WIDTH][HEIGHT]Vec3) {
	triangle := Triangle {
		a = Vec2{0.2 * WIDTH, 0.2 * HEIGHT},
		b = Vec2{0.9 * WIDTH, 0.4 * HEIGHT},
		c = Vec2{0.4 * WIDTH, 0.8 * HEIGHT},
	}
	blue: Vec3 = {0, 0, 1}
	black: Vec3 = {0, 0, 0}

	for y := 0; y < HEIGHT; y += 1 {
		for x := 0; x < WIDTH; x += 1 {
			if point_in_triangle(triangle, Vec2{f32(x), f32(y)}) {
				image[x][y] = blue
			} else {
				image[x][y] = black
			}
		}
	}

	return image
}

