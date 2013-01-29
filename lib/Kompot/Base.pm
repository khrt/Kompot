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

sub read_data {
    my ($self, $class, $data) = @_;
    state %CACHE;

    # Refresh or use cached data
    my $handle = do { no strict 'refs'; \*{"${class}::DATA"} };
    if (not fileno $handle) {
        return $data ? $CACHE{$class}{$data} : $CACHE{$class} || {};
    }

    seek $handle, 0, 0;
    my $content = join '', <$handle>;
    close $handle;

    # Ignore everything before __DATA__ (Windows will seek to start of file)
    $content =~ s/^.*\n__DATA__\r?\n/\n/s;

    # Ignore everything after __END__
    $content =~ s/\n__END__\r?\n.*$/\n/s;

    # Split
    my @data = split /^@@\s*(.+?)\s*\r?\n/m, $content;
    shift @data;

    # Find data
    my $all = $CACHE{$class} = {};
    while (@data) {
        my ($name, $content) = splice @data, 0, 2;
        $all->{$name} = $content;
    }

    return $data ? $all->{$data} : $all;
}

sub app { state $_app ||= Kompot::App->new }

1;

__END__
