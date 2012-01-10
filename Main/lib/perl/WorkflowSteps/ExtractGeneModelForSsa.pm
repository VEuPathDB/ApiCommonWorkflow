package ApiCommonWorkflow::Main::WorkflowSteps::ExtractGeneModelForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $outputFile = $self->getParamValue('outputFile');
  my $useCDSCoordinates = $self->getBooleanParamValue('useCDSCoordinates');
  my $useTopLevel = $self->getBooleanParamValue('useTopLevel');

  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();

  my $dbName = "${organismAbbrev}_primary_genome_RSRC";

  my $dbVersion = $self->getExtDbVersion($test,$dbName);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "extractGeneModelForSsa --outputFile $workflowDataDir/$outputFile --taxonId $taxonId --dbName $dbName --dbVersion $dbVersion ";
  
  $cmd .= " --coordinates CDS" if ($useCDSCoordinates);

  $cmd .= " --topLevel" if ($useTopLevel);

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test, $cmd);
      }
  }
}

sub getParamsDeclaration {
  return (
	  'table',
	  'outputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


