# protagonist-treegraph-perl
This project is a first draft of an eventual feature to be added to the Protagonist Collective, made for the purpose of familiarizing myself with Perl.

For some background, the idea behind the Protagonist Collective is that many people contribute to make a 'choose your own adventure' story. These stories can be represented graphically, and the goal of this project is to do just that. The output would look similar to the following.

```
   (001)
  /     \
(002) (003)________
  |     |          \
[004] (005)       (006)
        |  \        |
      (007) [008] [009]
        |  \
      [010] [011]
```

Each node represents a page, where parentheses represent a page with choices and brackets represent an ending. Each layer of the tree represents the depth, or how many pages into the story you are. Lines connecting pages represent the potential ways to reach those pages through the choices you make.

This project will have two main functions: a tree-generator, which returns something similar to the above, and a data-generator, which returns dummy data in the following way, the array represents a book and each hash represents a page. This dummy data does not need to perfectly mimic the natural growth of a tree, but it should come close. I intend to make it flexible, so as to offer many tree's sample data depending on the starting parameters possible when first creating a book on the original Protagonist Collective project.

```
[{id => 2, child1id => 4, child2id => -1}, ...]
```

I also aim to build tests for this system, as that will be important to my working career in the future.