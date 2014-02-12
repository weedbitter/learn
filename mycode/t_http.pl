#!usr/bin/perl
use utf8;
use JSON::XS;
use Mojo::UserAgent;
use Data::Dump;


my $ua = Mojo::UserAgent->new;
my $url = 'http://localhost:9898/';

#my $opt = 'down_file';
my $opt = 'assign_job';
my $id  = '429';
my $date = '2013-11-13';
my $type = '0039';

my $tx = $ua->post(
    $url,
    encode_json {
        action => $opt,
        param  => {
            mission_id    => $id,
            date      => $date,
            type      => $type,
            oper_user => '1',
        }
    }
)->res->json;
Data::Dump->dump($tx);

$res = $tx->{status};
if ( defined $res && $res == 0 ) {
    print "success\n";
}
else{
    print "error\n";
}
