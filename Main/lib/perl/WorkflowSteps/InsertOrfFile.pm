package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrfFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $substepClass = $self->getParamValue('substepClass');
  my $ncbiTaxId = $self->getParamValue('ncbiTaxonId');
  my $isfMappingFile = $self->getParamValue('isfMappingFile');
  my $soVersion = $self->getParamValue('soVersion');

  my $gusHome = $self->getSharedConfig('gusHome');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $algInvIds = $self->getAlgInvIds();

  my $args = <<"EOF";
--extDbName '$extDbName'  \\
--extDbRlsVer '$extDbRlsVer' \\
--mapFile $gusHome/lib/xml/isf/$isfMappingFile \\
--inputFileOrDir $workflowDataDir/$inputFile \\
--fileFormat gff3   \\
--seqSoTerm ORF  \\
--soCvsVersion $soVersion \\
--naSequenceSubclass $substepClass \\
--organism $ncbiTaxId \\
EOF

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


sub getParamsDeclaration {
  return (
	  'inputFile',
	  'genomeExtDbRlsSpec',
	  'substepClass',
	  'defaultOrgTaxId',
	  'isfMappingFileRelToGusHome',
	  'soVersion',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


