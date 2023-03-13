extends "res://canvas/line.gd"

func add_point_sparsely(point):
	.add_point_sparsely(point)
	if Geometry.merge_polygons_2d(points, $Polygon2D.polygon).size() > 0:
		$Polygon2D.polygon = points
