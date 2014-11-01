/*
 * Dan Kirshner - dan_kirshner@yahoo.com
 * Chow Loong Jin - hyperair@debian.org
 *
 * You are welcome to make free use of this software.  Retention of my
 * authorship credit would be appreciated.
 *
 * Version 1.3.  2013-12-01   Correct loop over turns -- don't have early cut-off
 * Version 1.2.  2012-09-09   Use discrete polyhedra rather than linear_extrude()
 * Version 1.1.  2012-09-07   Corrected to right-hand threads!
 */

// Examples:

test_threads ();

module test_threads ($fa=5, $fs=0.1)
{
    // M8
    metric_thread(8, 1.5, 10);

    translate ([10, 0, 0])
    square_thread(8, 1.5, 10);

    translate ([20, 0, 0])
    acme_thread(8, 1.5, 10);

    translate ([30, 0, 0])
    buttress_thread(8, 1.5, 10);

    translate ([40, 0, 0])
    english_thread(1/4, 20, 1);

    // Rohloff hub thread:
    translate ([65, 0, 0])
    metric_thread(34, 1, 10, internal=true, n_starts=6);
}

// ----------------------------------------------------------------------------
use <MCAD/general/utilities.scad>


// ----------------------------------------------------------------------------
// internal - true = clearances for internal thread (e.g., a nut).
//            false = clearances for external thread (e.g., a bolt).
//            (Internal threads should be "cut out" from a solid using
//            difference()).
// n_starts - Number of thread starts (e.g., DNA, a "double helix," has
//            n_starts=2).  See wikipedia Screw_thread.
module metric_thread (
    diameter = 8,
    pitch = 1,
    length = 1,
    internal = false,
    n_starts = 1
)
{
    trapezoidal_thread (
        pitch = pitch,
        length = length,
        upper_angle = 30, lower_angle = 30,
        outer_flat_length = pitch / 8,
        major_radius = diameter / 2,
        minor_radius = diameter / 2 - 5/8 * cos(30) * pitch,
        internal = internal,
        n_starts = n_starts
    );
}

module square_thread (
    diameter = 8,
    pitch = 1,
    length = 1,
    internal = false,
    n_starts = 1
)
{
    trapezoidal_thread (
        pitch = pitch,
        length = length,
        upper_angle = 0, lower_angle = 0,
        outer_flat_length = pitch / 2,
        major_radius = diameter / 2,
        minor_radius = diameter / 2 - pitch / 2,
        internal = internal,
        n_starts = n_starts
    );
}

module acme_thread (
    diameter = 8,
    pitch = 1,
    length = 1,
    internal = false,
    n_starts = 1
)
{
    trapezoidal_thread (
        pitch = pitch,
        length = length,
        upper_angle = 29/2, lower_angle = 29/2,
        outer_flat_length = 0.3707 * pitch,
        major_radius = diameter / 2,
        minor_radius = diameter / 2 - pitch / 2,
        internal = internal,
        n_starts = n_starts
    );
}

module buttress_thread (
    diameter = 8,
    pitch = 1,
    length = 1,
    internal = false,
    n_starts = 1,
    buttress_angles = [3, 33],
    pitch_flat_ratio = 6,       // ratio of pitch to flat length
    pitch_depth_ratio = 3/2     // ratio of pitch to thread depth
)
{
    trapezoidal_thread (
        pitch = pitch,
        length = length,
        upper_angle = buttress_angles[0], lower_angle = buttress_angles[1],
        outer_flat_length = pitch / pitch_flat_ratio,
        major_radius = diameter / 2,
        minor_radius = diameter / 2 - pitch / pitch_depth_ratio,
        internal = internal,
        n_starts = n_starts
    );
}

/**
 * trapezoid_thread():
 * generates a screw with a trapezoidal thread profile
 *
 * pitch = distance between the same part of adjacent teeth
 * length = length of the screw to generate
 * upper_angle = angle between the normal and the upper slant of a tooth
 * lower_angle = ditto, but for the lower slant
 * outer_flat_length = length of the flat part of the tooth along the outside
 * major_radius = radius of the screw until the outer flat
 * minor_radius = radius of the screw until the inner flat
 * internal = if true, generates a thread suitable for difference() to make nuts
 * n_starts = number of threads winding the screw
 */
module trapezoidal_thread (
    pitch,
    length,
    upper_angle,
    lower_angle,
    outer_flat_length,
    major_radius,
    minor_radius,
    internal = false,
    n_starts = 1
)
{
    // trapezoid calculation:
    /*
                upper flat
            ___________________
           /|                 |\
          / |                 | \
    left /__|_________________|__\ right
   angle|   |   lower flat    |   |angle
        |   |                 |   |
        |left                 |right
         flat                 |flat
    */
    // looking at the tooth profile along the upper part of a screw held
    // horizontally, which is a trapezoid longer at the bottom flat
    tooth_height = major_radius - minor_radius;
    left_angle = 90 - upper_angle;
    right_angle = 90 - lower_angle;
    upper_flat = outer_flat_length;
    left_flat = tooth_height / tan (left_angle);
    right_flat = tooth_height / tan (right_angle);
    lower_flat = upper_flat + left_flat + right_flat;
    clearance = 0.3/8 * tooth_height;

    // facet calculation
    facets = $fn > 0 ? $fn :
    max (30, min (2 * PI * minor_radius / $fs, 360 / $fa));
    tmp_fa = 360 / facets;
    $fa = length2twist (length) / round (length2twist (length) / tmp_fa);

    // convert length along the tooth profile to angle of twist of the screw
    function length2twist (length) = length / pitch * (360 / n_starts);
    function twist2length (angle) = angle / (360 / n_starts) * pitch;

    // polar coordinate function representing tooth profile
    function get_radius (angle) =
    minor_radius +
    (
        // left slant
        (angle < length2twist (left_flat)) ?
        tan (left_angle) * twist2length (angle) :

        // upper flat portion
        (angle < length2twist (left_flat + upper_flat)) ?
        tooth_height - (internal ? -clearance : 0):

        // right slant
        (angle < length2twist (lower_flat)) ?
        tan (right_angle) * (lower_flat - twist2length (angle)) :

        // past the end of the tooth
        internal ? 0 : clearance
    );

    // obtain vertex for angle on cross-section
    function get_vertex (angle) =
    conv2D_polar2cartesian ([get_radius (angle), angle]);

    linear_extrude (
        height = length,
        twist = -length2twist (length),
        slices = length2twist (length) / $fa
    )
    union () {
        for (start = [0:n_starts])
        rotate ([0, 0, start / n_starts * 360])
        for (angle = [0:$fa:360]) {
            // draw the profile of the tooth along the perimeter of
            // circle(minor_radius)
            polygon (points=[
                    [0, 0],
                    get_vertex (angle),
                    get_vertex (angle + $fa + 0.1)
                ]);
        }
    }
}

// ----------------------------------------------------------------------------
// Input units in inches.
// Note: units of measure in drawing are mm!
module english_thread(diameter=0.25, threads_per_inch=20, length=1,
                      internal=false, n_starts=1)
{
   // Convert to mm.
   mm_diameter = diameter*25.4;
   mm_pitch = (1.0/threads_per_inch)*25.4;
   mm_length = length*25.4;

   echo(str("mm_diameter: ", mm_diameter));
   echo(str("mm_pitch: ", mm_pitch));
   echo(str("mm_length: ", mm_length));
   metric_thread(mm_diameter, mm_pitch, mm_length, internal, n_starts);
}
