package rasterizer

import rl "vendor:raylib"
import math "core:math/linalg"

TRANSFORM_SPEED: f32 : 0.05
MOVE_SPEED: f32 : 0.03

handle_input :: proc(state: ^State) {
	update_transform(state)
	update_position(state)
}

update_transform :: proc(using state: ^State) {
	// Apply incremental rotations using quaternion multiplication
	// Each key press creates a small rotation quaternion and multiplies it with the current rotation

	if rl.IsKeyDown(.LEFT) {
		// Rotate around Y-axis (yaw left)
		delta_rotation := quat_from_axis_angle(Vec3{0, 1, 0}, TRANSFORM_SPEED)
		transform.rotation = math.mul(delta_rotation, transform.rotation)
		transform.rotation = math.quaternion_normalize(transform.rotation)
	}
	if rl.IsKeyDown(.RIGHT) {
		// Rotate around Y-axis (yaw right)
		delta_rotation := quat_from_axis_angle(Vec3{0, 1, 0}, -TRANSFORM_SPEED)
		transform.rotation = math.mul(delta_rotation, transform.rotation)
		transform.rotation = math.quaternion_normalize(transform.rotation)
	}
	if rl.IsKeyDown(.UP) {
		// Rotate around X-axis (pitch up)
		delta_rotation := quat_from_axis_angle(Vec3{1, 0, 0}, TRANSFORM_SPEED)
		transform.rotation = math.mul(delta_rotation, transform.rotation)
		transform.rotation = math.quaternion_normalize(transform.rotation)
	}
	if rl.IsKeyDown(.DOWN) {
		// Rotate around X-axis (pitch down)
		delta_rotation := quat_from_axis_angle(Vec3{1, 0, 0}, -TRANSFORM_SPEED)
		transform.rotation = math.mul(delta_rotation, transform.rotation)
		transform.rotation = math.quaternion_normalize(transform.rotation)
	}
	if rl.IsKeyDown(.Q) {
		// Rotate around Z-axis (roll counter-clockwise)
		delta_rotation := quat_from_axis_angle(Vec3{0, 0, 1}, TRANSFORM_SPEED)
		transform.rotation = math.mul(delta_rotation, transform.rotation)
		transform.rotation = math.quaternion_normalize(transform.rotation)
	}
	if rl.IsKeyDown(.E) {
		// Rotate around Z-axis (roll clockwise)
		delta_rotation := quat_from_axis_angle(Vec3{0, 0, 1}, -TRANSFORM_SPEED)
		transform.rotation = math.mul(delta_rotation, transform.rotation)
		transform.rotation = math.quaternion_normalize(transform.rotation)
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

