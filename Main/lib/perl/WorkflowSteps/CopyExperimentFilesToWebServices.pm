 package ApiCommonWorkflow::Main::WorkflowSteps::CopyExperimentFilesToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
    my ($self, $test, $undo) = @_;

    #get parameters
    my $copyFromDir = $self->getParamValue('copyFromDir');
    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $relativeDir = $self->getParamValue('relativeDir');
    my $experimentDatasetName = $self->getParamValue('experimentDatasetName');
    my $websiteFilesDir = $self->getWebsiteFilesDir($test);
    my $gusConfigFile = $self->getParamValue('gusConfigFile');
    $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

    my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();
    my $workflowDataDir = $self->getWorkflowDataDir();

    my $assayType = $self->getParamValue("assayType");
    my $fileType = $self->getParamValue("fileType");
    my $fileSuffix = $self->getParamValue("fileSuffix");
    my $indexSuffix = $self->getParamValue("indexSuffix");

    my $copyToDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/${assayType}/${fileType}/$experimentDatasetName";
    my $cmd_mkdir = "mkdir -p $copyToDir";

    my $index_cmd_copy;
    if($indexSuffix) {
        $index_cmd_copy = "cp $workflowDataDir/$copyFromDir/*.${indexSuffix} $copyToDir";
    }


    my $cmd_copy = "cp $workflowDataDir/$copyFromDir/*.${fileSuffix} $copyToDir";
    $self->testInputFile('copyFromDir', "$workflowDataDir/$copyFromDir");

    if ($undo) {
        $self->runCmd(0,"rm -rf $copyToDir");
    }else{
        $self->runCmd($test, $cmd_mkdir);
        $self->runCmd($test, $cmd_copy);
        $self->runCmd($test, $index_cmd_copy) if($indexSuffix);
    }
}

1;
