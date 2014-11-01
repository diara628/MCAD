// array functions
// by david powell 
// licence LGPL V2 or later 
//
// this lib provides 2 functions 
// Cubic_Array() , and Radial_Array()
//
//Cubic_Array(sx,sy,sz,nx,ny,nz,center){childobject}
//  produces a cubic grid of child objects 
//  sx,sy,sz = spacing for each axis 
//  nx,ny,nz and number of objects on each axis 
//  center = true/false on if geometery is centered or not

// main lib modules
module array_rectangular(sx,sy,sz,nx,ny,nz,center)
{
	if (center==true)
	{
		translate([-(((nx+1)*sx)/2),-(((ny+1)*sy)/2),-(((nz+1)*sz)/2)])
		{
			for(x=[1:nx])
			{
				for(y=[1:ny])
				{
					for(z=[1:nz])
					{
						translate([x*sx,y*sy,z*sz])
							for (k = [0:$children-1]) children(k,center=true);;
					}
				}
			}
		}
	}
	else
	{
		translate([0,0,0])
		{
			for(x=[1:nx])
			{
				for(y=[1:ny])
				{
					for(z=[1:nz])
					{
						translate([x*sx,y*sy,z*sz])
							for (k = [0:$children-1]) children(k);
					}
				}
			}
		}
	}
}
