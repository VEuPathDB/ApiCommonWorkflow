 package ApiCommonWorkflow::Main::WorkflowSteps::CopyBigWigFilesToWebServices;

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
    my $experimentResourceName = $self->getParamValue('experimentDatasetName');
    my $websiteFilesDir = $self->getWebsiteFilesDir($test);
    my $organismNameForFiles = $self->getOrganismInfor($test, $organismAbbrev)->getNameForFiles();
    my $workflowDataDir = $self->getWorkflowDataDir();


    my $copyToDir = "$webSiteFilesDir/$relativeDir/$organismNameForFiles/bigwig/$experimentResourceName";
    my $cmd_mkdir = "mkdir -p $copyToDir";

    my $cmd_copy = "cp $workflowDataDir/$copyFromDir/*.bw $copyToDir";
    
    if ($test) {
        $self->testInputFile('copyFromDir', "$workflowDataDir/$copyFromDir");
    }
    if ($undo) {
        $self->runCmd(0,"rm -rf $copyToDir");
    }else{
        $self->runCmd($test, $cmd_mkdir);
        $self-runCmd($test, $cmd_copy);
    }
}

sub getParamsDeclaration {
    return (
        'copyFromDir',
        'organismAbbrev',
        'relativeDir',
        'configFile',
        );
}

sub getConfigDeclaration {
    return (
        # [name, default, description]
        );
}
1;

