package Graph::QL::Introspection::Resolvers::__Field;
# ABSTRACT: GraphQL in Perl
use v5.24;
use warnings;
use experimental 'signatures', 'postderef';

use Graph::QL::Util::JSON;

our $VERSION = '0.01';

sub name        ($field, $, $, $) { $field->name }
sub description ($type, $, $, $) { return } # TODO

sub args ($field, $, $, $) {
    return [] unless $field->has_args;
    return $field->args;
}

sub type ($field, $, $, $) { $field->type }

sub isDeprecated      ($field, $, $, $) { Graph::QL::Util::JSON->FALSE } # TODO
sub deprecationReason ($field, $, $, $) { return } # TODO

1;

__END__

=pod

type __Field {
    name              : String!
    description       : String
    args              : [__InputValue!]!
    type              : __Type!
    isDeprecated      : Boolean!
    deprecationReason : String
}

=cut
