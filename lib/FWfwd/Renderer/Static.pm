package FWfwd::Renderer::Static;

use v5.12;

use strict;
use warnings;

use utf8;

use base 'FWfwd::Base';


sub render {
    my ( $self, $path ) = @_;


    $path = $self->app->dir->static . $path;
    return if not ( -e $path );


    my $data;

    open my $fh, '<', $path;
    $data .= $_ while (<$fh>);
    close $fh;

    return 'text/html', $data;
}


1;

__END__
