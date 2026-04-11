#gdlint: disable=class-definitions-order
extends GutTest


class TestGetOffsetAreaFromRangeAt extends GutTest:
	var test_params_valid: Variant = ParameterFactory.named_parameters(
			["coords", "range_distance", "offset_layout", "result"],
			[
				[
					Vector2i(0, 0), 0, Math.HexGrid.OffsetLayout.ODD_R,
					Array([
						Vector2i(0, 0),
					], TYPE_VECTOR2I, "", null),
				],
				[
					Vector2i(0, 0), 1, Math.HexGrid.OffsetLayout.ODD_R,
					Array([
						Vector2i(0, 0),
						Vector2i(1, 0),
						Vector2i(0, -1),
						Vector2i(-1, -1),
						Vector2i(-1, 0),
						Vector2i(-1, 1),
						Vector2i(0, 1),
					], TYPE_VECTOR2I, "", null),
				],
				[
					Vector2i(0, 0), 2, Math.HexGrid.OffsetLayout.ODD_R,
					Array([
						Vector2i(0, 0),
						Vector2i(1, 0),
						Vector2i(0, -1),
						Vector2i(-1, -1),
						Vector2i(-1, 0),
						Vector2i(-1, 1),
						Vector2i(0, 1),
						Vector2i(2, 0),
						Vector2i(1, -1),
						Vector2i(1, -2),
						Vector2i(0, -2),
						Vector2i(-1, -2),
						Vector2i(-2, -1),
						Vector2i(-2, 0),
						Vector2i(-2, 1),
						Vector2i(-1, 2),
						Vector2i(0, 2),
						Vector2i(1, 2),
						Vector2i(1, 1),

					], TYPE_VECTOR2I, "", null),
				],
				[
					Vector2i(0, 0), 0, Math.HexGrid.OffsetLayout.EVEN_R,
					Array([
						Vector2i(0, 0),
					], TYPE_VECTOR2I, "", null),
				],
				[
					Vector2i(0, 0), 1, Math.HexGrid.OffsetLayout.EVEN_R,
					Array([
						Vector2i(0, 0),
						Vector2i(1, 0),
						Vector2i(1, -1),
						Vector2i(0, -1),
						Vector2i(-1, 0),
						Vector2i(0, 1),
						Vector2i(1, 1),
					], TYPE_VECTOR2I, "", null),
				],
				[
					Vector2i(0, 0), 2, Math.HexGrid.OffsetLayout.EVEN_R,
					Array([
						Vector2i(0, 0),
						Vector2i(1, 0),
						Vector2i(1, -1),
						Vector2i(0, -1),
						Vector2i(-1, 0),
						Vector2i(0, 1),
						Vector2i(1, 1),
						Vector2i(2, 0),
						Vector2i(2, -1),
						Vector2i(1, -2),
						Vector2i(0, -2),
						Vector2i(-1, -2),
						Vector2i(-1, -1),
						Vector2i(-2, 0),
						Vector2i(-1, 1),
						Vector2i(-1, 2),
						Vector2i(0, 2),
						Vector2i(1, 2),
						Vector2i(2, 1),
					], TYPE_VECTOR2I, "", null),
				],
			])


	func test_get_offset_area_from_range_at_valid_params(
			params: Variant = use_parameters(test_params_valid)
	) -> void:
		var result: Array[Vector2i] = Math.HexGrid.get_offset_area_from_range_at(
				params.coords,
				params.range_distance,
				params.offset_layout)
		result.sort()
		var param_result: Array[Vector2i] = params.result
		param_result.sort()
		assert_eq(result, param_result)


	var test_params_invalid: Variant = ParameterFactory.named_parameters(
			["coords", "range_distance", "offset_layout", "result"],
			[
				[
					Vector2i(0, 0), -1, Math.HexGrid.OffsetLayout.ODD_R,
					"Parameter 'range_distance' must not be negative.",
				],
				[
					Vector2i(0, 0), -1, Math.HexGrid.OffsetLayout.EVEN_R,
					"Parameter 'range_distance' must not be negative.",
				],
			])


	func test_get_cube_area_from_range_at_invalid_params(
			params: Variant = use_parameters(test_params_invalid)
	) -> void:
		Math.HexGrid.get_offset_area_from_range_at(
				params.coords,
				params.range_distance,
				params.offset_layout)
		assert_push_error(params.result)


class TestGetCubeAreaFromRangeAt extends GutTest:
	var test_params_valid: Variant = ParameterFactory.named_parameters(
			["coords", "range_distance", "result"],
			[
				[
					Vector3i(0, 0, 0), 0,
					Array([
						Vector3i(0, 0, 0),
					], TYPE_VECTOR3I, "", null),
				],
				[
					Vector3i(0, 0, 0), 1,
					Array([
						Vector3i(0, 0, 0),
						Vector3i(1, 0, -1),
						Vector3i(1, -1, 0),
						Vector3i(0, -1, 1),
						Vector3i(-1, 0, 1),
						Vector3i(-1, 1, 0),
						Vector3i(0, 1, -1),
					], TYPE_VECTOR3I, "", null),
				],
				[
					Vector3i(0, 0, 0), 2,
					Array([
						Vector3i(0, 0, 0),
						Vector3i(1, 0, -1),
						Vector3i(1, -1, 0),
						Vector3i(0, -1, 1),
						Vector3i(-1, 0, 1),
						Vector3i(-1, 1, 0),
						Vector3i(0, 1, -1),
						Vector3i(2, 0, -2),
						Vector3i(2, -1, -1),
						Vector3i(2, -2, 0),
						Vector3i(1, -2, 1),
						Vector3i(0, -2, 2),
						Vector3i(-1, -1, 2),
						Vector3i(-2, 0, 2),
						Vector3i(-2, 1, 1),
						Vector3i(-2, 2, 0),
						Vector3i(-1, 2, -1),
						Vector3i(0, 2, -2),
						Vector3i(1, 1, -2),
					], TYPE_VECTOR3I, "", null),
				],
			])


	func test_get_cube_area_from_range_at_valid_params(
			params: Variant = use_parameters(test_params_valid)
	) -> void:
		var result: Array[Vector3i] = Math.HexGrid.get_cube_area_from_range_at(
				params.coords,
				params.range_distance)
		result.sort()
		var param_result: Array[Vector3i] = params.result
		param_result.sort()
		assert_eq(result, param_result)


	var test_params_invalid: Variant = ParameterFactory.named_parameters(
			["coords", "range_distance", "result"],
			[
				[
					Vector3i(0, 0, 0), -1,
					"Parameter 'range_distance' must not be negative.",
				],
			])


	func test_get_cube_area_from_range_at_invalid_params(
			params: Variant = use_parameters(test_params_invalid)
	) -> void:
		Math.HexGrid.get_cube_area_from_range_at(
				params.coords,
				params.range_distance)
		assert_push_error(params.result)
