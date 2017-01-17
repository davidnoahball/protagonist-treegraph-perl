use strict;
use warnings;
use diagnostics;

use feature 'say';
use List::Util 'first';

require "/Users/davidball/Development/code/protagonist-treegraph-perl/code/data_generator.pl";

sub tree_generator{
  my @tree_data = @_;

  my @unsorted_right = [[]]; #Whenever a depth value is found, either add it its proper array or create a new array and populate it
  my @unsorted_left = [[]];

  #First find the depth of each node and add it as an attribute.
  for my $page (@tree_data){ #Add information on parents
    $tree_data[${$page}{id} - 1]{parent_hash_ref} = ((first {${$_}{child1id} == ${$page}{id}} @tree_data) || (first {${$_}{child2id} == ${$page}{id}} @tree_data) || (0));
  }
  for my $page (@tree_data){ #Fill the '@unsorted' arrays with all of the layer information
    my $depth = 0; #holds the depth value, updated on each parent climb
    my $parent_check = $page; #the page for which to check and parent information, updated recursively
    my $memory_holder = 0; #holds a layer of memory for simplicity purposes
    my $is_right_node = 0; #uses $memory_holder to check if the node is a child of the left or right side of the tree
    while (1){ #keep looping until broken
      if (!$parent_check){ #if the node doesn't have a parent, break so the depth can be recorded
        last;
      } else{ #otherwise, update the values we're keeping track of
        $depth += 1; #iterate the depth value
        $is_right_node = $memory_holder; #set to old memory value, used because the right/left determining factor is checked in the next-to-last iteration
        $memory_holder = ${$parent_check}{id} == 3 ? 1 : 0; #checks if this node is a child of the node with id=3
        $parent_check = ${$parent_check}{parent_hash_ref}; #updates the node for which to check parents
      }
    }
    $tree_data[${$page}{id} - 1]{depth} = $depth; #adds the depth value as an attribute to nodes for future reference
    if ($depth == 1){next;} #if we're at the top of the tree, skip the next step because it doesn't belong in right nor left
    if ($is_right_node){ #if it is a node on the right side of the tree, put it in its proper place in the @unsorted_right
      if (!$unsorted_right[($depth - 1)]){
        push @unsorted_right, [%{$page}];
      } else{
        push @unsorted_right[($depth - 1)], %{$page};
      }
    } else{ #otherwise put it in the @unsorted_left
      if (!$unsorted_left[($depth - 1)]){
        push @unsorted_left, [%{$page}];
      } else{
        push @unsorted_left[($depth - 1)], %{$page};
      }
    }
  }
  shift @unsorted_right;
  my @sorted_right = row_sorter(\@unsorted_right, 3, \@tree_data);
}

sub row_sorter{
  my @unsorted = @{$_[0]}; #unsorted comes in as [[{k:v, k:v}, {k:v, k:v}], [{k:v, k:v}, {k:v, k:v}]]; children will always be in the next row
  my $apex = $_[1];
  my @raw_data = @{$_[2]};
  #the first step is to create an array that is the height of the entire tree, this preserves the vertical position data
  my @sorted = [];
  for my $i (1..(scalar @unsorted)) {
    push @sorted, [];
  }
  shift @sorted;
  #the next step is to determine which nodes are descendents of the apex to create a new tree: find a node, push that, find its children's nodes, push those, repeat for child nodes
  my $apex_node = find_by_id(\@raw_data, $apex);
  say $apex_node;
  #the next step is to pick a child on the bottommost layer of the apex tree
  #the next step is to climb the tree from the bottom node up to the apex and push those nodes into their respective positions in 'the array with the height of the entire tree', henceforth referred to as hometree
  #the next step is to climb the tree again in the exact same way and check if any of the nodes have brothers
  #if they do, then set a new value equal to the return value of a recursive call with that brother's node as the apex; do this and the next step for each brother before climbing any farther
  #with that return value, combine it with the hometree by checking which heights the tree occupies then putting it in the centermost position such that it does not intersect with any of the nodes on any of those rows and nor does it go more nor equally centerward in comparison to the rightmost node on the row directly below
  #once that is done for all brothers, return the hometree
  #
  #all of this needs to work with apexes that give trees with a height equal to 1
  say $apex;
  say scalar @unsorted;
  print join(", ", @{$sorted[0]}), "\n";
  print join(", ", @sorted), "\n";
  # if ($sorted[($depth - 1)]){
  #   push @unsorted_right, [${$page}{id}];
  # } else{
  #   push @unsorted_right[($depth - 1)], ${$page}{id};
  # }
}

sub find_by_id{
  my @searchspace = @{$_[0]};
  my $id = $_[1];
  for my $page (@searchspace){
    if (${$page}{id} == $id){
      return $page;
    }
  }
}

my @dummy = data_generator();
tree_generator(@dummy);
#print_data(@dummy);