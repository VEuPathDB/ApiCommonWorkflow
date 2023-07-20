package ApiCommonWorkflow::Main::WorkflowSteps::MakeBowtieMappingNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $preConfiguredDatabase = $self->getParamValue("preConfiguredDatabase");
    my $writeBedFile = $self->getParamValue("writeBedFile");
    my $hasPairedReads = $self->getParamValue("hasPairedReads");
    my $isColorSpace = $self->getParamValue("isColorSpace");
    my $removePCRDuplicates = $self->getParamValue("removePCRDuplicates");
    my $input = $self->getParamValue("input");
    my $downloadMethod = $self->getParamValue("downloadMethod");
    my $databaseFasta = $self->getParamValue("databaseFasta");
    my $databaseFileDir = $self->getParamValue("databaseFileDir");
    my $indexFileBasename = $self->getParamValue("indexFileBasename");
    my $mateAQual = $self->getParamValue("mateAQual");
    my $mateBQual = $self->getParamValue("mateBQual");
    my $sampleName = $self->getParamValue("sampleName");
  
    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  preconfiguredDatabase = $preConfiguredDatabase
  writeBedFile = $writeBedFile
  isSingleEnd = $isSingleEnd
  isColorSpace = $isColorSpace
  removePCRDuplicates = $removePCRDuplicates
  input = \"$input\"
  downloadMethod = \"$downloadMethod\"
  databaseFasta = \"$databaseFasta\"
  databaseFileDir = \"$databaseFileDir\"
  indexFileBasename = \"$indexFileBaseName\"
  mateAQual = \"$mateAQual\"
  mateBQual = \"$mateBQual\"
  outputDir = \"$outputDir\" 
  sampleName = \"$sampleName\" 
}
process {
  container = 'veupathdb/bowtiemapping'
}
singularity {
  enabled = true
}
";
	close(F);
    }
}

1;
