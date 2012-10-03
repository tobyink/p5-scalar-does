use Test::More tests => 11;
use Scalar::Does does => -make;

my $positive = make_role 'Positive Integer', where { $_[0] > 0 };

can_ok $positive => 'check';
is("$positive", "Positive Integer");

ok does($positive->name, q[""]);
ok does($positive->code, q[&{}]);

ok does("1", $positive);
ok does("1hello", $positive);
ok !does("-1", $positive);
ok !does("", $positive);

ok not eval {
	make_role();
};

my $name = make_role qr{^Toby$}i;
ok does("TOBY", $name);
ok !does("TOBIAS", $name);
