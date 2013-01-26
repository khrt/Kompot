# Kompot
Kompot is a simple Perl web-framework inspired by Dancer and
Mojolicious::Lite which is developed for training purposes.

# Usage
````
use Kompot;

get '/' => sub {
  my $self = shift;
  my $name = $self->param('p');
  $self->render(text => "Hello, $name!");
}
````

# Kompot?
Kompot is a traditional Eastern European non alcoholic clear juice obtained by
cooking fruit, in a large volume of water, like strawberries, apricots, peaches,
apples, rhubarb, gooseberries, or sour cherries.
