package ApiCommonWorkflow::Main::WorkflowSteps::LoadChIPChipPeakFeature;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $substepClass = $self->getParamValue('substepClass');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $isfMappingFile = $self->getParamValue('isfMappingFile');

  my $gusHome = $self->getSharedConfig('gusHome');

  my ($seqExtDbName,$seqExtDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $workflowDataDir = $self->getWorkflowDataDir();
  
  my $algInvIds = $self->getAlgInvIds();

  my $soVersion = $self->getExtDbVersion($test, 'SO_RSRC');

  my $args = <<"EOF";
--extDbName '$extDbName'  \\
--extDbRlsVer '$extDbRlsVer' \\
--seqExtDbName '$seqExtDbName'  \\
--seqExtDbRlsVer '$seqExtDbRlsVer' \\
--mapFile $gusHome/lib/xml/isf/$isfMappingFile \\
--inputFileOrDir $workflowDataDir/$inputFile \\
--organism $ncbiTaxonId \\
--fileFormat gff2   \\
--gff2GroupTag ID \\
--seqIdColumn source_id \\
--soCvsVersion $soVersion \\
--naSequenceSubclass $substepClass \\
EOF

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();


  if ($undo){
      $self->runCmd($test,"ga GUS::Supported::Plugin::InsertSequenceFeaturesUndo --mapFile $gusHome/lib/xml/isf/$isfMappingFile --algInvocationId $algInvIds --workflowContext --commit");
  }else{
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      }else{
	  $self->runPlugin($test, 0,"GUS::Supported::Plugin::InsertSequenceFeatures", $args);
      }
  }

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


