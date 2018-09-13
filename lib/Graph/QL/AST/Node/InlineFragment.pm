package Graph::QL::AST::Node::InlineFragment;
# ABSTRACT: AST Node for GraphQL in Perl
use v5.24;
use warnings;
use experimental 'signatures', 'postderef';
use decorators ':accessors', ':constructor';

use Ref::Util ();

use Graph::QL::Util::Errors 'throw';

our $VERSION = '0.01';

use parent 'Graph::QL::AST::Node';
use roles  'Graph::QL::AST::Node::Role::Selection';
use slots (
    type_condition => sub {},
    directives     => sub { +[] },
    selection_set  => sub { die 'You must supply a `selection_set`'},
);

sub BUILDARGS : strict(
    type_condition?  => type_condition,
    directives?      => directives,
    selection_set    => selection_set,
    location?        => super(location),
);

sub BUILD ($self, $params) {

    if ( exists $params->{type_condition} ) {
        throw('The `type_condition` must be of type(Graph::QL::AST::Node::NamedType), not `%s`', $self->{type_condition})
            unless Ref::Util::is_blessed_ref( $self->{type_condition} )
                && $self->{type_condition}->isa('Graph::QL::AST::Node::NamedType');
    }
    
    throw('The `directives` value must be an ARRAY ref')
        unless Ref::Util::is_arrayref( $self->{directives} );
    
    foreach ( $self->{directives}->@* ) {
         throw('The values in `directives` must all be of type(Graph::QL::AST::Node::Directive), not `%s`', $_ )
            unless Ref::Util::is_blessed_ref( $_ )
                && $_->isa('Graph::QL::AST::Node::Directive');
    }
    
    throw('The `selection_set` must be of type(Graph::QL::AST::Node::SelectionSet), not `%s`', $self->{selection_set})
        unless Ref::Util::is_blessed_ref( $self->{selection_set} )
            && $self->{selection_set}->isa('Graph::QL::AST::Node::SelectionSet');
    
}

sub type_condition : ro;
sub directives     : ro;
sub selection_set  : ro;

1;

__END__

=pod

=cut
