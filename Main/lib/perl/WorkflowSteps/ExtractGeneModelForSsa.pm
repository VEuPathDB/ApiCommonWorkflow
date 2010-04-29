package ApiCommonWorkflow::Main::WorkflowSteps::ExtractGeneModelForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $outputFile = $self->getParamValue('outputFile');
  my $sequenceOntology = $self->getParamValue('sequenceOntology');


  my @extDbRlsSpecList = split(/,/, $extDbRlsSpec);

  my $dbRlsIds;

  foreach my $db (@extDbRlsSpecList){
        
     $dbRlsIds .= $self->getExtDbRlsId($test, $db).",";

  }

  $dbRlsIds =~ s/(,)$//g;

  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$ncbiTaxonId);

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test,"rnaSeqIdxCreator.pl --outputFile $workflowDataDir/$outputFile --taxonId $taxonId");
      }
  }


sub getParamsDeclaration {
  return (
	  'table',
	  'extDbRlsSpec',
	  'outputFile',
	  'sequenceOntology'
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


