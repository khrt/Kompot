package Kompot::Renderer::Xslate;

use strict;
use warnings;

use utf8;
use v5.12;

use Text::Xslate;

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
}

sub render {
    my ($self, $name, %options) = @_;

    my $c = $self->c;

    my $xslate =
        Text::Xslate->new({
#            cache_dir => $cache_dir, # TODO
            path      => $self->app->conf->renderer_paths,
            function  => $c->helpers,
            %options,
        });

    my $out;
    eval { $out = $xslate->render($name, $c->stash); };
    if ($@) {
        carp $@;
        $out = '';
    }

    return
        Kompot::Response->new(
            content_type => 'text/html', # TODO detect content type
            content      => $out,
            status       => 200,
        );
}


1;

__END__
