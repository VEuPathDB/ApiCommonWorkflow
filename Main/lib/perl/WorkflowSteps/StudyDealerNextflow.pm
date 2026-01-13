package ApiCommonWorkflow::Main::WorkflowSteps::StudyDealerNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow;


# 
sub hasPluginCalls {
    my ($self) = @_;
    my $mode = $self->getParamValue("mode");

    if($mode eq 'rnaseq' || $mode eq 'chipChip')

    return 1;
}

sub isResumable {
    return 0;
}


sub nextflowConfigAsString {
    my ($self) = @_;

    my $studyWranglerTag = "1.0.28";
    
    my $workflowDataDir = $self->getWorkflowDataDir();

    my $resultsDirectory = $self->getResultsDirectory();
    my $workingDirectory = $self->getWorkingDirectory();

    my $gusConfigFile = $self->getParamValue("gusConfigFile");
    my $mode = $self->getParamValue("mode");
    my $datasetName = $self->getParamValue("datasetName");

    # TODO:  Remove this as it isn't used
    my $projectName = $self->getParamValue("projectName"); 

    my $sampleDetails = $self->getParamValue("sampleDetails"); #global/metaData_RnaSeq_RSRC/final
    my $multiDatasetStudiesJson = $self->getParamValue("multiDatasetStudiesJson"); #global/metaData_RnaSeq_RSRC/final/multiDatasetStudy.json
    
    my $inputDirectory = $self->getParamValue("inputDirectory");

    my $gusHomeDir = $ENV{GUS_HOME};
    
      my $configString = <<NEXTFLOW;
params {
    gusConfigFile = "${workflowDataDir}/${gusConfigFile}"
    gusHomeDir = "$gusHomeDir"
    workflowDataDir = "$workflowDataDir"
    multiDatasetStudies = "$workflowDataDir/$multiDatasetStudiesJson"
    mode = "$mode"
    studyWranglerTag = "$studyWranglerTag"                     
    outputDir = "${resultsDirectory}"
    datasetName = "$datasetName"
    workflowPath = "\${params.workflowDataDir}/${inputDirectory}"
    sampleDetails = "$sampleDetails"
    filePatterns = [phenotype: "\${params.workflowPath}/*.{txt,tab,csv}",
                    antibodyArray: "\${params.workflowPath}/*.{txt,tab,csv}",
                    rflp: "\${params.workflowPath}/*.{txt,tab,csv}",
                    cellularLocalization: "\${params.workflowPath}/*.{txt,tab,csv}",
                    ebiRnaSeqCounts: "\${params.workflowPath}/*/nextflowAnalysisDir/nextflow_output/analysis_output/{countsForEda,merged-0.25-eigengenes}*",
                    rnaSeqCounts: "\${params.workflowPath}/*/bulkrnaseq/analysisDir/nextflowAnalysisDir/nextflow_output/analysis_output/countsForEda*",
                    rnaseqAiMetadata: "\${params.workflowDataDir}/\${params.sampleDetails}/*/*.{tsv,yaml}",
                    chipChipMetadata: "\${params.workflowDataDir}/\${params.sampleDetails}/*/*.{tsv,yaml}"
                    ]
}

includeConfig "\$baseDir/conf/singularity.config"

NEXTFLOW


}


1;
