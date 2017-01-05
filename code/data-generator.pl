use strict;
use warnings;
use diagnostics;

use feature 'say';
use List::Util 'first';

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
      child1id => 2, #where the page leads on one choice
      child2id => 2, #where the page leads on the other choice
      end => 0 #is this page an ending (no children)?
    },
    {
      id => 2, #page identifier
      child1id => 2, #where the page leads on one choice
      child2id => 2, #where the page leads on the other choice
      end => 3 #is this page an ending (no children)?
    }
  );
  
  #a non-directional (doesn't search for openings) tree-descension is inefficient but necessary for accuracy without (much more) complexity
  while ($node_count < $node_limit){
    if ($complete && ($node_count + $available_positions == $node_limit)){ #checks for and toggles the end phase
      $ending = 1;
    }
    if ($ending){ #loops through all available positions and sets them to ending pages

    }
    my $current_page_check = 1; #start with first page
    while (1){ #loop until broken by finding a proper page
      my $child_check_page = 0; #to be used later, potentially
      my $current_page = first {$_->{id} == $current_page_check} @dummy_data; #sets the a reference to the page to check info for
      my $child_check_id = int(rand(2)) ? ${$current_page}{child1id} : ${$current_page}{child2id}; #picks a random child to grab the id for
      if (!$child_check_id){ #if child is empty slot (==0), add page; this is ok to do because the loop should never start from an end
      } else{
        $child_check_page = first {$_->{id} == $child_check_id} @dummy_data; #otherwise, create a reference to the child page to examine it and determine what to do next
      }
      return ${$child_check_page}{end};
    }
  }

  return @dummy_data;
}

#loop{
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

#my @dummy = data_generator();
#print_data(@dummy);
say data_generator();