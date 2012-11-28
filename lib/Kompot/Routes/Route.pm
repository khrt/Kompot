package Kompot::Routes::Route;

use v5.12;

use strict;
use warnings;

use utf8;
use autodie;

use DDP;
use Carp;
use File::stat;
use Digest::SHA1 qw(sha1_hex);

use base 'Kompot::Base';

use Kompot::Response;


sub init {
    my $self = shift;

    my $p = @_ % 2 ? $_[0] : { @_ };

    croak 'Not enough parameters for add route'
        if ( !$p->{method} || !$p->{path} || !$p->{code} );

    map { $self->{$_} = $p->{$_} } keys( %$p );

    $self->_path_keys;


    $self->{cache_ttl} = $self->app->config->cache_ttl || 0;

    return 1;
}


sub cache_ttl  { shift->{cache_ttl} }

sub has_params { shift->{has_params} }

sub code    { shift->{code} }

sub method  { uc( shift->{method} ) }
sub path    { shift->{path} }


sub path_re { 
    my $self = shift;

    # compile re
    if ( not $self->{path_re} ) {

        my $p = $self->path;

        # replace path to regex; to routes with defined regex
        $p =~ s#:([\w\d]+)(?:{([^}]+)})?#(?<$1>$2)#g;

        # add default regex to route params without regex
        $p =~ s#\(\?<([\w\d]+)>\)#(?<$1>[^/]+)#g;

        $self->{path_re} = qr/^$p$/;
    }

    return $self->{path_re};
}

sub match {
    my ( $self, $path ) = @_;

    my $re = $self->path_re;

    return if $path !~ $re;

    $self->parse_path_params;

    return 1;
}


sub parse_path_params {
    my $self = shift;

    my %p;

    foreach ( @{ $self->{_path_keys} } ) {
        $p{$_} = $+{$_};
    }

    $self->{_params} = \%p || {};

    $self->app->request->_set_route_params( $self->{_params} );

    return $self->{_params};
}


sub _path_keys {
    my $self = shift;

    my $path = $self->path;

    my @p;

    while ( $path =~ m#:([^/{]+)#g ) {

        $self->{has_params} ||= 1;

        push( @p, $1 );
    }

    $self->{_path_keys} = \@p || [];

    return $self->{_path_keys};
}


sub _cache_filename {
    my $self = shift;

    my $hash = $self->path;

    if ( $self->has_params ) {
        $hash .= join( '&', values( %{ $self->{_params} } ) );
    }

    my $name = '/tmp/' . $self->app->name . '-' . sha1_hex($hash);

    return $name;
}

sub cached {
    my $self = shift;

    my $file = $self->_cache_filename;

    # file not exists
    return if ( not -e $file );

    my $st = stat($file) or die $1;

    # cache expired
    return if ( $self->cache_ttl < ( time - $st->mtime ) );

    return 1;
}

sub cache {
    my ( $self, $res ) = @_;

    my $file = $self->_cache_filename;

    # cache
    if ( $res && $res->content && not $self->cached ) {

        open my $fh, '>:encoding(UTF-8)', $file;
        print $fh $res->status . "\n"; 
        print $fh $res->content_type . "\n"; 

        for ( @{ $res->content } ) { print $fh $_ };

        close $fh;

        return 1;
    }


    return if not $self->cached;


    open my $fh, '<', $file;
    my @data = <$fh>;
    close $fh;

    my $st = shift @data;
    chomp $st;

    my $ctype = shift @data;
    chomp $ctype;

    $res =
        Kompot::Response->new(
            status       => $st,
            content_type => $ctype,
            content      => \@data,
        );

say 'return from cache: ' . $self->path;

    return $res;
}


1;

__END__
