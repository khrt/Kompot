package YAFW::Renderer::Static;

use v5.12;

use strict;
use warnings;

use utf8;
use autodie qw(open close);

use MIME::Types;

use base 'YAFW::Base';

use YAFW::Response;

sub init {
    my $self = shift;

    $self->{_mime_types} = MIME::Types->new( only_complete => 1 );
}


sub render {
    my ( $self, $path ) = @_;

    $path = $self->app->dir->static . $path;
    return if not ( -e $path );

    my $data;

    open my $fh, '<', $path;
    $data .= $_ while (<$fh>);
    close $fh;

    my $mime = $self->_mime_type( $path );

    return 
        YAFW::Response->new(
            content_type => $mime,
            content      => $data,
        );
}


sub _mime_type {
    my ( $self, $path ) = @_;

    $path =~ /\.([\w\d]+)$/;

    my $ext = $1;

    my $type = $self->{_mime_types}->mimeTypeOf( lc($ext) );

    return $type || 'application/data';
}


1;

__END__
