package ApiCommonWorkflow::Main::WorkflowSteps::ClonedEndToWebservices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $sourceIdField = $self->getParamValue('sourceIdField');
  my $sourceIdJoiningRegex = $self->getParamValue('sourceIdJoinRegex');
  my $spanLengthCutoff = $self->getParamValue('spanLengthCutoff');
  my $includeMultipleSpans = $self->getParamValue('includeMultipleSpans');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  my $dataDir = $self->getParamValue('dataDir');
  my $exteralDatabaseName = $self->getParamValue('externalDatabaseName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirectory = "${workflowDataDir}/$dataDir";

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/clonedInsertEnds/";

  my $fileBaseName = "${externalDatabaseName}";

  my $cmd = "clonedInsertEndsToGff.pl --external_database_name '$externalDatabaseName' --output_directory $workingDirectory --source_id_field $sourceIdField  --source_id_joining_regex '$sourceIdJoiningRegex' --span_length_cutoff $spanLengthCutoff --include_multiple_spans $includeMultipleSpans --gus_config $gusConfigFile";

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
      $self->runCmd($test, "cp $workingDirectory/${externalDatabaseName}.gz $copyToDir");
      $self->runCmd($test, "cp $workflowDataDir/${externalDatabaseName}.gz.tbi $copyToDir");
  }
}

1;
