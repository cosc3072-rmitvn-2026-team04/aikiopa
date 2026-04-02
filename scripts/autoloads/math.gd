extends Node
## Math library.


## Matrix-related utility library.
class Matrix extends Node:

	## Converts the linear mapping row-major [param index] to its corresponding 2D
	## space coordinates.[br]
	## [br]
	## [param size_2d] is the dimensions (rows x columns) of the target 2D space.
	static func linear_index_to_coords_2d(index: int, size_2d: Vector2i) -> Vector2i:
		assert(index < size_2d.x * size_2d.y, "Index out of range.")
		@warning_ignore("integer_division")
		return Vector2i(index % size_2d.x, int(index / size_2d.x))


	## Converts the 2D space [param coords] to its corresponding linear mapping
	## row-major index.[br]
	## [br]
	## [param size_2d] is the dimensions (rows x columns) of the source 2D space.
	static func coords_2d_to_linear_index(coords: Vector2i, size_2d: Vector2i) -> int:
		assert(
				coords.x < size_2d.x and coords.y < size_2d.y,
				"Coordinates out of range.")
		return coords.y * size_2d.x + coords.x


## Hexagonal grid math libary.
class HexGrid extends Node:

	# TODO: Implement this.
	static func oddr_to_cube(_coords: Vector2i) -> Vector3i:
		return Vector3i.ZERO
	
	# TODO: Implement this.
	static func evenr_to_cube(_coords: Vector2i) -> Vector3i:
		return Vector3i.ZERO
