package Kompot::Renderer::JSON;

use v5.12;

use strict;
use warnings;

use utf8;

use JSON::XS;

use base 'Kompot::Base';

use Kompot::Response;

sub render {
    my $self = shift;

    my $p = {@_};

    my $json = encode_json($p->{json});

    return if not $json;

    return
        Kompot::Response->new(
            content_type => 'application/json',
            content      => $json,
            status       => 200,
        );
}


1;

__END__
