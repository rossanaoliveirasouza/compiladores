#ifndef SEMANT_H_
#define SEMANT_H_

#include <assert.h>
#include <iostream>
#include <map>
#include <vector>  
#include "cool-tree.h"
#include "stringtab.h"
#include "symtab.h"
#include "list.h"

#define TRUE 1
#define FALSE 0

class ClassTable;
typedef ClassTable *ClassTableP;

// This is a structure that may be used to contain the semantic
// information such as the inheritance graph.  You may use it or not as
// you like: it is only here to provide a container for the supplied
// methods.

enum class NodeState { Ok, NotYetVisited, RecentlyVisited };

class ClassTable {
private:
  int semant_errors;
  void install_basic_classes();
  ostream& error_stream;
  std::map<Symbol, std::vector<Symbol>> inheritance_graph;
  std::map<Symbol, Symbol> class_parents;
  std::map<Symbol, NodeState> node_state;

public:
  ClassTable(Classes);
  int errors() { return semant_errors; }
  bool install_user_classes(Classes classes);
  bool there_is_a_cycle_involving(Symbol node);
  bool is_inheritance_graph_acyclic();
  bool try_build_inheritance_graph();

  std::map<Symbol, Class_> class_bucket;
  ostream& semant_error();
  ostream& semant_error(Class_ c);
  ostream& semant_error(Symbol filename, tree_node *t);
};

#endif

