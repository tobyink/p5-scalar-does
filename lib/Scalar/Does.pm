package Scalar::Does;

use 5.008;
use strict;
use utf8;

our %_CONSTANTS;
BEGIN {
	$Scalar::Does::AUTHORITY = 'cpan:TOBYINK';
	$Scalar::Does::VERSION   = '0.003';
	
	%_CONSTANTS = (
		BOOLEAN    => q[bool],
		STRING     => q[""],
		NUMBER     => q[0+],
		REGEXP     => q[qr],
		SMARTMATCH => q[~~],
		map {; $_ => $_ } qw(
			SCALAR ARRAY HASH CODE REF GLOB
			LVALUE FORMAT IO VSTRING
		)
	);
}

BEGIN {
	package Scalar::Does::RoleChecker;
	use overload
		q[""]    => 'name',
		q[&{}]   => 'code',
		fallback => 1,
	;
	sub new {
		my $class = shift;
		my ($name, $coderef);
		for my $p (@_)
		{
			if (Scalar::Does::does($p, 'CODE'))  { $coderef = $p }
			if (Scalar::Does::does($p, 'HASH'))  { $coderef = $p->{where} }
			if (Scalar::Does::does($p, 'Regexp')){ $coderef = sub { $_[0] =~ $p } }
			if (not ref $p)                      { $name    = $p }
		}
		Carp::confess("Cannot make role without checker coderef or regexp.")
			unless $coderef;
		bless { name => $name, code => $coderef } => $class;
	}
	sub name  { $_[0]{name} }
	sub code  { $_[0]{code} }
	sub check { $_[0]{code}->($_[1]) }
}

use constant \%_CONSTANTS;
use Carp             0     qw( confess );
use IO::Detect       0.001 qw( is_filehandle );
use namespace::clean 0.19  qw();
use Scalar::Util     1.20  qw( blessed reftype looks_like_number );

use Sub::Exporter -setup => {
	exports => [
		qw( does overloads blessed reftype looks_like_number make_role where ),
		custom => \&_build_custom,
		keys %_CONSTANTS,
	],
	groups  => {
		default        => [qw( does )],
		constants      => [qw( -default -only_constants )],
		only_constants => [keys %_CONSTANTS],
		make           => [qw( make_role where )],
	},
	installer => sub {
		namespace::clean->import(
			-cleanee => $_[0]{into},
			grep { !ref } @{ $_[1] },
		);
		goto \&Sub::Exporter::default_installer;
	},
};

no warnings;

my %ROLES = (
	SCALAR   => sub { reftype($_) eq 'SCALAR'  or overloads($_, q[${}]) },
	ARRAY    => sub { reftype($_) eq 'ARRAY'   or overloads($_, q[@{}]) },
	HASH     => sub { reftype($_) eq 'HASH'    or overloads($_, q[%{}]) },
	CODE     => sub { reftype($_) eq 'CODE'    or overloads($_, q[&{}]) },
	REF      => sub { reftype($_) eq 'REF' },
	GLOB     => sub { reftype($_) eq 'GLOB'    or overloads($_, q[*{}]) },
	LVALUE   => sub { ref($_) eq 'LVALUE' },
	FORMAT   => sub { reftype($_) eq 'FORMAT' },
	IO       => \&is_filehandle,
	VSTRING  => sub { reftype($_) eq 'VSTRING' or ref($_) eq 'VSTRING' },
	Regexp   => sub { reftype($_) eq 'Regexp'  or ref($_) eq 'Regexp'  or overloads($_, q[qr]) },
	q[bool]  => sub { !blessed($_) or !overload::Overloaded($_) or overloads($_, q[bool]) },
	q[""]    => sub { !ref($_)     or !overload::Overloaded($_) or overloads($_, q[""]) },
	q[0+]    => sub { !ref($_)     or !overload::Overloaded($_) or overloads($_, q[0+]) },
	q[<>]    => sub { overloads($_, q[<>])     or is_filehandle($_) },
	q[~~]    => sub { overloads($_, q[~~])     or not blessed($_) },
	q[${}]   => 'SCALAR',
	q[@{}]   => 'ARRAY',
	q[%{}]   => 'HASH',
	q[&{}]   => 'CODE',
	q[*{}]   => 'GLOB',
	q[qr]    => 'Regexp',
);

while (my ($k, $v) = each %ROLES)
	{ $ROLES{$k} = $ROLES{$v} unless ref $v }

sub overloads ($;$)
{
	my ($thing, $role) = @_;
	
	# curry (kinda)
	return sub { overloads(shift, $thing) } if @_==1;
	
	goto \&overload::Method;
}

sub does ($;$)
{
	my ($thing, $role) = @_;
	
	# curry (kinda)
	return sub { does(shift, $thing) } if @_==1;
	
	if (my $test = $ROLES{$role})
	{
		local $_ = $thing;
		return !! $test->($thing);
	}
	
	if (blessed $role and $role->can('check'))
	{
		return !! $role->check($thing);
	}
	
	if (blessed $thing && $thing->can('DOES'))
	{
		return 1 if $thing->DOES($role);
	}
	elsif (UNIVERSAL::can($thing, 'can') && $thing->can('DOES'))
	{
		my $class = $thing;
		return '0E0' if $class->DOES($role);
	}
	
	return;
}

use constant MISSING_ROLE_MESSAGE => (
	"Please supply a '-role' argument when exporting custom functions, died"
);

sub _build_custom
{
	my ($class, $name, $arg) = @_;
	my $role = $arg->{ -role } or confess MISSING_ROLE_MESSAGE;
	
	return sub (;$) {
		push @_, $role;
		goto \&does;
	}
}

sub make_role
{
	return 'Scalar::Does::RoleChecker'->new(@_);
}

sub where (&)
{
	return +{ where => $_[0] };
}

"it does"
__END__

=head1 NAME

Scalar::Does - like ref() but useful

=head1 SYNOPSIS

  my $object = bless {}, 'Some::Class';
  
  does($object, 'Some::Class');   # true
  does($object, '%{}');           # true
  does($object, 'HASH');          # true
  does($object, 'ARRAY');         # false

=head1 DESCRIPTION

It has long been noted that Perl would benefit from a C<< does() >> built-in.
A check that C<< ref($thing) eq 'ARRAY' >> doesn't allow you to accept an
object that uses overloading to provide an array-like interface.

=head2 Functions

=over

=item C<< does($scalar, $role) >>

Checks if a scalar is capable of performing the given role. The following
(case-sensitive) roles are predefined:

=over

=item * B<SCALAR> or B<< ${} >>

Checks if the scalar can be used as a scalar reference.

Note: this role does not check whether a scalar is a scalar (which is
obviously true) but whether it is a reference to another scalar.

=item * B<ARRAY> or B<< @{} >>

Checks if the scalar can be used as an array reference.

=item * B<HASH> or B<< %{} >>

Checks if the scalar can be used as a hash reference.

=item * B<CODE> or B<< &{} >>

Checks if the scalar can be used as a code reference.

=item * B<GLOB> or B<< *{} >>

Checks if the scalar can be used as a glob reference.

=item * B<REF>

Checks if the scalar can be used as a ref reference (i.e. a reference to
another reference).

=item * B<LVALUE>

Checks if the scalar is a reference to a special lvalue (e.g. the result
of C<< substr >> or C<< splice >>).

=item * B<IO> or B<< <> >>

Uses L<IO::Detect> to check if the scalar is a filehandle or file-handle-like
object.

(The C<< <> >> check is slightly looser, allowing objects which overload
C<< <> >>, though overloading C<< <> >> well can be a little tricky.)

=item * B<VSTRING>

Checks if the scalar is a vstring reference.

=item * B<FORMAT>

Checks if the scalar is a format reference.

=item * B<Regexp> or B<< qr >>

Checks if the scalar can be used as a quoted regular expression.

=item * B<bool>

Checks if the scalar can be used as a boolean. (It's pretty rare for this
to not be true.)

=item * B<< "" >>

Checks if the scalar can be used as a string. (It's pretty rare for this
to not be true.)

=item * B<< 0+ >>

Checks if the scalar can be used as a number. (It's pretty rare for this
to not be true.)

Note that this is far looser than C<looks_like_number> from L<Scalar::Util>.
For example, an unblessed arrayref can be used as a number (it numifies to
its reference address); the string "Hello World" can be used as a number (it
numifies to 0).

=item * B<< ~~ >>

Checks if the scalar can be used on the right hand side of a smart match.

=back

If the given I<role> is blessed, and provides a C<check> method, then
C<< does >> delegates to that.

Otherwise, if the scalar being tested is blessed, then
C<< $scalar->DOES($role) >> is called, and C<does> returns true if
the method call returned true.

If the scalar being tested looks like a Perl class name, then 
C<< $scalar->DOES($role) >> is also called, and the string "0E0" is
returned, which evaluates to 0 in a numeric context but true in a
boolean context. This is an experimental feature; it has not yet
been decided whether true or false is the correct response. Testing
class names is a little dodgy, because you might get a different
when testing instances of the class. For example, instances are
typically blessed hashes, so C<< does($obj, 'HASH') >> is true.
However, it is impossible to tell that from the class name.

Note that the C<DOES> method is only defined in L<UNIVERSAL> in
Perl 5.10+. You may wish to load L<UNIVERSAL::DOES> on earlier versions
of Perl.

=item C<< does($role) >>

The single-argument form of C<does> returns a curried coderef.

=item C<< overloads($scalar, $role) >>

A function C<overloads> (which just checks overloading) is also available.

=item C<< overloads($role) >>

The single-argument form of C<overloads> returns a curried coderef.

=item C<< blessed($scalar) >>, C<< reftype($scalar) >>, C<< looks_like_number($scalar) >>

For convenience, this module can also re-export these functions from
L<Scalar::Util>. C<looks_like_number> is generally more useful than
C<< does($scalar, q[0+]) >>.

=item C<< make_role $name, where { BLOCK } >>

Returns an anonymous role object which can be used as a parameter to
C<does>. The block is arbitrary code which should check whether $_[0]
does the role.

=item C<< where { BLOCK } >>

Syntactic sugar for C<make_role>. Compatible with the C<where> function
from L<Moose::Util::TypeConstraints>, so don't worry about conflicts.

=back

=head2 Constants

The following constants may be used for convenience:

=over

=item C<SCALAR>

=item C<ARRAY>

=item C<HASH>

=item C<CODE>

=item C<GLOB>

=item C<REF>

=item C<LVALUE>

=item C<IO>

=item C<VSTRING>

=item C<FORMAT>

=item C<REGEXP>

=item C<BOOLEAN>

=item C<STRING>

=item C<NUMBER>

=item C<SMARTMATCH>

=back

=head2 Export

By default, only C<does> is exported. This module uses L<Sub::Exporter>, so
functions can be renamed:

  use Scalar::Does does => { -as => 'performs_role' };

Scalar::Does also plays some tricks with L<namespace::clean> to ensure that
any functions it exports to your namespace are cleaned up when you're finished
with them. This ensures that if you're writing object-oriented code C<does>
and C<overloads> will not be left hanging around as methods of your classes.
L<Moose::Object> provides a C<does> method, and you should be able to use
Scalar::Does without interfering with that.

You can import the constants (plus C<does>) using:

  use Scalar::Does -constants;

The C<make_role> and C<where> functions can be exported like this:

  use Scalar::Does -make;

Or list specific functions/constants that you wish to import:

  use Scalar::Does qw( does ARRAY HASH STRING NUMBER );

=head2 Custom Role Checks

  use Scalar::Does
    custom => { -as => 'does_array', -role => 'ARRAY' },
    custom => { -as => 'does_hash',  -role => 'HASH'  };
  
  does_array($thing);
  does_hash($thing);

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Scalar-Does>.

=head1 SEE ALSO

L<Scalar::Util>.

L<http://perldoc.perl.org/5.10.0/perltodo.html#A-does()-built-in>.

=head2 Relationship to Moose roles

Scalar::Does is not dependent on Moose, and its role-checking is not specific
to Moose's idea of roles, but it does work well with Moose roles.

Moose::Object overrides C<DOES>, so Moose objects and Moose roles should
"just work" with Scalar::Does.

  {
    package Transport;
    use Moose::Role;
  }
  
  {
    package Train;
    use Moose;
    with qw(Transport);
  }
  
  my $thomas = Train->new;
  does($thomas, 'Train');          # true
  does($thomas, 'Transport');      # true
  does($thomas, Transport->meta);  # not yet supported!

L<Mouse::Object> should be compatible enough to work as well, but seemingly
not L<Moo::Object>.

See also:
L<Moose::Role>,
L<Moose::Object>,
L<UNIVERSAL>.

=head2 Relationship to Moose type constraints

L<Moose::Meta::TypeConstraint> objects, plus the constants exported by
L<MooseX::Types> libraries all provide a C<check> method, so again, should
"just work" with Scalar::Does. Type constraint strings are not supported
however.

  use Moose::Util::TypeConstraints qw(find_type_constraint);
  use MooseX::Types qw(Int);
  use Scalar::Does qw(does);
  
  my $int = find_type_constraint("Int");
  
  does( "123", $int );     # true
  does( "123", Int );      # true
  does( "123", "Int" );    # false

L<Mouse::Meta::TypeConstraints> and L<MouseX::Types> should be compatible
enough to work as well.

See also:
L<Moose::Meta::TypeConstraint>,
L<Moose::Util::TypeConstraints>,
L<MooseX::Types>,
L<Scalar::Does::MooseTypes>.

=head2 Relationship to Role::Tiny and Moo roles

At the time of writing, Role::Tiny roles B<< do not >> work as roles for
Scalar::Does. There is an open ticket against Role::Tiny which, if resolved,
should fix this.

See L<https://rt.cpan.org/Ticket/Display.html?id=79747>.

Moo's role system is based on Role::Tiny, and consequently has the same
limitation.

=head2 Relationship to Moo type constraints

Unlike Moose and Mouse, Moo does not have a type system, but the C<< does >>
function can be used as ersatz type constraints.

  has my_list => (
    is     => 'rw',
    isa    => does('ARRAY'),
  );

=head2 Relationship to Object::DOES

L<Object::DOES> provides a convenient way of overriding C<DOES> in your
classes.

  {
    package Train;
    use Object::DOES -role => [qw/ Transport /];
    sub new { my ($class, %arg) = @_; bless \%arg, $class }
  }
  
  my $thomas = Train->new;
  does($thomas, 'Train');      # true
  does($thomas, 'Transport');  # true

See also:
L<Object::DOES>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

