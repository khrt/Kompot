#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../../lib";

use YAWFW;


get '/' => sub {
    my $self = shift;

    $self->stash(
        to   => 'World',
        from => 'YAWFW',
    );
    
    $self->render( text => 'Hello, <% to %>! From `<% from %>`.' );
};

get '/json' => sub {
    my $self = shift;


    my $data = {
        name  => 'hash',
        array => [ 0, 1, 2, 3, 4 ],
        hash  => { key => 'value' },
    };


    $self->render( json => $data );
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

    $self->render( text => $form, 'content-type' => 'text/html' );
};


post '/post' => sub {
    my $self = shift;

    my $name = $self->param('name');
    my $se = $self->param('second');

    $self->render( text => "Hello, $name! ($se)" );
};


get '/route/:pp' => sub {
    my $self = shift;

    my $pp = $self->param('pp');

    $self->render( text => "1 param. The param is $pp!" );
};


get '/route/:p/:pp' => sub {
    my $self = shift;

    my $p = $self->param('p');
    my $pp = $self->param('pp');

    $self->render( text => "2 param. The params is $p, $pp!" );
};

app->start;

__DATA__
