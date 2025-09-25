package rasterizer

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

write_to_file :: proc(image: [W][H]Vec3) {
	write := os.write_entire_file("image.ppm", {})
	fd, op_err := os.open("image.ppm", os.O_RDWR)
	defer os.close(fd)

	if op_err != nil {
		fmt.println("ERROR")
	}

	os.write_string(fd, fmt.tprintf("P3 %d %d 255 ", W, H))

	for y := 0; y < len(image); y += 1 {
		for x := 0; x < len(image[0]); x += 1 {
			col := image[x][y]
			r, g, b := int(col.r * 255), int(col.g * 255), int(col.b * 255)
			os.write_string(fd, fmt.tprintf("%d %d %d ", r, g, b))
		}
	}
}

load_obj_file :: proc() -> (vertices: [dynamic]Vec3, ok: bool) {
	f, err := os.open("cube.obj", os.O_RDONLY)
	if err != nil {
		fmt.println("ERROR: ", err)
		return vertices, false
	}
	defer os.close(f)


	data := os.read_entire_file(f) or_return
	defer delete(data)

	it := string(data)

	for line in strings.split_lines_iterator(&it) {
		if !strings.starts_with(line, "f") {
			continue
		}

		for s in strings.split(line, " ") {
			if s == "f" {
				continue
			}

			elements := strings.split(s, "/")
			vec: Vec3
			for v, i in elements {
				n := strconv.parse_f32(v) or_return
				vec[i] = n
			}
			append(&vertices, vec)
		}
	}

	return
}

