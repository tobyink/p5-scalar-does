use Test::More;

BEGIN {
	plan skip_all => "no support for lexical \$_" unless eval q{ my $_ = 1 };
};

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

