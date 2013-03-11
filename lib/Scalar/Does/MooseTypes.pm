package Scalar::Does::MooseTypes;

use strict;
use warnings;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.102';

use Scalar::Does qw( blessed does looks_like_number -make );

sub _is_class_loaded {
	return !!0 if ref $_[0];
	return !!0 if !defined $_[0];
	my $stash = do { no strict 'refs'; \%{"$_[0]\::"} };
	return !!1 if exists $stash->{'ISA'};
	return !!1 if exists $stash->{'VERSION'};
	foreach my $globref (values %$stash) {
		return !!1 if *{$globref}{CODE};
	}
	return !!0;
}

my @ROLES;
my @NAMES;
BEGIN {
	no warnings;
	@ROLES = (
		make_role('Any',       sub { 1 }),
		make_role('Item',      sub { 1 }),
		make_role('Undef',     sub { !defined $_[0] }),
		make_role('Defined',   sub { defined $_[0] }),
		make_role('Bool',      sub { !defined $_[0] || $_[0] eq q() || $_[0] eq '0' || $_[0] eq '1' }),
		make_role('Value',     sub { return unless defined $_[0]; !ref $_[0] }),
		make_role('Ref',       sub { ref $_[0] }),
		make_role('Str',       sub { return unless defined $_[0]; (ref(\($_[0])) eq 'SCALAR' || ref(\(my $val = $_[0])) eq 'SCALAR') }),
		make_role('Num',       sub { return unless defined $_[0]; !ref($_[0]) && looks_like_number($_[0]) }),
		make_role('Int',       sub { return unless defined $_[0]; !ref($_[0]) && $_[0] =~ /\A-?[0-9]+\z/ }),
		make_role('CodeRef',   sub { ref $_[0] eq 'CODE' }),
		make_role('RegexpRef', sub { ref $_[0] eq 'Regexp' }),
		make_role('GlobRef',   sub { ref $_[0] eq 'GLOB' }),
		make_role('FileHandle',sub { require IO::Detect; IO::Detect::is_filehandle($_[0]) }),
		make_role('Object',    sub { blessed($_[0]) }),
		make_role('ClassName', \&_is_class_loaded),
		make_role('RoleName',  \&_is_class_loaded),
		make_role('ScalarRef', sub { ref $_[0] eq 'SCALAR' || ref $_[0] eq 'REF' }),
		make_role('ArrayRef',  sub { ref $_[0] eq 'ARRAY' }),
		make_role('HashRef',   sub { ref $_[0] eq 'HASH' }),
	);
	@NAMES = map("$_", @ROLES);
}

use constant +{ map {;"$_"=>$_} @ROLES };
use Sub::Exporter -setup => {
	exports  => \@NAMES,
	groups   => {
		constants      => \@NAMES,
		only_constants => \@NAMES,
	},
};

1;

__END__

=head1 NAME

Scalar::Does::MooseTypes - additional constants for Scalar::Does, inspired by the built-in Moose type constraints

=head1 SYNOPSIS

  use 5.010;
  use Scalar::Does qw(does);
  use Scalar::Does::MooseTypes -all;
  
  my $var = [];
  if (does $var, ArrayRef) {
    say "It's an arrayref!";
  }

=head1 DESCRIPTION

This is partially a demonstration of how to create additional roles for
Scalar::Does, and partially included just in the hope that it would be
useful. (The Moose type constraint system has proven quite useful.)

=head2 Constants

=over

=item C<Any>

=item C<Item>

=item C<Bool>

=item C<Undef>

=item C<Defined>

=item C<Value>

=item C<Str>

=item C<Num>

=item C<Int>

=item C<ClassName>

=item C<RoleName>

=item C<Ref>

=item C<ScalarRef>

=item C<ArrayRef>

=item C<HashRef>

=item C<CodeRef>

=item C<RegexpRef>

=item C<GlobRef>

=item C<FileHandle>

=item C<Object>

=back

=head1 SEE ALSO

L<Scalar::Does>,
L<Moose::Util::TypeConstraints>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012-2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

