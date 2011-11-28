package ApiCommonWorkflow::Main::WorkflowSteps::InsertInterpro;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $inputDir = $self->getParamValue('inputDir');
    my $interproExtDbRlsSpec = $self->getParamValue('interproExtDbRlsSpec');
    my $configFile = $self->getParamValue('configFile');
    my $goVersion = $self->getParamValue('goVersion');
    my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$interproExtDbRlsSpec);
    my $aaSeqTable = 'TranslatedAASequence';

    my $workflowDataDir = $self->getWorkflowDataDir();
  
    my $args = <<"EOF";
--resultFileDir=$workflowDataDir/$inputDir \\
--confFile=$workflowDataDir/$configFile \\
--aaSeqTable=$aaSeqTable \\
--extDbName='$extDbName' \\
--extDbRlsVer='$extDbRlsVer' \\
--goVersion=\'$goVersion\' \\
EOF

  if ($test) {
    $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
  }

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertInterproscanResults", $args);

}


sub getParamsDeclaration {
    return ('inputDir',
            'interproExtDbRlsSpec',
            'configFile'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}


