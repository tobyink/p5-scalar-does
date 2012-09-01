use if $] < 5.010,
	'Test::More' => (skip_all => "Perl $] is too old");

use Test::More;
use Scalar::Does
	qw( does overloads ),
	custom => { -role => 'ARRAY', -as => 'does_array' },
	custom => { -role => 'HASH',  -as => 'does_hash'  };

my $A = +[];
my $H = +{};
	
my $curried = does 'ARRAY';

#use B::Deparse ();
#note( B::Deparse->new->coderef2text($curried) );

ok(
	ref $curried eq 'CODE',
	q(ref $curried eq 'CODE'),
);

ok(
	$curried->($A),
	q($curried->($A)),
);
ok(
	not($curried->($H)),
	q(not($curried->($H))),
);

ok(
	$A ~~ $curried,
	q($A ~~ $curried),
);
ok(
	not($H ~~ $curried),
	q(not($H ~~ $curried)),
);

ok(
	($A ~~does 'ARRAY'),
	q(($A ~~does 'ARRAY')),
);

ok(
	$A ~~does_array,
	q($A ~~does_array),
);

ok(
	not($H ~~does 'ARRAY'),
	q(not($H ~~does 'ARRAY')),
);

ok(
	not($H ~~does_array),
	q(not($H ~~does_array)),
);

ok(
	($H ~~does 'HASH'),
	q(($H ~~does 'HASH')),
);

ok(
	$H ~~does_hash,
	q($H ~~does_hash),
);

ok(
	not($A ~~does 'HASH'),
	q(not($A ~~does 'HASH')),
);

ok(
	not($A ~~does_hash),
	q(not($A ~~does_hash)),
);

ok(
	not($A ~~overloads 'ARRAY'),
	q(not($A ~~overloads 'ARRAY')),
);

done_testing();
