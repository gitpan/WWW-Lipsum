    use ExtUtils::MakeMaker;
    WriteMakefile
      ('DISTNAME' => 'WWW-Lipsum',
       'VERSION' => '0.11',
       'PL_FILES' => {},
       'PREREQ_PM' => {
			'LWP::UserAgent' => '0',
			'HTTP::Request::Common' => '0',

		      },
      );
