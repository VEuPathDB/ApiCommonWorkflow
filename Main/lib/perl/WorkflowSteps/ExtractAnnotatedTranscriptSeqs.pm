package ApiCommonWorkflow::Main::WorkflowSteps::ExtractAnnotatedTranscriptSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $outputFile = $self->getParamValue('outputFile');
  my $transcriptTable = $self->getParamValue('transcriptTable');
  my $seqTable = $self->getParamValue('seqTable');
  my $identifier = $self->getParamValue('identifier');

  my $dbRlsId = $self->getExtDbRlsId($test, $extDbRlsSpec);

  my $sql = "select t.$identifier, s.description,
            'length='||s.length,s.sequence
             from dots.$transcriptTable t, dots.$seqTable s
             where t.external_database_release_id = $dbRlsId
             and t.na_sequence_id = s.na_sequence_id";


  my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {  
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}
        $self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose");
    }
}
1;
