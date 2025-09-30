package rasterizer

import rl "vendor:raylib"


TRANSFORM_SPEED: f32 : 0.05


handle_input :: proc(state: ^State) {
	using state

	// TODO: improve it somehow?
	// -- Input
	if rl.IsKeyDown(.LEFT) {
		transform.yaw += TRANSFORM_SPEED
	}
	if rl.IsKeyDown(.RIGHT) {
		transform.yaw -= TRANSFORM_SPEED
	}
	if rl.IsKeyDown(.UP) {
		transform.pitch += TRANSFORM_SPEED
	}
	if rl.IsKeyDown(.DOWN) {
		transform.pitch -= TRANSFORM_SPEED
	}
}

