package ApiCommonWorkflow::Main::WorkflowSteps::StudyDealerNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow;

sub nextflowConfigAsString {
    my ($self) = @_;

    my $studyWranglerTag = "1.0.27";
    
    my $workflowDataDir = $self->getWorkflowDataDir();

    my $resultsDirectory = $self->getResultsDirectory();
    my $workingDirectory = $self->getWorkingDirectory();

    my $gusConfigFile = $self->getParamValue("gusConfigFile");
    my $mode = $self->getParamValue("mode");
    my $datasetName = $self->getParamValue("datasetName");
    my $projectName = $self->getParamValue("projectName");

    my $inputDirectory = $self->getParamValue("inputDirectory");

    my $gusHomeDir = $ENV{GUS_HOME};
    
      my $configString = <<NEXTFLOW;
params {
    gusConfigFile = "${workflowDataDir}/${gusConfigFile}"
    gusHomeDir = "$gusHomeDir"
    workflowDataDir = "$workflowDataDir"
    mode = "$mode"
    studyWranglerTag = "$studyWranglerTag"                     
    outputDir = "${resultsDirectory}"
    datasetName = "$datasetName"
    workflowPath = "\${params.workflowDataDir}/${inputDirectory}"
    filePatterns = [phenotype: "\${params.workflowPath}/*.{txt,tab}",
                    antibodyArray: "\${params.workflowPath}/*.{txt,tab}",
                    rflp: "\${params.workflowPath}/*.{txt,tab}",
                    cellularLocalization: "\${params.workflowPath}/*.{txt,tab}"
                    ]
}

includeConfig "\$baseDir/conf/singularity.config"

NEXTFLOW


}


1;
