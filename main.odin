#+feature dynamic-literals

package rasterizer

import "core:crypto"
import "core:fmt"
import math "core:math/linalg"
import "core:math/rand"
import "core:os"
import "core:time"

import rl "vendor:raylib"

Color :: distinct [4]u8
// TODO: to remove all triangles in favor of Vec3
Triangle :: struct {
	a, b, c: Vec2,
}
Model :: struct {
	triangle: Triangle,
	color:    Vec3,
}
Scene :: struct {
	colors: [W * H]Vec3,
}
Transform :: struct {
	yaw:   f32,
	pitch: f32,
}
State :: struct {
	transform: Transform,
}


// W, H :: 8, 8
// W, H :: 16, 16
// W, H :: 32, 32
W, H :: 64, 64
// W, H :: 128, 128
// W, H :: 256, 256

// Potential bugs:
// - Check if the grid is built correctly (no overflow) - suspicious that the triangle is not drawn when
//   disabling `vertex_to_screen` 

state := State {
	transform = Transform{},
}

main :: proc() {
	rl.InitWindow(1_000, 1_000, "Odin Rasterizer")
	texture := rl.LoadTextureFromImage(rl.GenImageColor(W, H, rl.BLACK))
	rl.SetTextureFilter(texture, rl.TextureFilter.BILINEAR)

	vertices, ok := load_obj_file("cube.obj")

	rl.SetTargetFPS(60)

	src := rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)}
	dst := rl.Rectangle{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
	origin := rl.Vector2{0, 0}

	pink := Vec3{1, 0.2, 1}
	red := Vec3{1, 0.2, 0}
	purple := Vec3{0.5, 0, 0.5}
	dark_green := Vec3{0, 0.5, 0}
	dark_blue := Vec3{0, 0, 0.5}
	blue := Vec3{0, 0.2, 1}

	tri_colors := [6]Vec3{pink, purple, red, dark_green, dark_blue, blue}

	for !rl.WindowShouldClose() {
		// TODO: make bounding optimization + refactor of model creation
		scene := new_scene(vertices, state.transform, tri_colors)
		text_byte_arr := scene_to_pixels(scene)

		handle_input(&state)

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

new_scene_mod :: proc(models: ^[10]Model) -> Scene {
	colors := [W * H]Vec3{}

	// - Bound triangle check can be applied but not necessary here
	for i := 0; i < W * H; i += 1 {
		x := i % W
		y := i / W

		#reverse for &model in models {
			using model

			if point_in_triangle(triangle, Vec2{f32(x), f32(y)}) {
				colors[i] = color
				continue
			}
		}
	}

	return Scene{colors}
}

// TODO: optimize (currently it's a mess)
new_scene_vert :: proc(
	vertices: [dynamic]Vec3,
	transform: Transform,
	tri_colors: [6]Vec3,
) -> Scene {
	colors := [W * H]Vec3{}
	triangles := [dynamic]Triangle{}

	for j := 0; j < len(vertices); j += 3 {
		a := vertex_to_screen(vertices[j], transform)
		b := vertex_to_screen(vertices[j + 1], transform)
		c := vertex_to_screen(vertices[j + 2], transform)

		tri := Triangle {
			a = a.xy,
			b = b.xy,
			c = c.xy,
		}

		append(&triangles, tri)
	}

	// - Bound triangle check must be applied!
	for i := 0; i < W * H; i += 1 {
		x := i % W
		y := i / W

		#reverse for &tri, index in triangles {
			using tri

			if point_in_triangle(tri, Vec2{f32(x), f32(y)}) {
				color_index := index % len(tri_colors)
				colors[i] = tri_colors[color_index]
				continue
			}
		}
	}

	return Scene{colors}
}

new_scene :: proc {
	new_scene_mod,
	new_scene_vert,
}

vertex_to_screen :: proc(vertex: Vec3, transform: Transform) -> Vec2 {
	num_pixels := Vec2{W, H}

	// - Addition of `point_to_world`
	vertex_world := point_to_world(vertex, transform)

	// - Screen heights in world units (i.e. from top to bottom)
	screen_height_world := 5
	pixels_per_world_unit := f32(num_pixels.y) / f32(screen_height_world)

	// - Offset from the center of the screen, which is taken for (0, 0)
	pixel_offset := vertex_world.xy * pixels_per_world_unit
	return num_pixels / 2 + pixel_offset
}

// TODO: figure out in details!!!
point_to_world :: proc(point: Vec3, using transform: Transform) -> Vec3 {
	using math

	// TODO: rework to just matrix multiplications
	i_hat_yaw := Vec3{cos(yaw), 0, sin(yaw)}
	j_hat_yaw := Vec3{0, 1, 0}
	k_hat_yaw := Vec3{-sin(yaw), 0, cos(yaw)}

	i_hat_pitch := Vec3{1, 0, 0}
	j_hat_pitch := Vec3{0, cos(pitch), -sin(pitch)}
	k_hat_pitch := Vec3{0, sin(pitch), cos(pitch)}

	i_hat := transform_vec(i_hat_yaw, j_hat_yaw, k_hat_yaw, i_hat_pitch)
	j_hat := transform_vec(i_hat_yaw, j_hat_yaw, k_hat_yaw, j_hat_pitch)
	k_hat := transform_vec(i_hat_yaw, j_hat_yaw, k_hat_yaw, k_hat_pitch)

	return transform_vec(i_hat, j_hat, k_hat, point)
}

transform_vec :: proc(i_hat, j_hat, k_hat, v: Vec3) -> Vec3 {
	return v.x * i_hat + v.y * j_hat + v.z * k_hat
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

