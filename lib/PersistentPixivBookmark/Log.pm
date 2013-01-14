package PersistentPixivBookmark::Log;

use strict;
use warnings;

sub debug {
    my ($class, $text) = @_;

    print "DEBUG: $text\n";
}

1;
