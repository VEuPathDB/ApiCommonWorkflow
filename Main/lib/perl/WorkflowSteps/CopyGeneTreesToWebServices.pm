 package ApiCommonWorkflow::Main::WorkflowSteps::CopyGeneTreesToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $copyFromDir = $self->getParamValue('geneTreesDir');
    my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
    my $webServicesDir = $self->getParamValue('webServicesDir');
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $websiteFilesDir = $self->getWebsiteFilesDir($test);

    my $copyToDir = "$websiteFilesDir/$webServicesDir/";
    my $cmd_copy = "cp -r $workflowDataDir/$copyFromDir $copyToDir";
    
    if ($undo) {
        $self->runCmd(0,"rm -rf $copyToDir/geneTrees");
    }else{
        $self->runCmd($test, $cmd_copy);
    }
}

1;
