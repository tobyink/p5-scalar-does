use strict;
use Test::More;
use Scalar::Does -constants;

my $var = "Hello world";

ok does(\$var, SCALAR);
ok does([], ARRAY);
ok does(+{}, HASH);
ok does(sub {0}, CODE);
ok does(\*STDOUT, GLOB);
ok does(\(\"Hello"), REF);
ok does(\(substr($var,0,1)), LVALUE);
ok does(\*STDOUT, IO);
ok does(qr{x}, REGEXP);
ok does(1, BOOLEAN);
ok does(1, STRING);
ok does(1, NUMBER);
ok does(1, SMARTMATCH);

if ($] >= 5.012)
{
	ok does(\v1.2.3, VSTRING);
}
else
{
	pass( "VSTRING test skipped on older Perls" );
}

done_testing;

