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
  my $skipIfFile = $self->getParamValue('skipIfFile');
  $skipIfFile = join("/", $workflowDataDir, $skipIfFile);

  my $cachedBuildVersion = `cat $cachedBuildVersionFile`;

  my $diff_result = `diff $cachedCheckSumFile $checkSumFile`;

  if($undo){
      $self->runCmd(0, "rm -f $skipIfFile") if -e $skipIfFile;
      $self->runCmd(0, "rm -rf $workflowDataDir/coreGroups") if -e "$workflowDataDir/coreGroups";
  }
  else {
    if ($test) {
      if ($diff_result eq '') {
        $self->runCmd(0, "echo test > $skipIfFile ");
        if ($cachedBuildVersion ne $buildVersion) {
          die "Cached build version $cachedBuildVersion and new build version $buildVersion are different even though the proteomes are the same\n";  
        }
      }
      else {
        if ($cachedBuildVersion eq $buildVersion) {
          die "Cached build version $cachedBuildVersion and new build version $buildVersion are identical even though the proteomes are different\n";  
        }
      }
    }
    else {
      if ($diff_result eq '') {
        if ($cachedBuildVersion ne $buildVersion) {
          die "Cached build version $cachedBuildVersion and new build version $buildVersion are different even though the proteomes are the same\n";  
        }
        $self->runCmd(0, "echo real > $skipIfFile ");
        $self->runCmd(0, "mkdir $workflowDataDir/coreGroups");
        $self->runCmd(0, "cp -r $cachedCoreResults $workflowDataDir/coreGroups");
      }
      else {
        if ($cachedBuildVersion eq $buildVersion) {
          die "Cached build version $cachedBuildVersion and new build version $buildVersion are identical even though the proteomes are different\n";  
        }
      }
    }
  }
}

1;
