/* 
 * Excerpt from... 
 * 
 * Parametric Encoder Wheel 
 *
 * by Alex Franke (codecreations), March 2012
 * http://www.theFrankes.com
 * 
 * Licenced under Creative Commons Attribution - Non-Commercial - Share Alike 3.0 
*/
 
// rclott 2015-01: 
//   modified to extrude only square or circular cross sections

module arc_circular( cross, radius, degrees ) {
    // This dies a horible death if it's not rendered here 
    // -- sucks up all memory and spins out of control 
    render()
      difference() {
          // Outer ring
          rotate_extrude($fn = 50)
              translate([radius, 0.5*cross, 0])
                  circle(d=cross);
          // Cut half off
          translate([0,-(radius+1),-.5]) 
              cube ([radius+1,(radius+1)*2,cross+1]);
       
          // Cover the other half as necessary
          rotate([0,0,180-degrees])
          translate([0,-(radius+1),-.5]) 
              cube ([radius+1,(radius+1)*2,cross+1]);
       
      }
}

module arc_square( cross, radius, degrees ) {
    // This dies a horible death if it's not rendered here 
    // -- sucks up all memory and spins out of control 
    render()
      difference() {
          // Outer ring
          rotate_extrude($fn = 100)
              translate([radius - 0.5*cross, 0, 0])
                  square([cross,cross]);
          // Cut half off
          translate([0,-(radius+1),-.5]) 
              cube ([radius+1,(radius+1)*2,cross+1]);
       
          // Cover the other half as necessary
          rotate([0,0,180-degrees])
          translate([0,-(radius+1),-.5]) 
              cube ([radius+1,(radius+1)*2,cross+1]);
       
      }
}

// TODO 
// here's another way to make a square cross section circle, 
// the advantage is it can make an ellipse as well as circles
module arc_square2() {
  difference() {
    scale([1,0.5,1]) linear_extrude( height=dia ) circle(d=6,$fn=50);
    scale([1,0.5,1]) translate([0,0,-0.5*dia]) linear_extrude( height=2*dia ) circle(d=6-dia,$fn=50);
  }
}
