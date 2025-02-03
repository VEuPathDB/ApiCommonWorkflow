package ApiCommonWorkflow::Main::WorkflowSteps::TranscriptSequencesToWebservices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $dataDir = $self->getParamValue('dataDir');
  my $queryExtDbSpec = $self->getParamValue('queryExtDbRlsSpec');
  my $targetExtDbSpec = $self->getParamValue('targetExtDbRlsSpec');


  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeWebServicesDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirectory = "${workflowDataDir}/$dataDir";

  my $copyToDir = "$websiteFilesDir/$relativeWebServicesDir/$organismNameForFiles/genomeAndProteome/gff/";

  my ($queryExtDbName, $queryExtDbVer) = split(/\|/, $queryExtDbSpec);

  my $outputFileBase;

  my $cmd = "alignedTranscriptSeqsToGff.pl --output_directory $workingDirectory --gus_config $gusConfigFile --target_ext_db_rls_spec '${targetExtDbSpec}' ";
  if($queryExtDbSpec) {
    $outputFileBase = $queryExtDbName;

    $cmd = $cmd . " --output_file_base $outputFileBase  --query_ext_db_rls_spec '${queryExtDbSpec}'";
  }
  # Else ESTs
  else {
    $outputFileBase = "${organismAbbrev}_ESTs";
    $cmd = $cmd . "--output_file_base $outputFileBase --is_est";
  }


  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/${outputFileBase}*");
    $self->runCmd(0, "rm -f $workingDirectory/${outputFileBase}*");

  } else{
      if($test){
          $self->runCmd(0, "echo test > $copyToDir/${outputFileBase}.gff.gz ");
          $self->runCmd(0, "echo test > $copyToDir/${outputFileBase}.gff.gz.tbi");

          $self->runCmd(0, "echo test > $workingDirectory/${outputFileBase}.gff.gz ");
          $self->runCmd(0, "echo test > $workingDirectory/${outputFileBase}.gff.gz.tbi");
      }

      $self->runCmd($test, $cmd);
      $self->runCmd($test, "cp $workingDirectory/${outputFileBase}.gff.gz $copyToDir");
      $self->runCmd($test, "cp $workingDirectory/${outputFileBase}.gff.gz.tbi $copyToDir");
  }
}

1;
