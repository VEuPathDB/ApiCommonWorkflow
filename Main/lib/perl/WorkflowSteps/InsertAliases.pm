package ApiCommonWorkflow::Main::WorkflowSteps::InsertAliases;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');

    my $externalDatabase = $self->getParamValue('externalDatabase');
    my $extDbVer = $self->getExtDbVersion($test, $externalDatabase, $gusConfigFile);
    my $aliasesFile = $self->getParamValue('inputMappingFile');
    my $fileFullPath = "$workflowDataDir/$aliasesFile";


    my $args = "--DbRefMappingFile $fileFullPath --extDbName $externalDatabase --extDbReleaseNumber $extDbVer --viewName 'ExternalAASequence' --columnSpec 'primary_identifier,remark' --tableName AASequenceDbRef --gusConfigFile $gusConfigFile";

    $self->testInputFile('aliasesFile', "$fileFullPath");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertDBxRefs", $args);

}
