package ApiCommonWorkflow::Main::WorkflowSteps::LoadIntronFeature;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $rnaSeqExtDbRlsSpec = $self->getParamValue('rnaSeqExtDbRlsSpec');
  my $isfMappingFileRelToGusHome = $self->getParamValue('isfMappingFileRelToGusHome');
  my $soVersion = $self->getParamValue('soVersion');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbSpec');

  my $gusHome = $self->getSharedConfig('gusHome');

  my ($seqExtDbName,$seqExtDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$rnaSeqExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();
  
  my $algInvIds = $self->getAlgInvIds();

  my $args = <<"EOF";
--extDbName '$extDbName'  \\
--extDbRlsVer '$extDbRlsVer' \\
--mapFile $gusHome/$isfMappingFileRelToGusHome \\
--inputFileOrDir $workflowDataDir/$inputFile \\
--fileFormat gff2   \\
--gff2GroupTag ID  \\
--seqIdColumn source_id \\
--seqExtDbName $seqExtDbName \\
--seqExtDbRlsVer $seqExtDbRlsVer \\
--soCvsVersion $soVersion \\
--naSequenceSubclass ExternalNASequence \\
EOF

  if ($undo){
      $self->runCmd($test,"ga GUS::Supported::Plugin::InsertSequenceFeaturesUndo --mapFile $gusHome/$isfMappingFileRelToGusHome --algInvocationId $algInvIds --workflowContext --commit");
  }else{
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      }else{
	  $self->runPlugin($test, 0,"GUS::Supported::Plugin::InsertSequenceFeatures", $args);
      }
  }

}


sub getParamsDeclaration {
  return (
	  'inputFile',
	  'genomeExtDbRlsSpec',
	  'substepClass',
	  'defaultOrg',
	  'isfMappingFileRelToGusHome',
	  'soVersion',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


