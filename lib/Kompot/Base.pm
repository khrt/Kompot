package Kompot::Base;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;

#sub import {
#    my $class = shift;
#}

sub new {
    my $class = shift;

    my $self = bless {}, ref $class || $class;
    $self->init(@_);

    return $self;
}

# default initializer
sub init {1}

sub app { state $_app ||= Kompot::App->new }

1;

__END__
