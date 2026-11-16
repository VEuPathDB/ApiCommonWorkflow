package ApiCommonWorkflow::Main::WorkflowSteps::StudyDealerNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow;


# 
sub loadsEdaStudies {
    my ($self) = @_;
    my $mode = $self->getParamValue("mode");

    return $mode eq 'rnaseq' || $mode eq 'chipChip' || $mode eq 'dnaseq';
}

sub hasPluginCalls {
    my ($self) = @_;
    return $self->loadsEdaStudies() ? 1 : 0;
}

sub isResumable {
    return 0;
}

sub skipUndo {
    my ($self) = @_;
    return $self->loadsEdaStudies() ? 1 : 0;
}

sub nextflowConfigAsString {
    my ($self) = @_;

    my $studyWranglerTag = $self->getSharedConfig("studyWranglerDockerTag");

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

    # Deliberately NOT calling getSharedClusterNextflowConfigIncludeBlock() here.
    # RunNextflow::run() execs nextflow directly (no ssh, no bsub) on whatever host
    # the ReFlow controller itself runs on -- this pipeline never dispatches to a
    # compute cluster, so the shared config's cluster-only setup (module load
    # apptainer) doesn't apply and breaks the run when included.

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
    sampleDetailsDir = "${workflowDataDir}/${sampleDetails}"
    filePatterns = [phenotype: "\${params.workflowPath}/*.{txt,tab,csv,tsv}",
                    antibodyArray: "\${params.workflowPath}/*.{txt,tab,csv,tsv}",
                    rflp: "\${params.workflowPath}/*.{txt,tab,csv,tsv}",
                    cellularLocalization: "\${params.workflowPath}/*.{txt,tab,csv,tsv}",
                    ebiRnaSeqCounts: "\${params.workflowPath}/*/nextflowAnalysisDir/nextflow_output/analysis_output/{countsForEda,merged-0.25-eigengenes}*",
                    rnaSeqCounts: "\${params.workflowPath}/*/bulkrnaseq/analysisDir/nextflowAnalysisDir/nextflow_output/analysis_output/countsForEda*",
                    rnaseqAiMetadata: "\${params.workflowDataDir}/\${params.sampleDetails}/*/*.{tsv,yaml}",
                    chipChipMetadata: "\${params.workflowDataDir}/\${params.sampleDetails}/*/*.{tsv,yaml}",
                    dnaseq: "\${params.workflowPath}/*/dnaseqNextflow/analysisDir/results/*/*_alignment_stats.tsv",
                    dnaseqStf: "\${params.sampleDetailsDir}/*/*/entity-sample.{tsv,yaml}"
                    ]
}

includeConfig "\$baseDir/conf/singularity.config"

NEXTFLOW


}


1;
