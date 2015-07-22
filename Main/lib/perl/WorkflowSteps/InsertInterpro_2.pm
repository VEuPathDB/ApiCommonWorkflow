package ApiCommonWorkflow::Main::WorkflowSteps::InsertInterpro_2;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# this is version 2 of this step class.  it adds a couple of parameters to the original.

sub run {
    my ($self, $test, $undo) = @_;

    my $inputDir = $self->getParamValue('inputDir');
    my $interproExtDbName = $self->getParamValue('interproExtDbName');
    my $configFile = $self->getParamValue('configFile');
    my $aaSeqTable = $self->getParamValue('aaSeqTable');
    my $sourceIdRegex = $self->getParamValue('sourceIdRegex');

    my $interproExtDbVer = $self->getExtDbVersion($test,$interproExtDbName);
    my $goVersion = $self->getExtDbVersion($test, 'GO_RSRC');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = <<"EOF";
--resultFileDir=$workflowDataDir/$inputDir \\
--confFile=$workflowDataDir/$configFile \\
--aaSeqTable=$aaSeqTable \\
--extDbName='$interproExtDbName' \\
--extDbRlsVer='$interproExtDbVer' \\
--goVersion=\'$goVersion\' \\
--srcIdRegex=\'$sourceIdRegex\' \\
EOF


$self->testInputFile('inputDir', "$workflowDataDir/$inputDir");


    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertInterproscanResultsTSV", $args);

}

1;
