#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

use Software::LicenseUtils;
my $pm_text = <<'END';
=head1 LICENSE AND COPYRIGHT

This program is licensed under the
Creative Commons Attribution-ShareAlike 3.0 Unported License.
To view a copy of this license, visit
L<http://creativecommons.org/licenses/by-sa/3.0/> or send a letter to Creative
Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
=head1 THANKS
END
my @guesses = Software::LicenseUtils->guess_license_from_pod($pm_text);
die Dumper [ @guesses ];


__END__
#!/usr/bin/env perl

use strict;
use warnings;
use lib qw{lib ../lib};

use WWW::Lipsum;

my $lipsum = WWW::Lipsum->new;

print $lipsum->generate;

my @paragraphs = $lipsum->generate(
    amount => 5,
    what   => 'paras',
    start  => 'no',
    html   => 1,
);

print "$_\n" for @paragraphs;