package WWW::Lipsum;

use strict;
use Carp qw(croak);
use vars qw( $VERSION );

use LWP::UserAgent;
use HTTP::Request::Common;
use HTML::TokeParser;

$VERSION = 0.11;

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub lipsum {
	my ($self, %args) = @_;

	foreach my $arg ( qw( amount type start html ) ) {
		$self->{$arg} = $args{$arg};
	}

	# Arguments. If none are given, generate 1 paragraph by default.

	my $amount = $args{ amount } || 1;	 # How much text is wanted?
	my $what   = $args{ what }   || 'paras'; # What type of text?
	my $start  = $args{ start }  || 1;	 # Begin with "Lorem ipsum..."?
	my $html   = $args{ html }   || 0;	 # Wrap text in HTML tags?

	my $ua = LWP::UserAgent->new;

	my $request = HTTP::Request->new('GET','http://www.lipsum.com/cgi-bin/lipsum.pl');
	my $response = $ua->request($request); 

	# Change a "1" answer for the "start" parameter to the 
        # "yes" that lipsum.com understands.

	if ( ($start) && ($start eq '1') ) { $start = 'yes' }
	else { $start = 'no' }

	# New HTTP request for the lipsum script.

	$response = $ua->request(POST 'http://www.lipsum.com/cgi-bin/lipsum.pl', [
					amount => $amount,
					what   => $what,
					start  => $start
				]);

	if ($response->is_success) {

		my $raw = $response->content;

	        my $stream = HTML::TokeParser->new( \$raw ) or die $!;

		# Skip the first table tag in the page.
		my $tag = $stream->get_tag('table');

		# Move to the inner table.
		$tag = $stream->get_tag('table');

		# Move to the "font"-enclosed area that contains our lorem ipsum text.
		$tag = $stream->get_tag('font');
		my $text = $stream->get_text('/font');

		if ($text =~ /(.*)Generated(.*)/s) {

			my $lipsum = $1;

			if ($what eq 'words') {
				$lipsum =~ s/\n//g;
				return $lipsum;
			}

			elsif ($what eq 'bytes') {
				$lipsum =~ s/\n//g;
				return $lipsum;
			}

			elsif ($what eq 'lists') {

				my @items = split( "\n", $lipsum );

				foreach my $li (@items) {

					# drop empty paragraphs created by double line breaks
					next unless $li;

					chomp($li);

					# fix sentences that have butted up against each other

					$li =~ s/\./\. /g;

					if ($html eq "1") {
						# wrap list items in <li></li>
						$li = "<li>" . $li;
						$li = $li . "</li>\n" 
					}
				}

				return @items;
			}

			else {
				$lipsum =~ s/^\n\n//;

				# The lipsum.com text generator puts the starting phrase on a line of its own, which isn't noticeable when viewing in
				# a browser, but causes a spurious 'paragraph' for us - so strip it.

				if ($start eq 'yes') {
					$lipsum =~ s/adipiscing elit(.*?)\n/adipiscing elit\. /;
				}

				my @paragraphs = split( "\n", $lipsum );

				foreach my $para (@paragraphs) {

					# drop empty paragraphs created by double  line breaks

					if ($para eq '') {
						shift(@paragraphs);
						next;
					}

					chomp($para);

					if ($html eq "1") {
						# wrap paragraphs in <p></p>
						$para = "<p>\n" . $para;
						$para = $para . "\n</p>";
					}
				}

				return @paragraphs;
			}
		}
	}
 
	else {
		return "Error: $!";
	}

}

1;

__END__

=head1 NAME

WWW::Lipsum - get autogenerated text from lipsum.com

=head1 DESCRIPTION

C<WWW::Lipsum> is a module that will retrive "lorem ipsum" placeholder text
from lipsum.com. 

What is "lorem ipsum"?

    "Lorem Ipsum, or Lipsum for short, is simply dummy text of the 
    printing and typesetting industry. Lipsum has been the industry's 
    standard dummy text ever since the 1500s, when an unknown printer 
    took a galley of type and scrambled it to make a type specimen book. 
    It has survived not only four centuries, but now the leap into 
    electronic typesetting, remaining essentially unchanged. It was 
    popularised in the 1960s with the release of Letraset sheets 
    containing Lipsum passages, and more recently with desktop 
    publishing software like Aldus PageMaker including versions of 
    Lipsum."  -- lipsum.com

lipsum.com is a useful resource on the Web that will generate passages of
lorem ipsum text for you in sizes of your choice. This module allows you to
retrieve them in an OO fashion to utilise for whatever purpose you wish.

=head1 SYNOPSIS

    use WWW::Lipsum;

    my $stuff = WWW::Lipsum->new();

    print $stuff->lipsum();

    my @paragraphs = $stuff->lipsum(
                                    amount => 5,
                                    what   => 'paras',
                                    start  => 1,
                                    html   => 1
                                   );

=head1 METHODS

There is just one method, C<lipsum()>, which returns lorem ipsum text. It
has several options to correspond with those offered by lipsum.com.

    print $stuff->lipsum();    # default usage, no options

This will give you one paragraph of lorem ipsum, beginning with the phrase
"Lorem ipsum dolor sit amet", as is traditional. The size of a "paragraph" is
randomly determined by the lipsum.com text generator, but is generally between
70 and 120 words.

    my @paragraphs = $stuff->lipsum(
                                    amount => 5,
                                    what   => 'paras',
                                    start  => 0,
                                    html   => 0
                                   );

This will give you five paragraphs of lorem ipsum, the first of which will
be without the starting phrase. Setting 'html' to 1 will cause each paragraph
to be wrapped in HTML's <p></p> tags.

    print $stuff->lipsum(
                         amount => 100,
                         what   => 'words'
                        );

This will give you roughly a hundred words of lorem ipsum with the starting
phrase. Roughly, because the lipsum.com text generator makes whole
'sentences' of random length. The amount setting will be more accurate at
higher values. The 'html' setting has no effect if you ask for words. When
used to fill a variable, this will give you a list with one item.

    print $stuff->lipsum(
                         amount => 1024,
                         what   => 'bytes'
                        );

This will give you roughly 1024 bytes of lorem ipsum with the starting
phrase. The same caveat regarding size applies, and again the 'html' setting
will have no effect. Again, this will give you a one-item list.

   my @lists = $stuff->lipsum(
                              amount => 10,
                              what   => 'lists',
                              html   => 1
                             );

The lipsum.com text generator's 'lists' setting produces HTML lists of
random size. Using this setting with this module will give you small chunks
of text, generally of the order of a couple of sentences. Using the 'html'
setting will cause these chunks to be wrapped in <li></li> tags for you to
use as you see fit.

=head1 AUTHOR

Earle Martin <emartin@cpan.org>.

=head1 LICENSE

This work is licensed under the Creative Commons Attribution-ShareAlike
License. To view a copy of this license, visit
L<http://creativecommons.org/licenses/by-sa/1.0/> or send a letter to Creative
Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

=head1 THANKS

James Wilson, for creating lipsum.com.