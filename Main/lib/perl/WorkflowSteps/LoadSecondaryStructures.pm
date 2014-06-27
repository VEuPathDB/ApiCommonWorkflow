package ApiCommonWorkflow::Main::WorkflowSteps::LoadSecondaryStructures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $algName = $self->getParamValue('algName');

    my $inputDir = $self->getParamValue('inputDir');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $algInvResult=$self->getParamValue('algInvResult');

    my $setPercent=$self->getParamValue('setPercent');

    my $algImpVer=$self->getParamValue('algImpVer');

    my $algInvStart = "2000-01-01";
    my $algInvEnd = "2000-01-01";
    $algName =~ s/\s//g;
    $algName =~ s/\///g;

    my $args = "--predAlgName $algName  --predAlgImpVersion $algImpVer --predAlgInvStart $algInvStart --predAlgInvEnd $algInvEnd --directory $workflowDataDir/$inputDir --setPercentages";

    $algInvResult =~ s/\s/_/g;
    
    $args .= " --predAlgInvResult $algInvResult";

    $args .= " --setPercentages" if ($setPercent);


    $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");


   $self->runPlugin($test,$undo, "GUS::Supported::Plugin::InsertSecondaryStructure", $args);

}


1;


