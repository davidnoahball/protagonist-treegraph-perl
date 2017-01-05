use strict;
use warnings;
use diagnostics;

use feature 'say';

sub data_generator{
  my ($node_limit, $treetop, $complete) = @_; #"node" and "change" are interchangeable terms

  $node_limit ||= 32; #number of nodes in tree
  $treetop ||= 3; #layers of only choice pages, too make sure the book's stories aren't too short
  $complete ||= 0; #do all paths lead to endings, 0 for false

  my $node_count = 1; #keeps track of the current number of nodes
  my $available_positions = 2; #keeps track of available positions for nodes to be added
  my $ending = 0; #toggle: when true, all future nodes will be made endings
  my $next_page_id = 2; #increments on each new page creation

  my @dummy_data = ( #it can be assumed that this will always be ordered by page id, where (index = id - 1)
    {
      id => 1, #page identifier
      child1id => 0, #where the page leads on one choice
      child2id => 0, #where the page leads on the other choice
      end => 0 #is this page an ending (no children)?
    }
  );
  
  #a non-directional (doesn't search for openings) tree-descension is inefficient but necessary for accuracy without (much more) complexity
  while ($node_count < $node_limit){
    if ($complete && ($node_count + $available_positions == $node_limit)){ #checks for and toggles the end phase
      $ending = 1;
    }
    if ($ending){ #loops through all available positions and sets them to ending pages

    }
  }

  return @dummy_data;
}

#start with first page
#loop{
#pick random child
#if child is empty slot (childid=0), add page
#if child is end (childid=2, id2.end=1), restart
#if child is choice (childid=2, id2.end=0), restart loop with this page
#}

sub print_data{ #doesn't print page info in order, but that's not so important for its purpose
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