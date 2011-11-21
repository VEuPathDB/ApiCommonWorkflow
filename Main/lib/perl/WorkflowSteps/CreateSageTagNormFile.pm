package ApiCommonWorkflow::Main::WorkflowSteps::CreateSageTagNormFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $studyName = $self->getParamValue('studyName');

  my $outputDir = $self->getParamValue('outputDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--studyName '$studyName' --fileDir $workflowDataDir/$outputDir";

  my $normFileDir = $studyName;

  $normFileDir=~ s/\s/_/g;

  $normFileDir =~ s/[\(\)]//g;

  if($undo){

      $self->runCmd(0,"rm -fr $workflowDataDir/$outputDir/$normFileDir");

  }else{
      if ($test) {
	  $self->runCmd(0,"mkdir -p $workflowDataDir/$outputDir/$normFileDir");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/$normFileDir/test.out");
      }else{
	  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CreateSageTagNormalizationFiles", $args);
      }
  }
}

sub getParamDeclaration {
  return (
	  'studyName',
	  'paramValue',
	  'outputDir',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

