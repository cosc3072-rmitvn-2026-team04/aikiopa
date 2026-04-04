extends GutTest


class TestGetOffsetNeighbor extends GutTest:
	var test_params: Variant = ParameterFactory.named_parameters(
			["coords", "direction", "offset_layout", "result"],
			[
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(1, 0),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.TOP_RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(0, -1),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.TOP_LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(-1, -1),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(-1, 0),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.BOTTOM_LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(-1, 1),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.BOTTOM_RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(0, 1),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(2, 3),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.TOP_RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(2, 2),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.TOP_LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(1, 2),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(0, 3),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.BOTTOM_LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(1, 4),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.BOTTOM_RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(2, 4),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(0, -3),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.TOP_RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(0, -4),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.TOP_LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(-1, -4),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(-2, -3),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.BOTTOM_LEFT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(-1, -2),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.BOTTOM_RIGHT,
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(0, -2),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(1, 0),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.TOP_RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(1, -1),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.TOP_LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(0, -1),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(-1, 0),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.BOTTOM_LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(0, 1),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.Direction.BOTTOM_RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(1, 1),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(2, 3),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.TOP_RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(1, 2),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.TOP_LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(0, 2),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(0, 3),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.BOTTOM_LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(0, 4),
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.Direction.BOTTOM_RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(1, 4),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(0, -3),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.TOP_RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(-1, -4),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.TOP_LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(-2, -4),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(-2, -3),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.BOTTOM_LEFT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(-2, -2),
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.Direction.BOTTOM_RIGHT,
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(-1, -2),
				],
			]
	)


	func test_get_offset_neighbor(
			params: Variant = use_parameters(test_params)
	) -> void:
		var result: Vector2i = Math.HexGrid.get_offset_neighbor(
				params.coords,
				params.direction,
				params.offset_layout)
		assert_eq(result, params.result)


class TestGetOffsetSurroundingNeighbors extends GutTest:
	var test_params: Variant = ParameterFactory.named_parameters(
			["coords", "offset_layout", "result"],
			[
				[
					Vector2i(0, 0),
					Math.HexGrid.OffsetLayout.ODD_R,
					[
						Vector2i(1, 0),
						Vector2i(0, -1),
						Vector2i(-1, -1),
						Vector2i(-1, 0),
						Vector2i(-1, 1),
						Vector2i(0, 1),
					],
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.OffsetLayout.ODD_R,
					[
						Vector2i(2, 3),
						Vector2i(2, 2),
						Vector2i(1, 2),
						Vector2i(0, 3),
						Vector2i(1, 4),
						Vector2i(2, 4),
					],
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.OffsetLayout.ODD_R,
					[
						Vector2i(0, -3),
						Vector2i(0, -4),
						Vector2i(-1, -4),
						Vector2i(-2, -3),
						Vector2i(-1, -2),
						Vector2i(0, -2),
					],
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.OffsetLayout.EVEN_R,
					[
						Vector2i(1, 0),
						Vector2i(1, -1),
						Vector2i(0, -1),
						Vector2i(-1, 0),
						Vector2i(0, 1),
						Vector2i(1, 1),
					],
				],
				[
					Vector2i(1, 3),
					Math.HexGrid.OffsetLayout.EVEN_R,
					[
						Vector2i(2, 3),
						Vector2i(1, 2),
						Vector2i(0, 2),
						Vector2i(0, 3),
						Vector2i(0, 4),
						Vector2i(1, 4),
					],
				],
				[
					Vector2i(-1, -3),
					Math.HexGrid.OffsetLayout.EVEN_R,
					[
						Vector2i(0, -3),
						Vector2i(-1, -4),
						Vector2i(-2, -4),
						Vector2i(-2, -3),
						Vector2i(-2, -2),
						Vector2i(-1, -2),
					],
				],
			]
	)


	func test_get_offset_surrounding_neighbors(
			params: Variant = use_parameters(test_params)
	) -> void:
		var result: Array[Vector2i] = Math.HexGrid.get_offset_surrounding_neighbors(
				params.coords,
				params.offset_layout)
		assert_eq(result, params.result)


class TestGetCubeNeighbor extends GutTest:
	var test_params: Variant = ParameterFactory.named_parameters(
			["coords", "direction", "result"],
			[
				[
					Vector3i(0, 0, 0),
					Math.HexGrid.Direction.RIGHT,
					Vector3i(1, 0, -1),
				],
				[
					Vector3i(0, 0, 0),
					Math.HexGrid.Direction.TOP_RIGHT,
					Vector3i(1, -1, 0),
				],
				[
					Vector3i(0, 0, 0),
					Math.HexGrid.Direction.TOP_LEFT,
					Vector3i(0, -1, 1),
				],
				[
					Vector3i(0, 0, 0),
					Math.HexGrid.Direction.LEFT,
					Vector3i(-1, 0, 1),
				],
				[
					Vector3i(0, 0, 0),
					Math.HexGrid.Direction.BOTTOM_LEFT,
					Vector3i(-1, 1, 0),
				],
				[
					Vector3i(0, 0, 0),
					Math.HexGrid.Direction.BOTTOM_RIGHT,
					Vector3i(0, 1, -1),
				],
				[
					Vector3i(1, 2, -3),
					Math.HexGrid.Direction.RIGHT,
					Vector3i(2, 2, -4),
				],
				[
					Vector3i(1, 2, -3),
					Math.HexGrid.Direction.TOP_RIGHT,
					Vector3i(2, 1, -3),
				],
				[
					Vector3i(1, 2, -3),
					Math.HexGrid.Direction.TOP_LEFT,
					Vector3i(1, 1, -2),
				],
				[
					Vector3i(1, 2, -3),
					Math.HexGrid.Direction.LEFT,
					Vector3i(0, 2, -2),
				],
				[
					Vector3i(1, 2, -3),
					Math.HexGrid.Direction.BOTTOM_LEFT,
					Vector3i(0, 3, -3),
				],
				[
					Vector3i(1, 2, -3),
					Math.HexGrid.Direction.BOTTOM_RIGHT,
					Vector3i(1, 3, -4),
				],
			])


	func test_get_cube_neighbor(
			params: Variant = use_parameters(test_params)
	) -> void:
		var result: Vector3i = Math.HexGrid.get_cube_neighbor(
				params.coords,
				params.direction)
		assert_eq(result, params.result)


class TestGetCubeSurroundingNeighbors extends GutTest:
	var test_params: Variant = ParameterFactory.named_parameters(
			["coords", "result"],
			[
				[
					Vector3i(0, 0, 0),
					[
						Vector3i(1, 0, -1),
						Vector3i(1, -1, 0),
						Vector3i(0, -1, 1),
						Vector3i(-1, 0, 1),
						Vector3i(-1, 1, 0),
						Vector3i(0, 1, -1),
					],
				],
				[
					Vector3i(1, 2, -3),
					[
						Vector3i(2, 2, -4),
						Vector3i(2, 1, -3),
						Vector3i(1, 1, -2),
						Vector3i(0, 2, -2),
						Vector3i(0, 3, -3),
						Vector3i(1, 3, -4),
					],
				],
			])


	func test_get_cube_surrounding_neighbors(
			params: Variant = use_parameters(test_params)
	) -> void:
		var result: Array[Vector3i] = Math.HexGrid.get_cube_surrounding_neighbors(
				params.coords)
		assert_eq(result, params.result)
