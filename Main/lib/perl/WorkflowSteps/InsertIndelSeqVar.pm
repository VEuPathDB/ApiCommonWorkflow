package ApiCommonWorkflow::Main::WorkflowSteps::InsertIndelSeqVar;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::InsertSnpMummer);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::InsertSnpMummer;


sub getSoTerm {
  return 'indel';
}


1;
