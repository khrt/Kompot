package Kompot::Renderer::EmPerl;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use DDP { output => 'stdout' };
use File::Spec::Functions 'catfile';

use base 'Kompot::Base';
use Kompot::Attributes;

has 'c';

sub init {
    my ($self, $c) = @_;

    return if not $c;
    $self->c($c);
    $self->register_default_helpers;
}

sub register_default_helpers { }

sub render {
    my ($self, $name) = @_;

    my $out;

    return $out;
}


1;

__END__
