#gdlint: disable=class-definitions-order
extends GutTest


class TestOffsetToCube extends GutTest:
	var test_params: Variant = ParameterFactory.named_parameters(
			["coords", "offset_layout", "result"],
			[
				[
					Vector2i(0, 0),
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector3i(0, 0, 0),
				],
				[
					Vector2i(-2, -2),
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector3i(-1, -2, 3),
				],
				[
					Vector2i(1, 1),
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector3i(1, 1, -2),
				],
				[
					Vector2i(0, 0),
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector3i(0, 0, 0),
				],
				[
					Vector2i(-2, -2),
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector3i(-1, -2, 3),
				],
				[
					Vector2i(1, 1),
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector3i(0, 1, -1),
				],
			])


	func test_offset_to_cube(params: Variant = use_parameters(test_params)) -> void:
		var result: Vector3i = Math.HexGrid.offset_to_cube(
				params.coords,
				params.offset_layout)
		assert_eq(result, params.result)


class TestCubeToOffset extends GutTest:
	var test_params: Variant = ParameterFactory.named_parameters(
			["coords", "offset_layout", "result"],
			[
				[
					Vector3i(0, 0, 0),
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(0, 0),
				],
				[
					Vector3i(-1, -2, 3),
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(-2, -2),
				],
				[
					Vector3i(1, 1, -2),
					Math.HexGrid.OffsetLayout.ODD_R,
					Vector2i(1, 1),
				],
				[
					Vector3i(0, 0, 0),
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(0, 0),
				],
				[
					Vector3i(-1, -2, 3),
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(-2, -2),
				],
				[
					Vector3i(0, 1, -1),
					Math.HexGrid.OffsetLayout.EVEN_R,
					Vector2i(1, 1),
				],
			])


	func test_cube_to_offset(params: Variant = use_parameters(test_params)) -> void:
		var result: Vector2i = Math.HexGrid.cube_to_offset(
				params.coords,
				params.offset_layout)
		assert_eq(result, params.result)
