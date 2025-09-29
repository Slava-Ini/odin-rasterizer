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

load_obj_file :: proc() -> (triangles: [dynamic]Triangle, ok: bool) {
	f, err := os.open("cube.obj", os.O_RDONLY)
	if err != nil {
		fmt.println("ERROR: ", err)
		return triangles, false
	}
	defer os.close(f)


	data := os.read_entire_file(f) or_return
	defer delete(data)

	it := string(data)

	vertex_buf: []Vec3

	for line in strings.split_lines_iterator(&it) {
		// - Reading vertices
		if strings.starts_with(line, "v ") {
			vertex := Vec3{}
			for v, i in strings.split(line[2:], " ") {
				n := strconv.parse_f32(v) or_else 0
				vertex[i] = n
			}
			vertex_buf[len(vertex_buf) - 1] = vertex
		}

		// - Reading faces
		if strings.starts_with(line, "f ") {
			for s, i in strings.split(line[2:], " ") {
				indices := strings.split(s, "/")

				// TODO: need better error handling here
				// - `- 1` because `.obj` indices start from 1
				vertex_index := strconv.parse_f32(indices[0]) or_else 1 - 1

				if (i >= 3) {
					// TODO: start here
					// - For now maybe continue using triangles, but needs to be changed later
				} 

				// TODO: mind adding 1 for correct coordinates interpolation?
				append(&triangles, Triangle{a = vec[0], b = vec[1], c = vec[2]})
			}
		}
	}

	return
}

