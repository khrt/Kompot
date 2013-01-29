package Kompot::Renderer;

use strict;
use warnings;

use utf8;
use v5.12;

use DDP { output => 'stdout' };
use Carp;

use base 'Kompot::Base';
use Kompot::Attributes;
use Kompot::Renderer::JSON;
use Kompot::Renderer::Static;
use Kompot::Response;

has default_content_type => 'text/html';
has engine  => 'Kompot::Renderer::MojoTemplate';
has helpers => {};

sub init {
    my $self = shift;

    # def tmpl path
    my $tpath = $self->app->conf->root . '/templates';
    $self->paths([$tpath]);

    $self->add_helper(dummy => sub { 'DUMMY' });
}

sub add_helper {
    my ($self, $name, $cb) = @_;
    $self->{helpers}{$name} = $cb;
}

sub paths {
    my ($self, $path) = @_;
    if ($path && ref($path)) {
        push(@{ $self->{paths} }, @$path);
    }
    return $self->{paths};
}

sub dynamic {
    my ($self, $c, $p) = @_;

    $p ||= {};

    my $stash = $c->stash;

    map { $p->{$_} = $stash->{$_} } keys(%$stash);

    my $json     = delete($p->{json});
    my $template = delete($p->{template});
    my $text     = delete($p->{text});
    my $type     = $p->{content_type} || $self->default_content_type;

    my $out;

    # JSON
    if (defined($json)) {
        $out = Kompot::Renderer::JSON->new->render(json => $json);
        $type = 'text/json';
    }
    # Text
    elsif (defined($text)) {
        $out = $text;
        $type = $p->{content_type} || 'text/plain';
    }
    elsif (defined($template)) {
        my $renderer = $self->engine;
        if ($self->load_package($renderer)) {
            $out = $renderer->new($c)->render($template);
        }
    }
    else {
        return $self->internal_error('No renderer');
    }

    # in case of errors
    if (not $out) {
        return $self->internal_error('render dynamic error');
    }

    my $r =
        Kompot::Response->new(
            status         => 200,
            content_type   => $type,
            content_length => length($out),
            content        => $out,
        );

    return $r;
}

sub static {
    my ($self, $path) = @_;

    my $out = Kompot::Renderer::Static->new->render($path);

    if (not $out) {
        croak 'file not found';
        return $self->not_found('file not found');
    }

    my $r =
        Kompot::Response->new(
            content_type     => 'text/html', # TODO detect content-type
            content          => $out,
            status           => 200,
            content_length   => length($out),
        );

    return $r;
}

# TODO Move to Rendere::Exception
sub not_found {
    my ($self, $error) = @_;

    if (!$error) {
        my $req = $self->app->request;
        my @routes = $self->app->route->routes;
        my $routes;

        foreach (@routes) {
            $routes .= $_->{method} . "\t=> " . $_->{path} . "\n";
        }

        $error = <<MSG_END;
No route to `${ \$req->path }` via ${ \uc($req->method) }.
Available routes:\n$routes
MSG_END
    }

    my $r =
        Kompot::Response->new(
            content_type     => 'text/plain',
            content          => $error,
            status           => 404,
            content_length   => length($error),
        );

p $self->read_data($self->app->main);
say $self->read_data($self->app->main, 'index.html.ep');
say $self->read_data(ref $self, 'not_found.html');

    return $r;
}

# TODO Move to Renderer::Exception
sub internal_error {
    my ($self, $error) = @_;

    my $r =
        Kompot::Response->new(
            content_type     => 'text/plain',
            content          => $error,
            status           => 500,
            'content-length' => length($error),
            'x-powered-by'   => $self->app->name,
        );

    return $r;
}

sub _is_text {
    my ($self, $content_type) = @_;
    return $content_type =~ /(x(?:ht)?ml|text|json|javascript)/;
}

1;

__DATA__

@@ not_found.html
<!DOCTYPE html>
<html>
<head>
<title>Not Found</title>
</head>
<body>
<h1>Page not found</h1>
<p>Requested URI not found.</p>
<% if ($dev_mode) {
  foreach my $r (@routes) {
    print $r->method;
    print $r->path;
  }
} %>
</body>
</html>

@@ exception.html
<!DOCTYPE html>
<html>
<head>
<title>Exception</title>
</head>
<body>
<h1>Exception</h1>
<p>An error was happened.</p>
</body>
</html>

@@ exception.dev.html
<!DOCTYPE html>
<html>
<head>
<title>Exception DEV</title>
</head>
<body>
<h1>Exception</h1>
<p>An error was happened DEV.</p>
</body>
</html>
