
package ApiCommonWorkflow::Main::WorkflowSteps::MakeSeqSizeFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  #my $gusConfigFile = $self->getGusConfigFile();
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNcbiTaxonId();
  my $tuningTablePrefix = $self->getTuningTablePrefix($test, $organismAbbrev, $gusConfigFile);

  my $sql = "select sa.source_id||chr(9)||ns.length
            from ApidbTuning.${tuningTablePrefix}GenomicSeqAttributes sa, dots.nasequence ns
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
      $self->runCmd($test,"makeFileWithSql --outFile $workflowDataDir/$outputFile --sql \"$sql\"  --gusConfigFile $gusConfigFile --verbose");
  }
}

1;
