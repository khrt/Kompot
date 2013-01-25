package Kompot::Renderer::JSON;

use strict;
use warnings;

use utf8;
use v5.12;

use JSON::XS;

use base 'Kompot::Base';

sub render {
    my ($self, %p) = @_;
    return encode_json($p{json});
}

1;

__END__
