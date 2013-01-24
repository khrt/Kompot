package Kompot::Renderer::MojoTemplate;

use strict;
use warnings;

use utf8;
use v5.12;

use Carp;
use File::Spec::Functions 'catfile';
use Mojo::Template;

use base 'Kompot::Base';

use Kompot::Response;

sub init {
    my $self = shift;

    my $conf = $self->app->conf;

    my $cache_dir = $conf->cache_dir;
    my @paths     = $conf->template_paths;

    $self->{mt} = Mojo::Template->new(encoding => 'UTF-8');

    return 1;
}

sub stash {die}
sub helpers {die}
sub register_default_helpers {die}
sub add_helper {die}
sub paths {die}

sub render {
    my ($self, %p) = @_;

    my $name = delete($p{template});
    my $tmpl = $self->_template_path($name) or return;

    my $out = $self->_process($tmpl) or return;

    while (my $extends = $self->_extends($self)) {
        my $self->stash(content => $out);
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

    for my $path (@{ $self->{paths} }) {
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

    $stash->{extends} ||= join('/', 'layouts', $layout);

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

    my $mt = $self->{mt};
    $mt->prepend($prepend);

    my $out = $mt->name($tmpl)->render_file($tmpl, $self);

    if (ref $out) {
        carp 'Rendering file failed: ' . $out->to_string;
        return;
    }

    return $out;
}

1;

__END__
