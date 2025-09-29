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

load_obj_file :: proc(path: string) -> (vertices: [dynamic]Vec3, ok: bool = true) {
	f, err := os.open(path, os.O_RDONLY)
	if err != nil {
		fmt.println("ERROR: ", err)
		return vertices, false
	}
	defer os.close(f)

	data := os.read_entire_file(f) or_return
	defer delete(data)

	it := string(data)

	// -- Vertex buffer is a buffer of all `vt` model points
	vertex_buf := [dynamic]Vec3{}

	for line in strings.split_lines_iterator(&it) {
		// - Reading vertices
		if strings.starts_with(line, "v ") {
			vertex := Vec3{}
			for v, i in strings.split(line[2:], " ") {
				n := strconv.parse_f32(v) or_else 0
				vertex[i] = n
			}

			append(&vertex_buf, vertex)
		}

		// - Reading faces
		if strings.starts_with(line, "f ") {
			for s, i in strings.split(line[2:], " ") {
				indices := strings.split(s, "/")

				// - `- 1` because `.obj` indices start from 1
				vertex_index, ok := strconv.parse_int(indices[0])
				vertex_index = ok ? vertex_index - 1 : 0

				// -- Ear clipping algorithm is needed for concavity
				if (i >= 3) {
					// fmt.println("A_3_1: ", vertex_buf[0])
					// fmt.println("A_3_2: ", vertex_buf[len(vertex_buf) - 2])
					append(&vertices, vertex_buf[0]) // might be wrong?
					append(&vertices, vertex_buf[len(vertex_buf) - 2])
				}

				// fmt.println("A_N: ", vertex_buf[vertex_index])
				append(&vertices, vertex_buf[vertex_index])
			}
		}
	}

	// -- Note --
	// Each 3 points of a result `vertices` is a triangle
	return
}

