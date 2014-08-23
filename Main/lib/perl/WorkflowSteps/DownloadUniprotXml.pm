package ApiCommonWorkflow::Main::WorkflowSteps::DownloadUniprotXml;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFastaFile = $self->getParamValue('outputFastaFile');
  my $outputEcFile = $self->getParamValue('ouputEcFile');
  my $reviewedStatus = $self->getParamValue('reviewedStatus');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $taxonFile = $self->getStepDir() . "/taxa.dat";

  if ($undo) {
    $self->runCmd(0, "rm $workflowDataDir/$outputFastaFile") if -e "$workflowDataDir/$outputFastaFile";
    $self->runCmd(0, "rm $workflowDataDir/$outputEcFile") if -e "$workflowDataDir/$outputEcFile";
    $self->runCmd(0, "rm $workflowDataDir/$taxonFile") if -e "$workflowDataDir/$taxonFile";
  } else {
    my $xmlFile = $self->getStepDir() . "/uniprot.xml";
    my $logFile = $self->getStepDir() . "/wget.log";
    my $cmd = "wget -O $xmlFile 'http://www.uniprot.org/uniprot/?query=reviewed%3ayes+AND+ec%3a*&sort=score&format=xml'";
    $self->runCmd($test, $cmd);
    unless ($test){
      my $wgetLogTail = $self->runCmd($test, "tail -2 $logFile|grep -i '[saved|FINISHED]'");
      $self->error ("Wget did not successfully run. Check log file: $logFile\n") unless ($wgetLogTail);
    }

    ## find distinct ncbi taxon ids in externalaasequence,to limit uniprot to those
    $cmd = "apiFindNcbiTaxonIds $taxonFile";
    $self->runCmd($test, $cmd);

    $cmd = "uniprotXmlToFasta -xmlFile uniprot.xml -taxonFile $taxonFile -fastaFile $workflowDataDir/$outputFastaFile -ecMappingFile $workflowDataDir/$outputEcFile";
    $self->runCmd($test, $cmd);
    if ($test) {
      $self->runCmd(0, "touch $workflowDataDir/$outputEcFile");
      $self->runCmd(0, "touch $workflowDataDir/$outputFastaFile");
    }
  }
}

1;
