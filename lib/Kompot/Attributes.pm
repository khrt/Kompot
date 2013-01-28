package Kompot::Attributes;

use strict;
use warnings;

use utf8;
use v5.12;

sub import {
    my $caller = caller;
    if (not $caller->can('has')) {
        no strict 'refs';
        *{"${caller}::has"} = sub { _attr($caller, @_) };
    }
}

sub _attr {
    my ($class, $name, $default) = @_;

    my $attr;
    if (ref $default eq 'CODE') {
        $attr = $default;
    }
    else {
        $attr = sub {
            my ($self, $value) = @_;
            $self->{$name} = $value if $value;
            return $self->{$name} // $default;
        };
    }

    no strict 'refs';
    *{"${class}::$name"} = $attr;
}

1;
