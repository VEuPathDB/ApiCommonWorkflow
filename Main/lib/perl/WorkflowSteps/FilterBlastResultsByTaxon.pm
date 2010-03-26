package ApiCommonWorkflow::Main::WorkflowSteps::FilterBlastResultsByTaxon;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $taxonList = $self->getParamValue('taxonHierarchy');
  my $inputFile = $self->getParamValue('inputFile');
  my $unfilteredOutputFile = $self->getParamValue('unfilteredOutputFile');
  my $filteredOutputFile = $self->getParamValue('filteredOutputFile');
  my $gi2taxidFileRelativeToDownloadDir = $self->getParamValue('gi2taxidFileRelativeToDownloadDir');

  my $downloadDir = $self->getGlobalConfig('downloadDir');

  $taxonList =~ s/\"//g if $taxonList;

  my $gi2taxidFile = "$downloadDir/$gi2taxidFileRelativeToDownloadDir";
  $self->runCmd(0, "gunzip $gi2taxidFile.gz") if (-e "$gi2taxidFile.gz");

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->runCmd(0, "gunzip $workflowDataDir/$inputFile.gz") if (-e "$workflowDataDir/$inputFile.gz");


  $self->runCmd(0,"cp $workflowDataDir/$inputFile $workflowDataDir/$unfilteredOutputFile");

  my $cmd = "splitAndFilterBLASTX --taxon \"$taxonList\" --gi2taxidFile $gi2taxidFile --inputFile $workflowDataDir/$unfilteredOutputFile --outputFile $workflowDataDir/$filteredOutputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$unfilteredOutputFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$filteredOutputFile");
  } else {  
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$filteredOutputFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamsDeclaration {
  return (
	  'taxonHierarchy',
	  'gi2taxidFileRelativeToDownloadDir',
	  'inputFile',
	  'unfilteredOutputFile',
	  'filteredOutputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['downloadDir', "", ""],
	 );
}



