package ApiCommonWorkflow::Main::WorkflowSteps::LoadSecondaryStructures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $algName = $self->getParamValue('algName');

    my $inputDir = $self->getParamValue('inputDir');

    my $localDataDir = $self->getLocalDataDir();

    my $algImpVer = "2.5";
    my $algInvStart = "2000-01-01";
    my $algInvEnd = "2000-01-01";
    $algName =~ s/\s//g;
    $algName =~ s/\///g;

    my $args = "--predAlgName $algName  --predAlgImpVersion $algImpVer --predAlgInvStart $algInvStart --predAlgInvEnd $algInvEnd --directory $localDataDir/$inputDir --setPercentages";

    if ($test) {
      $self->testInputFile('inputDir', "$localDataDir/$inputDir");
    }

   $self->runPlugin($test,$undo, "GUS::Supported::Plugin::InsertSecondaryStructure", $args);

}


sub getParamsDeclaration {
    return ('algName',
            'inputDir',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, descriptio]n
           );
}



