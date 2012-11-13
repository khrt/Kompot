package YAFW::Response;

use v5.12;

use strict;
use warnings;

use utf8;

use DDP { output => 'stdout' };
use Carp;

use base 'YAFW::Base';

sub init {
    my $self = shift;

    my $p = @_ % 2 ? $_[0] : { @_ };

    $self->status( $p->{status} )             if $p->{status};
    $self->content_type( $p->{content_type} ) if $p->{content_type};
    $self->content( $p->{content} )      if $p->{content};
}


sub status {
    my $self = shift;

    $self->{status} = $_[0] if $_[0];

    return $self->{status};
}

sub content_type {
    my $self = shift;

    if ( scalar @_ ) {
        $self->headers( 'content-type' => shift );
    }

    return $self->headers('content-type');
}

sub header { shift->headers(@_) }

sub headers {
    my $self = shift;

    my $h = $self->{headers} ||= {};

    # all
    return [ map { $_ => lc( $h->{$_} ) } keys %$h ] if not @_; # XXX Lower case all

    # one
    return $h->{ $_[0] } if @_ == 1;

    # new
    my $v = @_ % 2 ? $_[0] : { @_ };

    map { $h->{$_} = $v->{$_} } keys %$v;

    return 1;
}

sub content {
    my $self = shift;

    if ( scalar @_ ) {
        my @c = ref( $_[0] ) ? @{ $_[0] } : $_[0];
        push( @{ $self->{content} }, @c );
    }

    return $self->{content};
}



sub cookie {

}

sub cookies {

}



1;

__END__
