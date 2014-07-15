package ApiCommonWorkflow::Main::WorkflowSteps::InsertInterpro;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $inputDir = $self->getParamValue('inputDir');
    my $interproExtDbName = $self->getParamValue('interproExtDbName');
    my $configFile = $self->getParamValue('configFile');

    my $interproExtDbVer = $self->getExtDbVersion($test,$interproExtDbName);
    my $aaSeqTable = 'TranslatedAASequence';
    my $goVersion = $self->getExtDbVersion($test, 'GO_RSRC');

    my $workflowDataDir = $self->getWorkflowDataDir();
  
    my $args = <<"EOF";
--resultFileDir=$workflowDataDir/$inputDir \\
--confFile=$workflowDataDir/$configFile \\
--aaSeqTable=$aaSeqTable \\
--extDbName='$interproExtDbName' \\
--extDbRlsVer='$interproExtDbVer' \\
--goVersion=\'$goVersion\' \\
EOF


$self->testInputFile('inputDir', "$workflowDataDir/$inputDir");


    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertInterproscanResultsTSV", $args);

}

1;
