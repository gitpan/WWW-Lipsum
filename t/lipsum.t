#!/usr/bin/perl -w

use strict;
use Test::More tests => 7;

use lib '/home/earle/downlode.org/perl/modules/WWW-Lipsum/WWW-Lipsum-0.1/lib';
use WWW::Lipsum;

my $lipsum = WWW::Lipsum->new();

my ($default, $default_no_start, $default_no_start_correct, @single_paragraph_html,
    $single_paragraph_html_correct);

ok (
	defined $lipsum,
	'new() successful'
   );

ok (
	$lipsum->isa('WWW::Lipsum'),
	'object has right class'
   );


ok (
	$default = $lipsum->lipsum(),
	'was able to retrieve text'
   );

ok (
	$default_no_start = $lipsum->lipsum(
					start => 0 
					),
	'was able to retrieve text with "start" set to 0'
   );


if ($default_no_start !~ /^Lorem ipsum/) {
	$default_no_start_correct = 1;
}

is (
	$default_no_start_correct, 1,
	'setting "start" to 0 was successful'
   );
	
ok (
	@single_paragraph_html = $lipsum->lipsum(
						what => 'paras',
						amount => 1,
						html => 1
						),
	'was able to retrieve text with "what", "amount" and "html" settings'
   );


my $para = shift(@single_paragraph_html);

if (($para =~ /^\<p\>/) && ($para =~ /\<\/p\>$/)) {
	$single_paragraph_html_correct = 1;
}

is (
	$single_paragraph_html_correct, 1,
	'"what", "amount" and "html" settings were successful'
   );
