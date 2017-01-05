use strict;
use warnings;
use diagnostics;

use feature 'say';

sub data_generator{
  my ($node_count, $treetop, $complete) = @_;

  $node_count ||= 32; #number of nodes in tree
  $treetop ||= 3; #layers of only choice pages, too make sure the book's stories aren't too short
  $complete ||= 0; #do all paths lead to endings, 0 for false

  my @dummy_data = (
    {
      id => 1, 
      child1id => 2, 
      child2id => 3,
      end => 0
    },
    {
      id => 2, 
      child1id => 4, 
      child2id => 0,
      end => 0
    }
  );

  return @dummy_data;
}

sub print_data{ #doesn't print info in order, but that's not so important
  my @data = @_;

  say "(";
  for my $page ( @data ) {
      print "  {";
      for my $info ( keys %$page ) {
          print "$info=$page->{$info} ";
      }
      print "},\n";
  }
  say ")";
}

my @dummy = data_generator();
print_data(@dummy);