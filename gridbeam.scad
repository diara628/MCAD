/*
 *  OpenSCAD GridBeam Library (www.openscad.org)
 *  Copyright (C) 2009 Timothy Schmidt
 *
 *  License: LGPL 2.1 or later
*/

// zBeam(segments) - create a vertical gridbeam strut 'segments' long
// xBeam(segments) - create a horizontal gridbeam strut along the X axis
// yBeam(segments) - create a horizontal gridbeam strut along the Y axis
// shelf(width, height) - create a shelf suitable for use in gridbeam structures width and height in 'segments'
// translateBeam([x, y, z]) - translate gridbeam struts or shelves in X, Y, or Z axes in units 'segments'

include <units.scad>

$beam_width = inch * 1.5;
$beam_hole_radius = inch * 5/16;
$beam_is_hollow = 1;
$beam_wall_thickness = inch * 1/8;
$beam_shelf_thickness = inch * 1/4;

module zBeam(segments) {
	difference() {
		cube([$beam_width, $beam_width, $beam_width * segments]);
		for(i = [0 : segments - 1]) {
			translate([$beam_width / 2, $beam_width + 1, $beam_width * i + $beam_width / 2])
			rotate([90,0,0])
			cylinder(r=$beam_hole_radius, h=$beam_width + 2);

			translate([-1, $beam_width / 2, $beam_width * i + $beam_width / 2])
			rotate([0,90,0])
			cylinder(r=$beam_hole_radius, h=$beam_width + 2);
		}
	if ($beam_is_hollow == 1) {
		translate([$beam_wall_thickness, $beam_wall_thickness, -1])
		cube([$beam_width - $beam_wall_thickness * 2, $beam_width - $beam_wall_thickness * 2, $beam_width * segments + 2]);
	}
	}
}

module xBeam(segments) {
	translate([0,0,$beam_width])
	rotate([0,90,0])
	zBeam(segments);
}

module yBeam(segments) {
	translate([0,0,$beam_width])
	rotate([-90,0,0])
	zBeam(segments);
}

module translateBeam(v) {
	for (i = [0 : $children - 1]) {
		translate(v * $beam_width) child(i);
	}
}

module shelf(width, depth) {
	difference() {
		cube([width * $beam_width, depth * $beam_width, $beam_shelf_thickness]);
		translate([-1,  -1,  -1])
		cube([$beam_width + 2, $beam_width + 2, $beam_shelf_thickness + 2]);
		translate([-1, (depth - 1) * $beam_width, -1])
		cube([$beam_width + 2, $beam_width + 2, $beam_shelf_thickness + 2]);
		translate([(width - 1) * $beam_width, -1, -1])
		cube([$beam_width + 2, $beam_width + 2, $beam_shelf_thickness + 2]);
		translate([(width - 1) * $beam_width, (depth - 1) * $beam_width, -1])
		cube([$beam_width + 2, $beam_width + 2, $beam_shelf_thickness + 2]);
	}
}