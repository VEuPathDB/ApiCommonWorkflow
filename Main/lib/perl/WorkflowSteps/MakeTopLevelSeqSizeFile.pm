package ApiCommonWorkflow::Main::WorkflowSteps::MakeTopLevelSeqSizeFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();
  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

  my $sql = "select sa.source_id||chr(9)||ns.length
            from ApidbTuning.${tuningTablePrefix}sequenceattributes sa, dots.nasequence ns
            where sa.is_top_level = 1
            and sa.na_sequence_id = ns.na_sequence_id
            and sa.NCBI_TAX_ID = $ncbiTaxonId";
 

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,"makeFileWithSql --outFile $workflowDataDir/$outputFile --sql \"$sql\" --verbose");
  }
}

1;
