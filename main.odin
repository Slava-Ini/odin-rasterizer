#+feature dynamic-literals

package main

import "core:fmt"
import "core:os"

// Optionally, there's swizzle with `xyzw` or `rgba`, but only for arrays with length <=4 elements
// TODO: make an array alias instead of structs (mind `distinct`)
Vec3 :: struct {
	x, y, z: f32,
}
Vec2 :: struct {
	x, t: f32,
}
Triangle :: struct {
	a, b, c: Vec2,
}

WIDTH, HEIGHT :: 64, 64

main :: proc() {
	image := create_triangle_image()
	write_to_file(image)
}

create_test_image :: proc() -> (image: [WIDTH][HEIGHT]Vec3) {
	for y := 0; y < HEIGHT; y += 1 {
		for x := 0; x < WIDTH; x += 1 {
			r: f32 = f32(x) / (WIDTH - 1)
			g: f32 = f32(y) / (HEIGHT - 1)
			image[x][y] = Vec3 {
				x = r,
				y = g,
			}
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
	blue := Vec3 {
		z = 1.0,
	}
	black := Vec3{}

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

// TODO: start here
// Try several approaches:
// + Point in polygon
// - Cross product (same side)
// - Barycentric coordinates

point_in_triangle :: proc(tri: Triangle, p: Vec2) -> bool {
	return point_in_polygon(tri, p)
}

point_in_polygon :: proc(tri: Triangle, p: Vec2) -> bool {
	c := 0
	xp, yp := p.x, p.t
	edges := [3][2]Vec2{
		[2]Vec2{tri.a, tri.b},
		[2]Vec2{tri.b, tri.c},
		[2]Vec2{tri.c, tri.a}
	}

	for edge in edges {
		x1, y1 := edge[0].x, edge[0].t
		x2, y2 := edge[1].x, edge[1].t

		if (yp < y1) != (yp < y2) && xp < x1 + ((yp - y1) / (y2 - y1)) * (x2 - x1) {
			c += 1
		}
	}

	return c % 2 == 1
}

// point_in_triangle :: proc(tri: Triangle, p: Vec2) -> bool {
// 	// Rename for clarity
// 	a, b, c := tri.a, tri.b, tri.c

// 	// Compute vectors
// 	v0 := Vec2{c.x - a.x, c.t - a.t}
// 	v1 := Vec2{b.x - a.x, b.t - a.t}
// 	v2 := Vec2{p.x - a.x, p.t - a.t}

// 	// Compute dot products
// 	d00 := v0.x*v0.x + v0.t*v0.t
// 	d01 := v0.x*v1.x + v0.t*v1.t
// 	d11 := v1.x*v1.x + v1.t*v1.t
// 	d20 := v2.x*v0.x + v2.t*v0.t
// 	d21 := v2.x*v1.x + v2.t*v1.t

// 	// Compute barycentric coordinates
// 	denom := d00 * d11 - d01 * d01
// 	if denom == 0 {
// 		return false // degenerate triangle
// 	}

// 	v := (d11 * d20 - d01 * d21) / denom
// 	w := (d00 * d21 - d01 * d20) / denom
// 	u := 1.0 - v - w

// 	return u >= 0 && v >= 0 && w >= 0
// }

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
			// Swizzle here? + check array programming everywhere
			r, g, b := int(col.x * 255), int(col.y * 255), int(col.z * 255)
			os.write_string(fd, fmt.tprintf("%d %d %d ", r, g, b))
		}
	}
}

