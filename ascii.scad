// ASCII lookup table and other utility functions
// from user MichaelAtOz 
// date 16 Jun 2013 
// on OpenSCAD github, issue #116 discussion thread:
// https://github.com/openscad/openscad/issues/116

ASCIIv = [ 
            [ " ",32],[ "!",33],["\"",34],[ "#",35],[ "$",36],
            [ "%",37],[ "&",38],[ "'",39],[ "(",40],[ ")",41],
            [ "*",42],[ "+",43],[ ",",44],[ "-",45],[ ".",46],
            [ "/",47], 

            [ "0",48],[ "1",49],[ "2",50],[ "3",51],[ "4",52],
            [ "5",53],[ "6",54],[ "7",55],[ "8",56],[ "9",57],

            [ ":",58],[ ";",59],[ "<",60],[ "=",61],[ ">",62],
            [ "?",63],[ "@",64],

            [ "A",65],[ "B",66],[ "C",67],[ "D",68],[ "E",69],
            [ "F",70],[ "G",71],[ "H",72],[ "I",73],[ "J",74],
            [ "K",75],[ "L",76],[ "M",77],[ "N",78],[ "O",79],
            [ "P",80],[ "Q",81],[ "R",82],[ "S",83],[ "T",84],
            [ "U",85],[ "V",86],[ "W",87],[ "X",88],[ "Y",89],
            [ "Z",90],

            [ "[",91],[ "\\",92],[ "]",93],[ "^",94],[ "_",95],
            [ "`",96],

            [ "a", 97],[ "b", 98],[ "c", 99],[ "d",100],[ "e",101],
            [ "f",102],[ "g",103],[ "h",104],[ "i",105],[ "j",106],
            [ "k",107],[ "l",108],[ "m",109],[ "n",110],[ "o",111], 
            [ "p",112],[ "q",113],[ "r",114],[ "s",115],[ "t",116], 
            [ "u",117],[ "v",118],[ "w",119],[ "x",120],[ "y",121], 
            [ "z",122],

            [ "{",123],[ "|",124],[ "}",125],[ "~",126] 
        ];
ASCIIstart=32;
ASCIIend=len(ASCIIv)-1+ASCIIstart;
ASCIIfirst=ASCIIv[0][0];
ASCIIlast=ASCIIv[len(ASCIIv)-1][0];

// asc() return the character code (number) of the first char of a string
function asc(string) = ASCIIv[search(string[0],ASCIIv,1,0)[0]][1];

// chr() return the character (string really) matching the character number
function chr(charNum) = ASCIIv[search(charNum,ASCIIv,0,1)[0]][0];

// above will go into a library

// testing - comment out
echo("Test Part 1");

for (i = [0 : len(ASCIIv)-1 ] )
{
    echo(   i, 
            ASCIIv[i][0], 
            search(i+32,ASCIIv,0,1)[0], 
            search(i+32,ASCIIv,0,1)[0]+32,
            ASCIIv[search(i+32,ASCIIv,0,1)[0]][0]);

}
echo(str(" start=",ASCIIstart,
         " end=",ASCIIend,
         " first='",ASCIIfirst,
         "' last='",ASCIIlast,
         "' "));



echo("Test Part 2");
echo("asc(A) =",asc("A"));
echo("chr(65)=",chr(65));
echo("asc(a) =",asc("a"));
echo("chr(97)=",chr(97));


//     space->  ! " # $ % & ' (             <- in ASCII order 
charWidth = [ 5,2,6,5,6,2,4,2,4 ];  // ... (use 0 for chars you don't support)
function ascWidth(string) = charWidth[(asc(string[0])-ASCIIstart)];

echo("Width3=",charWidth[3]);
echo(asc("#"));
echo("Width'#'=", ascWidth("#"));
echo("Width'$'=", ascWidth("$"));
