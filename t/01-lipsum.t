#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 15;

use WWW::Lipsum;

my $l_test = WWW::Lipsum->new;
isa_ok($l_test, 'WWW::Lipsum');
can_ok($l_test, qw/what  amount  html  start  generate  lipsum  error/);

is( $l_test->what,   'paras', 'Default `what` is `paras`');
is( $l_test->amount, 5,       'Default `amount` is `5`'  );
is( $l_test->html,   0,       'Default `html` is `0`'    );
is( $l_test->start,  1,       'Default `start` is `1`'   );

my $l = WWW::Lipsum->new(
    what    => 'bytes',
    amount  => 1000,
    html    => 1,
    start   => 0,
);

is( $l->what,   'bytes', 'can change `what` arg in ->new'  );
is( $l->amount, 1000,    'can change `amount` arg in ->new');
is( $l->html,   1,       'can change `html` arg in ->new'  );
is( $l->start,  0,       'can change `start` arg in ->new' );

SKIP: {
    $l->start(1);
    $l->html(0);
    my $text = $l->generate;
    unless ( $text ) {
        if ( $l->error =~ /^Network/ ) {
            diag "Got error: " . ($l->error ? $l->error : '[undefined]');
            skip 'Got network error: ' . $l->error, 1;
        }
        else {
            BAIL_OUT 'Got weird error! ' . $l->error;
        }
    }

    like( $text, qr/^Lorem ipsum/, 'The text we got matches Lipsum' );
}

SKIP: {
    $l->start(1);
    $l->html(0);
    my $text = "$l";
    unless ( $text ) {
        if ( $l->error =~ /^Network/ ) {
            diag "Got error: " . ($l->error ? $l->error : '[undefined]');
            skip 'Got network error: ' . $l->error, 1;
        }
        else {
            BAIL_OUT 'Got weird error! ' . $l->error;
        }
    }

    like( $text, qr/^Lorem ipsum/,
        'The text we got matches Lipsum; when using overloading'
    );
}

SKIP: {
    $l->start(0);
    $l->html(0);
    my $text = "$l";
    unless ( $text ) {
        if ( $l->error =~ /^Network/ ) {
            diag "Got error: " . ($l->error ? $l->error : '[undefined]');
            skip 'Got network error: ' . $l->error, 1;
        }
        else {
            BAIL_OUT 'Got weird error! ' . $l->error;
        }
    }

    like( $text, qr/^(?!Lorem ipsum)/,
        'The text we got must NOT match Lipsum at the start'
    );
}

SKIP: {
    $l->html(1);
    $l->what('lists');
    my $text = "$l";
    unless ( $text ) {
        if ( $l->error =~ /^Network/ ) {
            diag "Got error: " . ($l->error ? $l->error : '[undefined]');
            skip 'Got network error: ' . $l->error, 1;
        }
        else {
            BAIL_OUT 'Got weird error! ' . $l->error;
        }
    }

    like( $text, qr/^\s*<ul>/,
        'The text we got must have some semblance to <ul> markup'
    );
}

SKIP: {
    $l->html(1);
    $l->what('paras');
    my $text = "$l";
    unless ( $text ) {
        if ( $l->error =~ /^Network/ ) {
            diag "Got error: " . ($l->error ? $l->error : '[undefined]');
            skip 'Got network error: ' . $l->error, 1;
        }
        else {
            BAIL_OUT 'Got weird error! ' . $l->error;
        }
    }

    like( $text, qr/^\s*<p>/,
        'The text we got must have some semblance to <p> markup'
    );
}