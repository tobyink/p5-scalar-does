use Test::More;
BEGIN { $] >= 5.010001 or plan skip_all => "Perl 5.10.1+" };

use feature qw(switch);
use Scalar::Does -constants;

plan tests => 2;

my $array = [];

ok does $array, ARRAY;

given ($array) {
	when ( does(HASH)  ) { fail() }
	when ( does(ARRAY) ) { pass() }
}

