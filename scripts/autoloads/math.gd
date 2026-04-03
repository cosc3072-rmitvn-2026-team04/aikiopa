extends Node
## Math library. Contains game-specific algorithms not implemented by the game
## engine.


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
		assert(coords.x < size_2d.x and coords.y < size_2d.y, "Coordinates out of range.")
		return coords.y * size_2d.x + coords.x


## Hexagonal grid math libary. Since the game exclusively implements
## [constant TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL], no algorithm
## is provided for vertical offset axis.
## @tutorial(Hexagonal Grids from Red Blob Games): https://www.redblobgames.com/grids/hexagons
class HexGrid extends Node:

	# ======================================================================== #
	#region Enums

	## Layout types of offset coordinates for the game's hexagonal grid.
	enum OffsetLayout {
		ODD_R, ## Odd rows get shoved to the right.
		EVEN_R, ## Even rows get shoved to the right.
	}

	## Valid directions of travel in the game's hexagonal grid.
	enum Direction {
		RIGHT,
		TOP_RIGHT,
		TOP_LEFT,
		LEFT,
		BOTTOM_LEFT,
		BOTTOM_RIGHT,
	}

	#endregion
	# ======================================================================== #

	# ======================================================================== #
	#region Coordinate conversion

	## Converts offset coordinates [param coords] in [param offset_layout] to
	## their equivalent cube coordinates.
	static func offset_to_cube(coords: Vector2i, offset_layout: OffsetLayout) -> Vector3i:
		var hex_col: int = coords.x
		var hex_row: int = coords.y
		var parity: int = 0
		match offset_layout:
			OffsetLayout.ODD_R:
				parity = -(coords.y & 0b1)
			OffsetLayout.EVEN_R:
				parity = coords.y & 0b1

		@warning_ignore("integer_division")
		var cube_col: int = hex_col - int((hex_row + parity) / 2)
		var cube_row: int = hex_row
		var cube_slice: int = -(cube_col + cube_row)
		return Vector3i(cube_col, cube_row, cube_slice)


	## Converts cube coordinates [param coords] to their equivalent offset
	## coordinates in [param offset_layout].
	static func cube_to_offset(coords: Vector3i, offset_layout: OffsetLayout) -> Vector2i:
		var parity: int = 0
		match offset_layout:
			OffsetLayout.ODD_R:
				parity = -(coords.y & 0b1)
			OffsetLayout.EVEN_R:
				parity = coords.y & 0b1

		@warning_ignore("integer_division")
		var col: int = coords.x + int((coords.y + parity) / 2)
		var row: int = coords.y
		return Vector2i(col, row)

	#endregion
	# ======================================================================== #


	# ======================================================================== #
	#region Neighbors

	## Returns a list surrounding neighbors for [param coords] in offset
	## coordinates.
	func get_offset_surrounding_neighbors(
			coords: Vector2i,
			offset_layout: OffsetLayout
	) -> Array[Vector2i]:
		const NEIGHBOR_DIRECTIONS: Array[Array] = [
			[
				Vector2i.LEFT,
				Vector2i.RIGHT,
				Vector2i.UP,
				Vector2i.DOWN,
				Vector2i.UP + Vector2i.LEFT,
				Vector2i.DOWN + Vector2i.LEFT,
			],
			[
				Vector2i.LEFT,
				Vector2i.RIGHT,
				Vector2i.UP,
				Vector2i.DOWN,
				Vector2i.UP + Vector2i.RIGHT,
				Vector2i.DOWN + Vector2i.RIGHT,
			],
		]

		var parity: int = 0
		match offset_layout:
			OffsetLayout.ODD_R:
				parity = coords.y & 0b1
			OffsetLayout.EVEN_R:
				parity = coords.y & 0b1 ^ 0b1

		return NEIGHBOR_DIRECTIONS[parity].map(func (direction: Vector2i):
				return coords + direction
		)


	## Returns a list surrounding neighbors for [param coords] in cube
	## coordinates.
	func get_cube_surrounding_neighbors(coords: Vector3i) -> Array[Vector3i]:
		return [
			coords + Vector3i(1, 0, -1), # Right.
			coords + Vector3i(1, -1, 0), # Top Right.
			coords + Vector3i(0, -1, 1), # Top Left.
			coords + Vector3i(-1, 0 ,1), # Left.
			coords + Vector3i(-1, 1, 0), # Bottom Left.
			coords + Vector3i(0, 1, -1), # Bottom Right.
		]

	#endregion
	# ======================================================================== #
