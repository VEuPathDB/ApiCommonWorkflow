
package ApiCommonWorkflow::Main::WorkflowSteps::CopyJBrowseFlatFilesToWebServiceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $jbrowseDir = $self->getParamValue('jbrowseDir');
  my $relativeWebServicesDir = $self->getParamValue('relativeWebServicesDir');

  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $copyToDir = "$websiteFilesDir/$relativeWebServicesDir/$organismNameForFiles/jbrowseFlatFiles";

  my $sourceDir = "$workflowDataDir/$jbrowseDir";

  if ($undo) {
    $self->runCmd(0, "rm -f $copyToDir/*.bed.gz");
    $self->runCmd(0, "rm -f $copyToDir/*.gff.gz");
    $self->runCmd(0, "rm -f $copyToDir/*.tbi");
    $self->runCmd(0, "rm -f $copyToDir/*.bw");
  } else {
    if ($test) {
      $self->runCmd(0, "mkdir -p $copyToDir");
      $self->runCmd(0, "echo test > $copyToDir/test.bed.gz");
      $self->runCmd(0, "echo test > $copyToDir/test.gff.gz");
      $self->runCmd(0, "echo test > $copyToDir/test.tbi");
      $self->runCmd(0, "echo test > $copyToDir/test.bw");
    }
    $self->runCmd($test, "mkdir -p $copyToDir");
    $self->runCmd($test, "cp $sourceDir/*.bed.gz $copyToDir/ 2>/dev/null || true");
    $self->runCmd($test, "cp $sourceDir/*.gff.gz $copyToDir/ 2>/dev/null || true");
    $self->runCmd($test, "cp $sourceDir/*.tbi $copyToDir/ 2>/dev/null || true");
    $self->runCmd($test, "cp $sourceDir/*.bw $copyToDir/ 2>/dev/null || true");
  }
}

1;
