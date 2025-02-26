package ApiCommonWorkflow::Main::WorkflowSteps::InsertGFF3;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;
    #get parameters
    my $copyFromDir = $self->getParamValue('inputsDir');
    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $experimentName = $self->getParamValue('experimentName');
    my $fileType = $self->getParamValue('fileType');
    my $gusConfigFile = $self->getParamValue('gusConfigFile');
    $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";
    my $workflowDataDir = $self->getWorkflowDataDir();

    my $gffFormat = substr($fileType, -1, 1);
    my $gffFile = "$workflowDataDir/$copyFromDir/${experimentName}.gff"
    my $args = "--file $gffFile --gff3DbName ${organismAbbrev}_${experimentName}_RSRC --gff3DbVer $version --gffFormat $gffFormat --seqExtDbName ${organismAbbrev}_primary_genome_RSRC --soExtDbSpec 'SO_RSRC|%' --gusConfigFile $gusConfigFile";
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGFF3", $args) if ($fileType =~ /^gff[123]$/);
}

1;
