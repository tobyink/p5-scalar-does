use Test::More tests => 2;

{
	package Local::Foo;
	use Scalar::Does;
	sub check_does {
		my ($class, $thing, $role) = @_;
		does($thing, $role);
	}
}

ok(
	!Local::Foo->can('does'),
	"does is cleaned up",
);

ok(
	Local::Foo->check_does( [] => 'ARRAY' ),
	"does still works",
);