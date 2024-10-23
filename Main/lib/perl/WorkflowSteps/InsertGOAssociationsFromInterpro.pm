package ApiCommonWorkflow::Main::WorkflowSteps::InsertGOAssociationsFromInterpro;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $interproResultsFile = $self->getParamValue('interproResultsFile');
    my $interpro2GOFile = $self->getParamValue('interpro2GOFile');
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
    my $interproExtDbName = $self->getParamValue('interproExtDbName');
    my $interproExtDbVer = $self->getExtDbVersion($test,$interproExtDbName);
    my $configFile = $self->getParamValue('configFile');
    my $aaSeqTable = 'TranslatedAASequence';
    my $goVersion = $self->getExtDbVersion($test, 'GO_RSRC');
    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = "--interproResultsFile=$workflowDataDir/$interproResultsFile --interpro2GOFile=$workflowDataDir/$interpro2GOFile --confFile=$workflowDataDir/$configFile --aaSeqTable=$aaSeqTable --extDbName=\'$interproExtDbName\' --extDbRlsVer=\'$interproExtDbVer\' --goVersion=\'$goVersion\'";

    $self->testInputFile('inputDir', "$workflowDataDir/$interproResultsFile");
  
    if($undo) {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGOAssociationsFromInterpro --limit 400000", $args);
    } else {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGOAssociationsFromInterpro", $args);
    }

}

1;
