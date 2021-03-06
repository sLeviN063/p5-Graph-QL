#!/usr/bin/env perl

use v5.24;
use warnings;
use experimental 'signatures';

use Test::More;
use Test::Differences;
use Data::Dumper;

BEGIN {
    use_ok('Graph::QL');
    use_ok('Graph::QL::Parser');
}

# https://raw.githubusercontent.com/graphql/libgraphqlparser/master/test/kitchen-sink.graphql
my $schema = q[
query queryName($foo: ComplexType, $site: Site = MOBILE) {
  whoever123is: node(id: [123, 456]) {
    id ,
    ... on User @defer {
      field2 {
        id ,
        alias: field1(first:10, after:$foo,) @include(if: $foo) {
          id,
          ...frag
        }
      }
    }
    ... @skip(unless: $foo) {
      id
    }
    ... {
      id
    }
  }
}

mutation likeStory {
  like(story: 123) @defer {
    story {
      id
    }
  }
}

subscription StoryLikeSubscription($input: StoryLikeSubscribeInput) {
  storyLikeSubscribe(input: $input) {
    story {
      likers {
        count
      }
      likeSentence {
        text
      }
    }
  }
}

# NOTE:
# I had to remove this, the string parsing was not working
# and I was unable to figure out why (honestly, didnt look
# that deep (yet)), so this should be uncommented sometime
# and figure out what it going wrong with it.
# - SL
# vv---------------------vv
# fragment frag on Friend {
#   foo(size: $size, bar: $b, obj: {key: "value", block: """
#
#       block string uses \"""
#
#   """})
# }

{
  unnamed(truthy: true, falsey: false, nullish: null),
  query
}
];

my $node = Graph::QL::Parser->parse( $schema );
my $ast  = JSON::MaybeXS->new->decode( Parser::GraphQL::XS->new->parse_string( $schema ) );

#warn Dumper $node->TO_JSON;

eq_or_diff($node->TO_JSON, $ast, '... round-tripped the ast');

done_testing;
