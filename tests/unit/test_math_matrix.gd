extends GutTest


class TestLinearIndexToCoords2D extends GutTest:
	var valid_params: Variant = ParameterFactory.named_parameters(
			["index", "size_2d", "result"],
			[
				[0, Vector2i(6, 7), Vector2i(0, 0)],
				[5, Vector2i(6, 7), Vector2i(5, 0)],
				[6, Vector2i(6, 7), Vector2i(0, 1)],
				[20, Vector2i(6, 7), Vector2i(2, 3)],
				[41, Vector2i(6, 7), Vector2i(5, 6)],
			])


	func test_linear_index_to_coords_2d_valid_params(
			params: Variant = use_parameters(valid_params)
	):
		var result: Vector2i = Math.Matrix.linear_index_to_coords_2d(
				params.index,
				params.size_2d)
		assert_eq(result, params.result)


	func test_linear_index_to_coords_2d_invalid_params():
		Math.Matrix.linear_index_to_coords_2d(42, Vector2i(6, 7))
		assert_push_error("Index out of matrix bounds.")


class TestCoords2DToLinearIndex extends GutTest:
	var valid_params: Variant = ParameterFactory.named_parameters(
			["coords", "size_2d", "result"],
			[
				[Vector2i(0, 0), Vector2i(6, 7), 0],
				[Vector2i(5, 0), Vector2i(6, 7), 5],
				[Vector2i(0, 1), Vector2i(6, 7), 6],
				[Vector2i(2, 3), Vector2i(6, 7), 20],
				[Vector2i(5, 6), Vector2i(6, 7), 41],
			])


	func test_coords_2d_to_linear_index_valid_params(
			params: Variant = use_parameters(valid_params)
	):
		var result: int = Math.Matrix.coords_2d_to_linear_index(
				params.coords,
				params.size_2d)
		assert_eq(result, params.result)


	func test_coords_2d_to_linear_index_invalid_params():
		Math.Matrix.coords_2d_to_linear_index(Vector2i(6, 7), Vector2i(6, 7))
		assert_push_error("Coordinates out of matrix bounds.")
