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

	# ======================================================================== #
	#region Coordinate conversion
	# TODO: Document these functions.

	static func oddr_to_cube(coords: Vector2i) -> Vector3i:
		var hex_col: int = coords.x
		var hex_row: int = coords.y
		var parity: int = coords.y & 0b01
		
		@warning_ignore("integer_division")
		var cube_col: int = hex_col - int((hex_row - parity) / 2)
		var cube_row: int = hex_row
		var cube_slice: int = -(cube_col + cube_row)
		return Vector3i(cube_col, cube_row, cube_slice)
	

	static func cube_to_oddr(coords: Vector3i) -> Vector2i:
		var parity: int = coords.y & 0b01
		@warning_ignore("integer_division")
		var col: int = coords.x + int((coords.y - parity) / 2)
		var row: int = coords.y
		return Vector2i(col, row)
	

	static func evenr_to_cube(coords: Vector2i) -> Vector3i:
		var hex_col: int = coords.x
		var hex_row: int = coords.y
		var parity: int = coords.y & 0b01
		
		@warning_ignore("integer_division")
		var cube_col: int = hex_col - int((hex_row + parity) / 2)
		var cube_row: int = hex_row
		var cube_slice: int = -(cube_col + cube_row)
		return Vector3i(cube_col, cube_row, cube_slice)


	static func cube_to_evenr(coords: Vector3i) -> Vector2i:
		var parity: int = coords.y & 0b01
		@warning_ignore("integer_division")
		var col: int = coords.x + int((coords.y + parity) / 2)
		var row: int = coords.y
		return Vector2i(col, row)

	#endregion
	# ======================================================================== #
