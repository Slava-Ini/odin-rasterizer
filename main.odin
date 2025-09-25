#+feature dynamic-literals

package rasterizer

import "core:crypto"
import "core:fmt"
import "core:math/linalg"
import "core:math/rand"
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

	vertices, ok := load_obj_file()
	fmt.println(ok, vertices)

	// TODO: make bounding optimization + refactor of model creation
	models := gen_triangles(10)
	scene := new_scene(&models)
	text_byte_arr := scene_to_pixels(scene)

	rl.SetTargetFPS(60)

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
	triangle: Triangle,
	color:    Vec3,
}

Scene :: struct {
	colors: [W * H]Vec3,
}

new_scene :: proc(models: ^[10]Model) -> Scene {
	colors := [W * H]Vec3{}
	black: Vec3 = {0, 0, 0}

	// - Bound triangle check can be applied but not necessary here
	for i := 0; i < W * H; i += 1 {
		x := i % W
		y := i / W

		for &model in models {
			using model

			if point_in_triangle(triangle, Vec2{f32(x), f32(y)}) {
				colors[i] = color
			}
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

gen_triangles :: proc($N: u16) -> (triangles: [N]Model) {
	triangle_is_valid :: proc(a: Vec2, b: Vec2, c: Vec2) -> bool {
		if (a == b || b == c || a == c) {
			return false
		}

		// Calculate the area of the triangle using the determinant method
		area := abs((a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2.0)

		return area > 100
	}

	random_vec2 :: proc() -> Vec2 {
		return Vec2{rand.float32() * f32(W), rand.float32() * f32(H)}
	}

	generate_triangle :: proc() -> Triangle {
		for {
			a := random_vec2()
			b := random_vec2()
			c := random_vec2()

			if triangle_is_valid(a, b, c) {
				return Triangle{a, b, c}
			}
		}
	}

	for i: u16 = 0; i < N; i += 1 {
		triangles[i] = Model {
			color    = Vec3{rand.float32(), rand.float32(), rand.float32()},
			triangle = generate_triangle(),
		}
	}

	return
}

