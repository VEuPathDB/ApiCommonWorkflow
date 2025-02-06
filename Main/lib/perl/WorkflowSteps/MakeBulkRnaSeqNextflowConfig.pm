package ApiCommonWorkflow::Main::WorkflowSteps::MakeBulkRnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  #NOTE: the subset size here would run "X" number of genomic sequences at a time on the cluster (chromosomes or contigs)
  my $fastaSubsetSize = 5;

  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $sampleSheet = $self->getParamValue("sampleSheetFile");
  my $gtfFile = $self->getParamValue("gtfFile");
  my $genomeFile = $self->getParamValue("genomeFile");

  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");

  my $isStranded = $self->getBooleanParamValue("isStranded") ? "true" : "false";
  my $intronLength = $self->getParamValue("maxIntronLength");
  my $cdsOrExon = $self->getParamValue("cdsOrExon");
  my $organismAbbrev = $self->getParamValue("organismAbbrev");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $digestedSampleSheetPath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $sampleSheet);
  my $digestedGtfFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $gtfFile);
  my $digestedGenomeFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomeFile);
  my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
  } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

      my $configString = <<NEXTFLOW;
params {
    fasta                      = "$digestedGenomeFilePath"
    gtf                        = "$digestedGtfFilePath"
    input                      = "$digestedSampleSheetPath"
    outdir                     = "$digestedOutputDir"
    isStranded                 =  $isStranded
    intronLength               =  $intronLength
    cdsOrExon                  = "$cdsOrExon"
    useExistingIndex           =  false
    genome                     = "$organismAbbrev"
}

includeConfig "\$baseDir/conf/nfcore_boilerplate.config"

includeConfig "$clusterConfigFile"

process {
  maxForks = 2
}

def check_max(obj, type) {
    if (type == 'memory') {
        try {
            if (obj.compareTo(params.max_memory as nextflow.util.MemoryUnit) == 1)
                return params.max_memory as nextflow.util.MemoryUnit
            else
                return obj
        } catch (all) {
            println "   ### ERROR ###   Max memory '\${params.max_memory}' is not valid! Using default value: \$obj"
            return obj
        }
    } else if (type == 'time') {
        try {
            if (obj.compareTo(params.max_time as nextflow.util.Duration) == 1)
                return params.max_time as nextflow.util.Duration
            else
                return obj
        } catch (all) {
            println "   ### ERROR ###   Max time '\${params.max_time}' is not valid! Using default value: \$obj"
            return obj
        }
    } else if (type == 'cpus') {
        try {
            return Math.min( obj, params.max_cpus as int )
        } catch (all) {
            println "   ### ERROR ###   Max cpus '\${params.max_cpus}' is not valid! Using default value: \$obj"
            return obj
        }
    }
}

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
