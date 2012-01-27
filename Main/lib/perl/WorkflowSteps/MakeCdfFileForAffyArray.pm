package ApiCommonWorkflow::Main::WorkflowSteps::MakeCdfFileForAffyArray;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Copy;


sub run {
  my ($self, $test, $undo) = @_;

  my $gene2probesInputFile = $self->getParamValue('gene2probesInputFile');
  my $probename2sequenceInputFile = $self->getParamValue('probename2sequenceInputFile');
  my $inputCdfFile = $self->getParamValue('inputCdfFile');
  my $outputCdfFile = $self->getParamValue('outputCdfFile');
  my $name = $self->getParamValue('mappingVendorFileName');
  my $rows = $self->getParamValue('probeRows');
  my $cols = $self->getParamValue('probeCols');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "get_pbase-tbase.pl $workflowDataDir/$probename2sequenceInputFile 1 > $workflowDataDir/pbase-tbase.out";

  # builds the header for the .cdf file
  my $cmd2 = "makeCdfHeader.pl  $workflowDataDir/$outputCdfFile $workflowDataDir/$gene2probesInputFile $name $rows $cols";

  # overwrites the provided .cdf file
  my $cmd3 = "create_cdf.pl $workflowDataDir/$outputCdfFile $workflowDataDir/$gene2probesInputFile $workflowDataDir/pbase-tbase.out";


  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/pbase-tbase.out");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputCdfFile");
  } else {
    if ($test) {
      $self->testInputFile('gene2probesInputFile', "$workflowDataDir/$gene2probesInputFile");
      $self->testInputFile('probename2sequenceInputFile', "$workflowDataDir/$probename2sequenceInputFile");
      $self->testInputFile('inputCdfFile', "$workflowDataDir/$inputCdfFile");
      $self->runCmd(0,"echo test > $workflowDataDir/pbase-tbase.out");

    }
    copy("$workflowDataDir/$inputCdfFile", "$workflowDataDir/$outputCdfFile") || $self->error("Can't copy inputCdfFile to outputCdfFile $workflowDataDir/$outputCdfFile");

    if (!$test) {
      $self->runCmd($test,$cmd1);
      $self->runCmd($test,$cmd2);
      $self->runCmd($test,$cmd3);
    }
  }
}

sub getParamDeclaration {
  return (
	  'gene2probesInputFile',
	  'probename2sequenceInputFile',
	  'gene2probesInputFile',
          'mappingVendorFileName',
          'probeRows',
          'probeCols',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

