=head1 PURPOSE

Check how IO::Detect handles L<IO::All> objects.

This test is skipped if IO::All is not available.

This file originally formed part of the IO-Detect test suite.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012-2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use Test::More;
BEGIN {
	eval("use IO::All 'io'; 1") && ($] >= 5.010)
	or plan skip_all => "Need IO::All and Perl 5.10 for this test.";
};

use IO::Detect;
plan tests => 3;

$_ = io('Makefile.PL');

ok is_filehandle, "is_filehandle";
ok is_filename, "is_filename";
ok not(is_fileuri), "is_fileuri";

