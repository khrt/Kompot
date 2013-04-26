package Kompot::Request::Upload;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;

use base 'Kompot::Base';
use Kompot::Attributes;

# Plack::Request::Upload

has filename     => sub { shift->{filename} };
has size         => sub { shift->{size} };
has tempname     => sub { shift->{tempname} };
has content_type => sub { shift->{headers}{content_type} };
has headers      => sub { shift->{headers} };

sub init {
    my $self = shift;
    my $p = shift;

    my $headers = delete $p->{headers};
    for (keys %$headers) {
        my $k = lc $_;
        $k =~ tr/-/_/;
        $self->{headers}{$k} = $headers->{$_};
    }

    map { $self->{$_} = $p->{$_} } keys %$p;

    return 1;
}

sub basename {
    my $self = shift;

    if (not $self->{basename}) {
        my $basename;
        # File::Utils # TODO

#        require File::Spec::Unix;
#        my $basename = $self->{filename};
#        $basename =~ s|\\|/|g;
#        $basename = ( File::Spec::Unix->splitpath($basename) )[2];
#        $basename =~ s|[^\w\.-]+|_|g;
#        $self->{basename} = $basename;

        $self->{basename} = $basename;
    }

    return $self->{basename};
}

1;

__END__
