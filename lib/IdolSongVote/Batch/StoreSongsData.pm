package IdolSongVote::Batch::StoreSongsData;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite(
    new => 1,
    ro  => [qw/c/],
);

sub run {
    my ($self, $num) = @_;
    my $c = $self->c;

    my $table = 'songs';

    my $songs = '';
    open my $fh, '<', $c->base_dir . '/script/songs_data/songs.tsv'
        or die "Please execue `phantomjs scrape_songs_data.js > songs.tsv`";
    while (my $line = <$fh>) {
        $songs .= $line;
    }
    close $fh;

    my $i = 0;
    $num  = 661;
    for my $song (split /\n/, $songs) {
        last if $i >= $num;

        my ($title, $first_char) = split /\t/, $song;
        next if !$title || !$first_char;

        eval {
            $c->db->insert($table,
                +{
                    title      => $title,
                    first_char => $first_char,
                    polled     => 0,
                },
            );
        };
        unless ($@) {
            $i++;
        }
    }
}

1;
