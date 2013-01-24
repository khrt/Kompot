package Kompot::Config;

use strict;
use warnings;

use utf8;
use v5.12;

use FindBin qw($Bin);

use base 'Kompot::Base';

sub init {
    my $self = shift;

    $self->{app_root} = $Bin;

    # default template paths
    $self->renderer_paths('/templates');
}

sub cache_ttl { 5 }

#
# Paths
#
sub root { shift->{app_root} }
sub static { shift->{app_root} . '/static' }

#
# TODO Move to Renderer
#
sub renderer { # TODO Rename to `engine`
    my ($self, $renderer) = @_;
    $self->{renderer} = $renderer if $renderer;
    return $self->{renderer} || 'Kompot::Renderer::Xslate';
}

sub renderer_paths {
    my ($self, $path) = @_;
    push(@{ $self->{template_paths} }, $self->root . $path) if $path;
    return $self->{template_paths};
}

#
# Cookie
#
sub secret {
    my ($self, $secret) = @_;
    $self->{secret} = $secret if $secret;
    return $self->{secret};
}

sub cookie_name {
    my ($self, $name) = @_;
    $self->{cookie_name} = $name if $name;
    return $self->{cookie_name} || 'kompot';
}

sub cookie_expires {
    my ($self, $expires) = @_;
    $self->{cookie_expires} = $expires if $expires;
    return $self->{cookie_expires} || 60 * 60; # one hour by default
}

1;

__END__
