#!/usr/bin/perl

use strict;

use Module::Build;

Module::Build->new(

	module_name        => 'WWW::Lipsum',
	requires           => {
				'HTTP::Request::Common'  => 0,
				'LWP::UserAgent' => 0
		              },
	license            => 'unrestricted',
	create_makefile_pl => 'traditional',

)->create_build_script;
