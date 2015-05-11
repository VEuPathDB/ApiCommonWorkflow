package ApiCommonWorkflow::Main::WorkflowSteps::MakeGlobalDerivedTables;
use base ApiCommonWorkflow::Main::WorkflowSteps::MakeDerivedTables;

use strict;

sub prefixAndFilterValueCommandString {
   return "-prefix 'globalWF_'  " ;
}

1;


