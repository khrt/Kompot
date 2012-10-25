#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../../lib";

use Data::Dumper;

use FWfwd;


get '/' => sub {
    my $self = shift;

    $self->stash(
        to   => 'World',
        from => 'FWfwd',
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


post '/post' => sub {
    my $self = shift;

    my $name = $self->param('name');

    $self->render( text => "Hello, $name!" );
};


FWfwd->start;
