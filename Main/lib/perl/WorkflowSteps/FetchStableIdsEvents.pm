package ApiCommonWorkflow::Main::WorkflowSteps::FetchStableIdsEvents;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $ebiFtpUser = $self->getConfig('ebiFtpUser');
  my $ebiFtpPassword = $self->getConfig('ebiFtpPassword');

  my $ebiVersion = $self->getParamValue('buildNumber');
  my $ebiOrganismName = $self->getParamValue('organismAbbrev');
  my $experimentName = $self->getParamValue('name');
  my $samplesDir = $self->getParamValue('samplesDir');
  my $projectName = $self->getParamValue('projectName');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fullPath = "$workflowDataDir/$samplesDir";

  if ($undo) {
    $self->runCmd(0, "rm -rf $fullPath/${experimentName}.tab");
  } else {
    chdir $fullPath or die "could not change directory to $fullPath";
    $self->runCmd($test,"wget --cut-dirs 8 --no-host-directories  --recursive --no-parent --ftp-user $ebiFtpUser --ftp-password $ebiFtpPassword ftp://ftp-private.ebi.ac.uk//upload/EBI/build${ebiVersion}/stable_id_events/metadata/$projectName/$ebiOrganismName/${experimentName}.tab");
}
}
1;
