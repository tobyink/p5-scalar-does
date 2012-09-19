use Test::More tests => 5;
use Scalar::Does
	custom => { -role => 'ARRAY', -as => 'does_array' },
	custom => { -role => 'HASH',  -as => 'does_hash'  };

ok  does_array( +[] );
ok !does_array( +{} );
ok !does_hash(  +[] );
ok  does_hash(  +{} );

ok not eval q{
	use Scalar::Does custom => { -as => 'foo' }
};