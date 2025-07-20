#+feature dynamic-literals

package main


import "core:fmt"
import "core:os"

// Optionally, there's swizzle with `xyzw` or `rgba`, but only for arrays with >=4 elements
Vec3 :: struct {
	x, y, z: f32,
}

main :: proc() {
	vec := Vec3 {
		x = 10,
		y = 10,
	}

	fmt.println(vec)
	create_test_image()
}

create_test_image :: proc() {
	WIDTH, HEIGHT :: 64, 64
	image: [WIDTH][HEIGHT]Vec3 = {}

	// -- Pixels
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

	// -- Color data
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
			// Swizzle here?
			r, g, b := int(col.x * 255), int(col.y * 255), int(col.z * 255)
			os.write_string(fd, fmt.tprintf("%d %d %d ", r, g, b))
		}
	}
}
