use Test::More tests => 4;
use Scalar::Does
	custom => { -role => 'ARRAY', -as => 'does_array' },
	custom => { -role => 'HASH',  -as => 'does_hash'  };

ok  does_array( +[] );
ok !does_array( +{} );
ok !does_hash(  +[] );
ok  does_hash(  +{} );
