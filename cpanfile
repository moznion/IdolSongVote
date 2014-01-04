requires 'Amon2', '6.00';
requires 'Capture::Tiny', '0.23';
requires 'Crypt::Blowfish', '2.14';
requires 'DBD::mysql', '4.025';
requires 'DBD::SQLite', '1.33';
requires 'DBI', '1.630';
requires 'File::ShareDir', '1.03';
requires 'Getopt::Long', '2.42';
requires 'HTML::FillInForm::Lite', '1.11';
requires 'HTTP::Session2', '0.04';
requires 'JSON', '2.50';
requires 'Module::Build', '0.4203';
requires 'Module::Functions', '2';
requires 'Plack::Middleware::ReverseProxy', '0.09';
requires 'Router::Boom', '0.06';
requires 'Starlet', '0.20';
requires 'SQL::Maker', '1.12';
requires 'Teng', '0.18';
requires 'Test::WWW::Mechanize::PSGI';
requires 'Text::Xslate', '2.0009';
requires 'Time::Piece', '1.20';
requires 'URI::Escape', '3.31';
requires 'perl', '5.010_001';
requires 'parent';

on configure => sub {
    requires 'Module::Build', '0.38';
    requires 'Module::CPANfile', '0.9010';
};

on test => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Requires', '0.07';
};

on develop => sub {
    requires 'Perl::Critic', '1.105';
    requires 'Test::Perl::Critic', '1.02';
};
