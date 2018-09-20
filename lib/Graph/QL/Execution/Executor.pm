package Graph::QL::Execution::Executor;
# ABSTRACT: GraphQL in Perl
use v5.24;
use warnings;
use experimental 'signatures', 'postderef';
use decorators ':accessors', ':constructor';

use Graph::QL::Util::Errors     'throw';
use Graph::QL::Util::Assertions ':all';

use Graph::QL::Validation::QueryValidator;

use constant DEBUG => $ENV{GRAPHQL_EXECUTOR_DEBUG} // 0;

our $VERSION = '0.01';

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    schema     => sub {}, # Graph::QL::Schema
    operation  => sub {}, # Graph::QL::Operation
    root_value => sub { +{} }, # root object for execution result
    variables  => sub { +{} }, # any variables passed to execution
    resolvers  => sub { +{} }, # a mapping of TypeName to Resolver instance
    # internals ...
    _context   => sub { +{} }, # the context arg (3rd) to any resolver funtions
    _errors    => sub { +[] }, # a place for errors to accumulate
);

sub BUILDARGS : strict(
    schema      => schema,
    operation   => operation,
    root_value? => root_value,
    variables?  => variables,
    resovlers?  => resolvers,
);

sub BUILD ($self, $params) {

    throw('The `schema` must be of an instance of `Graph::QL::Schema`, not `%s`', $self->{schema})
        unless assert_isa( $self->{schema}, 'Graph::QL::Schema' );

    throw('The `schema` must be of an instance that does the `Graph::QL::Operation` role, not `%s`', $self->{operation})
        unless assert_does( $self->{operation}, 'Graph::QL::Operation' );

    if ( exists $params->{root_value} ) {
        throw('The `root_value` must be a HASH ref, not `%s`', $self->{root_value})
            unless assert_hashref( $self->{root_value} );
    }

    if ( exists $params->{variables} ) {
        throw('The `variables` must be a HASH ref, not `%s`', $self->{variables})
            unless assert_hashref( $self->{variables} );
    }

    if ( exists $params->{resolvers} ) {
        throw('The `resolvers` must be a HASH ref, not `%s`', $self->{resolvers})
            unless assert_non_empty( $self->{resolvers} );

        foreach ( values $self->{resolvers}->%* ) {
             throw('The values in `resolvers` must all be of type(Graph::QL::Execution::FieldResolver), not `%s`', $_ )
                unless assert_isa( $_, 'Graph::QL::Execution::FieldResolver' );
        }
    }
}

sub validate ($self) {
    Graph::QL::Validation::QueryValidator->new(
        schema => $self->{schema},
    )->validate( $self->{operation} );
}


1;

__END__

=pod

=head1 DESCRIPTION

This object contains the data that must be available at all points
during query execution.

Namely, schema of the type system that is currently executing, and
the fragments defined in the query document.

=cut
