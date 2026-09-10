package ApiCommonWorkflow::Main::WorkflowSteps::RunNgsSamplesAndNextflow;

@ISA = (ReFlow::StepClasses::RunAndMonitorNextflow);

use strict;
use warnings;
use ReFlow::StepClasses::RunAndMonitorNextflow;

# ngs-samples-nextflow fetches the reads; the analysis workflow then consumes them.
# Both run from this single step so the pair holds one throttle slot: as separate
# steps the analysis had to re-queue behind other experiments' fetches.
sub ngsSamplesWorkflow { return "VEuPathDB/ngs-samples-nextflow" }

# Each run keeps its own job info, log, trace and stdout files.  Crash recovery
# depends on that: a re-entered step detects an already-finished run from its log
# and moves on to the next one.
sub nextflowRuns {
  my ($self) = @_;

  my @runs;

  # optional.  analyses with no samples to fetch leave it empty
  my $ngsSamplesConfigFile = $self->getParamValue("ngsSamplesNextflowConfigFile");

  push(@runs, { label                  => "ngs-samples",
                workflow               => $self->ngsSamplesWorkflow(),
                configFile             => $ngsSamplesConfigFile,
                resultsDir             => $self->getParamValue("ngsSamplesResultsDir"),
                entry                  => "",
                clusterJobInfoFileName => "ngs-samples-clusterJobInfo.txt",
                logFileName            => "ngs-samples-nextflow.log",
                traceFileName          => "ngs-samples-trace.txt",
                nextflowStdoutFileName => "ngs-samples-nextflow.txt",
              }) if $ngsSamplesConfigFile;

  push(@runs, { label                  => $self->getParamValue("nextflowWorkflow"),
                workflow               => $self->getParamValue("nextflowWorkflow"),
                configFile             => $self->getParamValue("nextflowConfigFile"),
                resultsDir             => $self->getParamValue("resultsDir"),
                entry                  => $self->getParamValue("entry"),
                clusterJobInfoFileName => $self->clusterJobInfoFileName(),
                logFileName            => $self->logFileName(),
                traceFileName          => $self->traceFileName(),
                nextflowStdoutFileName => $self->nextflowStdoutFileName(),
              });

  return @runs;
}

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterTransferServer = $self->getSharedConfig('clusterFileTransferServer');
  my $userName = $self->getSharedConfig("$clusterServer.clusterLogin");
  my $clusterQueue = $self->getSharedConfig("$clusterServer.clusterQueue");
  my $maxTimeMins = $self->getSharedConfig("$clusterServer.maxAllowedRuntimeDays") * 24 * 60;

  my $isGitRepo = $self->getBooleanParamValue("isGitRepo");

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $clusterWorkingDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath,
                                                                   $self->getParamValue("workingDir"));

  foreach my $nextflowRun ($self->nextflowRuns()) {

    my $clusterResultsDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath,
                                                                     $nextflowRun->{resultsDir});
    my $clusterNextflowConfigFile = $self->relativePathToNextflowClusterPath($workingDirRelativePath,
                                                                            $nextflowRun->{configFile});

    my $jobInfoFile = "$clusterWorkingDir/" . $nextflowRun->{clusterJobInfoFileName};
    my $logFile = "$clusterWorkingDir/" . $nextflowRun->{logFileName};
    my $traceFile = "$clusterWorkingDir/" . $nextflowRun->{traceFileName};
    my $nextflowStdoutFile = "$clusterWorkingDir/" . $nextflowRun->{nextflowStdoutFileName};

    if ($undo) {
      $self->runCmdOnClusterTransferServer(0, "rm -fr $clusterWorkingDir/work");
      $self->runCmdOnClusterTransferServer(0, "rm -fr $clusterResultsDir/*");
      $self->runCmdOnClusterTransferServer(0, "rm -fr $traceFile");
      $self->runCmdOnClusterTransferServer(0, "rm -fr $logFile");
      $self->runCmdOnClusterTransferServer(0, "rm -fr $nextflowStdoutFile");
      $self->log("Removing log file at: $logFile");
      next;
    }

    my $success = $self->runAndMonitor($test, $userName, $clusterServer, $clusterTransferServer,
                                       $jobInfoFile, $logFile, $nextflowStdoutFile, $clusterWorkingDir,
                                       $maxTimeMins, $clusterQueue, $nextflowRun->{workflow}, $isGitRepo,
                                       $clusterNextflowConfigFile, $nextflowRun->{entry});

    $self->error($self->nextflowFailureMessage($nextflowRun->{label}, $logFile, $traceFile)) unless $success;

    # remove the work directory
    $self->runCmdOnClusterTransferServer(0, "rm -fr $clusterWorkingDir/work");
  }
}

sub nextflowFailureMessage {
  my ($self, $label, $logFile, $traceFile) = @_;

  return
"
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
The '$label' nextflow run in this step did not successfully run.  Check its task
log file on the cluster:
  $logFile

If the task log file ends in a perl error, that suggests an unusual controller failure.  Often those are recoverable by setting the step to ready and trying again.

Otherwise, to diagnose the problem, look in the scheduler and nextflow step logs to see what command is executed on the nodes.  Find those logs at:
  $traceFile

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
";
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         );
}

1;
