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

  if ($undo) {
      foreach my $bed (glob "$fullPath/*RR*/*.bed") {
        my $oldBed = "$bed.old";
        $self->runCmd(0, "rm $bed");
        $self->runCmd(0, "mv $oldBed $bed");
      }
      foreach my $junctions (glob "$fullPath/*RR*/junctions.tab") {
        my $oldJunctions = "$junctions.old";
        $self->runCmd(0, "rm $junctions");
        $self->runCmd(0, "mv $oldJunctions $junctions");
      }

  } else {

    foreach my $bed (glob "$fullPath/*/*.bed") {
      my $oldBed = "$bed.old";
      $self->runCmd(0, "mv $bed $oldBed");
      $self->runCmd(0, "awk '{print \"${organismAbbrev}_\"\$0}' $oldBed >$bed");
    }

    foreach my $junction (glob "$fullPath/*/junctions.tab") {
      my $oldJunction = "$junction.old";
      $self->runCmd(0, "mv $junction $oldJunction");
      $self->runCmd(0, "awk '{if(NR==1) {print \$0} else{print \"${organismAbbrev}_\"\$0}}' $oldJunction >$junction");
    }

  }

}


1;
