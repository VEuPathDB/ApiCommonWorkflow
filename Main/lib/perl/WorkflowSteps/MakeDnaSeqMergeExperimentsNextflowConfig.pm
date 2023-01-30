package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqMergeExperimentsNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $inputDir = join("/", $workflowDataDir, $self->getParamValue("inputDir")); 
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir")); 
  my $configFileName = $self->getParamValue("configFileName");
  my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $gtfFile = join("/", $workflowDataDir, $self->getParamValue("gtfFile"));
  my $genomeFastaFile = join("/", $workflowDataDir, $self->getParamValue("genomeFastaFile"));
  my $organismAbbrev = $self->getParamValue("organismAbbrev");
  my $referenceStrain = $self->getParamValue("referenceStrain");
  my $cacheFile = $self->getParamValue("cacheFile");
  my $undoneStrains = $self->getParamValue("undoneStrains");
  my $varscanDirectory = join("/", $workflowDataDir, $self->getParamValue("varscanDirectory"));
  my $varscanFilePath = join("/", $workflowDataDir, $self->getParamValue("varscanFilePath"));
  
  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {

  inputDir = \"$inputDir\"
  outputDir = \"$outputDir\"
  gusConfig = \"\$GUS_HOME/config/gus.config\"
  cacheFile = \"$cacheFile\"
  undoneStrains = \"$undoneStrains\"
  organism_abbrev = \'$organismAbbrev\' 
  reference_strain = \'$referenceStrain\'
  varscan_directory = \"$varscanDirectory\"
  genomeFastaFile = \"$genomeFastaFile\"
  gtfFile = \"$gtfFile\"
  varscanFilePath = \"$varscanFilePath\"

}

singularity {
  enabled = true
  autoMounts = true
}
";
  close(F);
 }
}

1;

