package ApiCommonWorkflow::Main::WorkflowSteps::RunWdkSolrJsonReports;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


# runWdkReports organism pfal3d7 "http://localhost:7781" ~/junk/solr-batches --paramName organismAbbrev --paramValue "pfal3D7"
sub run {
    my ($self, $test, $undo) = @_;

    my $batchType = $self->getParamValue('batchType');
    my $batchName = $self->getParamValue('batchName');
    my $relativeOutputDir = $self->getParamValue('relativeOutputDir');  # relative to web services dir
    my $paramName = $self->getParamValue('paramName');
    my $paramValue = $self->getParamValue('paramValue');

    my $outputDirFullPath = $self->getWebsiteFilesDir($test) + "/$relativeOutputDir";

    my $paramStr = "";

    if ($paramName ne "" && $paramValue ne "") {
      $paramStr = " --paramName $paramName --paramValue $paramValue";
    }
    #need Steve to fix it
    #elsif !($paramName eq "" && $paramValue eq "") {
    #  $self->error("parameters 'paramName' and 'paramValue' must both either be empty or provided together");
    #}

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "/usr/bin/python3 $ENV{GUS_HOME}/bin/runWdkReports $batchType $batchName 'http://localhost:7781' $outputDirFullPath $paramStr";

    if ($undo) {
	$self->runCmd(0, "rm -f $outputDirFullPath/solr-json-batch_${batchType}_${batchName}_*");  # we don't know the timestamp, so use wildcard
    } else {
      if ($test) {
        $self->runCmd(0,"mkdir $outputDirFullPath/solr-json-batch_${batchType}_${batchName}_" + time);
      }
      $self->runCmd($test, $cmd);
    }
}

1;

