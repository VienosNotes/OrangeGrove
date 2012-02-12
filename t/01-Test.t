use 5.14.0;
use OrangeGrove;
use OrangeGrove::Utils;
use Test::More;


#chdir "t/proj";
$OrangeGrove::DEBUG = 1;

my $og = OrangeGrove->new(type => "XML", proj => "t/proj");
$og->run;
ok $og->type eq "XML";
ok $og->proj eq "t/proj/";
say Dumper $og;
done_testing;
