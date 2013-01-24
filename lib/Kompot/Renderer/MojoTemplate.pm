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

# TODO update stash code or think of something else
sub stash {
    my ($self, $key) = @_;
    return $key ? $self->{stash}{$key} : $self->{stash};
}


sub helpers {}
sub register_default_helpers {}
sub add_helper {}

sub render {
    my ($self, $name, %p) = @_;

    # set stash
    $self->{stash} = \%p;

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

    my $stash = $self->stash;
    my $layout = delete $stash->{layout};

    $stash->{extends} ||= join('/', 'layouts', $layout) if $layout;

    return delete $stash->{extends};
}

sub _process {
    my ($self, $tmpl) = @_;

    my $stash = $self->stash;
    my $helpers = $self->helpers;

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

    my $out = $mt->name($tmpl)->render_file($tmpl, $self);

    # TODO: Detect fails
    # if rendering failed Mojo::Template does not tell us about it anything
    # and just returns an error as a plain text, the same as it do in success

    return $out;
}

1;

__END__
