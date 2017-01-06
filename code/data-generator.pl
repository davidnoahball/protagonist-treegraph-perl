use strict;
use warnings;
use diagnostics;

use feature 'say';
use List::Util 'first';

sub data_generator{
  my ($node_limit, $treetop, $complete) = @_; #"node" and "change" are interchangeable terms

  $node_limit ||= 32; #number of nodes in tree
  $treetop ||= 3; #layers of only choice pages, to make sure the book's stories aren't too short
  $complete ||= 0; #do all paths lead to endings, 0 for false

  my $node_count = 1; #keeps track of the current number of nodes
  my $available_positions = 2; #keeps track of available positions for nodes to be added
  my $ending = 0; #toggle: when true, all future nodes will be made endings
  my $next_page_id = 2; #increments on each new page creation
  my $ends_available = 0; #makes sure there aren't ever more endings than choices, to avoid tree ending before scheduled

  my @dummy_data = ( #this is to be created into the final return value, and it can be assumed that this will always be ordered by page id, where (index = id - 1)
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
    my $current_page_check = 1; #start with first page
    while (1){ #loop until broken by finding a proper page
      my $child_check_page = 0; #to be used later, potentially
      my $current_page = first {$_->{id} == $current_page_check} @dummy_data; #sets the a reference to the page to check info for
      my $child_check_id = int(rand(2)) ? ${$current_page}{child1id} : ${$current_page}{child2id}; #picks a random child to grab the id for
      if (!$child_check_id){ #if child is empty slot (==0), add page; this is ok to do because the loop should never start from an end --TODO-- Add the ability for 'end' attribute to be true
        push @dummy_data, {id => $next_page_id, child1id => 0, child2id => 0, end => 0}; #create the new node
        my $first_check = int(rand(2));
        if ($first_check && !${$current_page}{child1id}){ #this ugly if block just sets a random available childid to the new node's id
          $dummy_data[$current_page_check - 1]{child1id} = $next_page_id;
        } elsif ($first_check){
          $dummy_data[$current_page_check - 1]{child2id} = $next_page_id;
        } elsif (!${$current_page}{child2id}) {
          $dummy_data[$current_page_check - 1]{child2id} = $next_page_id;
        } else{
          $dummy_data[$current_page_check - 1]{child1id} = $next_page_id;
        }
        $node_count += 1; 
        $available_positions += 1;
        $next_page_id += 1;
        last;
      } else{
        $child_check_page = first {$_->{id} == $child_check_id} @dummy_data; #otherwise, create a reference to the child page to examine it and determine what to do next

      }
      if (${$child_check_page}{end}){ #if child is end, restart
        $current_page_check = 1;
        next;
      } else{ #if child is a choice, restart loop with this page
        $current_page_check = $child_check_id;
        next;
      }
    }
  }

  return @dummy_data;
}

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