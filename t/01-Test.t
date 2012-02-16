use 5.14.0;
use OrangeGrove;
use OrangeGrove::Utils;
use Test::More;

$OrangeGrove::FLAGS{DEBUG} = 1;
$OrangeGrove::FLAGS{CHECK} = 1;
$OrangeGrove::FLAGS{VALIDATE} = 1;
$OrangeGrove::FLAGS{OUTPUT} = 1;
$OrangeGrove::FLAGS{CACHE} = 1;

my $og = OrangeGrove->new(type => "XML", proj => "t/proj");
$og->run;
ok $og->type eq "XML";
ok $og->proj eq "t/proj/";
say Dumper $og;
done_testing;
