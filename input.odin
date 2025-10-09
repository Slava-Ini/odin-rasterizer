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
		transform.yaw = limit_to_pi(transform.yaw + TRANSFORM_SPEED)
	}
	if rl.IsKeyDown(.RIGHT) {
		transform.yaw = limit_to_pi(transform.yaw - TRANSFORM_SPEED)
	}
	if rl.IsKeyDown(.UP) {
		transform.pitch = limit_to_pi(transform.pitch + TRANSFORM_SPEED)
	}
	if rl.IsKeyDown(.DOWN) {
		transform.pitch = limit_to_pi(transform.pitch - TRANSFORM_SPEED)
	}
	if rl.IsKeyDown(.Q) {
		transform.roll = limit_to_pi(transform.roll + TRANSFORM_SPEED)
	}
	if rl.IsKeyDown(.E) {
		transform.roll = limit_to_pi(transform.roll - TRANSFORM_SPEED)
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

