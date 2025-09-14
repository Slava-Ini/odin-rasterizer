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

	i = 0

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

	// image := create_triangle_image()
	// write_to_file(image)
}

create_test_image :: proc() -> (image: [WIDTH][HEIGHT]Vec3) {
	for y := 0; y < HEIGHT; y += 1 {
		for x := 0; x < WIDTH; x += 1 {
			r: f32 = f32(x) / (WIDTH - 1)
			g: f32 = f32(y) / (HEIGHT - 1)
			image[x][y] = {r, g, 0}
		}
	}

	return image
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

point_in_triangle :: proc(tri: Triangle, p: Vec2) -> bool {
	// -- Method 1: Ray Casting
	//    Cast a ray in random direction to count how many times the ray intersects the triangle
	// return ray_casting(tri, p)

	// -- Method 2: Edge function using dot product
	//    Find on which side of every edge the point is using dot product and rotation
	// return edge_function_dot_product(tri, p)

	// -- Method 3: Edge function using cross product
	//    Find on which side of every edge the point is using cross product
	// return edge_function_cross_product(tri, p)

	// -- Method 4: Barycentric Coordinates
	//    Find barycentric weights to determine wheather the point is in triangle
	return barycentric(tri, p)
}

write_to_file :: proc(image: [WIDTH][HEIGHT]Vec3) {
	write := os.write_entire_file("image.ppm", {})
	fd, op_err := os.open("image.ppm", os.O_RDWR)
	defer os.close(fd)

	if op_err != nil {
		fmt.println("ERROR")
	}

	os.write_string(fd, fmt.tprintf("P3 %d %d 255 ", WIDTH, HEIGHT))

	for y := 0; y < len(image); y += 1 {
		for x := 0; x < len(image[0]); x += 1 {
			col := image[x][y]
			r, g, b := int(col.r * 255), int(col.g * 255), int(col.b * 255)
			os.write_string(fd, fmt.tprintf("%d %d %d ", r, g, b))
		}
	}
}

