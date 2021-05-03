#!/usr/bin/perl

local($password);

if ($ENV{QUERY_STRING} =~ /password=(.*)/)
{
 $password=$1;
}

use bytes;
use Digest::SHA;
use MIME::Base64;

sub random_bytes($) {
    my($n) = @_;
    my($v, $i);

    if ( open(RANDOM, '<', '/dev/random') ||
	 open(RANDOM, '<', '/dev/urandom') ) {
	read(RANDOM, $v, $n);
    } else {
	# No real RNG available...
	srand($$ ^ time);
	$v = '';
	for ( $i = 0 ; $i < $n ; $i++ ) {
	    $v .= ord(int(rand() * 256));
	}
    }

    return $v;
}


#($pass, $salt) = @ARGV;

unless (defined($salt)) {
    $salt = MIME::Base64::encode(random_bytes(6), '');
}
$pass = Digest::SHA::sha1_base64($salt, $password);

print "Content-Type: text/html\n";
print "Cache-Control: no-cache\n\n";
print '$4$', $salt, '$', $pass, "\$\n";
