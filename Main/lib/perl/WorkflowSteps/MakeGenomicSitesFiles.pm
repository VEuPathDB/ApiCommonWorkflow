package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenomicSitesFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $orthomclVersion = $self->getParamValue('orthomclVersion');
  $orthomclVersion =~ s/_//g;
  my $peripheralDir = $self->getParamValue('peripheralDir');
  my $peripheralMapFileName = $self->getParamValue('peripheralMapFileName');
  my $coreMapFile = $self->getParamValue('coreMapFile');
  my $residualMapFile = $self->getParamValue('residualMapFile');
  my $cladeFile = $self->getParamValue('cladeFile');
  my $ecFile = $self->getParamValue('ecFile');
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $genomicSitesDir = $workflowDataDir."/genomicSitesFiles_".$orthomclVersion;

  if ($undo) {
    $self->runCmd(0, "rm -rf $genomicSitesDir") if -e "$genomicSitesDir";
  } else {
    my $cmd = "orthomclMakeGenomicSitesFiles $genomicSitesDir $workflowDataDir/$peripheralDir $peripheralMapFileName $workflowDataDir/$coreMapFile $workflowDataDir/$residualMapFile $workflowDataDir/$cladeFile $workflowDataDir/$ecFile";
    $self->runCmd($test, $cmd);

    #these are the temporary commands for changing 'rhiz' to 'rirr'
    $cmd = "sed -i 's/rhiz/rirr/g' $genomicSitesDir/orthomclTaxons.txt";
    $self->runCmd($test, $cmd);
    $cmd = "sed -i 's/rhiz|/rirr|/g' $genomicSitesDir/orthomclGroups.txt";
    $self->runCmd($test, $cmd);

    if ($test) {
      $self->runCmd(0, "touch $workflowDataDir/$peripheralDir");
      $self->runCmd(0, "touch $workflowDataDir/$coreMapFile");
      $self->runCmd(0, "touch $workflowDataDir/$residualMapFile");
      $self->runCmd(0, "touch $workflowDataDir/$cladeFile");
    }
  }
}


