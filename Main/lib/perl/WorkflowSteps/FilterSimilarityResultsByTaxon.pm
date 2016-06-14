package ApiCommonWorkflow::Main::WorkflowSteps::FilterSimilarityResultsByTaxon;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# CAUTION: THIS STEP CLASS HAS BEEN HACKED
# TO COMPENSATE FOR AN ERROR IN THE GRAPH
# IT SHOULD BE FIXED ON NEXT REBUILD
#
# THE HACK: ignore the unfilteredOutputFile and filteredOutputFile params.
# instead, use ${inputFile}.filtered as the filtered file, and use inputFile as the unfiltered.
#
# WHEN WE DO A REBUILD: change this to take in:
#   - inputFile
#   - outputFile
#   - doNotFilterFlag  -- if true, don't filter, just cp the input file to the output file.
#   - lose unfiltered and filtered output file params
#
sub run {
  my ($self, $test, $undo) = @_;

  my $taxonList = $self->getParamValue('taxonHierarchy');
  my $inputFile = $self->getParamValue('inputFile');
  my $unfilteredOutputFile = $self->getParamValue('unfilteredOutputFile');
  my $filteredOutputFile = $self->getParamValue('filteredOutputFile');
  my $gi2taxidFile = $self->getParamValue('gi2taxidFile');
  my $inputFileType = $self->getParamValue('inputFileType');

  # HACK
  $filteredOutputFile = "$inputFile.filtered";

  $self->error("Parameter inputFileType=$inputFileType is invalid.  It must be either blat or blast") unless $inputFileType eq 'blat' || $inputFileType eq 'blastSim';

  $taxonList =~ s/\"//g if $taxonList;
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $gi2taxidFile = "$workflowDataDir/$gi2taxidFile";
  $self->runCmd(0, "gunzip $gi2taxidFile.gz") if (-e "$gi2taxidFile.gz");

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->runCmd(0, "gunzip $workflowDataDir/$inputFile.gz") if (-e "$workflowDataDir/$inputFile.gz");

# HACK: COMMENT OUT THIS LINE.
#  $self->runCmd(0,"cp $workflowDataDir/$inputFile $workflowDataDir/$unfilteredOutputFile");

  my $cmd = "splitAndFilterGenomeSimilarities";

  $cmd .= " --taxon \"$taxonList\" --gi2taxidFile $gi2taxidFile --inputFile $workflowDataDir/$inputFile --inputFileType $inputFileType --outputFile $workflowDataDir/$filteredOutputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$unfilteredOutputFile") if -e "$workflowDataDir/$unfilteredOutputFile";
    $self->runCmd(0, "rm -f $workflowDataDir/$filteredOutputFile");
  } else {  
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$filteredOutputFile");
      }
    $self->runCmd($test,$cmd);
  }
}

1;


