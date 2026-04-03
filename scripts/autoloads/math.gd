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


## Hexagonal grid math libary. Since the game exclusively implements
## [constant TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL], no algorithm
## is provided for vertical offset axis.
## @tutorial(Hexagonal Grids from Red Blob Games): https://www.redblobgames.com/grids/hexagons
class HexGrid extends Node:

	## Layout types of offset coordinates for hexagonal grids.
	enum OffsetLayout {
		ODD_R, ## Odd rows get shoved to the right.
		EVEN_R, ## Even rows get shoved to the right.
	}

	# ======================================================================== #
	#region Coordinate conversion

	## Converts offset coordinates [param coords] of [param offset_layout] to
	## their equivalent cube coordinates.
	static func offset_to_cube(
			coords: Vector2i,
			offset_layout: OffsetLayout
	) -> Vector3i:
		var hex_col: int = coords.x
		var hex_row: int = coords.y
		var parity: int = 0
		match offset_layout:
			OffsetLayout.ODD_R:
				parity = -(coords.y & 0b01)
			OffsetLayout.EVEN_R:
				parity = coords.y & 0b01

		@warning_ignore("integer_division")
		var cube_col: int = hex_col - int((hex_row + parity) / 2)
		var cube_row: int = hex_row
		var cube_slice: int = -(cube_col + cube_row)
		return Vector3i(cube_col, cube_row, cube_slice)


	## Converts cube coordinates [param coords] to their equivalent offset
	## coordinates of [param offset_layout].
	static func cube_to_offset(
			coords: Vector3i,
			offset_layout: OffsetLayout
	) -> Vector2i:
		var parity: int = 0
		match offset_layout:
			OffsetLayout.ODD_R:
				parity = -(coords.y & 0b01)
			OffsetLayout.EVEN_R:
				parity = coords.y & 0b01

		@warning_ignore("integer_division")
		var col: int = coords.x + int((coords.y + parity) / 2)
		var row: int = coords.y
		return Vector2i(col, row)

	#endregion
	# ======================================================================== #
