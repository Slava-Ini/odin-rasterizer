package rasterizer

import math "core:math/linalg"
import rl "vendor:raylib"


TRANSFORM_SPEED: f32 : 0.05
MOVE_SPEED: f32 : 0.03


handle_input :: proc(state: ^State) {
	update_transform(state)
	update_position(state)
}

update_transform :: proc(using state: ^State) {
	limit_to_pi :: proc(value: f32) -> f32 {
		// TODO: finalize the bounds and think about it more! 
		result := f32(math.mod(value + math.PI, math.TAU)) // TAU = 2 * PI
		return result - math.PI
	}

	if rl.IsKeyDown(.LEFT) {
		transform.yaw = limit_to_pi(TRANSFORM_SPEED + transform.yaw)
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
	if rl.IsKeyDown(.Q) {
		transform.roll += TRANSFORM_SPEED
	}
	if rl.IsKeyDown(.E) {
		transform.roll -= TRANSFORM_SPEED
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

