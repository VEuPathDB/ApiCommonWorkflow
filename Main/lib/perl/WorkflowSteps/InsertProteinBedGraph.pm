package ApiCommonWorkflow::Main::WorkflowSteps::InsertProteinBedGraph;

use strict;
use warnings;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::InsertBedGraph;

our @ISA = ('ApiCommonWorkflow::Main::WorkflowSteps::InsertBedGraph');

sub isProteinAlignments {
    return 1;
}

1;
