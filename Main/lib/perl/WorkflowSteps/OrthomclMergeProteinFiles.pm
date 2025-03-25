package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMergeProteinFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $outputGoodProteinsFile = join("/", $workflowDataDir, $self->getParamValue('outputGoodProteinsFile'));
  my $outputBadProteinsFile = join("/", $workflowDataDir, $self->getParamValue('outputBadProteinsFile'));
  my $proteomesDir = join("/", $workflowDataDir, $self->getParamValue("proteomesDir"));

  if ($undo) {
      $self->runCmd(0, "rm -f $outputGoodProteinsFile");
      $self->runCmd(0, "rm -f $outputBadProteinsFile");
  }
  elsif ($test) {
      $self->runCmd(0, "echo test> $outputGoodProteinsFile");
      $self->runCmd(0, "echo test> $outputBadProteinsFile");
  }
  else {

      opendir(DIR, $proteomesDir) || die "Can't open input directory '$proteomesDir'\n";
          my @directories = readdir('DIR');
      closedir(DIR);

      die "Input directory $proteomesDir does not contain any files" unless scalar(@directories);

      foreach my $directory (@directories) {
	  if ($directory ne '.' && $directory ne '..') {
	      system("cat ${proteomesDir}/${directory}/*_good.fasta >> $outputGoodProteinsFile");
	      system("cat ${proteomesDir}/${directory}/*_bad.fasta >> $outputBadProteinsFile");
	  }
      }

  }

}

1;
