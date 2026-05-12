package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndUncompressUpdatePeripheralCacheDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Stages all files needed from the peripheral officialDiamondCache into the
# update peripheral working directory before the update workflow runs.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $cacheDir = join("/", $self->getSharedConfig('preprocessedDataCache'), "OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache");
  my $fullOutputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $fullOutputDir/peripheralCacheDir");
      $self->runCmd(0, "rm -f $fullOutputDir/GroupsFile.txt");
      $self->runCmd(0, "rm -f $fullOutputDir/coreBestReps.txt");
      $self->runCmd(0, "rm -f $fullOutputDir/coreBestReps.fasta");
      $self->runCmd(0, "rm -f $fullOutputDir/fullProteome.fasta");
      $self->runCmd(0, "rm -f $fullOutputDir/reformattedResidualGroups.txt");
      $self->runCmd(0, "rm -f $fullOutputDir/residualBestReps.fasta");
      $self->runCmd(0, "rm -f $fullOutputDir/residuals.fasta");
      $self->runCmd(0, "rm -rf $fullOutputDir/residualGroupFastas");
      $self->runCmd(0, "rm -f $fullOutputDir/previousGroups.txt");
  }
  elsif ($test) {
      $self->runCmd(0, "mkdir -p $fullOutputDir/peripheralCacheDir");
      $self->runCmd(0, "mkdir -p $fullOutputDir/residualGroupFastas");
  }
  else {
      # Extract peripheral diamond blast cache for existing organisms
      $self->runCmd(0, "cp ${cacheDir}/peripheralCacheDir.tar.gz $fullOutputDir/peripheralCacheDir.tar.gz");
      $self->runCmd(0, "tar -xzf $fullOutputDir/peripheralCacheDir.tar.gz -C $fullOutputDir");
      $self->runCmd(0, "rm $fullOutputDir/peripheralCacheDir.tar.gz");
      die "$fullOutputDir/peripheralCacheDir does not exist" unless(-e "$fullOutputDir/peripheralCacheDir");

      # Full core+peripheral groups file (base for appending new peripheral assignments)
      $self->runCmd(0, "cp ${cacheDir}/GroupsFile.txt $fullOutputDir/GroupsFile.txt");

      # Best representative text file (seqID -> groupID); stats are recalculated
      # using these existing reps rather than recomputing them from scratch
      $self->runCmd(0, "cp ${cacheDir}/coreBestReps.txt $fullOutputDir/coreBestReps.txt");

      # Best representative fasta (group ID as defline); consumed by postUpdateEntry
      $self->runCmd(0, "cp ${cacheDir}/coreBestReps.fasta $fullOutputDir/coreBestReps.fasta");

      # Full proteome (core + all current peripheral) for combining with new peripheral sequences
      $self->runCmd(0, "cp ${cacheDir}/fullProteome.fasta $fullOutputDir/fullProteome.fasta");

      # Residual groups from previous postResidual run (OGR prefix); staged under a
      # distinct name so it does not collide with the core reformattedGroups.txt
      $self->runCmd(0, "cp ${cacheDir}/reformattedGroups.txt $fullOutputDir/reformattedResidualGroups.txt");

      # Residual best reps fasta for merging in postUpdate
      $self->runCmd(0, "cp ${cacheDir}/residualBestReps.txt $fullOutputDir/residualBestReps.fasta");

      # Combined residuals fasta for merging in postUpdate
      $self->runCmd(0, "cp ${cacheDir}/residuals.fasta $fullOutputDir/residuals.fasta");

      # Residual per-group fastas for postUpdate gene tree filtering
      $self->runCmd(0, "cp -r ${cacheDir}/residualGroupFastas $fullOutputDir/");

      # Previous groups mapping for tracking group changes across builds
      $self->runCmd(0, "cp ${cacheDir}/previousGroups.txt $fullOutputDir/previousGroups.txt");
  }
}

1;
