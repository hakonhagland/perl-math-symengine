package Math::SymEngine;
use strict;
use warnings;
use Exporter qw(import);
our %EXPORT_TAGS = ( 'all' => [ qw(    ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(    );
our $VERSION = 0.01;
require XSLoader;

XSLoader::load();

package Math::SymEngine::Basic;
use strict;
use warnings;

package Math::SymEngine::Symbol;
use strict;
use warnings;
our @ISA = qw(Math::SymEngine::Basic);

package Math::SymEngine::Number;
use strict;
use warnings;
our @ISA = qw(Math::SymEngine::Basic);

package Math::SymEngine::Integer;
use strict;
use warnings;
our @ISA = qw(Math::SymEngine::Number);

1;

=head1 NAME

Math::SymEngine - Short description of Math::SymEngine
