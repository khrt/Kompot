package Kompot::Base;

use v5.12;

use strict;
use warnings;

use utf8;


sub new {
    my $class = shift;

    my $self = bless({}, ref($class) || $class);

    $self->init(@_);

    return $self;
}

sub init {1}

sub app { state $_app ||= Kompot::App->new }


1;

__END__
