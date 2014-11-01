// array functions
// by david powell 
// licence LGPL V2 or later 
//
// this lib provides 2 functions 
// Cubic_Array() , and Radial_Array()
//
//Radial_Array(a,n,r){child object}
// produces a clockwise radial array of child objects rotated around the local z axis   
// a= interval angle 
// n= number of objects 
// r= radius distance 
//
module array_polar(a,n,r)
{
	for (k=[0:n-1])
	{
		rotate([0,0,-(a*k)])
			translate([0,r,0])
			for (k = [0:$children-1]) children(k);
	}
}
