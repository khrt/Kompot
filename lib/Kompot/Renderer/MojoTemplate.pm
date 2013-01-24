package Kompot::Renderer::MojoTemplate;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use DDP { output => 'stdout' };
use File::Spec::Functions 'catfile';
use Mojo::Template;

use base 'Kompot::Base';

use Kompot::Response;

sub init {
    my ($self, $c) = @_;
    $self->{controller} = $c or return;
    $self->register_default_helpers;
    return 1;
}

sub c { shift->{controller} }

sub register_default_helpers {
    my $self = shift;
    my $c = $self->c;

    $c->add_helper(dummy => sub { 'DUMMY' });

    # from Mojolicious::Plugin::DefaultHelpers
    for my $name (qw(layout title)) {
        $c->add_helper(
            $name => sub {
                my $self  = shift;
                my $stash = $self->stash;

                $stash->{$name} = shift if @_;
                $self->stash(@_) if @_;

                return $stash->{$name};
            }
        );
    }
}

sub render {
    my ($self, $name) = @_;

    my $tmpl = $self->_template_path($name) or return;
    my $out = $self->_process($tmpl) or return;

    while (my $extends = $self->_extends($self)) {
        $self->stash(content => $out);
        $tmpl = $self->_template_path($extends) or return;
        $out = $self->_process($tmpl) or return;
    }

    return
        Kompot::Response->new(
            content_type => 'text/html', # TODO detect content type
            content      => $out,
            status       => 200,
        );
}

sub _template_path {
    my ($self, $name) = @_;

    return if not $name;

    my $paths = $self->app->conf->renderer_paths;

    for my $path (@$paths) {
        my $file = catfile($path, split('/', $name));
        return $file if -r $file;
    }

    carp "Can't find `$name` in paths.";
    return;
}

sub _extends {
    my $self = shift;

    my $stash = $self->c->stash;
    my $layout = delete $stash->{layout};

    $stash->{extends} ||= join('/', 'layouts', $layout) if $layout;

    return delete $stash->{extends};
}

sub _process {
    my ($self, $tmpl) = @_;

    my $c = $self->c;
    my $stash   = $c->stash;
    my $helpers = $c->helpers;

    my $prepend = q/
my $self = shift;
use Scalar::Util 'weaken';
weaken $self;
no strict 'refs';
no warnings 'redefine';
my $_H = $self->helpers;
/;

    for my $name (keys %$helpers) {
        next if $name !~ /^[a-z]\w*$/i;
        $prepend .= "sub $name; *$name = sub {\$_H->{'$name'}->(\$self, \@_)};";
    }

    $prepend .= 'use strict; my $_S = $self->stash;';

    for my $var (keys %$stash) {
        next if $var !~ /^[a-z]\w*$/i;
        $prepend .= "my \$$var = \$_S->{'$var'};";
    }

    $prepend =~ s/\R//gs;

    my $mt = Mojo::Template->new(encoding => 'UTF-8');
    $mt->prepend($prepend);

    my $out = $mt->name($tmpl)->render_file($tmpl, $c);

    if (ref $out) {
        carp 'Render error: ' . $out->to_string;
        return;
    }

    return $out;
}

1;

__END__
