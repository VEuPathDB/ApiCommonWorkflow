package ApiCommonWorkflow::Main::WorkflowSteps::ClonedEndToWebservices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $sourceIdField = $self->getParamValue('sourceIdField');
  my $sourceIdJoiningRegex = $self->getParamValue('sourceIdJoiningRegex');
  my $spanLengthCutoff = $self->getParamValue('spanLengthCutoff');
  my $includeMultipleSpans = $self->getParamValue('includeMultipleSpans');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $dataDir = $self->getParamValue('dataDir');
  my $externalDatabaseName = $self->getParamValue('externalDatabaseName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeWebServicesDir = $self->getParamValue('relativeWebServicesDir');
  my $dataType = $self->getParamValue('dataType');
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirectory = "${workflowDataDir}/$dataDir";

  my $copyToDir = "$websiteFilesDir/$relativeWebServicesDir/$organismNameForFiles/$dataType/gff/";

  my $cmd = "clonedInsertEndsToGff.pl --external_database_name '$externalDatabaseName' --output_directory $workingDirectory --source_id_field $sourceIdField  --source_id_joining_regex '$sourceIdJoiningRegex' --span_length_cutoff $spanLengthCutoff --include_multiple_spans $includeMultipleSpans --gus_config $gusConfigFile --output_file_base $externalDatabaseName";

  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/${externalDatabaseName}*");
    $self->runCmd(0, "rm -f $workingDirectory/${externalDatabaseName}*");

  } else{
      if($test){
          $self->runCmd(0, "echo test > $copyToDir/${externalDatabaseName}.gff.gz ");
          $self->runCmd(0, "echo test > $copyToDir/${externalDatabaseName}.gff.gz.tbi");

          $self->runCmd(0, "echo test > $workingDirectory/${externalDatabaseName}.gff.gz ");
          $self->runCmd(0, "echo test > $workingDirectory/${externalDatabaseName}.gff.gz.tbi");
      }

      $self->runCmd($test, $cmd);
      $self->runCmd($test, "cp $workingDirectory/${externalDatabaseName}.gff.gz $copyToDir");
      $self->runCmd($test, "cp $workingDirectory/${externalDatabaseName}.gff.gz.tbi $copyToDir");
  }
}

1;
