package ApiCommonWorkflow::Main::WorkflowSteps::MakeDecoyDatabase;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $inputFile = $self->getParamValue("inputFile");
  my $outputFile = $self->getParamValue("outputFile");
  my $outputDir = $self->getParamValue("decoyDatabaseDir");
  my $decoyRatio = $self->getParamValue("decoyRatio");
  my $decoyRegEx = $self->getParamValue("decoyRegEx");


  # expects string true/false
  
  my $workflowDataDir = $self->getWorkflowDataDir();
  $inputFile = $workflowDataDir."/".$inputFile;
  $outputFile=$outputDir."/".$outputFile;
  $inputFile=~s/\/+/\//g;
  $outputFile=~s/\/+/\//g;
  my $cmd = "create_fasta_for_searchEngine.pl --inputFile $inputFile --decoyRatio $decoyRatio --decoyRegEx $decoyRegEx --outputFile $outputFile";
  
  if ($undo) {
    $self->runCmd(0, "rm -rf $outputFile");
  }else {

    #TODO should write outputFile here?

    $self->testInputFile('inputFile', "$inputFile");
    $self->runCmd($test, $cmd);
  }
 }	

1;
