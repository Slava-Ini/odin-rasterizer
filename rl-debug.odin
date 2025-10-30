package rasterizer

import "core:strings"
import rl "vendor:raylib"

print_state :: proc(state: ^State) {
	sb := strings.builder_make()

	// Convert quaternion to Euler angles for display
	yaw, pitch, roll := quat_to_euler(state.transform.rotation)

	strings.write_string(&sb, "Yaw: ")
	strings.write_f32(&sb, yaw, 'f')
	strings.write_string(&sb, "\nPitch: ")
	strings.write_f32(&sb, pitch, 'f')
	strings.write_string(&sb, "\nRoll: ")
	strings.write_f32(&sb, roll, 'f')

	// Also show quaternion components
	strings.write_string(&sb, "\n\nQuaternion (w,x,y,z):")
	strings.write_string(&sb, "\nw: ")
	strings.write_f32(&sb, real(state.transform.rotation), 'f')
	strings.write_string(&sb, " x: ")
	strings.write_f32(&sb, imag(state.transform.rotation), 'f')
	strings.write_string(&sb, "\ny: ")
	strings.write_f32(&sb, jmag(state.transform.rotation), 'f')
	strings.write_string(&sb, " z: ")
	strings.write_f32(&sb, kmag(state.transform.rotation), 'f')

	rl.DrawText(strings.to_cstring(&sb), 10, 30, 22, rl.WHITE)
}

print_fps :: proc() {
	rl.DrawFPS(10, 10)
}

