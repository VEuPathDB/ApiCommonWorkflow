package ApiCommonWorkflow::Main::WorkflowSteps::AssociateGenesWithDbXrefs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $entrezGeneInfoFile = $self->getParamValue('entrezGeneInfoFile');
  my $gene2pubmedFile = $self->getParamValue('gene2pubmedFile');
  my $uniprotIdMappingDbFile = $self->getParamValue('uniprotIdMappingDbFile');
  my $ncbiTaxId = $self->getParamValue('ncbiTaxId');
  my $speciesNcbiTaxonId = $self->getParamValue('speciesNcbiTaxonId');
  my $outputDir = $self->getParamValue('outputDir');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  # Test input files exist
  $self->testInputFile('entrezGeneInfoFile', "$workflowDataDir/$entrezGeneInfoFile");
  $self->testInputFile('gene2pubmedFile', "$workflowDataDir/$gene2pubmedFile");
  $self->testInputFile('uniprotIdMappingDbFile', "$workflowDataDir/$uniprotIdMappingDbFile");

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$outputDir");
    return;
  }

  # Create output directory if it doesn't exist
  $self->runCmd($test, "mkdir -p $workflowDataDir/$outputDir");

  # Build the command to run the script
  my $cmd = "associateGenesWithDbXrefs"
    . " --geneInfoDb '$workflowDataDir/$entrezGeneInfoFile'"
    . " --gene2pubmedDb '$workflowDataDir/$gene2pubmedFile'"
    . " --idMappingDb '$workflowDataDir/$uniprotIdMappingDbFile'"
    . " --taxId '$ncbiTaxId'"
    . " --speciesTaxId '$speciesNcbiTaxonId'"
    . " --outputDir '$workflowDataDir/$outputDir'"
    . " --gusConfigFile '$workflowDataDir/$gusConfigFile'";

  $self->runCmd($test, $cmd);
}

1;
