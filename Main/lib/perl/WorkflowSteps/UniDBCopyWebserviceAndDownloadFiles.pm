package ApiCommonWorkflow::Main::WorkflowSteps::UniDBCopyWebserviceAndDownloadFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $websiteFilesDir = $self->getSharedConfig('websiteFilesDir');

  my $workflowName = $self->getWorkflowConfig('name');
  my $workflowVersion = $self->getWorkflowConfig('version');

  my $componentProjectName = $self->getParamValue('componentProjectName');
  my $componentWorkflowVersion = $self->getParamValue('componentWorkflowVersion');

  my $relativeWebServicesDir = $self->getParamValue('relativeWebServicesDir');
  my $relativeDownloadSiteDir = $self->getParamValue('relativeDownloadSiteDir');
  my $relativeAuxiliaryDir = $self->getParamValue('relativeAuxiliaryDir');

  my $fromAuxiliaryDir = "$websiteFilesDir/$componentProjectName/$componentWorkflowVersion/real/auxiliary/$componentProjectName";
  my $fromDownloadSiteDir = "$websiteFilesDir/$componentProjectName/$componentWorkflowVersion/real/downloadSite/$componentProjectName";
  my $fromWebServicesDir = "$websiteFilesDir/$componentProjectName/$componentWorkflowVersion/real/webServices/$componentProjectName";

  my $toAuxiliaryDir = "$websiteFilesDir/$workflowName/$workflowVersion/real/$relativeAuxiliaryDir/$componentProjectName";
  my $toDownloadSiteDir = "$websiteFilesDir/$workflowName/$workflowVersion/real/$relativeDownloadSiteDir/$componentProjectName";
  my $toWebServicesDir = "$websiteFilesDir/$workflowName/$workflowVersion/real/$relativeWebServicesDir/$componentProjectName";

  my @directoryPairs = ([$fromAuxiliaryDir, $toAuxiliaryDir],
                        [$fromWebServicesDir, $toWebServicesDir],
                        [$fromDownloadSiteDir, $toDownloadSiteDir]);

  unless($test) {
    foreach $pair(@directoryPairs) {
      my $from = $pair->[0];
      my $to = $pair->[1];

      if($undo) {
        $self->runCmd($test, "rm -rf $to");
      }
      else {
        $self->runCmd($test, "cp -r $from $to");
      }
    }
  }

}

1;


