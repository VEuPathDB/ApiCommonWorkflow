package ApiCommonWorkflow::Main::WorkflowSteps::MakeArrayProbeMappingNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $gtfFeatureType = "exon";
  my $geneGtfTag = "gene_id";
  my $minProbes = 1;


  my $resultsDirectory = $self->getParamValue("resultsDirectory");

  my $platformType = $self->getParamValue("platformType");
  my $projectName = $self->getParamValue("projectName");

  #my $wantSplicedAlignments = lc $self->getParamValue("wantSplicedAlignments");
  my $wantSplicedAlignments = "true";
  if($platformType ne 'expression' || $projectName eq 'TriTrypDB') {
    $wantSplicedAlignments = false;
  }

  my $gtfFile = $self->getParamValue("gtfFile");
  my $genomeFile = $self->getParamValue("genomeFile");
  my $finalDirectory = $self->getParamValue("finalDirectory");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $organismAbbrev = $self->getParamValue("organismAbbrev");

  my $outputFileName = $self->getParamValue("outputFileName");
  my $inputProbesFastaName = $self->getParamValue("inputProbesFastaName");


  my $makeCdfFile = lc $self->getParamValue("makeCdfFile");
  my $makeNdfFile = lc $self->getParamValue("makeNdfFile");
  my $geneProbeMappingFileName = $self->getParamValue("geneProbeMappingFileName");

  # defaults for non cdf/ndf mapping
  my $vendorMappingFileName = "NA";
  my $probeRows = 0;
  my $probeCols = 0;

  if($self->getBooleanParamValue("makeCdfFile") || $self->getBooleanParamValue("makeNdfFile")) {
      $vendorMappingFileName = $self->getParamValue("vendorMappingFileName");
  }

  if($self->getBooleanParamValue("makeCdfFile")) {
      $probeRows = $self->getParamValue("probeRows");
      $probeCols = $self->getParamValue("probeCols");
  }

  my $limitNU = $self->getParamValue("limitNU");

  # DEPRECATED?? (these are configured but not used??)
  my $variableLengthReads = lc $self->getParamValue("variableLengthReads");
  my $numInsertions = $self->getParamValue("numInsertions");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $digestedGtfFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $gtfFile);
  my $digestedGenomeFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomeFile);
  my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);
  my $digestedFinalDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $finalDirectory);


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
  genomeFastaFile = "$digestedGenomeFilePath"
  outputDir = "$digestedOutputDir"
  outputFileName = "$outputFileName"
  probesFastaFile = "$digestedFinalDir/$inputProbesFastaName"
  wantSplicedAlignments = $wantSplicedAlignments
  platformType = "$platformType"
  gtfFile = "$digestedGtfFilePath"
  makeCdfFile = $makeCdfFile
  makeNdfFile = $makeNdfFile
  outputMappingFileName = "$geneProbeMappingFileName"
  vendorMappingFile = "$digestedFinalDir/$vendorMappingFileName"
  arrayRows = $probeRows
  arrayColumns = $probeCols
}

process {
  maxForks = 1

  withName: gsnapMapping {
    ext.nPaths = 30
    ext.params = "-n $limitNU -D 20 -R 3 -N 1 -L 20 -i S,1,0.50 -I 0 -X 1000 -f"
  }

  withName: bedToGene2Probe {
    ext.gtfFeatureType = "$gtfFeatureType"
    ext.geneGtfTag = "$geneGtfTag"
  }

  withName: cdfFromGene2Probe {
    ext.minProbes = $minProbes
  }
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
