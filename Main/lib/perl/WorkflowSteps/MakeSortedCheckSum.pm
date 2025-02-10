package ApiCommonWorkflow::Main::WorkflowSteps::MakeSortedCheckSum;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $proteomesDir = $self->getParamValue('proteomesDir');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my @inputs = glob "$workflowDataDir/$proteomesDir/*.fasta";
 
  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$proteomesDir/checkSum.tsv");
  }
  else {
    if($test) {
      $self->runCmd(0, "echo test > $workflowDataDir/$proteomesDir/checkSum.tsv");
    }
    else { 
      foreach my $inputFile (@inputs) {
        my $fileName = basename($inputFile);
        my $abbrev = $fileName;
        $abbrev =~ s/\.fasta//g;
        $self->runCmd(0, "singularity run docker://staphb/seqkit seqkit sort -i $inputFile > $workflowDataDir/$proteomesDir/$abbrev");
        $self->runCmd(0, "md5sum $workflowDataDir/$proteomesDir/$abbrev >> $workflowDataDir/$proteomesDir/unsortedCheckSum.tsv");
        my $backslashPath = "$workflowDataDir/$proteomesDir/";
	$backslashPath =~ s/\//\\\//g;
        $self->log("Sed command is sed -i \'s/${backslashPath}//g\' $workflowDataDir/$proteomesDir/unsortedCheckSum.tsv");
        $self->runCmd(0, "sed -i \'s/${backslashPath}//g\' $workflowDataDir/$proteomesDir/unsortedCheckSum.tsv");
        $self->runCmd(0, "rm $workflowDataDir/$proteomesDir/$abbrev");
      }
      $self->runCmd(0, "sort $workflowDataDir/$proteomesDir/unsortedCheckSum.tsv > $workflowDataDir/$proteomesDir/checkSum.tsv");
      $self->runCmd(0, "rm $workflowDataDir/$proteomesDir/unsortedCheckSum.tsv");
    }
  }
}

1;
