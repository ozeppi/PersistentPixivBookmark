use strict;
use warnings;

use Test::More;
use Test::MockModule;
use YAML::Syck;

BEGIN {
    use_ok 'PersistentPixivBookmark::Identity';
};

subtest 'when exists id and mail_address' => sub {
    my $identity_data = {
        pass            => 'bbb',
        mail_address    => 'aaa@pixiv.net',
    };
    my $mocked_yaml_syck = Test::MockModule->new('YAML::Syck');
    $mocked_yaml_syck->mock(LoadFile => sub {
        return $identity_data;
    });

    my $identity = PersistentPixivBookmark::Identity->_load();
    isa_ok $identity, 'PersistentPixivBookmark::Identity';

    is $identity->id, $identity_data->{mail_address}; 
    is $identity->pass, $identity_data->{pass}; 
};

subtest 'when exists mail_address only' => sub {
    my $dummy_file_path = 't/lib/PersistentPixivBookmark/dummy_identify.yaml';
    my $mocked_idenfity = Test::MockModule->new('PersistentPixivBookmark::Identity');
    $mocked_idenfity->mock(IDENTIFY_FILE_PATH => sub {
        return $dummy_file_path;
    });

    my $identity = PersistentPixivBookmark::Identity->_load();
    isa_ok $identity, 'PersistentPixivBookmark::Identity';

    my $original_data = YAML::Syck::LoadFile($dummy_file_path);
    is $identity->id, $original_data->{id}; 
    is $identity->pass, $original_data->{pass}; 
};

done_testing;
