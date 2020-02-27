package ApiCommonWorkflow::Main::WorkflowSteps::FetchEbiRNASeq;

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
  #for experiments in formatn SRPXXXXXX_SRPYYYYYYY only the first part of this identifier is used in the ftp path
  my $ftpExperimentDir = (split('_', $experimentName))[0];
  my $samplesDir = $self->getParamValue('samplesDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fullPath = "$workflowDataDir/$samplesDir";


  if ($undo) {
    $self->runCmd(0, "rm -rf $fullPath/*");
  } else {
    chdir $fullPath or die "could not change directory to $fullPath";

    # exclude/reject bw files; 
    # cut-dirs=6 makes it so we only get sample directories
    $self->runCmd($test,"wget --reject '.bw' -nH --cut-dirs=6 --recursive --no-parent --ftp-user $ebiFtpUser --ftp-password $ebiFtpPassword ftp://ftp-private.ebi.ac.uk:/EBIout/$ebiVersion/rnaseq/alignments/$ebiOrganismName/$ftpExperimentDir/*");

  }

}

1;
