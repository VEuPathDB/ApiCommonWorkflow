package ApiCommonWorkflow::Main::WorkflowSteps::CheckOrthomclBuildVersion;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $orthoCacheDir = $self->getSharedConfig("orthoCacheDir");
  my $buildVersion = $self->getSharedConfig("buildVersion");
  my $cachedCoreResults = join("/",$orthoCacheDir,$self->getSharedConfig("cachedCoreResults"));
  my $cachedBuildVersionFile = join("/", $orthoCacheDir,"buildVersion.txt");
  my $cachedCheckSumFile = join("/", $orthoCacheDir,"checkSum.tsv");
  my $checkSumFile = join("/", $workflowDataDir, $self->getParamValue("checkSum"));
  my $cachedBuildVersion = `cat $cachedBuildVersionFile`;

  my $diff_result = `diff $cachedCheckSumFile $checkSumFile`;

  if ($diff_result eq '') {
    if ($cachedBuildVersion != $buildVersion) {
      die "Cached build version $cachedBuildVersion and new build version $buildVersion are different even though the proteomes are the same\n";  
    }
  }
  else {
    if ($cachedBuildVersion eq $buildVersion) {
      die "Cached build version $cachedBuildVersion and new build version $buildVersion are identical even though the proteomes are different\n";  
    }
  }
}


1;
