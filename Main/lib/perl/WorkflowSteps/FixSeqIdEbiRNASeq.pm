package ApiCommonWorkflow::Main::WorkflowSteps::FixSeqIdEbiRNASeq;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $samplesDir = $self->getParamValue('samplesDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fullPath = "$workflowDataDir/$samplesDir";

  my $junctionsCmd = "awk '{if(NR==1) {print \$0} else{print \"${organismAbbrev}:\"\$0}}'";
  my $bedCmd = "awk '{print \"${organismAbbrev}:\"\$0}'";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$samplesDir/*/*.fixed.bed");
      $self->runCmd(0, "rm $workflowDataDir/$samplesDir/*/*.fixed.tab");
  } else {

    foreach my $bed (glob "$fullPath/*/*.bed") {
      my $fixedBed = $bed;
      $fixedBed =~ s/\.bed$/.fixed.bed/;
      $self->runCmd(0, "awk '{print \"${organismAbbrev}:\"\$0}' $bed >$fixedBed");
    }

    foreach my $junction (glob "$fullPath/*/junctions.tab") {
      my $fixedJunction = $junction;
      $fixedJunction =~ s/\.tab$/.fixed.tab/;
      $self->runCmd(0, "awk '{if(NR==1) {print \$0} else{print \"${organismAbbrev}:\"\$0}}' $junction >$fixedJunction");
    }

  }

}


1;
