package ApiCommonWorkflow::Main::WorkflowSteps::MakeCoverageSnpsConfFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $samplesDataDir = $self->getParamValue("samplesDataDir");
  my $sampleNameList = $self->getParamValue("sampleNameList");
  my $outputFile = $self->getParamValue("outputFile");

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$outputFile");
  }else {

      my $coverageSnpsConfFile = "$workflowDataDir/$outputFile";
      open(F, ">$coverageSnpsConfFile") || die "Can't open file '$coverageSnpsConfFile' for writing";
      my $content;
      my @sampleNames = split (/;/,$sampleNameList);
      foreach my $sample (@sampleNames) {
	  $content .= "$workflowDataDir/$samplesDataDir/analyze${sample}/SNPs.cons\t$sample\n";
      }

      print F "$content";
       close(F);
  }
}

1;
