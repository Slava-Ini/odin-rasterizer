#+feature dynamic-literals

package main

import "core:crypto"
import "core:fmt"
import "core:os"

import rl "vendor:raylib"

Vec3 :: distinct [3]f32
Vec2 :: distinct [2]f32
Triangle :: struct {
	a, b, c: Vec2,
}

WIDTH, HEIGHT :: 64, 64

main :: proc() {
	rl.InitWindow(1_000, 1_000, "Odin Rasterizer")
	// texture := rl.LoadTextureFromImage(rl.GenImageColor(1_000, 1_000, rl.BLACK))
  // text_byte_array := [WIDTH * HEIGHT * 4]byte{}

	for !rl.WindowShouldClose() {
		// rl.UpdateTexture(texture, ([^]byte)(im_scarfy_anim.data)[next_frame_data_offset:])
		// rl.UpdateTexture(texture, &text_byte_array)
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.EndDrawing()
	}
	rl.CloseWindow()

	image := create_triangle_image()
	write_to_file(image)
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

ray_casting :: proc(tri: Triangle, p: Vec2) -> bool {
	c := 0
	xp, yp := p.x, p.y
	edges := [3][2]Vec2{[2]Vec2{tri.a, tri.b}, [2]Vec2{tri.b, tri.c}, [2]Vec2{tri.c, tri.a}}

	for edge in edges {
		x1, y1 := edge[0].x, edge[0].y
		x2, y2 := edge[1].x, edge[1].y

		if (yp < y1) != (yp < y2) && xp < x1 + ((yp - y1) / (y2 - y1)) * (x2 - x1) {
			c += 1
		}
	}

	return c % 2 == 1
}

edge_function_cross_product :: proc(tri: Triangle, p: Vec2) -> bool {
	xp, yp := p.x, p.y
	edges := [3][2]Vec2{[2]Vec2{tri.a, tri.b}, [2]Vec2{tri.b, tri.c}, [2]Vec2{tri.c, tri.a}}
	res := [3]bool{}

	for e, index in edges {
		x1, y1 := e[0].x, e[0].y
		x2, y2 := e[1].x, e[1].y

		cross_product := (x2 - x1) * (yp - y1) - (y2 - y1) * (xp - x1)

		res[index] = cross_product >= 0
	}

	// Note: Can be improved by checking if all three are either bool
	return res[0] && res[1] && res[2]
}


dot :: proc(a, b: Vec2) -> f32 {
	return a.y * b.y + a.x * b.x
}

// Note: rotating clockwise
perpendicular :: proc(vec: ^Vec2) {
	vec.x, vec.y = vec.y, -vec.x
}

edge_function_dot_product :: proc(tri: Triangle, p: Vec2) -> bool {
	xp, yp := p.x, p.y
	edges := [3][2]Vec2{[2]Vec2{tri.a, tri.b}, [2]Vec2{tri.b, tri.c}, [2]Vec2{tri.c, tri.a}}
	res := [3]bool{}

	for e, i in edges {
		x1, y1 := e[0].x, e[0].y
		x2, y2 := e[1].x, e[1].y

		ap := Vec2{xp - x1, yp - y1}
		ab := Vec2{x2 - x1, y2 - y1}
		perpendicular(&ab)

		// Note: here we can change `<` to `>=` but then the `return` check will change as well
		//       It depends on how to rotate the triangle in order to get how we are checking
		res[i] = dot(ap, ab) < 0
	}

	return res[0] && res[1] && res[2]
}

barycentric :: proc(t: Triangle, p: Vec2) -> bool {
	xp, yp := p.x, p.y
	x1, y1 := t.a.x, t.a.y
	x2, y2 := t.b.x, t.b.y
	x3, y3 := t.c.x, t.c.y

	denom := (y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3)

	if (denom <= 0) {
		return false
	}

	a := ((xp - x3) * (y2 - y3) + (x3 - x2) * (yp - y3)) / denom
	b := ((x1 - x3) * (yp - y3) + (x3 - xp) * (y1 - y3)) / denom
	c := 1 - a - b

	return a >= 0 && a <= 1 && b >= 0 && b <= 1 && c >= 0 && c <= 1
	// -- Note: We might as well omit 1 comparison as sum of weights can't exceed 1
	// return a >= 0 && b >= 0 && c >= 0
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

