=head1 PURPOSE

Check how IO::Detect handles L<Path::Tiny> objects.

This test is skipped if Path::Tiny is not available.

This file originally formed part of the IO-Detect test suite.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use Test::More;
BEGIN {
	eval("use Path::Tiny 'path'; 1") && ($] >= 5.010)
	or plan skip_all => "Need Path::Tiny for this test.";
};

use IO::Detect;
plan tests => 3;

$_ = path('Makefile.PL');

ok not(is_filehandle), "is_filehandle";
ok is_filename, "is_filename";
ok not(is_fileuri), "is_fileuri";

