=head1 PURPOSE

Check that Scalar::Does doesn't issue any unexpected warnings, even under
C<< $^W >>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test::More;
use Test::NoWarnings;

$^W = 1;
require Scalar::Does;
Scalar::Does::does(undef, 'ARRAY');

done_testing(1);