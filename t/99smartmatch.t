# This is an experimental feature.
#

use Test::More;
BEGIN { $] >= 5.010001 or plan skip_all => "Perl 5.10.1+" };

plan tests => 4;

use Scalar::Does qw( does overloads -constants );

BEGIN {
	package Local::OL;
	use overload q[@{}] => sub { [] };
	sub new { bless +{} }
}

ok(  ("a" ~~ does STRING)  );
ok( !("a" ~~ does SCALAR) );

my $obj = Local::OL->new;
ok(  ($obj ~~ overloads '@{}') );
ok( !($obj ~~ overloads '${}') );

