#!usr/bin/perl

use Mojo::UserAgent;
my $ua = Mojo::UserAgent->new;

# Say hello to the Unicode snowman with "Do Not Track" header
say $ua->get('www.☃.net?hello=there' => {DNT => 1})->res->body;

# Form POST with exception handling
my $tx = $ua->post('https://metacpan.org/search' => form => {q => 'mojo'});
if (my $res = $tx->success) { say $res->body }
else {
    my ($err, $code) = $tx->error;
    say $code ? "$code response: $err" : "Connection error: $err";
}

# Quick JSON API request with Basic authentication
say $ua->get('https://sri:s3cret@example.com/search.json?q=perl')
->res->json('/results/0/title');

# Extract data from HTML and XML resources
say $ua->get('www.perl.org')->res->dom->html->head->title->text;

# Scrape the latest headlines from a news site
say $ua->get('perlnews.org')->res->dom('h2 > a')->text->shuffle;

# IPv6 PUT request with content
my $tx
= $ua->put('[::1]:3000' => {'Content-Type' => 'text/plain'} => 'Hello!');

# Grab the latest Mojolicious release :)
$ua->max_redirects(5)->get('latest.mojolicio.us')
->res->content->asset->move_to('/Users/sri/mojo.tar.gz');

# TLS certificate authentication and JSON POST
my $tx = $ua->cert('tls.crt')->key('tls.key')
->post('https://example.com' => json => {top => 'secret'});

# Blocking parallel requests (does not work inside a running event loop)
my $delay = Mojo::IOLoop->delay;
for my $url ('mojolicio.us', 'cpan.org') {
    my $end = $delay->begin(0);
    $ua->get($url => sub {
            my ($ua, $tx) = @_;
            $end->($tx->res->dom->at('title')->text);
        });
}
my @titles = $delay->wait;

# Non-blocking parallel requests (does work inside a running event loop)
my $delay = Mojo::IOLoop->delay(sub {
        my ($delay, @titles) = @_;
        ...
    });
for my $url ('mojolicio.us', 'cpan.org') {
    my $end = $delay->begin(0);
    $ua->get($url => sub {
            my ($ua, $tx) = @_;
            $end->($tx->res->dom->at('title')->text);
        });
}
$delay->wait unless Mojo::IOLoop->is_running;

# Non-blocking WebSocket connection sending and receiving JSON messages
$ua->websocket('ws://example.com/echo.json' => sub {
        my ($ua, $tx) = @_;
        say 'WebSocket handshake failed!' and return unless $tx->is_websocket;
        $tx->on(json => sub {
                my ($tx, $hash) = @_;
                say "WebSocket message via JSON: $hash->{msg}";
                $tx->finish;
            });
        $tx->send({json => {msg => 'Hello World!'}});
    });
Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
