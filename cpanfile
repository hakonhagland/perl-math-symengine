on 'build' => sub {
    requires 'ExtUtils::CXX';
};
on 'test' => sub {
    requires 'Package::Alias';
};
