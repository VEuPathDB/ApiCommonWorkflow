package ApiCommonWorkflow::Main::WorkflowSteps::ExtractMixedGenomicSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


## to do
## API $self->getExtDbRlsId($test, $genomeExtDbRlsSpec)

sub run {
  my ($self, $test, $undo) = @_;

  # get params
  my $outputFile = $self->getParamValue('outputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $genomeVirtualSeqsExtDbRlsSpec = $self->getParamValue('genomeVirtualSeqsExtDbRlsSpec');
  my $genomeSource = $self->getParamValue('genomeSource');
  my $withVirtualSeqs = $self->getParamValue('withVirtualSeqs');

  my $genomDbRlsId = $self->getExtDbRlsId($test, $genomeExtDbRlsSpec);
  my $virtualDbRlsId; 
  $virtualDbRlsId= $self->getExtDbRlsId($test, $genomeVirtualSeqsExtDbRlsSpec) if $withVirtualSeqs;

  my $sql1 = "select source_id, sequence from Dots.VIRTUALSEQUENCE where external_database_release_id = '$virtualDbRlsId'";

  my $sql2 =  "select source_id, sequence from Dots.EXTERNALNASEQUENCE es where external_database_release_id = '$genomDbRlsId' and es.na_sequence_id NOT IN (select sp.piece_na_sequence_id from dots.SEQUENCEPIECE sp, dots.VIRTUALSEQUENCE vs where vs.na_sequence_id = sp.virtual_na_sequence_id AND vs.external_database_release_id ='$virtualDbRlsId')";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "dumpSequencesFromTable.pl --outputfile $workflowDataDir/$outputFile --idSQL \"$sql1\" --verbose";

  my $cmd2 = "dumpSequencesFromTable.pl --outputfile $workflowDataDir/$outputFile --idSQL \"$sql2\" --verbose";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test,$cmd1);
	  $self->runCmd($test,$cmd2);
      }
  }


}

sub getParamsDeclaration {
  my @properties =
    ('outputFile',
     'genomeExtDbRlsSpec',
     'genomeVirtualSeqsExtDbRlsSpec',
    );
  return @properties;
}

sub getConfigDeclaration {
  my @properties = 
    (
     # [name, default, description]
    );
  return @properties;
}



