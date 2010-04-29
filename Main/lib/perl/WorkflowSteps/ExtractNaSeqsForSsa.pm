package ApiCommonWorkflow::Main::WorkflowSteps::ExtractNaSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $table = $self->getParamValue('table');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $outputFile = $self->getParamValue('outputFile');
  my $sequenceOntology = $self->getParamValue('sequenceOntology');


  my @extDbRlsSpecList = split(/,/, $extDbRlsSpec);

  my $dbRlsIds;

  foreach my $db (@extDbRlsSpecList){
        
     $dbRlsIds .= $self->getExtDbRlsId($test, $db).",";

  }

  $dbRlsIds =~ s/(,)$//g;

  my $sql = "select x.na_sequence_id, x.description,
            'length='||x.length,x.sequence
             from dots.$table x, sres.sequenceontology s
             where x.external_database_release_id in ($dbRlsIds)
             and x.sequence_ontology_id = s.sequence_ontology_id
             and lower(s.term_name) = '$sequenceOntology'";

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


