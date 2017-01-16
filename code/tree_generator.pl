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
  my @sorted_right = [];

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
        push @unsorted_right, [${$page}{id}];
      } else{
        push @unsorted_right[($depth - 1)], ${$page}{id};
      }
    } else{ #otherwise put it in the @unsorted_left
      if (!$unsorted_left[($depth - 1)]){
        push @unsorted_left, [${$page}{id}];
      } else{
        push @unsorted_left[($depth - 1)], ${$page}{id};
      }
    }
  }
  for my $layer (@unsorted_right){ #Print @unsorted_depths for examination
    say join(", ", @{$layer});
  }
  for my $layer (@unsorted_left){ #Print @unsorted_depths for examination
    say join(", ", @{$layer});
  }
}

sub row_sorter{
  my (@tree, @last_it, $apex) = @_;
  #Create a tree from the apex
}

my @dummy = data_generator();
tree_generator(@dummy);
print_data(@dummy);

sub folded_notes_please_ignore{
  #I've worked out that it makes the most sense to find the abs_pos of the tree nodes in the row sorting phase and this block is just notes so I don't have to keep referencing my notebook. For all intents and purposes, treat left most as centermost and rightmost as outwardmost. The row_sorter method will be recursive and work in the following manner. First, it will choose a random node at the bottom of the tree and climb, setting each of the initial values in a multidimensional array meant to keep track of the sorted positions, similar to the @unsorted_left, for example. Then, again starting at the bottom, it will climb and call the function again within itself whenever it comes across a node with an undocumented brother, using that as the new apex. The result of that call will be added to the previous call by the following method. The leftmost side of the returned multidimensional array will be treated as a line. This line's position will be determined by the nodes the set is being added to; it will be as far left as possible while making sure that on each row it does not intersect with the existing set's nodes and nor does it go further left than the position of the rightmost node on the layer immediately below it. This is likely not clear to any outside readers (difficult to express without visuals), but it will serve as good reference to me.
}