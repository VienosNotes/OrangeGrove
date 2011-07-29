########################################################################
#
#  Pager::XML::Page - Convert from XML scenario files to Page objects.
#  Wrote by D.Aoki in 2011.03.17 - yyyy.mm.dd
#
########################################################################

package OrangeGrove::XML::Page;
use 5.12.3;
use Moose;
use MooseX::AttributeHelpers;
use Data::Dumper;

has proj => (
    is => "ro",
);

has title => (
    is => "rw",
);

has bg => (
    is => "rw",
);

has fg => (
    metaclass => "Collection::Array",
    is => "rw",
    isa => "ArrayRef",
    default => sub { [] },
    provides => {
        push => "fg_push",
        clear => "fg_clear",
    },
);

has name => (
    is => "rw",
);

has msg => (
    is => "rw",
);

has ext => (
    is => "rw",
);

has config => (
    is => "rw",
);

sub BUILDARGS {

    my ($self, $ctrlr, $tree, $prev) = @_;

    if (defined $prev) {
         return {
             proj => $ctrlr->proj
             config => $ctrlr->config,
             tree => $tree,
             prev => $prev,
         };
     } else {
         return {
             proj => $ctrlr->proj
             config => $ctrlr->config,
             tree => $tree,
         };
     }
}

sub BUILD {
    my $self = shift;

    #これが最初のページだったらnoneで初期化
    unless (defined $self->prev) {
        $self->bg("none");

        say Dumper $self;
        for (0..$self->config->fg_count) {
            $self->fg_push("none");
        }

        $self->name("none");
        $self->msg("none");
        $self->ext("none");
    }

    #ハッシュツリーからページを構築

    #ページタイトルは引き継がないので毎回初期化
    if (defined $self->tree->{title}) {
        $self->title($self->tree->{title});
    } else {
        $self->title("none");
    }

    #背景画像の上書き/引き継ぎ/初期化
    if (defined $self->tree->{fig}->{bg}->{fig}) {
        $self->bg($self->tree->{fig}->{bg}->{fig});
    } elsif (defined $self->prev) {
        $self->bg($self->prev->bg);
    } else {
        $self->bg("none");
    }

    #前景画像リストの上書き/引き継ぎ/初期化
    $self->fg_clear;

    #$self->fgをclearしてからpushで突っ込む
    for (0..$self->config->fg_count-1) {
        if (defined $self->tree->{fig}->{fg}->{"pos$_"}) {
            $self->fg_push($self->tree->{fig}->{fg}->{"pos$_"});
        } elsif (defined $self->prev) {
#            $self->fg_push(${$self->prev}->fg->[$_]);
            $self->fg_push($self->prev->fg->[$_]);
        } else {
            $self->fg_push("none");
        }
    }

    #発言者は引き継がないので毎回初期化
    if (defined $self->tree->{text}->{name}) {
        $self->name($self->tree->{text}->{name})
    } else {
        $self->name("none");
    }

    #本文は引き継がないので毎回初期化
    if (defined $self->tree->{text}->{msg}) {
        $self->msg($self->tree->{text}->{msg});
    } else {
        $self->msg("none");
    }

    #拡張は引き継がないので毎回初期化
    if (defined $self->tree->{ext}) {
        $self->ext($self->tree->{ext});
    } else {
        $self->ext("none");
    }

    return $self;
}

1;
