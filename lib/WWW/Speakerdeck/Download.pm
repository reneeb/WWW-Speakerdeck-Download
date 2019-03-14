package WWW::Speakerdeck::Download;

# ABSTRACT: Download a deck from speakerdeck.com

use Mojo::Base -base, -signatures;

use Carp;
use Mojo::UserAgent;
use Mojo::File qw(path);
use Scalar::Util qw(blessed);

has ua => sub {
    Mojo::UserAgent->new
};

has base_url => 'https://speakerdeck.com';

sub download ($self, $user, $name, $to = '' ) {

    croak 'need plain path to target or Mojo::File object' if !blessed( $to ) && ref $to;

    my $url  = join '/', $self->base_url, $user, $name;
    my $tx   = $self->ua->get( $url );

    croak 'cannot get deck ' . $url . ': ' . $tx->res->message if $tx->res->is_error;

    my $icon = $tx->res->dom->find("svg.icon-download")->first;

    croak 'cannot download ' . $name . ' deck: download link not found' if !$icon;

    my $link = $icon->parent->attr('href');

    my $basename = path( $link )->basename;

    $to = path( '.', $basename ) if !$to;
    $to = path($to)              if !blessed( $to );

    croak 'need plain path to target or Mojo::File object' if !$to->isa('Mojo::File');

    my $download_tx = $self->ua->get( $link );
    my $res         = $download_tx->res;

    croak 'cannot download deck: ' . $res->message if $res->is_error;

    $to->spurt( $res->body );

    return 1;
}

1;

=head1 SYNOPSIS

    use WWW::Speakerdeck::Download;
    
    my $client = WWW::Speakerdeck::Download->new;
    $client->download('reneeb_perl', 'is-mojolicious-web-only');

=head1 METHODS

=head2 download

Returns C<1> if the deck was downloaded, C<croak>s otherwise.

   $client->download('reneeb_perl', 'is-mojolicious-web-only');
   $client->download('reneeb_perl', 'is-mojolicious-web-only', '/path/to/target.pdf');

=head1 ATTRIBUTES

=over 4

=item * base_url

Default: C<https://speakerdeck.com>

=item * ua

A L<Mojo::UserAgent> (or one of its subclasses) object.

=back
