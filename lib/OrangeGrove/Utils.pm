package OrangeGrove::Utils;

use 5.14.0;
use Term::ANSIColor qw/:constants/;
use utf8;
use Encode;
our @EXPORT = qw/sayd Dumper/;
use base qw/Exporter/;

no warnings 'redefine';

$Term::ANSIColor::AUTORESET = 1;

use Data::Dumper;
BEGIN {
    package Data::Dumper {
        sub qquote { return shift; }
    }
}

$Data::Dumper::Useperl = 1;

sub sayd {
    my ($pckg, $fn, $ln) = caller;
    my $sub = (caller(1))[3];
    print RED "[DEBUG]";
    print GREEN "[$fn:";
    print MAGENTA "$sub";
    say GREEN ":$ln] ";
    print GREEN "# ";
    say UNDERLINE @_;
}

sub Dumper {
    encode("utf8", Data::Dumper::Dumper(@_));
}
1;
