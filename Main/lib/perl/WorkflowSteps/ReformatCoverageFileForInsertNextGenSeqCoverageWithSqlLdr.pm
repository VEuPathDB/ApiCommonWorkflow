package ApiCommonWorkflow::Main::WorkflowSteps::ReformatCoverageFileForInsertNextGenSeqCoverageWithSqlLdr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFileDir = $self->getParamValue('inputFileDir');

  my $outputFile =  $self->getParamValue('outputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $genomeExtDbSpec =  $self->getParamValue('genomeExtDbSpec');
   
  my $cmdCat = "cat ";

 my $workflowDataDir = $self->getWorkflowDataDir();

  my @inputFileNames = $self->getInputFiles($test,'$workflowDataDir/$inputFileDir','','cov');
    
  my $size=scalar @inputFileNames;

  if (scalar @inputFileNames==0){
	die "No input files. Please check inputDir: $workflowDataDir/$inputFileDir\n";
  }else {
	$cmdCat .= join (" " ,@inputFileNames);
    }

  $cmdCat .= " >$workflowDataDir/$inputFileDir/TEMP.cov";

  my $cmdReformat = "generateCoveragePlotInputFile.pl  --filename $workflowDataDir/$inputFileDir/TEMP.cov --RNASeqExtDbSpecs $extDbRlsSpec --genomeExtDbSpecs $genomeExtDbSpec > $workflowDataDir/$outputFile";

  my $cmdRemoveTEMP = "rm -r $workflowDataDir/$inputFileDir/TEMP.cov";
  
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test, $cmdCat);
	    $self->runCmd($test, $cmdReformat);
	    $self->runCmd($test, $cmdRemoveTEMP);
      }
  }

}

sub getParamDeclaration {
  return (
	  'inputFileDir',
	  'outputFile',
	  'extDbRlsSpec',
	  'genomeExtDbSpec',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

