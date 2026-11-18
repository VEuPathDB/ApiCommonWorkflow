package ApiCommonWorkflow::Main::WorkflowSteps::LoadFileAttributes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Load a tab file (loadFileAttributes.pl format) into apidb.fileattributes.
# The script loads the whole file in one transaction: every row or none.
# The rows carry no row_alg_invocation_id, so undo deletes by build_num:
# every build present in the input file.

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getWorkflowDataDir() . "/" . $self->getParamValue('inputFile');
  my $gusConfigFile = $self->getGusConfigFile();

  if ($undo) {
    return if $test;
    my @builds = $self->getBuildNumbers($inputFile);
    my $sql = "DELETE FROM apidb.fileattributes WHERE build_num IN (" . join(',', @builds) . ")";
    $self->log("Running SQL: $sql\n");
    my $rows = $self->getDbh()->do($sql);
    $self->log("Deleted " . ($rows + 0) . " rows from apidb.fileattributes\n");
  } else {
    if (!$test) {
      $self->error("Input file '$inputFile' does not exist") unless -e $inputFile;
      $self->error("Input file '$inputFile' is empty") if -z $inputFile;
    }
    $self->runCmd($test, "loadFileAttributes.pl --gusConfigFile $gusConfigFile --input_file $inputFile");
  }
}

# distinct build_num values (column 5) in the input file
sub getBuildNumbers {
  my ($self, $inputFile) = @_;

  open(my $fh, '<', $inputFile) or $self->error("Can't open '$inputFile' to find its builds: $!");
  my %builds;
  while (my $line = <$fh>) {
    chomp $line;
    next unless $line;
    my $build = (split(/\t/, $line))[4];
    $self->error("Non-numeric build_num '$build' at line $. of '$inputFile'")
      unless defined $build && $build =~ /^\d+$/;
    $builds{$build} = 1;
  }
  close($fh);

  $self->error("No rows in '$inputFile'") unless %builds;
  return sort { $a <=> $b } keys %builds;
}

1;
