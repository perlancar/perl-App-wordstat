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
    examples => [
        {
            args => {text=><<'_'},
An optimistic person sees good things everywhere, is generally confident and
hopeful of what the future holds. From the optimist's point-of-view the world is
full of potential opportunities. The pessimist, on the other hand, observes
mainly the negative aspects of everything around.

_
            naked_result => {
                'avg_line_len' => '56',
                'avg_line_with_words_len' => '70',
                'avg_nonempty_line_len' => '70',
                'avg_word_len' => '5.17777777777778',
                'avg_words_per_line' => '9',
                'avg_words_per_line_with_words' => '11.25',
                'avg_words_per_nonempty_line' => '11.25',
                'longest_word_len' => 13,
                'num_chars' => 285,
                'num_lines' => 5,
                'num_lines_with_words' => 4,
                'num_nonempty_lines' => 4,
                'num_unique_words' => 36,
                'num_words' => 45,
                'shortest_word_len' => 1
            },
        },
        {
            summary => 'Supply text from file or stdin',
            argv => ['file.txt'],
            test => 0,
            'x.doc.show_result' => 0,
        },
    ],
};
sub wordstat {
    my %args = @_;
    my $text = $args{text};

    my %stats = (
        # line stats
        num_lines => 0,
        num_nonempty_lines => 0,
        num_lines_with_words => 0,
        avg_line_len => 0,
        avg_nonempty_line_len => 0,
        avg_line_with_words_len => 0,

        # word stats
        num_words => 0,
        num_unique_words => 0,
        longest_word_len => 0,
        shortest_word_len => undef,
        avg_word_len => 0,
        avg_words_per_line => 0,
        avg_words_per_nonempty_line => 0,
        avg_words_per_line_with_words => 0,

        # char stats
        num_chars => 0,
    );

    $stats{num_chars} = length($text);

  LINE_STATS: {
        my @lines = split /^/m, $text;
        chomp for @lines;

        my $tot_line_len = 0;
        for my $line (@lines) {
            my $line_len = length($line);

            $stats{num_lines}++;
            $stats{num_nonempty_lines}++ if $line =~ /\S/;
            $stats{num_lines_with_words}++ if $line =~ /\w+/;
            $tot_line_len += $line_len;
        }
        $stats{avg_line_len}            = $tot_line_len / $stats{num_lines} if $stats{num_lines};
        $stats{avg_nonempty_line_len}   = $tot_line_len / $stats{num_nonempty_lines} if $stats{num_nonempty_lines};
        $stats{avg_line_with_words_len} = $tot_line_len / $stats{num_lines_with_words} if $stats{num_lines_with_words};
    }

  WORD_STATS: {
        my %words;
        my $tot_word_len = 0;
        while ($text =~ /(\w+)/g) {
            my $word = $1;
            my $word_len = length($word);

            $stats{num_words}++;
            $stats{num_unique_words}++ unless $words{ lc $word }++;
            $stats{longest_word_len}  = $word_len if $word_len > $stats{longest_word_len};
            $stats{shortest_word_len} = $word_len if !defined($stats{shortest_word_len}) || $stats{shortest_word_len} > $word_len;
            $tot_word_len += $word_len;
        }

        $stats{avg_word_len} = $tot_word_len / $stats{num_words} if $stats{num_words};
        $stats{avg_words_per_line}            = $stats{num_words} / $stats{num_lines} if $stats{num_lines};
        $stats{avg_words_per_nonempty_line}   = $stats{num_words} / $stats{num_nonempty_lines} if $stats{num_nonempty_lines};
        $stats{avg_words_per_line_with_words} = $stats{num_words} / $stats{num_lines_with_words} if $stats{num_lines_with_words};
    }

    [200, "OK", \%stats];
}

1;
#ABSTRACT:

=head1 DESCRIPTION

See included script L<wordstat>.


=head1 SEE ALSO

L<freqtable> from L<App::freqtable>.

=cut
