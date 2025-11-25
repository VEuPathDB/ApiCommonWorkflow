package ApiCommonWorkflow::Main::WorkflowSteps::CopyNormalizedBedGraphToWebServiceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;


# PlasmoDB/pfal3D7/rnaseq/pfal3D7_Newbold_ebi_rnaSeq_RSRC/normalize_coverage/results/ERR006184/normalized/final

  # get parameters
  my $copyFromDir = $self->getParamValue('copyFromDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDir = $self->getParamValue('relativeDir');

  my $experimentDatasetName = $self->getParamValue('experimentDatasetName');
  my $analysisConfig = $self->getParamValue('analysisConfig');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  my $dataType = $self->getParamValue('dataType');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/${dataType}/bigwig/$experimentDatasetName";
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_mkdir = "mkdir -p $copyToDir";

  my $cmd_copy = "copyNormalizedBedGraphToWebServiceDir.pl --inputDir $workflowDataDir/$copyFromDir --outputDir $copyToDir --analysisConfig $workflowDataDir/$analysisConfig"; 

  $self->testInputFile('copyFromDir', "$workflowDataDir/$copyFromDir");

  if ($undo) {
    $self->runCmd(0, "rm -fr $copyToDir");
  } else {
    $self->runCmd($test, $cmd_mkdir);
    $self->runCmd($test, $cmd_copy);
  }

}

1;


