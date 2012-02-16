package OrangeGrove::Cache;
use 5.14.0;
use Moose;
use MooseX::Singleton;
use Digest::SHA1 qw/sha1_hex/;
use OrangeGrove::Utils;
#use OrangeGrove::Utils;

has "cache" => (
    is => "ro",
    isa => "HashRef",
    default => sub { {} }
);

has "font" => (
    is => "ro",
    isa => "HashRef",
    default => sub { {} }
);

has "proj" => (
    is => "ro",
    isa => "Str",
    required => 1
);

has "config" => (
    is => "ro",
    required => 1
);

sub load {
    my ($self, $resource) = @_;
    sayd "$resource reauired";
    say Dumper caller;
    if (defined $self->cache->{$resource}) {
        return $self->cache->{$resource}->copy;
    } else {
        my $img = Imager->new;
        $img->read(file => $self->proj . "fig/" . $resource . ".png") or die $img->errstr;
        {
            no warnings;
            $self->cache->{$resource} = $img if $OrangeGrove::FLAGS{CACHE};
        }
        return $img->copy;
    }
}

sub load_font {
    my ($self, @font) = @_;
    my $digest = sha1_hex Dumper @_;
    if (defined $self->font->{$digest}) {
        return $self->font->{$digest};
    } else {
        my $f = Imager::Font->new(@font);
        $self->font->{$digest} = $f;
        return $f;
    }
}
1;
