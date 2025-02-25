 package ApiCommonWorkflow::Main::WorkflowSteps::CopyDiamondDatabaseToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $copyFromDir = $self->getParamValue('peripheralResultsDir');
    my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
    my $webServicesDir = $self->getParamValue('webServicesDir');
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $websiteFilesDir = $self->getWebsiteFilesDir($test);

    my $copyToDir = "$websiteFilesDir/$webServicesDir/diamond/";
    my $cmd_mkdir = "mkdir -p $copyToDir";

    my $cmd_copy = "cp $workflowDataDir/$copyFromDir/*.dmnd $copyToDir";
    
    if ($undo) {
        $self->runCmd(0,"rm -rf $copyToDir");
    }else{
        $self->runCmd($test, $cmd_mkdir);
        $self->runCmd($test, $cmd_copy);
    }
}

1;
