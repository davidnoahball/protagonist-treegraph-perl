#package DataGenerator;

use strict;
use warnings;
use diagnostics;

use feature 'say';
use List::Util 'first';
#use Exporter;

#our @ISA= qw(Exporter);
#our @EXPORT = qw(data_generator print_data);

sub data_generator{
  my ($node_limit, $treetop, $complete) = @_; #"node" and "change" are interchangeable terms

  $node_limit ||= 32; #number of nodes in tree
  $treetop ||= 3; #layers of only choice pages, to make sure the book's stories aren't too short
  $complete ||= 0; #if truthy, all paths will lead to endings

  $node_limit < 4 ? $node_limit = 4 : 0;#need to put an absolute minimum on the node_limit to ensure proper functionality
  $treetop < 1 ? $treetop = 1 : 0;#need to put an absolute minimum on the treetop
  $node_limit < ((2 ** $treetop) * 2) ? $node_limit = ((2 ** $treetop) * 2) : 0;#need to make sure the node_limit is also at least equal to ((2 ** $treetop)) * 2 for proper subroutine functionality

  my $node_count = 1; #keeps track of the current number of nodes
  my $available_positions = 2; #keeps track of available positions for nodes to be added
  my $ending = 0; #toggle: when true, all future nodes will be made endings
  my $next_page_id = 2; #increments on each new page creation
  my $ends_available = 0; #makes sure there aren't ever more endings than choices, to avoid tree ending before scheduled
  my $current_page_check = 1; #keeps track of which page you're checking logic for, starts with page 1

  my @dummy_data = ( #this is to be created into the final return value, and it can be assumed that this will always be ordered by page id, where (index = id - 1)
    {
      id => 1, #page identifier
      child1id => 0, #where the page leads on one choice
      child2id => 0, #where the page leads on the other choice
      end => 0, #is this page an ending (no children)?
      parent_id => 0
    }
  );
  
  while ($node_count < ((2 ** $treetop) - 1)){ #the number of nodes in the 'treetop' (layers of only choice pages) will always be equal to (2^l)-1, where l is the layer count; this while loop follows the process of set all new nodes to choices, add new nodes to all available positions in incrementing order of id, update essential data, break out once the required number of nodes are met
    push @dummy_data, {id => $next_page_id, child1id => 0, child2id => 0, end => 0, parent_id => $dummy_data[$current_page_check - 1]{id}};
    $dummy_data[$current_page_check - 1]{child1id} = $next_page_id;
    $next_page_id += 1;
    push @dummy_data, {id => $next_page_id, child1id => 0, child2id => 0, end => 0, parent_id => $dummy_data[$current_page_check - 1]{id}};
    $dummy_data[$current_page_check - 1]{child2id} = $next_page_id;
    $next_page_id += 1;
    $current_page_check += 1;
    $available_positions += 2;
    $node_count += 2;
  }

  #a non-directional (doesn't search for openings) tree-descension is inefficient but necessary for accuracy without (much more) complexity
  while ($node_count < $node_limit){
    if ($complete && (($node_count + $available_positions == $node_limit) || ($node_count + $available_positions == $node_limit - 1))){ #checks for and toggles the end phase; due to the nature of the tree, it is impossible to have a finished tree with an even number of nodes, so this will cause the tree to effectively round down the node_count to the nearest odd number if the node_count is even; if this form of looping is not used in favor of the tree descension mechanism below, there will often be hundreds or thousands of more loops than necessary, without much added benefit
      $ending = 1;
    }
    if ($ending){ #loops through all available positions and sets them to ending pages
      for my $page (@dummy_data){ 
        if (!${$page}{end}){
          if (!${$page}{child1id}){
            push @dummy_data, {id => $next_page_id, child1id => 0, child2id => 0, end => 1, parent_id => ${$page}{id}};
            ${$page}{child1id} = $next_page_id;
            $next_page_id += 1;
          }
          if (!${$page}{child2id}){
            push @dummy_data, {id => $next_page_id, child1id => 0, child2id => 0, end => 1, parent_id => ${$page}{id}};
            ${$page}{child2id} = $next_page_id;
            $next_page_id += 1;
          }
        }
      }
      return @dummy_data;
    }
    while (1){ #loop until broken by finding a proper page
      my $next_is_end = ($ends_available > 0 && int(rand(2))) ? 1 : 0; #sets the next node to be an end %50 of the time if there are ends available
      my $child_check_page = 0; #to be used later, potentially
      my $current_page = first {$_->{id} == $current_page_check} @dummy_data; #sets the a reference to the page to check info for
      my $child_check_id = int(rand(2)) ? ${$current_page}{child1id} : ${$current_page}{child2id}; #picks a random child to grab the id for
      if (!$child_check_id){ #if child is empty slot (==0), add page; this is ok to do because the loop should never start from an end --TODO-- Add the ability for 'end' attribute to be true
        push @dummy_data, {id => $next_page_id, child1id => 0, child2id => 0, end => $next_is_end, parent_id => $dummy_data[$current_page_check - 1]{id}}; #create the new node
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
        $node_count += 1; #for this, $ends_available, and $available_positions, it is easier and more intuitive to just keep track like this than to count every time the value is needed
        if ($next_is_end){
          $available_positions -= 1;
          $ends_available -= 1;
        } else{
          $available_positions += 1;
          $ends_available += 1;
        }
        #say $node_count . " + " . $ends_available . " = " . ($node_count + $ends_available);
        $next_page_id += 1; #increments so that no two pages have the same id
        last; #breaks so the cycle can restart and a new node can be created
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

sub print_data{
  my @data = @_;

  say "(";
    my $content_string = "";
  for my $page ( @data ) {
      $content_string = $content_string . "  {";
      my $page_string = "";
      foreach((sort{$a cmp $b}(keys(%$page)))){
          $page_string = $page_string . "$_=$page->{$_}, ";
      }
      $page_string = substr $page_string, 0, ((length $page_string) - 2);
      $content_string = $content_string . $page_string;
      $content_string = $content_string . "},\n";
  }
  say substr $content_string, 0, ((length $content_string) - 2);
  say ")";
}

1;