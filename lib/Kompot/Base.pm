package Kompot::Base;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;

sub import {
    my $caller = caller;
#say "-- [$caller] can has? " . ($caller->can('has') ? 'yes' : 'no');
    if (not $caller->can('has')) {
        no strict 'refs';
say "--> import has to $caller";
        *{"${caller}::has"} = sub { _attr($caller, @_) };
    }
}

sub new {
    my $class = shift;

    my $self = bless {}, ref $class || $class;
    $self->init(@_);

    return $self;
}

# default initializer
sub init {1}

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

sub load_package {
    my ($self, $package) = @_;

    return if not $package;
    return 1 if $package->can('new');

    eval "use $package";
    if ($@) {
        carp "Can't init `$package`!";
        return;
    }

    return 1;
}

sub app { state $_app ||= Kompot::App->new }

1;

__END__
