package Kompot::Base;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;

sub new {
    my $class = shift;

    my $self = bless {}, ref $class || $class;
    $self->init(@_);

    return $self;
}

# default initializer
sub init {1}

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
