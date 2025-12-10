package ApiCommonWorkflow::Main::WorkflowSteps::StudyDealerNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow;

sub nextflowConfigAsString {
    my ($self) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $resultsDirectory = $self->getResultsDirectory();
    my $workingDirectory = $self->getWorkingDirectory();

    my $gusConfigFile = $self->getParamValue("gusConfigFile");
    my $mode = $self->getParamValue("mode");
    my $datasetName = $self->getParamValue("datasetName");
    my $projectName = $self->getParamValue("projectName");

    my $inputDirectory = $self->getParamValue("inputDirectory");

    my $workflowGraphDir = "organismSpecific";

    my @expected = glob("${workflowDataDir}/${$inputDirectory}/*.{txt,tab,r,R}");
    if($mode eq 'phenotype' && scalar(@expected) != 2) {
        $self->error("Phenotype dataset must provide both tab/txt and R file");
    }

      my $configString = <<NEXTFLOW;
params {
    gusConfigFile = "${workflowDataDir}/${gusConfigFile}"
    workflowDataDir = "$workflowDataDir"
    mode = "$mode"
    outputDir = "${resultsDirectory}"
    datasetName = "$datasetName"
    workflowPath = "\${params.workflowDataDir}/${inputDirectory}"
    filePatterns = [phenotype: "\${params.workflowPath}/*.{txt,tab}",
                    phenotypeScript: "\${params.workflowPath}/*.{R,r}" ]
}

includeConfig "\$baseDir/conf/singularity.config"

NEXTFLOW


}


1;
