#!/usr/bin/perl -w
use warnings;
use strict;
if (!$ARGV[0]) {
print "Error: requres file name.";
exit;
}
my $filename = $ARGV[0];
my $filesize = -s $filename;
print "$filesize bytes in $filename.\n";
my $totalpixles = int($filesize / 3);
print "Calculated Pixles will be: $totalpixles.\n";
#get aspect ratio WARNING NO INPUT CHECKS
print "What aspect rato would you like this image Please type as y:x\n [1:1] ";
my ($Haspect,$Vaspect) = split(/:/,<STDIN>);
#calculate aspect ratio
my $aspectunit = sqrt($totalpixles/($Vaspect*$Haspect));
my $imagewidth = int($Haspect*$aspectunit);
my $imageheight = int($Vaspect*$aspectunit)+1;
print "Calculated width and height: $imagewidth x $imageheight.\n";
#Open file for reading as binary
open(INPUT, "<$filename") or die "Cannot open $filename";
binmode(INPUT);
my ($buf, $data, $n);
#loop height
#Image File size calulation
my $rowpadding = (3*$imagewidth)%4;
$rowpadding=$rowpadding?(4-$rowpadding):0;
my $rowsize = 3*$imagewidth+$rowpadding;
#Image file size
my $imagedatasize =$imageheight*$rowsize;
my $imagesize=$imagedatasize+54;
#Bitmap header write here
open(OUTPUT, ">$filename.bmp") or die "Failed to create $filename.bmp";
binmode(OUTPUT);
print OUTPUT "\x42\x4d";
print OUTPUT pack("V", $imagesize);
print OUTPUT "\0\0\0\0";
print OUTPUT pack("V", 54);
# And the DIB Header
print OUTPUT "\x28\0\0\0";		# DIB Head size
print OUTPUT pack("V", $imagewidth);	# Width
print OUTPUT pack("V", $imageheight);	# Height
print OUTPUT "\1\0";			# Number of Color planes
print OUTPUT "\x18\0";			# Bits per pixle (3 bytes)
print OUTPUT "\0\0\0\0";		# No compression
print OUTPUT pack("V", $imagedatasize); # Image size
print OUTPUT "\x13\x0B\0\0";
print OUTPUT "\x13\x0B\0\0";		# Resolution in px/metre
print OUTPUT "\0\0\0\0";		# Palette colors (no palette)
print OUTPUT "\0\0\0\0";		# Importaint colors?
#ask for pixle rate (adjust memmory usage)  WARNING NO INPUT CHECKS
print "What speed would you like the convertion?\n NOTE: The faster you set this the more processing power file2pic will use. [1 - $imagewidth] :";
my $pps = <STDIN>;
#Image Data
my ($progress,$progpercent,$bufhex) = (0,0,0);
for (my $y=0;$y<=$imageheight;$y++) {
	for (my $x=0; $x<$imagewidth/$pps; $x++) {
		read(INPUT,$data,3*$pps);
		$buf=unpack("B*",$data);
		$bufhex=unpack("H*",$data);
		print OUTPUT "$data";
		$progress++;
		$progpercent = int(($progress/($imageheight*($imagewidth/$pps)))*100);
		print "\r";
		my $curpix = substr($bufhex, 0, 6);
		print "$progpercent% done, ".$progress*$pps." pixles written. Current Pixle: $curpix";
	}
	for (my $p=0; $p<$rowpadding;$p++) {
		print OUTPUT "\0";
	}
}
close INPUT;
close OUTPUT;
print "\n";
