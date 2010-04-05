package ApiCommonWorkflow::Main::WorkflowSteps::InsertNextGenSeqCoverageWithSqlLdr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFileDir = $self->getParamValue('inputFileDir');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $genomeExtDbSpec =  $self->getParamValue('genomeExtDbSpec');
   
  my $cmd = "cat ";

 my $workflowDataDir = $self->getWorkflowDataDir();

  my @inputFileNames = $self->getInputFiles($test,$workflowDataDir/$inputFileDir,'','cov');
    
  my $size=scalar @inputFileNames;

  if (scalar @inputFileNames==0){
	die "No input files. Please check inputDir: $workflowDataDir/$inputFileDir\n";
  }else {
	$cmd .= join (" " ,@inputFileNames);
    }

  $cmd .= " >$workflowDataDir/$inputFileDir/ALL_SAMPLES.cov";

  #cat all cov files in inputDir
  $self->runCmd($test, $cmd);

  #convert concatenated cov file into the format recognized by plugin
  $cmd = "generateCoveragePlotInputFile.pl  --filename $workflowDataDir/$inputFileDir/ALL_SAMPLES.cov --RNASeqExtDbSpecs $extDbRlsSpec --genomeExtDbSpecs $genomeExtDbSpec > $workflowDataDir/$inputFileDir/ALL_SAMPLES_formated.cov";
  
  $self->runCmd($test, $cmd);

  my $args = "--dataFile $workflowDataDir/$inputFileDir/ALL_SAMPLES_formated.cov";

  

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$inputFileDir/ALL_SAMPLES_formated.cov");
      $self->runCmd(0, "rm -f $workflowDataDir/$inputFileDir/ALL_SAMPLES.cov");
  }

  if ($test){
      $self->runCmd(0, "echo test > $workflowDataDir/$inputFileDir/ALL_SAMPLES_formated.cov");
      $self->runCmd(0, "echo test > $workflowDataDir/$inputFileDir/ALL_SAMPLES.cov");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertNextGenSeqCoverageWithSqlLdr", $args);

}

sub getParamDeclaration {
  return (
	  'inputFileDir',
	  'extDbRlsSpec',
	  'genomeExtDbSpec',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

