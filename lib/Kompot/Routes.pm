package Kompot::Routes;

use v5.12;

use strict;
use warnings;

use utf8;

use Carp;
use DDP { output => 'stdout' };

use base 'Kompot::Base';

use Kompot::Request;
use Kompot::Routes::Route;
use Kompot::Controller;


sub init {
    my $self = shift;

    $self->{routes} ||= [];
}

sub add {
    my $self = shift;

    my ($methods, $path, $code) = @_;

    $methods = [$methods] if not ref($methods);

    foreach my $method (@$methods) {
        my $route =
            Kompot::Routes::Route->new(
                { method => $method, path => $path, code => $code, }
            );

        push(@{ $self->{routes} }, $route);
    }
}

sub routes {
    map { { method => $_->method, path => $_->path } } @{ shift->{routes} };
}

sub find {
    my ($self, $method, $path) = @_;

    grep { (uc($method) eq $_->method) && $_->match($path) } @{ $self->{routes} };
}

sub dispatch {
    my $self = shift;

    my $req = $self->app->request;

    my $res;

    # static
    if ($req->is_static) {
        $res = $self->app->render->static($req->path);
    }
    # action
    elsif (my ($route) = $self->find($req->method, $req->path)) {
#say 'route:';
#p $route;
#say "\n\n";
        if ($route->cached) {
            $res = $route->cache;
        }
        else {
            $res = $route->code->(Kompot::Controller->new($req));
            $route->cache($res) if $res;
        }
    }

    # 404
    if (not $res) {
        my @routes = $self->routes;
        my $routes;

        foreach (@routes) {
            $routes .= $_->{method} . "\t=> " . $_->{path} . "\n";
        }

        my $errmsg = <<MSG_END;
No route to `${ \$req->path }` via ${ \uc($req->method) }.
Available routes:\n$routes
MSG_END

        $res = $self->app->render->not_found($errmsg);
    }

    return $res;
}


1;

__END__
