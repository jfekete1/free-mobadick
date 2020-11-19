#!/usr/bin/perl

use MIME::Base64;
use utf8;
use POSIX;
use Archive::Zip;

if(!@ARGV){
	print "Usage:\n";
	print '    free-mobadick.pl <UserName> <Version>'."\n\n";
	print '    <UserName>:      The Name licensed to'."\n";
	print '    <Version>:       The Version of MobaXterm you are using'."\n";
	print '                      Example:    20.5'."\n\n";
	exit;
}
my ($username, $version) = @ARGV;
my ($major_version, $minor_version) = split /\./, $version;
my $type=1;
my $count=1;
my $license_string = $type . '#' . $username . '|' . $major_version . $minor_version . '#' . $count . '#' . $major_version . '3' . $minor_version . '6' . $minor_version . '#' . '0' . '#' . '0' . '#' . '0' . '#';

my $VariantBase64Table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
my @VariantBase64Dict = split //, $VariantBase64Table;

sub VariantBase64Encode {
	my $input_string = shift;
	my $len = length($input_string);
	my $blocks_count = floor($len / 3);
	my $left_bytes = $len % 3;
	my $coding_int = 0;
	my $result = '';
	my $block;

	my @arr = ($input_string =~ m/.../g );
	foreach my $str (@arr) {
		my @chars = split //, $str;
		my $c0 = shift @chars;
		my $i0 = ord($c0) * 1;
		my $c1 = shift @chars;
		my $i1 = ord($c1) * 256;
		my $c2 = shift @chars;
		my $i2 = ord($c2) * 256 * 256;
		$coding_int = $i2 + $i1 + $i0;
		$block = $VariantBase64Dict[$coding_int & 0x3f];
		$block .= $VariantBase64Dict[(($coding_int >> 6) & 0x3f)];
		$block .= $VariantBase64Dict[(($coding_int >> 12) & 0x3f)];
		$block .= $VariantBase64Dict[(($coding_int >> 18) & 0x3f)];
		$result .= $block;
	}
	if ($left_bytes == 0){
		return $result;
	} elsif ($left_bytes == 1) {
		my $cn = substr $input_string, -1;
		$coding_int = ord($cn);
		$block = $VariantBase64Dict[$coding_int & 0x3f];
		$block .= $VariantBase64Dict[(($coding_int >> 6) & 0x3f)];
		$result .= $block;
		return $result;
	} else {
		my $cn1 = chop($input_string); #107 * 256 = 27392 -> +120 = 27512
		my $in1 = ord($cn1) * 256;
		my $cn2 = chop($input_string); #120
		my $in2 = ord($cn2);
		$coding_int = $in1 + $in2;
		$block = $VariantBase64Dict[$coding_int & 0x3f];
		$block .= $VariantBase64Dict[(($coding_int >> 6) & 0x3f)];
		$block .= $VariantBase64Dict[(($coding_int >> 12) & 0x3f)];
		$result .= $block;
		return $result;
	}
}

sub EncryptBytes {
	my ($key, $input_string) = @_;
	my @bs = split //, $input_string;
	my $result = '';
	for (my $i=0; $i < scalar(@bs); $i++){
		if($i == 0){
			$result .= chr(ord($bs[$i]) + 5);
		}
		else {
			$result .= chr(ord($bs[$i]) ^ (($key >> 8) & 0xff));
			$key = (ord($bs[$i - 1]) ^ (($key >> 8) & 0xff) ) & $key | 0x482D;
		}
	}
	return $result;
}

my $res = EncryptBytes(18477, $license_string);
my $oui = VariantBase64Encode($encrypted);
my $prokey = VariantBase64Encode($res);

my $filename = 'Pro.key';
open(my $fh, ">", $filename) or die "Nem sikerult megnyitni a fajlt: $filename mert $!";
print $fh "$prokey";
close $fh;

my $zip = Archive::Zip->new();
my $member = $zip->addFile($filename);
$zip->writeToFileNamed('Custom.mxtpro');

if("$^O" == "MSWin32"){
	`DEL $filename`;
}
else{
	`rm $filename`;
}

print "Successfully created licence file named Custom.mxtpro \n";
print "Please copy the licence file to your MobaXterm installation directory, or next to the MobaXterm executable if you are using portable mobaxterm.\n";
