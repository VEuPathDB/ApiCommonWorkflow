package ApiCommonWorkflow::Main::WorkflowSteps::MakeGlobalDerivedTables;
use base ApiCommonWorkflow::Main::WorkflowSteps::MakeDerivedTables;

use strict;

sub prefixAndFilterValueCommandString {
  my ($self, $prefix) = @_;

   return "-prefix '$prefix'  " ;
}

1;


