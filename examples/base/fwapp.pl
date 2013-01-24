#!/usr/bin/env perl

use v5.12;

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../../lib";

use Kompot;

get '/' => sub {
    my $self = shift;

    $self->stash(
        to   => 'World',
        from => 'Kompot',
    );
    
    $self->render(text => 'Hello, <% to %>! From `<% from %>`.');
};

get '/json' => sub {
    my $self = shift;

    my $data = {
        name  => 'hash',
        array => [ 0, 1, 2, 3, 4 ],
        hash  => { key => 'value' },
    };

    $self->render(json => $data);
};

get '/to-post' => sub {
    my $self = shift;

    my $form = <<EOF;
to post<br>
<form action="/post" method="post">
<input type="text" name="name" value="=default=">
<input type="text" name="second" value="=second=">
<input type="submit">
</form>
EOF

    $self->render(text => $form, 'content-type' => 'text/html');
};

post '/post' => sub {
    my $self = shift;

    my $name = $self->param('name');
    my $se = $self->param('second');

    $self->render(text => "Hello, $name! ($se)");
};

get '/regex/:route{\d\w+}' => sub {
    my $self = shift;

    my $route = $self->param('route');

    $self->render(text => "route: $route");
};

get '/regex/:a{\d\w+}/:b{\w+}' => sub {
    my $self = shift;

    my $a = $self->param('a');
    my $b = $self->param('b');

    $self->render(text => "a: $a; b: $b");
};

get '/route/:pp' => sub {
    my $self = shift;

    my $pp = $self->param('pp');

    $self->render(text => "1 param. The param is $pp!");
};

get '/route/:p/:pp' => sub {
    my $self = shift;

    my $p = $self->param('p');
    my $pp = $self->param('pp');

    $self->render(text => "2 param. The params is $p, $pp!");
};

get '/session/set' => sub {
    my $self = shift;

    my $test = $self->param('test') || 'default';
    my $value = $self->param('value') || 'default';

    $self->session(test => $test);
    $self->session(value => $value);

    $self->render(text => "Set cookie: test => `$test`, value => `$value`.");
};

get '/session/get' => sub {
    my $self = shift;

    my $p1 = $self->session('test');
    my $p2 = $self->session('value');

    $self->render(text => "Get cookie: $p1/$p2");
};

get '/render/mojo' => sub {
    my $self = shift;

    $self->stash(
        title => 'Test',
        head  => 'Head',
        p     => 'Paragraph',
    );

    $self->render(template => 'mojo.ep');
};

app->secret('verysecret');
app->start;

__DATA__
