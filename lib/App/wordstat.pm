package App::wordstat;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{wordstat} = {
    v => 1.1,
    summary => 'Return word statistics of a text',
    args => {
        text => {
            schema => ['str*'],
            req => 1,
            pos => 0,
            cmdline_src => 'stdin_or_files',
        },
        # XXX ci
    },
};
sub wordstat {
    my %args = @_;
    my $text = $args{text};

    my %stats = (
        num_chars => 0,
        num_lines => 0,
        num_words => 0,
        num_unique_words => 0,
        longest_word_len => 0,
        shortest_word_len => undef,
        avg_word_len => 0,
        # avg_num_words_per_line
        # avg_line_len
        # avg_words_per_line
    );

    $stats{num_chars} = length($text);
    $stats{num_lines}++ while $text =~ /^/gm;

    my %words;
    my $tot_word_len = 0;
    while ($text =~ /\b(S+?)\b/g) {
        my $word = $1;
        my $word_len = length($word);

        $stats{num_words}++;
        $stats{num_unique_words}++ unless $words{ lc $word }++;
        $stats{longest_word_len}  = $word_len if $word_len > $stats{longest_word_len};
        $stats{shortest_word_len} = $word_len if !defined($stats{shortest_word_len}) || $stats{shortest_word_len} > $word_len;
        $tot_word_len += $word_len;
    }

    $stats{avg_word_len} = $tot_word_len / $stats{num_words} if $stats{num_words};

    [200, "OK", \%stats];
}

1;
#ABSTRACT:

=head1 DESCRIPTION

See included script L<wordstat>.


=head1 SEE ALSO

=cut
