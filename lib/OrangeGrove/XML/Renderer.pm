package OrangeGrove::XML::Renderer;

use 5.12.3;
use Moose;
use MooseX::AttributeHelpers;

use Encode;
use Imager;
use Imager::Font;
use Imager::DTP::TextBox::Horizontal;

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

sub BUILDARGS {
    my ($self, @pages) = @_;
#    say Dumper @_;
    return { pages => \@pages, done => 0};
}

sub init {
}

sub run {
    my $self = shift;
 #   say Dumper @{$self->pages};

    for (@{$self->pages}) {
#        say Dumper $_;
#        $self->render($_);
    }
}

sub render {
    my ($self, $page)  = @_;

    #背景のロード
#    die Dumper $page;
    my $bg = Imager->new;
    $bg->read(file => $page->bg) or die $bg->errstr;

    #前景のロード

    for (0..$page->config->fg_max) {
        my $fg = Imager->new;
        $fg->read(file => $page->fg->[$_]) or die $fg->errstr;

        #背景と合成
        $bg->rubthrough(src => $fg,
                        tx => $page->config->fg_pos->[$_]->{xmid} - $fg->getwidth/2,
                        ty => $page->config->fg_pos->[$_]->{ymid} - $fg->getheight/2
                    ) or die $bg->errstr;
    }

    #メッセージボックスのロード
    my $msgbox = Imager->new;
    $msgbox->read(file => $page->config->msgbox->{fig}) or die $msgbox->errstr;

    #合成
    $bg->rubthrough(src => $msgbox,
                   tx => $page->config->msgbox->{x},
                   ty => $page->config->msgbox->{"y"},
               ) or die $bg->errstr;

    #フォントのロード
    my $font = Imager::Font->new(file => $page->config->charcter->{font},
                              size => $page->config->charcter->{size},
                              aa => 1,
                              color => Imager::Color->new(r => 255, g => 255, b => 255)
                          );

    #テキストの生成
    my $text = " - " . $page->name . " - \n" . $page->text;
    my $tb = Imager::DTP::TextBox::Horizontal->new(text => decode("utf-8", $text),
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
    mkdir "./png" unless -d "./png";
    my $num = sprintf("%10d", $self->done);
    $bg->write(file => "./png/" . $num . ".png");
    $self->done($self->done + 1);
}

return 1;
