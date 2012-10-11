use Test::More;
use Test::NoWarnings;

$^W = 1;
require Scalar::Does;
Scalar::Does::does(undef, 'ARRAY');

done_testing;