package ApiCommonWorkflow::Main::WorkflowSteps::ExtractNaSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $outputFile = $self->getParamValue('outputFile');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');


  my @extDbRlsSpecList = split(/,/, $extDbRlsSpec);

  my $dbRlsIds;

  foreach my $db (@extDbRlsSpecList){
        
     $dbRlsIds .= $self->getExtDbRlsId($test, $db).",";

  }

  $dbRlsIds =~ s/(,)$//g;

  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$ncbiTaxonId);

  my $sql = "select enas.source_id||':1-'||enas.length||'_strand=+', enas.sequence 
             from dots.externalnasequence enas 
             where enas.taxon_id=$taxonId";


  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose");
      }
  }
}

sub getParamsDeclaration {
  return (
	  'extDbRlsSpec',
	  'outputFile',
	  'ncbiTaxonId'
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


