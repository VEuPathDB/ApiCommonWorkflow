package ApiCommonWorkflow::Main::WorkflowSteps::MakeCdfFileForAffyArray;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Copy;

my $MIN_PROBES = 3;

sub run {
  my ($self, $test, $undo) = @_;

  my $gene2probesInputFile = $self->getParamValue('gene2probesInputFile');
  my $probename2sequenceInputFile = $self->getParamValue('probename2sequenceInputFile');
  my $outputCdfFile = $self->getParamValue('outputCdfFile');
  my $name = $self->getParamValue('vendorMappingFileName');
  my $rows = $self->getParamValue('probeRows');
  my $cols = $self->getParamValue('probeCols');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "get_pbase-tbase.pl $workflowDataDir/$probename2sequenceInputFile 1 > $workflowDataDir/pbase-tbase.out";

  # builds the header for the .cdf file
  my $cmd2 = "makeCdfHeader.pl  --gene2probes $workflowDataDir/$outputCdfFile --outputFilePath $workflowDataDir/$gene2probesInputFile --name $name --rows $rows --cols $cols --minProbes $MIN_PROBES";

  # overwrites the provided .cdf file
  my $cmd3 = "create_cdf.pl $workflowDataDir/$outputCdfFile $workflowDataDir/$gene2probesInputFile $workflowDataDir/pbase-tbase.out $MIN_PROBES";


  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/pbase-tbase.out");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputCdfFile");
  } else {
    if ($test) {
      $self->testInputFile('gene2probesInputFile', "$workflowDataDir/$gene2probesInputFile");
      $self->testInputFile('probename2sequenceInputFile', "$workflowDataDir/$probename2sequenceInputFile");
      $self->runCmd(0,"echo test > $workflowDataDir/pbase-tbase.out");
      $self->runCmd(0,"echo test > $workflowDataDir/$outputCdfFile");

    }

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
          'vendorMappingFileName',
          'probeRows',
          'probeCols',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

