=head1 PURPOSE

Tests that the one-argument form of C<does> works with lexical C<< $_ >>,
using C<< my $_ >>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test::More;

BEGIN {
	plan skip_all => "no support for lexical \$_" unless eval q{ my $_ = 1 };
};

use Scalar::Does -constants;

$_ = [];
ok does ARRAY;
ok not does HASH;

{
	my $_ = {};
	ok does HASH;
	ok not does ARRAY;
}

done_testing;

