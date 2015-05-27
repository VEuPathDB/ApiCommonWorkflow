package ApiCommonWorkflow::Main::WorkflowSteps::MakeGsnapMaskFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::MakeGtfForGuidedCufflinks);

use strict;
use warnings;

use ApiCommonWorkflow::Main::WorkflowSteps::MakeGtfForGuidedCufflinks;

sub getSequenceOntologyTermString { 
  return "rRNA_encoding"; 
}

sub getSequenceOntologyExclude { 
  return 1;
}

1;
