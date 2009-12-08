package ApiCommonWorkflow::Main::WorkflowSteps::UnpackExternalResource;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use GUS::Pipeline::ExternalResources::RepositoryEntry;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    my $dataSource = $self->getDataSource($dataSourceName);
    my $unpacks =  $dataSource->getUnpacks();
    my $unpackOutput =  $dataSource->getUnpackOutput();

    my $unpackers;
    if (ref($unpacks) eq 'ARRAY') {
	$unpackers = $unpacks;
    } else {
	$unpackers = [$unpacks];
    }
  
    map { _formatForCLI($_) } @$unpackers;

    if ($undo) {
      $self->runCmd(0, "rm -fr $targetDir/$unpackOutput");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo hello > $targetDir/$unpackOutput");
	}else{
	    foreach my $unpacker (@$unpackers) {
		if ($unpacker){  
		    GUS::Pipeline::ExternalResources::RepositoryEntry::runCmd($unpacker);
		  }
	    }
	}
    }
}


# remove line wrappings for command line processing
sub _formatForCLI {
    $_[0] =~ s/\\$//gm;
    $_[0] =~ s/[\n\r]+/ /gm;
}

sub getParamsDeclaration {
    return (
            'dataSourceName'
           );
}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



