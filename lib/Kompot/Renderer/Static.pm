package Kompot::Renderer::Static;

use strict;
use warnings;

use utf8;
use v5.12;

use autodie qw(open close);

use base 'Kompot::Base';

sub render {
    my ($self, $path) = @_;

    $path = $self->app->conf->static . $path;
    return if not -e $path;

    my $data;
    open my $fh, '<', $path;
    $data .= $_ while (<$fh>);
    close $fh;

    return $data;
}

1;

__END__
