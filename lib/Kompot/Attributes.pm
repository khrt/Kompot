package Kompot::Attributes;

use strict;
use warnings;

use utf8;
use v5.12;

sub import {
    my $caller = caller;
#say "-- [$caller] can has? " . ($caller->can('has') ? 'yes' : 'no');
    if (not $caller->can('has')) {
        no strict 'refs';
say "--> import has to $caller";
        *{"${caller}::has"} = sub { _attr($caller, @_) };
    }
}

sub _attr {
    my ($class, $name, $default) = @_;

    no strict 'refs';
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

    *{"${class}::$name"} = $attr;
}

1;
