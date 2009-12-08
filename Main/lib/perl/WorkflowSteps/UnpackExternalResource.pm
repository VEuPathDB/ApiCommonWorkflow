package ApiCommonWorkflow::Main::WorkflowSteps::UnpackExternalResource;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use GUS::Pipeline::ExternalResources::RepositoryEntry;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    $self->{dataSource} = $self->getDataSource($dataSourceName);
    my $WgetArgs=  $self->{dataSource}->getWgetArgs();
    my $unpacks =  $self->{dataSource}->getUnpacks();
    my $unpackOutput =  $self->{dataSource}->getUnpackOutput();

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
		    $self->runCmd($test,$unpacker);
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



