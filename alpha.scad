use <arc.scad>;
use <ascii.scad>;

// Technical Lettering used in Drafting
//   see Wikipedia:
//   http://en.wikipedia.org/wiki/Engineering_drawing#Technical_lettering
//
// Historical (pre-computers) technical lettering styles can be found
// in various references:
//   http://p3cdn4static.sharpschool.com/UserFiles/Servers/Server_926913/Image/Migration/vertical_lettering.jpg
//   http://1.bp.blogspot.com/_nm98fXNhUco/TDHJMNGx9lI/AAAAAAAAAGM/JcZuvE6f_g8/s1600/Picture8.jpg
//   http://3.bp.blogspot.com/_nm98fXNhUco/TDHIM8VktBI/AAAAAAAAAF8/CSbxvOlo8pk/s1600/Picture5.jpg
//
// In modern era, 
//   European standards specify ISO-3098
//   American standards specify ANSI-Y14.5M-2009
//
// An interesting discussion on this FreeCAD discussion forum:
// http://forum.freecadweb.org/viewtopic.php?f=8&t=4349
//
// from which we find the following ttf fonts, specifically designed
// to follow these technical lettering drafting standards
// 
// 1.  Micronus / Y14.5M-2009
//       http://www.fontspace.com/micronus/y145m-2009
// 2.  osifont / ISO-3098
//       http://code.google.com/p/osifont/
//
// This OpenSCAD module uses the pre-computer styles, which in turn
// seem to have been the model for the ANSI standard.  Furthermore, an
// approximation is made for some letters to avoid the missing ellipse
// extrusion capability in OpenSCAD.
//
// Wikipedia notes that ISO standards implemented certain features to 
// improve legibility (except for the "one" glyph, I don't see these
// features in the osifont ISO-look-alike font):
//
//   (a) serifed "one"
//   (b) barred "seven"
//   (c) open "four", "six" and "nine"
//   (d) rounded top "three"
//
// I have implemented these, except "d" which  I don't understand.  
// And furthemore, I chose to add the following for legibility reasons:
//
//   (e) a diagonal bar through my zero glyph
//   (f) a bar on the "seven"
//
//
// Each letter is descibed by a combination of line and circular
// segments (some letters actually require elliptical segments, 
// for which I substituted ovals instead).
// 
// Each line segment is described by two points, beginning and ending,
// in a vector as follows:  
//   [x0,y0, x1,y1]
//
// Each cicular segment is described by a center point, radius, 
// and beginning and ending angle in a vector as follows:
//   [x0,y0, rad, abeg,aend]
//
// Each letter is described in a vector whose elements are as follows:
// [ 
//   ascii_code,
//   name, 
//   width, 
//   vector_of_line_segments, 
//   vector_of_circular_segments 
// ]
//
// The diagrams available to me seemed to use the following grid.
// Not sure if this is spelled out in the two standards or not, but 
// it's easy enough to scale these letters to any desired size.
//
// Uppercase letters are all constructed in a grid which is 6 units tall,
// and most characters are either 5 or 6 units wide.  Lowercase letters
// are typically 4 units tall, with a few letters being 6 units tall. 
// Those letters with descenders extend two units below the baseline.
// (per the referenced lettering charts shown above).
//
// Stroke thickness should be 10% of character height.
//
// I've assigned the arbitrary coordinate system to the grid:
//
//     0 1 2 3 4 5 6 7 8 9 
//   6 + + + + + + + + + +
//   5 + + + + + + + + + +
//   4 + + + + + + + + + +
//   3 + + + + + + + + + +
//   2 + + + + + + + + + +
//   1 + + + + + + + + + +
//   0 + + + + + + + + + +
//  -1 + + + + + + + + + +
//  -2 + + + + + + + + + +
//     0 1 2 3 4 5 6 7 8 9 
//
//
// Letters are drawn by extruded squares or circles.  It would be
// straightforward to draw the with any arbitrary extruded polygon
// with only minor changes to the code.
//
// One note on the "end caps" of the lines. For circular letters,
// it's easy to make all end caps a sphere.  But for rectangular 
// cross section letters, a similar cap of a truncated pyramid 
// doesn't look as good when line segments join.  To properly join
// such line segments as a bigger headache than I wanted to endure.
// I compromised by making circular segments have truncated
// pyramidal endcaps, but line segments have half a cube (the line 
// segment is essentially extended by half the cross section length).
// This is an adequate compromise, and frankly I liked the circular 
// cross section letters best, so I didn't pursue this further.

letters=[
  [   0, "NUL",   6,  [[0,0, 6,0], [6,0, 6,6], [6,6, 0,6], [0,6, 0,0] ], [] ], // 0x00
  [   1, "SOH",   6,  [[0,0, 0,6], [0,6, 6,6]], [] ],
  [   2, "STX",   5,  [[0,0, 4,0], [2,0, 2,6]], [] ],
  [   3, "ETX",   6,  [[0,0, 6,0], [6,0, 6,6]], [] ],
  [   4, "EOT",   6,  [[0,6, 4,3], [4,3, 2,3], [2,3, 6,0]], [] ],
  [   5, "ENQ",   6,  [[0,0, 6,0], [6,0, 6,6], [6,6, 0,6], [0,6, 0,0], [0,0, 6,6,], [0,6, 6,0] ], [] ], 
  [   6, "ACK",   6,  [[0,2, 2,0], [2,0, 6,6]], [] ],
  [   7, "BEL",   6,  [[0,3, 6,3], [2,3, 2,0], [2,0, 0,0,], [4,3, 4,0], [4,0, 6,0]], [[3,3,3,0,180]] ],
  [   8, "BS",    6,  [[6,3, 6,0], [1,3, 1.5,4], [1,3, 0.5,4]], [[3.5,3,2.5,0,180]] ],
  [   9, "HT",    6,  [[0,3, 6,3], [0,0, 6,3], [0,6, 6,3]], [] ],
  [  10, "LF",    6,  [[0,1.5, 6,1.5], [0,3, 6,3], [0,4.5, 6,4.5]], [] ],
  [  11, "VT",    6,  [[3,0, 3,6], [3,0, 0,6], [3,0,6,6]], [] ],
  [  12, "FF",    6,  [ [3,0,3,6], [3,0, 0,4], [3,0, 6,4],  [3,2, 0,6], [3,2, 6,6] ], [] ],
  [  13, "CR",    6,  [[0,3, 6,3], [0,3, 6,6], [0,3, 6,0]], [] ],
  [  14, "SO",    6,  [[1,1, 5,5], [5,1, 1,5]], [[3,3, 3, 0,360]] ],
  [  15, "SI",    6,  [], [[3,3, 3, 0,360], [3,3, 0.4, 0,360]] ],
  [  16, "DLE",   6,  [[0,0, 6,0], [6,0, 6,6], [6,6, 0,6], [0,6, 0,0], [0,3, 6,3] ], [] ], // 0x10
  [  17, "DC1",   6,  [[3,3,3,6], [3,3,6,3]], [[3,3, 3, 0,360]] ],
  [  18, "DC2",   6,  [[3,3,3,0], [3,3,6,3]], [[3,3, 3, 0,360]] ],
  [  19, "DC3",   6,  [[3,3,3,0], [3,3,0,3]], [[3,3, 3, 0,360]] ],
  [  20, "DC4",   6,  [[3,3,3,6], [3,3,0,3]], [[3,3, 3, 0,360]] ],
  [  21, "NAK",   6,  [[0,2, 2,0], [2,0, 6,6], [2,3, 6,3]], [] ],
  [  22, "SYN",   6,  [[0,0, 2,0], [2,0, 2,6], [2,6, 4,6], [4,6, 4,0], [4,0, 6,0]], [] ],
  [  23, "ETB",   6,  [[0,3, 6,3], [6,1, 6,5]], [] ],
  [  24, "CAN",   6,  [[0,0, 6,6], [0,6, 6,0], [0,0, 6,0], [0,6, 6,6]], [] ],
  [  25, "EM",    3,  [[1,0, 1,6]], [[1,3, 0.4, 0,360]] ],
  [  26, "SUB",   4,  [[0.6,2.6, 1.1,2], [1.5,0, 1.5,-0.5]], [[2,4,2,45,225], [-0.5,0.8,2,0,45]] ],
  [  27, "ESC",   6,  [[0,3,6,3]], [[3,3, 3, 0,360]] ],
  [  28, "FS",    6,  [[3,3,3,6], [3,3,0,3], [0,0, 6,0], [6,0, 6,6], [6,6, 0,6], [0,6, 0,0]], [] ],
  [  29, "GS",    6,  [[3,3,3,0], [3,3,0,3], [0,0, 6,0], [6,0, 6,6], [6,6, 0,6], [0,6, 0,0]], [] ],
  [  30, "RS",    6,  [[3,3,3,0], [3,3,6,3], [0,0, 6,0], [6,0, 6,6], [6,6, 0,6], [0,6, 0,0]], [] ],
  [  31, "US",    6,  [[3,3,3,6], [3,3,6,3], [0,0, 6,0], [6,0, 6,6], [6,6, 0,6], [0,6, 0,0]], [] ],
  [  32, " ",     6,  [], [] ], // 0x20
  [  33, "!",   1,  [ [0,6, 0,2], [0,0, 0,0.5] ], [] ],
  [  34, "\"",  2,  [ [0.5,6, 0,5], [1.5,6, 1,5] ], [] ],
  [  35, "#",   6,  [ [1,0, 3,6], [3,0, 5,6], [0,2, 6,2], [0,4, 6,4] ], [] ],
  [  36, "$",   3,  [ [1,0, 1,6], [2,0, 2,6], [1,1, 2,1], [1,3, 2,3], [1,5, 2,5]],  [ [1,2, 1, 190,270], [2,2, 1, 270,90], [1,4, 1, 90,270], [2,4, 1, 0, 90], ] ],
  [  37, "%",   6,  [ [0,0, 4,6] ], [ [1,5, 1, 0,360], [3,1, 1, 0,360] ] ],
  [  38, "&",   5,  [[1.30,4.25, 5,0],[2.6,4.25, 0.7, 2.50], [1.75,0, 3,0]  ], [ [2,5, 1, -45, 225], [3,2, 2, -90, 0], [1.75,1.5, 1.5, 135, -90], ] ],
  [  39, "'",   1,  [ [ 0.5,6, 0,5] ], [] ],
  [  40, "(",   1,  [], [[6,3, 6, 152,208]] ],
  [  41, ")",   1,  [], [[-5,3, 6, -28,28]] ],
  [  42, "*",   6,  [[1,3, 4,3], [1.5,1.5, 3.5,4.5], [1.5,4.5, 3.5,1.5]], [] ],
  [  43, "+",   6,  [[1.5,3, 4.5,3], [3,1.5, 3,4.5]], [] ],
  [  44, ",",   6,  [[0.5,0.5, 0.5,0], [0.5,0, 0,-1] ], [] ],
  [  45, "-",   6,  [[1.5,3, 4.5,3]], [] ],
  [  46, ".",   6,  [[0.5,0.5, 0.5,0]], [] ],
  [  47, "/",   6,  [[0,0, 4,6]], [] ],
  [  48, "O",   5,  [[1,1, 4,5], [0,2.5, 0,3.5], [5,2.5, 5,3.5] ], [[2.5,2.5, 2.5, 180, 360], [2.5,3.5, 2.5, 0, 180]] ], // 0x30
  [  49, "1",   2,  [ [1,0, 1,6], [0,5.5, 1,6], [0,0, 2,0] ], [] ],
  [  50, "2",   5,  [[0,0, 5,0], [2,6, 3,6]],  [ [2, 4.5,  1.5,    90, 150], [3, 4.5,  1.5,  270, 90], [3, 0,  3,    90, 180], ] ],
  [  51, "3",   5,  [[1.5,0, 3.5,0], [2.5,3, 3.5,3], [2,6, 3,6]],  [ [1.5, 1.5,  1.5, 190, 270], [3.5, 1.5,  1.5,  270, 90], [2, 4.5,  1.5,    90, 150], [3, 4.5,  1.5,  270, 90], ] ],
  [  52, "4",   5,  [[0,1.5, 5,1.5], [0,1.5, 4,6], [4,6,, 4,0] ], [] ], 
  [  53, "5",   5,  [[0,6, 5,6], [0,6, 0,3], [2,4, 3,4], [2,0, 3,0] ], [ [1.75,2, 2, 90, 150], [3,2, 2, -90, 90], [1.75,2, 2, -150, -90], ] ],
  [  54, "6",   5,  [[2,6, 3,6], [2,4, 3,4], [2,0, 3,0], [0,4, 0,2] ], [[2,2, 2, 90, 270], [3,2, 2, 270, 90], [2,4, 2, 90, 180], [3,4, 2, 30, 90] ] ],
  [  55, "7",   5,  [[0,6, 5,6], [5,6, 2.5,2.5], [2,3.5, 4.3,3.5]], [ [5,0, 3.5, 135, 180] ] ],
  [  56, "8",   5,  [[1.5,0, 3.5,0], [1.5,3, 3.5,3], [2,6, 3,6]],  [ [1.5, 1.5,  1.5,  90, 270], [3.5, 1.5,  1.5,  270, 90], [2, 4.5,  1.5,  90, 270], [3, 4.5,  1.5,  270, 90], ] ],
  [  57, "9",   5,  [[2,6, 3,6], [2,2, 3,2], [2,0, 3,0], [5,4, 5,2] ], [[2,4, 2, 90, 270], [3,4, 2, 270, 90], [2,2, 2, 200, 270], [3,2, 2, 270, 360] ] ],
  [  58, ":",   1,  [[0.5,4, 0.5,3.5], [0.5,0.5, 0.5,0] ], [] ],
  [  59, ":",   1,  [[0.5,4, 0.5,3.5], [0.5,0.5, 0.5,0], [0.5,0, 0,-1]], [] ],
  [  60, "<",   3,  [[0,3, 3,5], [0,3, 3,1]], [] ],
  [  61, "=",   6,  [[0,3.25, 3,3.25], [0,1.75, 3,1.75] ], [] ],
  [  61, "<",   3,  [[3,3, 0,5], [3,3, 0,1]], [] ],
  [  63, "?",   3,  [[1.5,0, 1.5,-0.5], [2,2.8, 2.5,3.3], [1.5,1.5, 1.5,0.75] ], [[1.5,4.5, 1.5, -45,180], [3,1.7, 1.5, 135, 180]] ],
  [  64, "@",   5,  [[0,2.5, 0,3.5], [5,1.75, 5,3.5], [3.75,1.75, 3.75,4.25] ], [ [2.5,2.5, 2.5, 180, 285], [2.5,3.5, 2.5, 0, 180], [2.5,3, 1.25, 0, 360], [4.375,1.75, 0.625, 180,360]] ], // 0x40
  [  65, "A",   6,  [ [0,0, 3,6], [3,6, 6,0], [1,2, 5,2] ], [] ],
  [  66, "B",   5,  [[0,0, 0,6], [0,3, 3.5,3], [0,6, 3,6], [0,0, 3.5,0] ], [[3.5, 1.5,  1.5,  360-90, 90], [3.0, 4.5,  1.5,  360-90, 90]] ],
  [  67, "C",   5,  [ ], [[3,3, 3, 60, 360-45]] ],
  [  68, "D",   5,  [[0,0, 0,6], [0,0, 2,0], [0,6, 2,6] ], [[2,3, 3, 360-90, 90]] ],
  [  69, "E",   5,  [ [0,0, 0,6], [0,6, 5,6], [0,3, 4,3], [0,0, 5,0] ], [] ],
  [  70, "F",   5,  [ [0,0, 0,6], [0,6, 5,6], [0,3, 4,3] ], [] ],
  [  71, "G",   5,  [ [5,0.9, 5,3], [5,3, 3,3] ], [[3,3, 3, 60, 312]] ],
  [  72, "H",   5,  [ [0,0, 0,6], [0,3, 5,3], [5,0, 5,6] ], [] ],
  [  73, "I",   1,  [ [0,0, 0,6] ], [] ],
  [  74, "J",   5,  [[5,2, 5,6]], [[2.5,2.5, 2.5, 200, 350]] ],
  [  75, "K",   5,  [ [0,0, 0,6], [0,2, 4.5,6], [2,3.5, 5,0] ], [] ],
  [  76, "L",   5,  [ [0,6, 0,0], [0,0, 5,0] ], [] ],
  [  77, "M",   6,  [ [0,0, 0,6], [0,6, 3,0], [3,0, 6,6], [6,6, 6,0] ], [] ],
  [  78, "N",   5,  [ [0,0, 0,6], [0,6, 5,0], [5,0, 5,6] ], [] ],
  [  79, "O",   6,  [ ], [[3,3, 3, 0, 360]] ],
  [  80, "P",   5,  [[0,0, 0,6], [0,3, 3.5,3], [0,6, 3.5,6]], [[3.5,4.5, 1.5, 360-90, 90]] ], // 0x50
  [  81, "Q",   6,  [[4,1, 5,-0.5]], [[3,3, 3, 0, 360]] ],
  [  82, "R",   5,  [[0,0, 0,6], [0,3, 3.5,3], [0,6, 3.5,6], [3,3, 5,0]], [[3.5,4.5, 1.5, 360-90, 90]] ],
  [  83, "S",   5,  [[1.5,0, 3.5,0], [2,3, 3.5,3], [2,6, 3,6]],  [ [1.5, 1.5,  1.5, 190, 270], [3.5, 1.5,  1.5,  270, 90], [2, 4.5,  1.5,  90, 270], [3, 4.5,  1.5,  0, 90], ] ],
  [  84, "T",   6,  [ [0,6, 6,6], [3,6, 3,0] ], [] ],
  [  85, "U",   5,  [[0,2, 0,6], [5,2, 5,6]], [[2.5,2.5, 2.5, 190, 350]] ],
  [  86, "V",   6,  [ [0,6, 3,0], [3,0, 6,6] ], [] ],
  [  87, "W",   8,  [ [0,6, 2,0], [2,0, 4,6], [4,6, 6,0], [6,0, 8,6] ], [] ],
  [  88, "X",   6,  [ [0,0, 5.5,6], [6,0, 0.5,6] ], [] ],
  [  89, "Y",   6,  [ [0,6, 3,3], [3,3, 6,6], [3,3, 3,0] ], [] ],
  [  90, "Z",   5,  [ [0,6, 5,6], [5,6, 0,0], [0,0, 5,0], [1,3, 4,3] ], [] ],
  [  91, "\[",  2,  [ [0,0, 0,6], [0,0, 1,0], [0,6, 1,6]], [] ],
  [  92, "\\",  4,  [ [4,0, 0,6] ], [] ],
  [  93, "\]",  2,  [ [1,0, 1,6], [0,0, 1,0], [0,6, 1,6]], [] ],
  [  94, "\^",  3,  [ [0,4, 1.5,6], [1.5,6, 3,4] ], [] ],
  [  95, "_",   3,  [ [0,0, 3,0]], [] ],
  [  96, "\`",  6,  [ [0,6, 0.5,5] ], [] ], // 0x60
  [  97, "a",   4,  [ [4,0, 4,4] ], [[2,2, 2, 0, 360]] ],
  [  98, "b",   4,  [ [0,0, 0,6] ], [[2,2, 2, 0, 360]] ],
  [  99, "c",   4,  [ ], [[2,2, 2, 60, 360-45]] ],
  [ 100, "d",   4,  [ [4,0, 4,6] ], [[2,2, 2, 0, 360]] ],
  [ 101, "e",   4,  [ [0,2.17, 4,2.17] ], [[2,2, 2, 10, 360-35]] ],
  [ 102, "f",   3,  [ [1,0, 1,5], [0,4, 2,4] ], [[2,5, 1, 30, 180]] ],
  [ 103, "g",   4,  [ [4,-1, 4,4] ], [[2,2, 2, 0, 360], [2,-1, 2, 200, 360]] ],
  [ 104, "h",   4,  [ [0,0, 0,6], [4,0, 4,2] ], [[2,2, 2, 0, 180]] ],
  [ 105, "i",   1,  [ [0,0, 0,4], [0,5.5, 0,6] ], [] ],
  [ 106, "j",   2,  [ [2,-1, 2,4], [2,5.5, 2,6] ], [[1,-1, 1, 200, 360]] ],
  [ 107, "k",   4,  [ [0,0, 0,6], [0,1.5, 3.5,4], [1.5,2.5, 4,0] ], [] ],
  [ 108, "l",   1,  [ [0,6, 0,0] ], [] ],
  [ 109, "m",   6,  [ [0,0, 0,4], [3,0, 3,2.5], [6,0, 6,2.5] ], [[1.5,2.5, 1.5,  0,180], [4.5,2.5, 1.5, 0,180]] ],
  [ 110, "n",   4,  [ [0,0, 0,4], [4,0, 4,2] ] , [[2,2, 2, 0,180]] ],
  [ 111, "o",   4,  [ ], [[2,2, 2, 0, 360]] ],
  [ 112, "p",   4,  [ [0,4, 0,-2] ], [[2,2, 2, 0, 360]] ], // 0x70
  [ 113, "q",   4,  [ [4,4, 4,-2] ], [[2,2, 2, 0, 360]] ],
  [ 114, "r",   2,  [ [0,0, 0,4] ], [[1,3, 1, 30, 180]] ],
  [ 115, "s",   4,  [[1,0, 3,0], [1,2, 3,2], [1,4, 3,4]],  [ [1,1,  1, 190, 270], [3,1,  1,  270, 90], [1,3,  1,  90, 270], [3,3,  1,  0, 90], ] ],
  [ 116, "t",   2,  [ [1,0, 1,6], [0,4, 2,4] ], [] ],
  [ 117, "u",   4,  [ [4,0, 4,4], [0,2, 0,4] ] , [[2,2, 2, 180, 360]] ],
  [ 118, "v",   4,  [ [0,4, 2,0], [2,0, 4,4] ], [] ],
  [ 119, "w",   6,  [ [0,4, 1.5,0], [1.5,0, 3,4], [3,4, 4.5,0], [4.5,0, 6,4] ], [] ],
  [ 120, "x",   4,  [ [0,0, 3.5,4], [4,0, 0.5,4] ], [] ],
  [ 121, "Y",   4,  [ [0,4, 2,0], [4,4, 1,-2], [1,-2, 0,-2] ], [] ],
  [ 122, "Z",   5,  [ [0.5,4, 4,4], [4,4, 0,0], [0,0, 4,0], [1,2, 3,2] ], [] ],
  [ 123, "{",   2,  [ [1,1, 1,2], [1,4, 1,5] ], [ [2,5, 1, 90,180], [2,1, 1, 180,270], [0,2, 1, 0,90], [0,4, 1, 270,360]] ],
  [ 124, "|",   1,  [ [0,0, 0,6]], [] ],
  [ 125, "}",   2,  [ [1,1, 1,2], [1,4, 1,5] ], [ [0,5, 1, 0,90], [0,1, 1, 270,360], [2,2, 1, 90,180], [2,4, 1, 180,270]] ],
  [ 126, "~",   3,  [], [ [0.7,1.35, 1, 45,135], [2.3,2.65, 1, 225,315] ] ],
  [ 127, "DEL", 6,  [ [0,0, 4,0], [4,0, 4,6], [4,6, 0,6], [0,6, 0,0], [0,0, 4,1], [0,1, 4,2], [0,2, 4,3], [0,3, 4,4], [0,4, 4,5], [0,5, 4,6], ], [] ],
];

function getx(r,a)=r*cos(a);
function gety(r,a)=r*sin(a);

function getxcen(a)=a[0];
function getycen(a)=a[1];
function getrad(a)=a[2];
function getangbeg(a)=a[3];
function getangend(a)=a[4];

function strlen(str,i) = (str[i]==undef ? 0 : 1 + strlen(str,i+1));
function sumwidth(str,i,len=0) = (len==0 ? 0 : gap + letters[asc(str[i])][iwidth] + sumwidth(str,i+1,len-1));

function captype_line(a)=(a=="round" ? "sphere" : "blunt" );
function captype_arc(a)=(a=="round" ? "sphere" : "poly" );

glyph_max=128;   // how many glyphs
gap=2;           // distance between letters of a string
norm=0.6;
bold=1.0;
$uline="false";  // control underlining
$type="round";   // type of cross section, round or square
$cross=norm;     // diameter or extent of line segments (cross sectional length)
icode=0;         // index into table of ASCII code
iname=1;         // index into table of glyph name
iwidth=2;        // index into table of glyphe width
ilines=3;        // index into table of vector of line segments segments
icircs=4;        // index into table of vector of circular segments

function getcross()=($cross);
function gettype()=($type);

module alpha_line_cap( cross, height, type ) {
  h=height;
  b1=cross/2.0;
  b2=b1/4;
  r1=0.5*cross;
  r2=0.5*cross/4;
  if(type=="poly") {
    polyhedron(
        points=[ [b1,b1,0],[b1,-b1,0],[-b1,-b1,0],[-b1,b1,0], // the four points at b1
                 [b2,b2,h],[b2,-b2,h],[-b2,-b2,h],[-b2,b2,h] ], // four apex points
        faces=[  [0,1,5,4],[1,2,6,5],[2,3,7,6],[3,0,4,7],     // each polygon sides
                 [0,3,2,1],                                  // square base
                 [4,5,6,7] ]                                 // square tip
      );
  } else if(type=="blunt") {
    translate([0,0,0.5*height]) cube([cross, cross, height], center=true);
  } else if(type=="sphere") {
    sphere(d=cross, $fn=100);
  } else if(type=="cylinder") {
    cylinder(h=h, r1=r1, r2=r2, $fn=100 );
  }
}

module alpha_draw_line_basic( length ) {
  if($type=="round") {
    linear_extrude( height=length ) 
      circle(d=$cross, $fn=50);
  } else if($type=="square") {
    linear_extrude( height=length ) 
      square($cross, center=true);
  }
}

module alpha_draw_arc_basic( radius, angle ) {
  if($type=="round") {
    if(angle<=180) {
      translate([0,0,-0.5*$cross])
        arc_circular( $cross, radius, angle );
    } else {
      translate([0,0,-0.5*$cross]) {
        arc_circular( $cross, radius, 180 );
        rotate(180,[0,0,1]) arc_circular( $cross, radius, angle-180 );
      }
    }
  } else if($type=="square") {
    if(angle<=180) {
      translate([0,0,-0.5*$cross])
        arc_square( $cross, radius, angle );
    } else {
      translate([0,0,-0.5*$cross]) {
        arc_square( $cross, radius, 180 );
        rotate(180,[0,0,1]) arc_square( $cross, radius, angle-180 );
      }
    }
  }
}

module alpha_draw_delta_rect( x0, y0, dx, dy ) {
  len=sqrt(dx*dx + dy*dy);
  ang=90-atan2(dy,dx);
  translate([x0,y0,0])
    rotate(-ang,[0,0,1]) 
      rotate(-90,[1,0,0]) 
        union() {
          alpha_draw_line_basic( len );
          rotate(180,[0,1,0]) alpha_line_cap( $cross, 0.5*$cross, captype_line($type));
          translate([0,0,len]) alpha_line_cap( $cross, 0.5*$cross, captype_line($type));
        }
}

module alpha_draw_delta_polar( x0, y0, r, a ) {
  dx=r*cos(a);
  dy=r*sin(a);
  alpha_draw_delta_rect(x0,y0, dx,dy );
}

module alpha_draw_line( a=[0,0,1,1] ) {
  dx=a[2]-a[0];
  dy=a[3]-a[1];
  alpha_draw_delta_rect(a[0], a[1], dx,dy );
}


module alpha_draw_arc( a=[3,3, 3, 0,360] ) {
  aspan=getangend(a)-getangbeg(a);
  x=getrad(a)*cos(aspan);
  y=getrad(a)*sin(aspan);
  translate([getxcen(a), getycen(a), 0])
    rotate(getangbeg(a),[0,0,1])
      rotate(180, [1,0,0]) 
        rotate(90, [0,0,1]) 
          union() {
            alpha_draw_arc_basic( getrad(a), aspan );
            translate([0,-getrad(a),0]) 
             rotate(90,[0,1,0]) 
                alpha_line_cap( $cross, 0.5*$cross, captype_arc($type));
            translate([-y,-x,0]) 
              rotate(-aspan,[0,0,1]) 
                rotate(-90,[0,1,0]) 
                  alpha_line_cap( $cross, 0.5*$cross, captype_arc($type));
          }
}

module alpha_letter( g ) {
  union() { 
    /* color("cyan") */   for( i = g[ilines] ) alpha_draw_line( i );
    /* color("blue") */   for( i = g[icircs] ) alpha_draw_arc( i );
  }
}

module character_grid(wid,hgt,desc) {
  echo("wid=",wid, "  hgt=",hgt );
  color("cyan") {
    for(i = [0:wid]) translate([i,0,0]) rotate(-90, [1,0,0]) cylinder(h=hgt,d=0.05);
    for(i = [0:hgt]) translate([0,i,0]) rotate(90, [0,1,0]) cylinder(h=wid,d=0.05);
  }
  color("blue") {
    for(i = [0:wid]) translate([i,-desc,0]) rotate(-90, [1,0,0]) cylinder(h=desc,d=0.05);
    for(i = [0:desc]) translate([0,-(desc-i),0]) rotate(90, [0,1,0]) cylinder(h=wid,d=0.05);
  }
}

module alpha_draw_string( x, y, angle, string ) {
  len=strlen(string,0);
  wid=sumwidth(string,0,strlen(string,0));
  echo("input string=", string, "  length=", len, " width=", wid );
  if($uline==true) alpha_draw_delta_rect( x-gap,y-1, wid+gap,0 );
  for( i = [0:strlen(string,0)-1] ) {
    *echo("character=", string[i], " ascii value: ", asc(string[i]) );
    translate([x,y,0])
      rotate(-angle,[0,0,1]) 
        translate([sumwidth(string,0,i), 0, 0]) {
          *character_grid(letters[asc(string[i])][iwidth],6,2);
          alpha_letter( letters[asc(string[i])] );
        }
  }
}

*union() { // demo the building blocks
  echo("Cross section size is: ", getcross());
  character_grid(6,6,2);
  alpha_draw_line_basic( 4 );
  alpha_draw_delta_rect( 0, 0, 4, 4 );
  alpha_draw_line( [0,0,4,2] );
  alpha_draw_arc_basic( 3, 45 );
  alpha_draw_arc( [3,3, 2, 15,345] );
  *display_one_ascii(33);
  *ascii_chart();
}


// alpha_draw_string(0, 0, 0, "  Hello", $cross=bold, $uline=true);
alpha_draw_string(0, 0, 0, "Simple Technical Lettering", $cross=bold, $uline=true);
// alpha_draw_string(0, -10, 0, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
// alpha_draw_string(0, -20, 0, "abcdefghijklmnopqrstuvwxyz");
// alpha_draw_string(0, -30, 0, "0123456789");

sentence=["The", "Quick", "Brown", "Fox", "Jumped", "Over", "The", "Lazy", "Dog"];
nwords=9;
angle_span=150;
angle_half_span=angle_span/2;
angle_delta=angle_span / (nwords-1);
radius=10;
for( i=[0:(nwords-1)] ) {
  echo("word=",sentence[i]);
  alpha_draw_string( getx(radius,(angle_half_span-i*angle_delta)), 
                     gety(radius,(angle_half_span-i*angle_delta)), 
                     (angle_half_span-i*angle_delta) ,
                     sentence[i], $uline=true );
}


// Draw an ASCII Chart
chartx0=0;
charty0=110;
chartdx=12;
chartdy=12;

// draw the borders of an ASCII chart
module ascii_chart_grid(x0,y0,dx,dy) {
  hgt=8*dy;
  wid=16*dx;
  color("gray") {
    translate([chartx0, charty0, 0]) {
      for(i = [0:16]) translate([i*dx,-hgt,0]) rotate(-90, [1,0,0]) cylinder(h=hgt,d=0.25);
      for(i = [0:8]) translate([0,-i*dy,0]) rotate(90, [0,1,0]) cylinder(h=wid,d=0.25);
    }
  }
}

function getn(i,j)=(j*16+i);

module ascii_chart() {
  ascii_chart_grid(chartx0,charty0,chartdx,chartdy);
  for( j = [0:7] ) {
    for( i = [0:15] ) {
      echo("letter=", i, j, getn(i,j), letters[getn(i,j)][icode], letters[getn(i,j)][iname], " width: ", letters[getn(i,j)][iwidth] );
      translate([0.5*(chartdx-letters[getn(i,j)][iwidth]), 2+0.5*(chartdy-8), 0]) {
        translate([chartx0+i*chartdx, charty0-(j+1)*chartdy, 0]) {
          character_grid(6,6,2);
          alpha_letter( letters[getn(i,j)] );
        }
      }
    }
  }
}


module display_one_ascii(i) {
  character_grid(6,6,2);
  alpha_letter( letters[i] );
}
