package PersistentPixivBookmark::Identity;

use parent qw/Class::Accessor::Fast/;

use strict;
use warnings;

use YAML::Syck;

__PACKAGE__->mk_ro_accessors(qw/
    _id
    _pass
    _mail_address
/);

my $instance;

sub IDENTIFY_FILE_PATH { '.identify.yaml'; }

sub _load {
    my ($class) = @_;
    my $identity = YAML::Syck::LoadFile(IDENTIFY_FILE_PATH());
    $instance = $class->SUPER::new({
        _id              => $identity->{id},
        _pass            => $identity->{pass},
        _mail_address    => $identity->{mail_address},
    });
    return $instance;
}

sub id {
    my ($class) = @_;

    unless ($instance) {
        $class->_load();
    }
    return $instance->_id || $instance->_mail_address;
}

sub pass {
    my ($class) = @_;
    unless ($instance) {
        $class->_load();
    }
    return $instance->_pass;
}

1;
