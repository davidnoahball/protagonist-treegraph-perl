use strict;
use warnings;
use diagnostics;

use feature 'say';
use List::Util 'first';

require "/Users/davidball/Development/code/protagonist-treegraph-perl/code/data_generator.pl";

sub tree_generator{
  my @tree_data = @_;

  my @unsorted_depths = []; #Whenever a depth is found, either add it to a new array in this one or add it to its proper array, by position

  #First find the depth of each node and add it as an attribute.
  for my $page (@tree_data){ #Add information on parents
    $tree_data[${$page}{id} - 1]{parent_hash_ref} = ((first {${$_}{child1id} == ${$page}{id}} @tree_data) || (first {${$_}{child2id} == ${$page}{id}} @tree_data) || (0));
  }
  for my $page (@tree_data){ #Fill @unsorted_depths with all of the layer information
    my $depth = 1;
    my $parent_check = ${$page}{parent_hash_ref};
    while (1){
      if (!$parent_check){
        last;
      } else{
        $depth += 1;
        $parent_check = ${$parent_check}{parent_hash_ref};
      }
    }
    $tree_data[${$page}{id} - 1]{depth} = $depth;
    if (!$unsorted_depths[($depth - 1)]){
      push @unsorted_depths, [${$page}{id}]; 
    } else{
      push @unsorted_depths[($depth - 1)], ${$page}{id};
    }
  }
  for my $layer (@unsorted_depths){ #Print @unsorted_depths for examination
    say join(", ", @{$layer});
  }
}

my @dummy = data_generator();
tree_generator(@dummy);
print_data(@dummy);

sub folded_notes_please_ignore{
  #For this tree, I should aim to make the nodes as compact as possible. Each choice page will have the opportunity to branch down or to one side. It can always be assumed that the space beneath a node will be available. That only leaves when to expand out to one side (right for the right side of the tree and left for the left; the Adam node (id=1) will branch to both sides in order to create 2 halves of a tree, as shown in the README). 

  #For any parent node, the number of spaces it will have to extend to have its "side child" is equal to the distance between its position in respect to the center of the tree and the next available position on the level below it. Since the order that children are created is random, it cannot be assumed that the tree will not need continuous updating, as would be unnecessary if the tree built itself strictly inward out. The root of the problem that causes this scenario is that choice nodes can have one or no children and when their second child is made, they require more space on the level of the tree below them (deeper into the story), which could cause conflict with other nodes stemming from higher up in the tree (and therefore being on the further edges of it). It is possible to simply reserve this spot until the tree is completed in building itself, but that would lead to a tree which looks too "spread-out", as a result of unused space. The possible solution to *this* problem is that you could have an "end-phase" of the tree creation which would compactify the tree and remove these gaps. 

  #The alternative, to avoid this problem, is to go with a bottom-up approach to building the tree. If one were to know the depth or level of each respective node in addition to its distance from the center, one could build the tree from bottom-up relatively easy. The process of building and organizing node metadata, for each side, follows in the next comment, but first some context and clarification. This method assumes that you start with gathering the data for the tree before you literally start "building" it, as knowing the positions if the nodes makes the literal creation of the tree a simple task. To clarify, the "data-in" to this step of the tree building process, which I will refer to as "data-organizing", is the node data from the data-generator. The "data-out" to this step is a copy of the original nodes with additional data of: node depth (depth), node position relative to the center of the tree (abs_pos), and node position relative to the tree in terms of literal numerical position with relation to the other nodes at that depth (rel_pos). The generation of this data, though would ultimately happen if done top-down and updating on each conflict, is much easier to collect when starting at the roots. 

  #First, the depth of each node would be determined. This could be accomplished by following each available path to completion while counting nodes along the way by iterating over the nodes and climbing the tree for each one, or one of several other possible methods with varying degrees of complexity and efficiency; the method by which this data is acquired is not so important. After that, now that the knowledge of which nodes should be compared with each other (by depth) is available, the rel_pos would be determined.

  #The most important universal law here is that each node must be next to its brother if it has one. Considering that the nature of the tree is one with unorded paths, it can be determined that any single node on the bottom layer has the potential to be the centermost node. With these two ideas in mind, it is possible to build bottom-up. Keep a set of arrays, one for each layer of the tree. In these arrays, push the ids of the nodes by the following method. Choose a random node on the bottom layer of the tree. Then, climb the tree. In order for the bottom node to be closest to the center, each of its ancestors must also be closest to the center, add these nodes' ids *and* their brother's ids to their respective arrays in the dataset. 

  #Once that is done, restart from the bottom and climb the tree (in the same manner) once more until you reach a page who's brother has undocumented children. Treat that page as the top of a new tree and repeat this process recursively. This will give all the data necessary to find the rel_pos of every node.

  #To find the absolute position of each node, one can start by looking at the fullest row, with precedence given to the lowest of the full rows in the case of equality. Each of these pages will have an abs_pos equal to their rel_pos. 
}