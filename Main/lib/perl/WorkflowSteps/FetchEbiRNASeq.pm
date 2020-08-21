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
  my $samplesDir = $self->getParamValue('samplesDir');
  my $projectName = $self->getParamValue('projectName');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fullPath = "$workflowDataDir/$samplesDir/$experimentName";

  if ($undo) {
    $self->runCmd(0, "rm -rf $fullPath/*");
  } else {
    chdir $fullPath or die "could not change directory to $fullPath";

    # exclude/reject bw files; 
    # cut-dirs=6 makes it so we only get sample directories
    # for experiments in format SRPXXXXXX_SRPYYYYYY we need to retrieve from each project separately
    #foreach my $experiment  (split('_', $experimentName)) {
    #    $self->runCmd($test,"wget --reject '.bw' -nH --cut-dirs=6 --recursive --no-parent --ftp-user $ebiFtpUser --ftp-password $ebiFtpPassword ftp://ftp-private.ebi.ac.uk:/EBIout/$ebiVersion/rnaseq/alignments/$ebiOrganismName/$experiment/*");
    #}
    $self->runCmd($test,"wget --reject '.bw' -nH --cut-dirs=6 --recursive --no-parent --ftp-user $ebiFtpUser --ftp-password $ebiFtpPassword ftp://ftp-private.ebi.ac.uk:/EBIout/$ebiVersion/rnaseq/$projectName/$ebiOrganismName/$experimentName/*");
    }
}

1;
