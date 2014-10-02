package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrfFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $substepClass = $self->getParamValue('substepClass');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $isfMappingFile = $self->getParamValue('isfMappingFile');

  my $ncbiTaxId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $gusHome = $self->getSharedConfig('gusHome');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $algInvIds = $self->getAlgInvIds();

# TODO:  SO_RSRC is hardcoded here; Should be passed down;

  my $args = <<"EOF";
--extDbName '$extDbName'  \\
--extDbRlsVer '$extDbRlsVer' \\
--mapFile $gusHome/lib/xml/isf/$isfMappingFile \\
--inputFileOrDir $workflowDataDir/$inputFile \\
--fileFormat gff3   \\
--seqSoTerm ORF  \\
--soExtDbSpec 'SO_RSRC|%' \\
--naSequenceSubclass $substepClass \\
--organism $ncbiTaxId \\
EOF

  if ($undo){
      $self->runCmd($test,"ga GUS::Supported::Plugin::InsertSequenceFeaturesUndo --mapFile $gusHome/lib/xml/isf/$isfMappingFile --algInvocationId $algInvIds --workflowContext --commit");
  }else{
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    $self->runPlugin($test, 0,"GUS::Supported::Plugin::InsertSequenceFeatures", $args);
  }

}


1;

