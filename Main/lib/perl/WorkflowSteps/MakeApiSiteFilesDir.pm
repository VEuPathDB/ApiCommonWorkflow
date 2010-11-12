package ApiCommonWorkflow::Main::WorkflowSteps::MakeApiSiteFilesDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

## make a dir relative to the workflow's data dir

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $apiSiteFilesDir = $self->getParamValue('apiSiteFilesDir');

  my $baseDir = $self->getSharedConfig('apiSiteFilesDir');

  if($undo){

      $self->runCmd(0, "echo Doing nothing for undo");

      # why don't we delete the dir on undo?  -steve

  }else{

      $self->runCmd(0, "mkdir -p $baseDir/$apiSiteFilesDir");
      # go to root of local path to avoid skipping intermediate dirs
      #my @path = split(/\//,$apiSiteFilesDir);
      #$self->runCmd(0, "chmod -R g+w $baseDir/$path[0]");
  }
}
sub getParamsDeclaration {
  return (
          'apiSiteFilesDir',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
           ['baseDir', '', ''],
         );
}

