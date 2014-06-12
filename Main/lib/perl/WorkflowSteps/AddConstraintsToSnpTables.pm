package ApiCommonWorkflow::Main::WorkflowSteps::AddConstraintsToSnpTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusInstance = $self->getGusInstanceName();
  my $gusLogin = $self->getGusDatabaseLogin();
  my $gusPassword = $self->getGusDatabasePassword();

  my $cmd = "sqlplus $gusLogin/$gusPassword\@$gusInstance \@$ENV{GUS_HOME}/lib/sql/apidbschema/addConstraintsAndIndexesToSnpTables.sql ";

  if ($undo) {
    # must undo the parent
  } else {
      $self->runCmd($test, $cmd);
  }
}

1;
