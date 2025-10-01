package rasterizer

import rl "vendor:raylib"


TRANSFORM_SPEED: f32 : 0.05
MOVE_SPEED: f32 : 0.03


handle_input :: proc(state: ^State) {
	update_transform(state)
	update_position(state)
}

update_transform :: proc(using state: ^State) {
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

update_position :: proc(using state: ^State) {
	if rl.IsKeyDown(.W) {
		position.z += MOVE_SPEED
	}
	if rl.IsKeyDown(.S) {
		position.z -= MOVE_SPEED
	}
	if rl.IsKeyDown(.A) {
		position.x -= MOVE_SPEED
	}
	if rl.IsKeyDown(.D) {
		position.x += MOVE_SPEED
	}
}

