package ApiCommonWorkflow::Main::WorkflowSteps::InsertNormSageTagFreqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $studyName = $self->getParamValue('studyName');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $studyName =~ s/\s/_/g;

  $studyName =~ s/[\(\)]//g;

  my $inputDir = $self->getParamValue('inputDir')  ."/" . $studyName;
  
  my $configFile = "configFile";

  my $args = "--configFile '$configFile' --subclass_view RAD::DataTransformationResult";

  if($undo){
    $self->runCmd(0,"rm -rf $configFile");
  }else{

      if ($test) {
	  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
      }
      opendir (DIR,"$workflowDataDir/$inputDir") || die "Can not open dir $workflowDataDir/$inputDir";

      my @files = grep { /\w*\.dat/ && -f "$workflowDataDir/$inputDir/$_" } readdir(DIR); 

      open(F,">$configFile");

      foreach my $dataFile (@files) {

	  my $cfgFile = $dataFile;

	  $cfgFile =~ s/\.dat/\.cfg/;
    
	  print F "$workflowDataDir/$inputDir/$cfgFile\t$workflowDataDir/$inputDir/$dataFile\n";
      }
     
      close F;
      
      $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertRadAnalysis", $args);
  }





}

sub getParamDeclaration {
  return (
	  'studyName',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

