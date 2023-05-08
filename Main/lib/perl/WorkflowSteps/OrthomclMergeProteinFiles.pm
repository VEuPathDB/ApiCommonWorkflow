package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMergeProteinFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $proteomesDir = $self->getParamValue('proteomesDir');
  my $outputGoodProteinsFile = $self->getParamValue('outputGoodProteinsFile');
  my $outputBadProteinsFile = $self->getParamValue('outputBadProteinsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputGoodProteinsFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputBadProteinsFile");
  }
  elsif ($test) {
      $self->runCmd(0, "echo test> $workflowDataDir/$outputGoodProteinsFile");
      $self->runCmd(0, "echo test> $workflowDataDir/$outputBadProteinsFile");
  }
  else {
      opendir(DIR, $proteomesDir) || die "Can't open input directory '$proteomesDir'\n";
      my @goodFiles = readdir('DIR/*_CoreFromEbi_RSRC/good.fasta');
      my @badFiles = readdir('DIR/*_CoreFromEbi_RSRC/bad.fasta');
      closedir(DIR);

      die "Input directory $inputDir does not contain any files" unless scalar(@files);

      foreach my $file (@goodFiles) {
          system("cat $file >> $outputGoodProteinsFile");
      }

      foreach my $file (@badFiles) {
          system("cat $file >> $outputBadProteinsFile");
      }
  }

}

1;
