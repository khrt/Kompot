package Kompot::Response;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };
use Carp;

use base 'Kompot::Base';
use Kompot::Attributes;

my @HEADERS = qw(
    status location content_type content_length content x_powered_by
);

sub _res_attr {
    my $h = shift;
    return sub {
        my ($self, $v) = @_;
        $self->{headers}{$h} = $v if $v;
        return $self->{headers}{$h};
    };
}

has 'header' => sub { shift->headers(@_) };
has 'status';
has 'content_type'   => _res_attr('Content-Type',   @_);
has 'content_length' => _res_attr('Content-Length', @_);
has 'x_powered_by'   => _res_attr('X-Powered-By',   @_);
has 'set_cookie'     => _res_attr('Set-Cookie',     @_);
has 'location'       => _res_attr('Location',       @_);

sub init {
    my $self = shift;
    my $p = @_ % 2 ? $_[0] : {@_};

    foreach my $method (@HEADERS) {
        $self->$method($p->{$method}) if $p->{$method};
    }

    $self->x_powered_by($self->app->name) if !$self->x_powered_by;
}

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

1;

__END__
