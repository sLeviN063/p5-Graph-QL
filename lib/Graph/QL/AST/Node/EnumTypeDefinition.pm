package Graph::QL::AST::Node::EnumTypeDefinition;
# ABSTRACT: AST Node for GraphQL in Perl
use v5.24;
use warnings;
use experimental 'signatures', 'postderef';
use decorators ':accessors', ':constructor';

use Ref::Util ();

use Graph::QL::Util::Errors 'throw';

our $VERSION = '0.01';

use parent 'Graph::QL::AST::Node';
use roles  'Graph::QL::AST::Node::Role::Definition';
use slots (
    name       => sub { die 'You must supply a `name`'},
    directives => sub { +[] },
    values     => sub { +[] },
);

sub BUILDARGS : strict(
    name         => name,
    directives?  => directives,
    values?      => values,
    location?    => super(location),
);

sub BUILD ($self, $params) {

    throw('The `name` must be of type(Graph::QL::AST::Node::Name), not `%s`', $self->{name})
        unless Ref::Util::is_blessed_ref( $self->{name} )
            && $self->{name}->isa('Graph::QL::AST::Node::Name');
    
    throw('The `directives` value must be an ARRAY ref')
        unless Ref::Util::is_arrayref( $self->{directives} );
    
    foreach ( $self->{directives}->@* ) {
         throw('The values in `directives` must all be of type(Graph::QL::AST::Node::Directive), not `%s`', $_ )
            unless Ref::Util::is_blessed_ref( $_ )
                && $_->isa('Graph::QL::AST::Node::Directive');
    }
    
    throw('The `values` value must be an ARRAY ref')
        unless Ref::Util::is_arrayref( $self->{values} );
    
    foreach ( $self->{values}->@* ) {
         throw('The values in `values` must all be of type(Graph::QL::AST::Node::EnumValueDefinition), not `%s`', $_ )
            unless Ref::Util::is_blessed_ref( $_ )
                && $_->isa('Graph::QL::AST::Node::EnumValueDefinition');
    }
    
}

sub name       : ro;
sub directives : ro;
sub values     : ro;

1;

__END__

=pod

=cut
