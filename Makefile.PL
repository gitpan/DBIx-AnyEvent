use inc::Module::Install;

name 'DBIx-AnyEvent';

all_from 'lib/DBIx/AnyEvent.pm';

build_requires 'Test::Exception' => '0.27';
build_requires 'Test::More'      => '0.72';

requires 'AnyEvent'            => '2.9';
requires 'AnyEvent::Semaphore' => '0.00';
requires 'DBI'                 => '1.604';
requires 'DBD::Pg'             => '2.5.0';

auto_install;

WriteAll;

