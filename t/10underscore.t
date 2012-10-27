use Test::More;
use Scalar::Does -constants;

$_ = [];
ok does ARRAY;
ok not does HASH;

{
	my $_ = {};
	ok does HASH;
	ok not does ARRAY;
}

done_testing;

