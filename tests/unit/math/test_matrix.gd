extends GutTest


class TestLinearIndexToCoords2D extends GutTest:
	var test_params_valid: Variant = ParameterFactory.named_parameters(
			["index", "size_2d", "result"],
			[
				[0, Vector2i(6, 7), Vector2i(0, 0)],
				[5, Vector2i(6, 7), Vector2i(5, 0)],
				[6, Vector2i(6, 7), Vector2i(0, 1)],
				[20, Vector2i(6, 7), Vector2i(2, 3)],
				[41, Vector2i(6, 7), Vector2i(5, 6)],
			])


	func test_linear_index_to_coords_2d_valid_params(
			params: Variant = use_parameters(test_params_valid)
	) -> void:
		var result: Vector2i = Math.Matrix.linear_index_to_coords_2d(
				params.index,
				params.size_2d)
		assert_eq(result, params.result)


	var test_params_invalid: Variant = ParameterFactory.named_parameters(
			["index", "size_2d", "result"],
			[
				[42, Vector2i(6, 7), "Index out of matrix bounds."],
				[-1, Vector2i(6, 7), "Index out of matrix bounds."],
				[42, Vector2i(0, 0), "Invalid matrix size."],
				[42, Vector2i(-1, 0), "Invalid matrix size."],
				[42, Vector2i(0, -1), "Invalid matrix size."],
				[42, Vector2i(-1, -1), "Invalid matrix size."],
			])


	func test_linear_index_to_coords_2d_invalid_params(
			params: Variant = use_parameters(test_params_invalid)
	) -> void:
		Math.Matrix.linear_index_to_coords_2d(
				params.index,
				params.size_2d)
		assert_push_error(params.result)


class TestCoords2DToLinearIndex extends GutTest:
	var test_params_valid: Variant = ParameterFactory.named_parameters(
			["coords", "size_2d", "result"],
			[
				[Vector2i(0, 0), Vector2i(6, 7), 0],
				[Vector2i(5, 0), Vector2i(6, 7), 5],
				[Vector2i(0, 1), Vector2i(6, 7), 6],
				[Vector2i(2, 3), Vector2i(6, 7), 20],
				[Vector2i(5, 6), Vector2i(6, 7), 41],
			])


	func test_coords_2d_to_linear_index_valid_params(
			params: Variant = use_parameters(test_params_valid)
	) -> void:
		var result: int = Math.Matrix.coords_2d_to_linear_index(
				params.coords,
				params.size_2d)
		assert_eq(result, params.result)


	var test_params_invalid: Variant = ParameterFactory.named_parameters(
			["coords", "size_2d", "result"],
			[
				[
					Vector2i(6, 7), Vector2i(6, 7),
					"Coordinates out of matrix bounds."
				],
				[
					Vector2i(3, 7), Vector2i(6, 7),
					"Coordinates out of matrix bounds."
				],
				[
					Vector2i(6, 3), Vector2i(6, 7),
					"Coordinates out of matrix bounds."
				],
				[
					Vector2i(-1, 3), Vector2i(6, 7),
					"Coordinates out of matrix bounds."
				],
				[
					Vector2i(3, -1), Vector2i(6, 7),
					"Coordinates out of matrix bounds."
				],
				[
					Vector2i(-1, -1), Vector2i(6, 7),
					"Coordinates out of matrix bounds."
				],
				[
					Vector2i(6, 7), Vector2i(0, 0),
					"Invalid matrix size."
				],
				[
					Vector2i(6, 7), Vector2i(-1, 0),
					"Invalid matrix size."
				],
				[
					Vector2i(6, 7), Vector2i(0, -1),
					"Invalid matrix size."
				],
				[
					Vector2i(6, 7), Vector2i(-1, -1),
					"Invalid matrix size."
				],
			])


	func test_coords_2d_to_linear_index_invalid_params(
			params: Variant = use_parameters(test_params_invalid)
	) -> void:
		Math.Matrix.coords_2d_to_linear_index(
				params.coords,
				params.size_2d)
		assert_push_error(params.result)
