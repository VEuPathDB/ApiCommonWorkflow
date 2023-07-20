package ApiCommonWorkflow::Main::WorkflowSteps::EdaFactory;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use ApiCommonWorkflow::Main::WorkflowSteps::RunPopbioEdaNextflow;
use ApiCommonWorkflow::Main::WorkflowSteps::RunClinEpiEdaNextflow;
use ApiCommonWorkflow::Main::WorkflowSteps::RunMBioEdaNextflow;
use ApiCommonWorkflow::Main::WorkflowSteps::RunMegaStudyEdaNextflow;

sub new {
  my $class = shift;

  # need to make an instance of the Factory class here to get the context
  my $self = $class->SUPER::new(@_);
  my $context = $self->getParamValue("context");

  my $rv;
  if($context eq 'popbio') {
      $rv = ApiCommonWorkflow::Main::WorkflowSteps::RunPopbioEdaNextflow->new(@_);
  }
  elsif($context eq 'mega') {
      $rv = ApiCommonWorkflow::Main::WorkflowSteps::RunMegaStudyEdaNextflow->new(@_);
  }
  elsif($context eq 'clinepi') {
      $rv = ApiCommonWorkflow::Main::WorkflowSteps::RunClinEpiEdaNextflow->new(@_);
  }
  elsif($context eq 'microbiome') {
      $rv = ApiCommonWorkflow::Main::WorkflowSteps::RunMBioEdaNextflow->new(@_);
  }
  # Other Genomics Contexts (popbio, ....)

  else {
      $self->error("Could not determine class for context $context:  Expected one or [popbio, mega, ...]");
  }

  return $rv;
}
