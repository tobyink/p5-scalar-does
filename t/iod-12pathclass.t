=head1 PURPOSE

Check how IO::Detect handles L<Path::Class> objects.

This test is skipped if Path::Class is not available.

This file originally formed part of the IO-Detect test suite.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012-2014 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use Test::More;
use Test::Requires "v5.10", "Path::Class";

use Path::Class 'file';
use IO::Detect;

$_ = file('Makefile.PL');

ok not(is_filehandle), "is_filehandle";
ok is_filename, "is_filename";
ok not(is_fileuri), "is_fileuri";

done_testing;
