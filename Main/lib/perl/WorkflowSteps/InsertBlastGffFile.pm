package ApiCommonWorkflow::Main::WorkflowSteps::InsertBlastGffFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $extDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $substepClass = $self->getParamValue('substepClass');
  my $defaultOrg = $self->getParamValue('defaultOrg');
  my $isfMappingFileRelToGusHome = $self->getParamValue('isfMappingFileRelToGusHome');
  my $soVersion = $self->getParamValue('soVersion');

  my $gusHome = $self->getSharedConfig('gusHome');

  my ($seqExtDbName,$seqExtDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();
  
  my $algInvIds = $self->getAlgInvIds();

  my $args = <<"EOF";
--extDbName '$extDbName'  \\
--extDbRlsVer '$extDbRlsVer' \\
--seqExtDbName '$extDbName'  \\
--seqExtDbRlsVer '$extDbRlsVer' \\
--mapFile $gusHome/$isfMappingFileRelToGusHome \\
--inputFileOrDir $workflowDataDir/$inputFile \\
--fileFormat gff2   \\
--gff2GroupTag ID \\
--seqIdColumn source_id \\
--soCvsVersion $soVersion \\
--naSequenceSubclass $substepClass \\
EOF
  if ($defaultOrg) {
    $args .= "--defaultOrganism '$defaultOrg'";
  }



  if ($undo){
      $self->runCmd($test,"ga GUS::Supported::Plugin::InsertSequenceFeaturesUndo --mapFile $gusHome/$isfMappingFileRelToGusHome --algInvocationId $algInvIds --workflowContext --commit");
  }else{


    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

    $self->runPlugin($test, 0,"GUS::Supported::Plugin::InsertSequenceFeatures", $args);

  }

}


1;

