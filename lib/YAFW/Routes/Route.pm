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

    return 1;
}

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

    if ( $path =~ $re ) {
        $self->parse_path_params;
        return 1;
    }

    return 0;
}

# TODO
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

sub has_params { shift->{has_params} }

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

    $self->{cache_file} ||=
        '/tmp/' . sha1_hex($self->app->config->salt) . sha1_hex($self->path);

    return $self->{cache_file};
}

sub cache_ttl { shift->{cache_ttl} || 42 }

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

return 0;

    # cache
    if ( $res && $res->content && not $self->cached ) {

        open my $fh, '>:encoding(UTF-8)', $self->cache_file;
        print $fh $res->status . "\n"; 
        print $fh $res->content_type . "\n"; 
        print $fh $res->content;
        close $fh;

        return 1;
    }


    return if not $self->cached;

    open my $fh, '<', $self->cache_file;
    my @data = <$fh>;
    close $fh;

p @data;
die;

    my $status = 000; # read
    my $content_type = '/'; # ...
    my $content = ''; # ...


    return
        YAFW::Response->new(
            status       => $status,
            content_type => $content_type,
            content      => $content,
        );
}


1;

__END__
