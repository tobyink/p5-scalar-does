package Scalar::Does;

use 5.008;
use strict;
use utf8;

BEGIN {
	$Scalar::Does::AUTHORITY = 'cpan:TOBYINK';
	$Scalar::Does::VERSION   = '0.001';
}

use IO::Detect qw( is_filehandle );
use overload qw();
use Scalar::Util qw( blessed reftype );
use Sub::Exporter -setup => {
	exports => [qw( does overloads blessed )],
	groups  => {
		default => [qw( does )],
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
	VSTRING  => sub { reftype($_) eq 'VSTRING' or reftype($_) eq 'VSTRING' },
	Regexp   => sub { reftype($_) eq 'Regexp'  or overloads($_, q[qr]) },
	q[${}]   => 'SCALAR',
	q[@{}]   => 'ARRAY',
	q[%{}]   => 'HASH',
	q[&{}]   => 'CODE',
	q[*{}]   => 'GLOB',
	q[bool]  => sub { !blessed($_) or !overload::Overloaded($_) or overloads($_, q[bool]) },
	q[""]    => sub { !ref($_)     or !overload::Overloaded($_) or overloads($_, q[""]) },
	q[0+]    => sub { !ref($_)     or !overload::Overloaded($_) or overloads($_, q[0+]) },
	q[qr]    => sub { reftype($_) eq 'Regexp'  or overloads($_, q[qr]) },
	q[<>]    => sub { overloads($_, q[<>])     or is_filehandle($_) },
	q[~~]    => sub { overloads($_, q[~~])     or not blessed($_) },
);

while (my ($k, $v) = each %ROLES)
	{ $ROLES{$k} = $ROLES{$v} unless ref $v }

sub overloads ($;$)
{
	my ($thing, $role) = @_;
	
	# curry (kinda)
	return sub { overloads(shift, $thing) } if @_ < 2;
	
	goto \&overload::Method;
}

sub does ($;$)
{
	my ($thing, $role) = @_;
	
	# curry (kinda)
	return sub { does(shift, $thing) } if @_ < 2;
	
	if (my $test = $ROLES{$role})
	{
		local $_ = $thing;
		my $does = $test->($thing);
		return 1 if $does;
	}
	
	if (blessed $thing)
	{
		return 1 if $thing->DOES($role);
	}
	
	if (blessed $role and $role->can('check'))
	{
		return 1 if $role->check($thing);
	}
	
	return;
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

Or the shiny Perl 5.10+ syntax:

  $object ~~does 'Some::Class'    # true
  $object ~~does '%{}'            # true
  $object ~~does 'HASH'           # true
  $object ~~does 'ARRAY'          # false

=head1 DESCRIPTION

It has long been noted that Perl would benefit from a C<< does() >> built-in.
A check that C<< ref($thing) eq 'ARRAY' >> doesn't allow you to accept an
object that uses overloading to provide an array-like interface.

This module provides a prototype C<< does() >> function which can be used in
as a standard function, or using a pseudo-infix notation (via smart match).

=over

=item C<< does($scalar, $role) >>

Checks if a scalar is capable of performing the given role. The following
(case-sensitive) roles are predefined:

=over

=item * B<SCALAR> or B<< ${} >>

Checks if the scalar can be used as a scalar reference.

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

=item * B<< ~~ >>

Checks if the scalar can be used on the right hand side of a smart match.

=back

For roles not on the predefined list above, the following behaviour is
followed:

=over

=item 1. If the given scalar is blessed, then C<< $scalar->DOES($role) >>
is called, and if that returns true, then C<< does >> returns true.

=item 2. If the given I<role> is blessed, and provides a C<check> method,
then C<< does >> delegates to that. This allows L<MooseX::Types> types to
be used as roles. (But not L<Moose>'s type constraint strings.)

=back

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Scalar-Does>.

=head1 SEE ALSO

L<Scalar::Util>.

L<http://perldoc.perl.org/5.10.0/perltodo.html#A-does()-built-in>

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

