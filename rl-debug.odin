package rasterizer

import "core:strings"
import rl "vendor:raylib"

print_state :: proc(state: ^State) {
	sb := strings.builder_make()

	strings.write_string(&sb, "Yaw: ")
	strings.write_f32(&sb, state.transform.yaw, 'f')
	strings.write_string(&sb, "\nPitch: ")
	strings.write_f32(&sb, state.transform.pitch, 'f')
	strings.write_string(&sb, "\nRoll: ")
	strings.write_f32(&sb, state.transform.roll, 'f')
	
	rl.DrawText(strings.to_cstring(&sb), 10, 30, 22, rl.WHITE)
}

print_fps :: proc() {
	rl.DrawFPS(10, 10)
}

