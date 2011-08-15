package OrangeGrove;

use 5.12.3;
use Moose;
use Data::Dumper;

has type => (
    is => "ro",
);

has proj => (
    is => "ro",
);

has controller => (
    is => "rw",
);

sub BUILD {
    my $self = shift;
    my $ctrlr_name = "OrangeGrove::" . $self->type . "::Controller";

    eval {
        Class::MOP::load_class($ctrlr_name);
    };
    if ( $@ ) {
        say $@;
        die "Module for ". $self->type ." hasn't been installed yet.";
    }

    $self->controller($ctrlr_name->new($self->proj));
}

return 1;
