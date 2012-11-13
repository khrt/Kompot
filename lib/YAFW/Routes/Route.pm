package YAFW::Routes::Route;

use v5.12;

use strict;
use warnings;

use utf8;
use autodie;

use DDP;
use Carp;
use File::stat;
use Digest::SHA1 qw(sha1_hex);

use base 'YAFW::Base';

use YAFW::Response;


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

        $p =~ s#:([\w\d]+)#(?<$1>[^/]+)#g;

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

    return $self->{_params} if $self->{_params};

    my %p;

    foreach ( @{ $self->{_path_keys} } ) {
        $p{$_} = $+{$_};
    }

    $self->{_params} = \%p || {};

    return $self->{_params};
}


sub _path_keys {
    my $self = shift;

    my $path = $self->path;

    my @p;

    while ( $path =~ m#:([^/]+)#g ) {

        $self->{has_params} ||= 1;

        push( @p, $1 );
    }

    $self->{_path_keys} = \@p || [];

    return $self->{_path_keys};
}


sub cache_file {
    my $self = shift;

    return $self->{cache_file} if $self->{cache_file};


    my $hash = $self->path;

    if ( $self->has_params ) {
        $hash .= values( %{ $self->parse_path_params } );
    }

    $self->{cache_file} = '/tmp/' . $self->app->name . '-' . sha1_hex($hash);

    return $self->{cache_file};
}

sub cached {
    my $self = shift;

    # file not exists
    return if ( not -e $self->cache_file );

    my $st = stat( $self->cache_file ) or die $1;

    # cache expired
    return if ( $self->cache_ttl < ( time - $st->mtime ) );

    return 1;
}

sub cache {
    my ( $self, $res ) = @_;

    # cache
    if ( $res && $res->content && not $self->cached ) {

        open my $fh, '>:encoding(UTF-8)', $self->cache_file;
        print $fh $res->status . "\n"; 
        print $fh $res->content_type . "\n"; 

        for ( @{ $res->content } ) { print $fh $_ };

        close $fh;

        return 1;
    }


    return if not $self->cached;


    open my $fh, '<', $self->cache_file;
    my @data = <$fh>;
    close $fh;

    my $st = shift @data;
    chomp $st;

    my $ctype = shift @data;
    chomp $ctype;

    $res =
        YAFW::Response->new(
            status       => $st,
            content_type => $ctype,
            content      => \@data,
        );

    return $res;
}


1;

__END__
