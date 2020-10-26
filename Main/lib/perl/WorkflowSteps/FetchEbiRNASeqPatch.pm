package ApiCommonWorkflow::Main::WorkflowSteps::FetchEbiRNASeqPatch;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $ebiFtpUser = $self->getConfig('ebiFtpUser');
  my $ebiFtpPassword = $self->getConfig('ebiFtpPassword');

  my $ebiVersion = $self->getParamValue('ebiVersion');
  my $ebiOrganismName = $self->getParamValue('ebiOrganismName');
  my $experimentName = $self->getParamValue('experimentName');
  my $samplesDir = $self->getParamValue('samplesDir');
  my $projectName = $self->getParamValue('projectName');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fullPath = "$workflowDataDir/$samplesDir";

  if ($undo) {
    $self->runCmd(0, "rm -rf $fullPath/*");
  } else {
    chdir $fullPath or die "could not change directory to $fullPath";

    $self->runCmd($test,"wget --reject '.bw' -nH --cut-dirs=6 --recursive --no-parent --ftp-user $ebiFtpUser --ftp-password $ebiFtpPassword ftp://ftp-private.ebi.ac.uk:/EBIout/$ebiVersion/rnaseq/update/$projectName/$ebiOrganismName/$experimentName/*");
    }
}

1;
