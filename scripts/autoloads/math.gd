extends Node
## Math library. Contains game-specific algorithms not implemented by the game
## engine.


## Matrix-related utility library.
class Matrix extends Node:

	## Converts the linear mapping row-major [param index] to its corresponding
	## 2D space coordinates.[br]
	## [br]
	## [param size_2d] is the dimensions (rows x columns) of the target 2D
	## space.[br]
	## [br]
	## Pushes error and returns [code]Vector2i(-1, -1)[/code] if [param index]
	## is out of bounds. Does not handle negative indexes.
	static func linear_index_to_coords_2d(index: int, size_2d: Vector2i) -> Vector2i:
		if (index < 0) or (index >= size_2d.x * size_2d.y):
			push_error("Index out of matrix bounds.")
			return Vector2i(-1, -1)
		@warning_ignore("integer_division")
		return Vector2i(index % size_2d.x, int(index / size_2d.x))


	## Converts the 2D space [param coords] to its corresponding linear mapping
	## row-major index.[br]
	## [br]
	## [param size_2d] is the dimensions (rows x columns) of the source 2D
	## space.[br]
	## [br]
	## Pushes error and returns [code]-1[/code] if [param coords] is out of
	## bounds. Does not handle negative coordinates.
	static func coords_2d_to_linear_index(coords: Vector2i, size_2d: Vector2i) -> int:
		if (
				(coords.x < 0 or coords.y < 0)
				or (coords.x >= size_2d.x or coords.y >= size_2d.y)
		):
			push_error("Coordinates out of matrix bounds.")
			return -1
		return coords.y * size_2d.x + coords.x


## Hexagonal grid math libary. Since the game exclusively implements
## [constant TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL], no algorithm
## is provided for vertical offset axis.[br]
## [br]
## [u]Note:[/u] This library does not provide algorithms to find distances,
## areas, intersection, etc. Please refer to the Online Tutorials below for
## impelemtation details.
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
	#region Constants

	const CUBE_UNIT_VECTORS: Dictionary[Direction, Vector3i] = {
		Direction.RIGHT: Vector3i(1, 0, -1),
		Direction.TOP_RIGHT: Vector3i(1, -1, 0),
		Direction.TOP_LEFT: Vector3i(0, -1, 1),
		Direction.LEFT: Vector3i(-1, 0 ,1),
		Direction.BOTTOM_LEFT: Vector3i(-1, 1, 0),
		Direction.BOTTOM_RIGHT: Vector3i(0, 1, -1),
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

	## Returns the neighboring offset coordinates to [param coords], identified
	## by [param direction] and adjusted for [param offset_layout].
	static func get_offset_neighbor(
			coords: Vector2i,
			direction: Direction,
			offset_layout: OffsetLayout
	) -> Vector2i:
		var cube_coords: Vector3i = offset_to_cube(coords, offset_layout)
		return cube_to_offset(get_cube_neighbor(cube_coords, direction), offset_layout)


	## Returns the list of all neighboring offset coordinates to [param coords]
	## in [param offset_layout].
	static func get_offset_surrounding_neighbors(
			coords: Vector2i,
			offset_layout: OffsetLayout
	) -> Array[Vector2i]:
		var cube_coords: Vector3i = offset_to_cube(coords, offset_layout)
		var cube_surrounding_neighbors: Array[Vector3i] =\
				get_cube_surrounding_neighbors(cube_coords)
		return Array(cube_surrounding_neighbors.map(func (neighbor: Vector3i):
				return cube_to_offset(neighbor, offset_layout)),
				TYPE_VECTOR2I, "", null)


	## Returns the neighboring cube coordinates to [param coords], identified by
	## [param direction].
	static func get_cube_neighbor(coords: Vector3i, direction: Direction) -> Vector3i:
		return coords + CUBE_UNIT_VECTORS[direction]


	## Returns the list of all neighboring cube coordinates to [param coords].
	static func get_cube_surrounding_neighbors(coords: Vector3i) -> Array[Vector3i]:
		return Array(CUBE_UNIT_VECTORS.keys().map(func (direction: Direction):
				return coords + CUBE_UNIT_VECTORS[direction]),
				TYPE_VECTOR3I, "", null)

	#endregion
	# ======================================================================== #
