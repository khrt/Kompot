package Kompot::Response;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };
use Carp;

use base 'Kompot::Base';

sub init {
    my $self = shift;
    my $p = @_ % 2 ? $_[0] : {@_};

    $self->status($p->{status})             if $p->{status};
    $self->content_type($p->{content_type}) if $p->{content_type};
    $self->content($p->{content})           if $p->{content};
}

sub status {
    my ($self, $status) = @_;
    $self->{status} = $status if $status;
    return $self->{status};
}

sub content_type {
    my ($self, $ctype) = @_;
    $self->headers('content-type' => $ctype) if $ctype;
    return $self->headers('content-type');
}

sub header { shift->headers(@_) }

sub headers {
    my $self = shift;

    my $h = $self->{headers} ||= {};

    # all / Lower case
    return [map { $_ => $h->{$_} } keys %$h] if not @_;

    # one
    return $h->{ $_[0] } if @_ == 1;

    # new
    my $v = @_ % 2 ? $_[0] : {@_};

    map { $h->{$_} = $v->{$_} } keys %$v;

    return 1;
}

sub content {
    my $self = shift;

    if (scalar @_) {
        my @c = ref($_[0]) ? @{ $_[0] } : $_[0];

        push(@{ $self->{content} }, @c);
    }

    return $self->{content};
}

sub set_cookie {
    my ($self, $cookie_str) = @_;
    $self->header('set-cookie' => $cookie_str);
}

1;

__END__
