package OrangeGrove;

use 5.14.0;

use Moose;
#use Data::Dumper;
use OrangeGrove::Utils;

our $VERSION = "Beta";
our $DEBUG = 0;
our $VALIDATE = 0;
our %FLAGS;

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
    sayd "Run in debug mode...";
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
    sayd "Use " . $ctrlr_name . " for controller.";

    $self->controller($ctrlr_name->new($self->proj));
}

sub run {
    my $self = shift;
    $self->controller->run;
}
return 1;
