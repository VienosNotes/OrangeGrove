package OrangeGrove;

use 5.12.3;
use Moose;
use Data::Dumper;

our $VERSION = "Beta";

has type => (
    is => "ro",
);

has proj => (
    is => "rw",
);

has controller => (
    is => "rw",
);



sub BUILD {

    say "This is Orange Grove - Movie Builder ver. $VERSION";

    my $self = shift;
    my $ctrlr_name = "OrangeGrove::" . $self->type . "::Controller";
    $self->proj($self->proj . "/") unless ($self->proj =~ m/.*\/$/);

    eval {
        Class::MOP::load_class($ctrlr_name);
    };
    if ( $@ ) {
        say $@;
        die "Module for ". $self->type ." hasn't been installed yet.";
    }

    $self->controller($ctrlr_name->new($self->proj));
}

sub run {
    my $self = shift;
    $self->controller->run;
}
return 1;
