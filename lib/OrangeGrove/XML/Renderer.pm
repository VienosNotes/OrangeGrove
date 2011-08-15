package OrangeGrove::XML::Renderer;

use 5.12.3;
use Moose;
use MooseX::AttributeHelpers;

use Encode;
use Imager;
use Imager::Font;
use Imager::DTP::Textbox::Horizontal;

use Data::Dumper;

has pages => (
    isa => "ArrayRef",
    is => "rw"
);

# has config => (
#     is => "ro"
# );

has done => (
    isa => "Int",
    is => "rw"
);

has proj => (
    is => "ro"
);

sub BUILDARGS {
    my ($self, $proj, @pages) = @_;
    return { proj => $proj, pages => \@pages, done => 0};
}

sub init {
}

sub run {
    my $self = shift;

    for (@{$self->pages}) {

        print "\r";
        printf (" => Drawing page %d / %d ...", $self->done + 1, scalar @{$self->pages});

        $self->render($_);
    }
        say "done.";
}

sub render {
    my ($self, $page)  = @_;

    #背景のロード
    my $bg = Imager->new;
    $bg->read(file => $self->proj . "fig/" . $page->bg) or die $bg->errstr;

    #前景のロード
    for (0..$page->config->fg_max) {

        next if ((!defined $page->fg->[$_]) or ($page->fg->[$_] eq "none"));
        my $fg = Imager->new;
        $fg->read(file => $self->proj . "fig/" . $page->fg->[$_]) or die $fg->errstr;

        #背景と合成

        $bg->rubthrough(src => $fg,
                        tx => $page->config->size->{x} * ($page->config->fg_pos->[$_]->{xmid} / 100) - $fg->getwidth/2,
                        ty => $page->config->size->{"y"} * ($page->config->fg_pos->[$_]->{ymid} / 100) - $fg->getheight/2
                    ) or die $bg->errstr;
    }

    #メッセージボックスのロード
    my $msgbox = Imager->new;
    $msgbox->read(file => $self->proj . "fig/" . $page->config->msgbox->{fig}) or die $msgbox->errstr;

    #合成
    $bg->rubthrough(src => $msgbox,
                   tx => $page->config->msgbox->{x},
                   ty => $page->config->msgbox->{"y"},
               ) or die $bg->errstr;

    #フォントのロード
    my $font = Imager::Font->new(file => $self->proj . $page->config->character->{font},
                              size => $page->config->character->{size},
                              aa => 1,
                              color => Imager::Color->new(r => 255, g => 255, b => 255)
                          );

    die "フォント見つからないよ" unless defined $font;

    #テキストの生成
    my $text = " - " . $page->name . " - \n" . $page->msg;
    my $tb = Imager::DTP::Textbox::Horizontal->new(text => decode("utf-8", $text),
                                                   font => $font,
                                                   wspace => 1,
                                                   leading => 130,
                                                   halign => "left",
                                                   valign => "top",
                                                   wrapWidth => $msgbox->getwidth - 50,
                                                   wrapHeight => $msgbox->getheight - 50,
                                                   xscale => 1,
                                                   yscale => 1
                                               );

    #テキストの合成
    $tb->draw(target => $bg,
              x => $page->config->msgbox->{x} + 15,
              y => $page->config->msgbox->{"y"} + 25,
          );

    #PNGとして出力
    mkdir $self->proj . "/output" unless -d $self->proj . "/output";
    my $num = sprintf("%010d", $self->done);
    $bg->write(file => $self->proj . "/output/" . $num . ".png");
    $self->done($self->done + 1);
}

return 1;
