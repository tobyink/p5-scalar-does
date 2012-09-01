use Test::More;

BEGIN {
	eval { require Moose; require MooseX::Types::Moose; 1 }
		or plan skip_all => "needs Moose and MooseX::Types::Moose";
}

use Scalar::Does;
use MooseX::Types::Moose -all;

ok(
	does(12, Num),
	'12 does Num',
);
ok(
	!does('12b', Num),
	"12b doesn't Num",
);

my $union = Num | ArrayRef[Num];

ok(
	does(12, $union),
	'12 does custom type',
);
ok(
	does([qw(1 2 3)], $union),
	'[1,2,3] does custom type',
);
ok(
	!does([qw(a b c)], $union),
	'[a,b,c] doesn\'t custom type',
);
ok(
	!does(+{}, $union),
	'hashref doesn\'t custom type',
);

{
	package Local::Foo;
	use Moose::Role;
}

{
	package Local::Bar;
	use Moose;
	with 'Local::Foo';
}

{
	package MyLib;
	use MooseX::Types -declare => ['IsBar', 'DoesFoo'];
	role_type DoesFoo, { role => 'Local::Foo' };
	class_type IsBar, { class => 'Local::Bar' };
}

my $obj = Local::Bar->new;
ok(does $obj, Any);
ok(does $obj, Object);
ok(does $obj, 'UNIVERSAL');
ok(does $obj, 'Moose::Object');
ok(does $obj, 'Local::Foo');
ok(does $obj, 'Local::Bar');
ok(does $obj, MyLib::IsBar);
ok(does $obj, MyLib::DoesFoo);

done_testing();
