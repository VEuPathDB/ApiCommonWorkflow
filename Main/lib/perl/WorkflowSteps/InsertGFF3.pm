package ApiCommonWorkflow::Main::WorkflowSteps::InsertGFF3;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;
    #get parameters
    my $inputsDir = $self->getParamValue('inputsDir');
    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $relativeDir = $self->getParamValue('relativeDir');
    my $experimentResourceName = $self->getParamValue('experimentDatasetName');
    my $fileType = $self->getParamValue('fileType');
    my $websiteFilesDir = $self->getWebsiteFilesDir($test);
    my $gusConfigFile = $self->getParamValue('gusConfigFile');
    $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

    my $gffFile = "$workflowDataDir/$copyFromDir/$organismAbbrev_$experimentResourceName.gff";
    my $args = "--file $gffFile --gff3DbName $experimentResourceName --gff3DbVer $version --gffFormat $gffFormat --seqExtDbName ${organismAbbrev}_primary_genome_RSRC --soExtDbSpec 'SO_RSRC|%'";
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGFF3", $args);
}

1;
