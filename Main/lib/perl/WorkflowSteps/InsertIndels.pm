package ApiCommonWorkflow::Main::WorkflowSteps::InsertIndels;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $indelFile = $self->getParamValue('indelFile');
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
    my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

    my $workflowDataDir = $self->getWorkflowDataDir();
  
    my $args = <<"EOF";
--extDbRlsSpec=$extDbRlsSpec \\
--genomeExtDbRlsSpec=$genomeExtDbRlsSpec \\
--IndelFile=$workflowDataDir/$indelFile \\
--commit
EOF

$self->testInputFile('inputDir', "$workflowDataDir/$inputDir");

    if($undo) {
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertIndel", $args);
    } else {
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertIndel", $args);
    }

}

1;
