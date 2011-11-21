package ApiCommonWorkflow::Main::WorkflowSteps::InsertSimpleRadAnalysisFromConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $analysisWorkingDir = $self->getParamValue('inputDir');

  my $configFile = $self->getParamValue('configFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  open(CFILE, "$workflowDataDir/$configFile") || die "Can't open config file '$workflowDataDir/$configFile'";

  my $noPlugin;

  while (my $line = <CFILE>){
    $noPlugin = 1 if $line =~ m/NO ANALYSIS TO LOAD/i;
  }

  close(CFILE);

  my $analysisResultView =  $self->getParamValue('analysisResultView');

  my $naFeatureView =  $self->getParamValue('naFeatureView');

  my $useSqlLdr =  $self->getParamValue('useSqlLdr');

#  my $profileSetNames =  $self->getParamValue('profileSetNames'); # see redmine issue 4257
  my $profileSetNames =  "";

  my $args = "--inputDir '$workflowDataDir/$analysisWorkingDir' --configFile '$workflowDataDir/$configFile' --analysisResultView $analysisResultView  --naFeatureView $naFeatureView";

  $args.=" --useSqlLdr" if($useSqlLdr eq "true"); 

  if ($test) {
    $self->testInputFile('analysisWorkingDir', "$workflowDataDir/$analysisWorkingDir");
    $self->testInputFile('configFile', "$workflowDataDir/$configFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAnalysisResult", $args) unless $noPlugin;

}

sub getParamDeclaration {
  return (
	  'analysisWorkingDir',
	  'analysisResultView',
	  'naFeatureView',
	  'useSqlLdr',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

