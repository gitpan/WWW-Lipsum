#!/usr/bin/perl

use warnings;
use strict;

use Module::Build;

Module::Build->new(

	module_name        => 'WWW::Lipsum',
	requires           => {
                         'HTML::TokeParser::Simple' => 0,
                         'HTTP::Request::Common'    => 0,
                         'LWP::UserAgent'           => 0,
                         'perl' => '5.005',
                        },
	license            => 'unrestricted',
	create_makefile_pl => 'traditional',
    configure_requires => { 'Module::Build' => 0.40 },

)->create_build_script;
if ( $ENV{RELEASE_TESTING} ) {
    system('pod2text lib/WWW/Lipsum.pm > README');
}

