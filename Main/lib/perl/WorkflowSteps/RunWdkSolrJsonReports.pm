package ApiCommonWorkflow::Main::WorkflowSteps::RunWdkSolrJsonReports;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


# runWdkReports organism pfal3d7 "http://localhost:7781" ~/junk/solr-batches --paramName organismAbbrev --paramValue "pfal3D7"
sub run {
    my ($self, $test, $undo) = @_;

    my $batchType = $self->getParamValue('batchType');
    my $batchName = $self->getParamValue('batchName');
    my $outputDir = $self->getParamValue('outputDir');
    my $paramName = $self->getParamValue('paramName');
    my $paramValue = $self->getParamValue('paramValue');

    my $paramStr = "";

    if ($paramName ne "" && $paramValue ne "") {
      $paramStr = " --paramName $paramName --paramValue $paramValue";
    }
    elsif !($paramName eq "" && $paramValue eq "") {
      $self->error("parameters 'paramName' and 'paramValue' must both either be empty or provided together");
    }

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "runWdkReports $batchType $batchName 'http://localhost:7781' $outputDir $paramStr";

    if ($undo) {
	$self->runCmd(0, "rm -f $outputDir/solr-json-batch_$batchType_$batchName_*");  # we don't know the timestamp, so use wildcard
    } else {
      if ($test) {
        $self->runCmd(0,"echo test > $outputDir/solr-json-batch_$batchType_$batchName_" + time);
      }
      $self->runCmd($test, $cmd);
    }
}

1;

