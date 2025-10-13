package ApiCommonWorkflow::Main::WorkflowSteps::InsertProteinBedGraph;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::InsertBedGraph);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub isProteinAlignments {
    return 1;
}


1;
