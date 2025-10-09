package rasterizer

import math "core:math/linalg"

Vec2 :: [2]f32
Vec3 :: [3]f32

point_in_triangle :: proc(tri: Triangle, p: Vec2) -> bool {
	// -- Method 1: Ray Casting
	//    Cast a ray in random direction to count how many times the ray intersects the triangle
	//    Note: Doesn't work for 3D
	// return ray_casting(tri, p)

	// -- Method 2: Edge function using dot product
	//    Find on which side of every edge the point is using dot product and rotation
	return edge_function_dot_product(tri, p)

	// -- Method 3: Edge function using cross product
	//    Find on which side of every edge the point is using cross product
	// return edge_function_cross_product(tri, p)

	// -- Method 4: Barycentric Coordinates
	//    Find barycentric weights to determine wheather the point is in triangle
	// return barycentric(tri, p)
}

// Note: rotating clockwise
perpendicular :: proc(vec: ^Vec2) {
	vec.x, vec.y = vec.y, -vec.x
}

dot :: proc(a, b: Vec2) -> f32 {
	return a.y * b.y + a.x * b.x
}

barycentric :: proc(t: Triangle, p: Vec2) -> bool {
	xp, yp := p.x, p.y
	x1, y1 := t.a.x, t.a.y
	x2, y2 := t.b.x, t.b.y
	x3, y3 := t.c.x, t.c.y

	denom := (y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3)

	if (denom <= 0) {
		return false
	}

	a := ((xp - x3) * (y2 - y3) + (x3 - x2) * (yp - y3)) / denom
	b := ((x1 - x3) * (yp - y3) + (x3 - xp) * (y1 - y3)) / denom
	c := 1 - a - b

	return a >= 0 && a <= 1 && b >= 0 && b <= 1 && c >= 0 && c <= 1
	// -- Note: We might as well omit 1 comparison as sum of weights can't exceed 1
	// return a >= 0 && b >= 0 && c >= 0
}


edge_function_dot_product :: proc(tri: Triangle, p: Vec2) -> bool {
	xp, yp := p.x, p.y
	edges := [3][2]Vec2{[2]Vec2{tri.a, tri.b}, [2]Vec2{tri.b, tri.c}, [2]Vec2{tri.c, tri.a}}
	res := [3]bool{}

	for e, i in edges {
		x1, y1 := e[0].x, e[0].y
		x2, y2 := e[1].x, e[1].y

		ap := Vec2{xp - x1, yp - y1}
		ab := Vec2{x2 - x1, y2 - y1}
		perpendicular(&ab)

		// Note: here we can change `<=` to `>=` but then the `return` check will change as well
		//       It depends on how to rotate the triangle in order to get how we are checking
		res[i] = dot(ap, ab) <= 0
	}

	// Note: this one will result in no back face culling
	// return res[0] == res[1] && res[2] == res[1]
	return res[0] && res[1] && res[2]
}


ray_casting :: proc(tri: Triangle, p: Vec2) -> bool {
	c := 0
	xp, yp := p.x, p.y
	edges := [3][2]Vec2{[2]Vec2{tri.a, tri.b}, [2]Vec2{tri.b, tri.c}, [2]Vec2{tri.c, tri.a}}

	for edge in edges {
		x1, y1 := edge[0].x, edge[0].y
		x2, y2 := edge[1].x, edge[1].y

		if (yp < y1) != (yp < y2) && xp < x1 + ((yp - y1) / (y2 - y1)) * (x2 - x1) {
			c += 1
		}
	}

	return c % 2 == 1
}

edge_function_cross_product :: proc(tri: Triangle, p: Vec2) -> bool {
	xp, yp := p.x, p.y
	edges := [3][2]Vec2{[2]Vec2{tri.a, tri.b}, [2]Vec2{tri.b, tri.c}, [2]Vec2{tri.c, tri.a}}
	res := [3]bool{}

	for e, index in edges {
		x1, y1 := e[0].x, e[0].y
		x2, y2 := e[1].x, e[1].y

		cross_product := (x2 - x1) * (yp - y1) - (y2 - y1) * (xp - x1)

		res[index] = cross_product >= 0
	}

	// Note: Can be improved by checking if all three are either bool
	return res[0] && res[1] && res[2]
}

clamp :: proc(v, min, max: f32) -> f32 {
	return math.max(min, math.min(max, v))
}

limit_to_pi :: proc(value: f32) -> f32 {
	// Here we limit the value to rotate from `0 to PI` and then switch to going from `-PI to 0`
	result := f32(math.mod(value + math.PI, math.TAU))
	return result - math.PI
}

import "core:testing"

@(test)
clamp_test :: proc(t: ^testing.T) {
	testing.expect(t, clamp(3, 0, 1) == 1)
	testing.expect(t, clamp(1.1, 0, 1) == 1)
	testing.expect(t, clamp(0.9, 0, 1) == 0.9)
	testing.expect(t, clamp(0.5, 0, 1) == 0.5)
	testing.expect(t, clamp(-1, 0, 1) == 0)
	testing.expect(t, clamp(-1.2, 0, 1) == 0)
}

