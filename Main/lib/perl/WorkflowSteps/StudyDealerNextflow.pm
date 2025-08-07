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
    my $organismAbbrev = $self->getParamValue("organismAbbrev");


    my $workflowGraphDir = "organismSpecific";

      my $configString = <<NEXTFLOW;
params {
    gusConfigFile = "${workflowDataDir}/${gusConfigFile}"
    workflowDataDir = "$workflowDataDir"
    mode = "$mode"
    outputDir = "${resultsDirectory}"
    datasetName = "$datasetName"
    workflowPath = "\${params.workflowDataDir}/${projectName}/${organismAbbrev}/${workflowGraphDir}"
    filePatterns = [phenotype: "\${params.workflowPath}/\${params.datasetName}/final/*.{txt,tab}",
                    phenotypeScript: "\${params.workflowPath}/\${params.datasetName}/final/*.{R,r}" ]
}

includeConfig "\$baseDir/conf/singularity.config"

NEXTFLOW


}


1;
