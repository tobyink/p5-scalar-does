use Test::More;
use Scalar::Does;

{
	package Local::Does::Array;
	use overload '@{}' => 'array';
	sub new   { bless +{ array=>[] }, pop };
	sub array { return shift->{array} };
	sub DOES  { return 1 if $_[1] eq 'Monkey'; shift->SUPER::DOES(@_) }
}

my %tests = (
	ARRAY => [
		[],
		does   => [qw( ARRAY @{} )],
		doesnt => [qw( HASH %{} )],
	],
	HASH => [
		+{},
		does   => [qw( HASH %{} )],
		doesnt => [qw( ARRAY @{} )],
	],
	SCALAR => [
		\"Hello World",
		does   => [qw( SCALAR ${} )],
		doesnt => [qw( ARRAY HASH @{} %{} CODE Regexp Foo::Bar UNIVERSAL )],
	],
	CODE => [
		sub { 1 },
		does   => [qw( CODE &{} )],
		doesnt => [qw( SCALAR @{} UNIVERSAL )],
	],
	Blessed_CODE => [
		bless(sub { 1 } => 'Foo::Bar'),
		does   => [qw( CODE &{} Foo::Bar UNIVERSAL )],
		doesnt => [qw( SCALAR @{} Regexp )],
	],
	Overloaded_Object => [
		Local::Does::Array->new,
		does   => [qw( ARRAY @{} HASH %{} Local::Does::Array UNIVERSAL Monkey )],
		doesnt => [qw( CODE bool "" )],
	],
	STDOUT => [
		\*STDOUT,
		does   => [qw( IO <> GLOB *{} )],
		doesnt => [qw( SCALAR @{} Regexp CODE &{} Foo::Bar UNIVERSAL )],
	],
	Lvalue => [
		\(substr($INC[0], 0, 1)),
		does   => [qw( LVALUE )],
		doesnt => [qw( SCALAR @{} Regexp CODE &{} Foo::Bar UNIVERSAL IO GLOB )],
	],
);

foreach my $name (sort keys %tests)
{
	my ($value, %cases) = @{ $tests{$name} };
	
	foreach my $tc (@{ $cases{does} }) {
		ok(does($value, $tc), "$name does $tc");
	}

	foreach my $tc (@{ $cases{doesnt} }) {
		ok(!does($value, $tc), "$name doesn't $tc");
	}
}

done_testing();
