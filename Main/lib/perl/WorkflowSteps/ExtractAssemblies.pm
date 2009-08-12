package ApiCommonWorkflow::Main::WorkflowSteps::ExtractAssemblies;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $outputFile = $self->getParamValue('outputFile');

  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$ncbiTaxonId);

  my $sql = "select na_sequence_id,description,'('||number_of_contained_sequences||' sequences)','length='||length,sequence from dots.Assembly where taxon_id = $taxonId";

  my $localDataDir = $self->getLocalDataDir();

  my $cmd = "gusExtractSequences --outputFile $localDataDir/$outputFile --verbose --idSQL \"$sql\"";

  if ($undo) {
    $self->runCmd(0, "rm -f $localDataDir/$outputFile");
  } else {
      if ($test){
	  $self->runCmd(0, "echo test > $localDataDir/$outputFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }

}

sub getParamsDeclaration {
  return ('ncbiTaxonId',
	  'outputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

