package Kompot::Base;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;

sub attr {
    my ($class, $name, $default) = @_;

    no strict 'refs';
    my $caller = caller;

    *{"${caller}::$name"} = sub {
        my ($self, $value) = @_;
        $self->{$name} = $value if $value;
        return $self->{$name} || $default || undef;
    };
}

sub new {
    my $class = shift;

    my $self = bless {}, ref $class || $class;
    $self->init(@_);

    return $self;
}

# default initializer
sub init {1}

sub app { state $_app ||= Kompot::App->new }

1;

__END__
