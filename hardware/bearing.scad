/*
 * Bearing model.
 *
 * Originally by Hans Häggström, 2010.
 * Dual licenced under Creative Commons Attribution-Share Alike 3.0 and LGPL2 or later
 */

/*
change list 13/6/2013
 added ,604,606,607,628,629,6200,6201,6202,6203,6205,6206   bearing sizes 
*/

include <MCAD/units/metric.scad>
include <MCAD/materials/materials.scad>

BEARING_INNER_DIAMETER = 0;
BEARING_OUTER_DIAMETER = 1;
BEARING_WIDTH = 2;

// Common bearing names
SkateBearing = 608;

// Bearing dimensions
// model == XXX ? [inner dia, outer dia, width]:
function bearingDimensions(model) =
	model == 603 ? [3*length_mm, 10*length_mm, 4*length_mm]:
	model == 604 ? [4*length_mm, 12*length_mm, 4*length_mm]:
	model == 606 ? [6*length_mm, 17*length_mm, 6*length_mm]:
	model == 607 ? [7*length_mm, 19*length_mm, 6*length_mm]:
	model == 608 ? [8*length_mm, 22*length_mm, 7*length_mm]:
	model == 623 ? [3*length_mm, 10*length_mm, 4*length_mm]:
	model == 624 ? [4*length_mm, 13*length_mm, 5*length_mm]:
	model == 625 ? [5*length_mm, 16*length_mm, 5*length_mm]:
	model == 626 ? [6*length_mm, 19*length_mm, 6*length_mm]:
	model == 627 ? [7*length_mm, 22*length_mm, 7*length_mm]:
	model == 628 ? [8*length_mm, 24*length_mm, 8*length_mm]:
	model == 629 ? [9*length_mm, 26*length_mm, 8*length_mm]:
	model == 688 ? [8*length_mm, 16*length_mm, 4*length_mm]:
	model == 698 ? [8*length_mm, 19*length_mm, 6*length_mm]:
	model == 6200 ? [10*length_mm, 30*length_mm, 9*length_mm]:
	model == 6201 ? [12*length_mm, 32*length_mm, 10*length_mm]:
	model == 6202 ? [15*length_mm, 35*length_mm, 11*length_mm]:
	model == 6203 ? [17*length_mm, 40*length_mm, 12*length_mm]:
	model == 6205 ? [25*length_mm, 52*length_mm, 15*length_mm]:
	model == 6206 ? [30*length_mm, 62*length_mm, 16*length_mm]:

//
//todo:-
// add
//mr105		5			10			4
//mr115		5			11			4
//mr126		6			12			4
// and other standard sizes   
//

  [8*length_mm, 22*length_mm, 7*length_mm]; // this is the default


function bearingWidth(model) = bearingDimensions(model)[BEARING_WIDTH];
function bearingInnerDiameter(model) = bearingDimensions(model)[BEARING_INNER_DIAMETER];
function bearingOuterDiameter(model) = bearingDimensions(model)[BEARING_OUTER_DIAMETER];

module bearing(pos=[0,0,0], angle=[0,0,0], model=SkateBearing, outline=false,
                material=Steel, sideMaterial=Brass, center=false) {
  // Common bearing names
  model =
    model == "Skate" ? 608 :
    model;

  w = bearingWidth(model);
  innerD = outline==false ? bearingInnerDiameter(model) : 0;
  outerD = bearingOuterDiameter(model);

  innerRim = innerD + (outerD - innerD) * 0.2;
  outerRim = outerD - (outerD - innerD) * 0.2;
  midSink = w * 0.1;

  centering_pos = (center) ? [0, 0, -w/2] : [0, 0, 0];

  translate(pos) rotate(angle) translate (centering_pos) union() {
    color(material)
      difference() {
        // Basic ring
        Ring([0,0,0], outerD, innerD, w, material, material);

        if (outline==false) {
          // Side shields
          Ring([0,0,-epsilon], outerRim, innerRim, epsilon+midSink, sideMaterial, material);
          Ring([0,0,w-midSink], outerRim, innerRim, epsilon+midSink, sideMaterial, material);
        }
      }
  }

  module Ring(pos, od, id, h, material, holeMaterial) {
    color(material) {
      translate(pos)
        difference() {
          cylinder(r=od/2, h=h,  $fs = 0.01);
          color(holeMaterial)
            translate([0,0,-10*epsilon])
              cylinder(r=(id/2)+epsilon, h=h+20*epsilon,  $fs = 0.01);
        }
    }
  }

}


