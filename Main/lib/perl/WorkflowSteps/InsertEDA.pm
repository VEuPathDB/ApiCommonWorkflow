package ApiCommonWorkflow::Main::WorkflowSteps::InsertEDA;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use feature "switch";

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

  my %paramSet = (
    'ApiCommonData::Load::Plugin::InsertEntityGraph' => [ qw/
      commit
      dateObfuscationFile
      extDbRlsSpec
      investigationBaseName
      isSimpleConfiguration
      metaDataRoot
      ontologyMappingFile
      ontologyMappingOverrideFileBaseName
      valueMappingFile
      / ],
   'ApiCommonData::Load::Plugin::LoadAttributesFromEntityGraph' => [ qw/ 
     commit
     extDbRlsSpec
     logDir
     ontologyExtDbRlsSpec
      / ],
    'ApiCommonData::Load::Plugin::LoadEntityTypeAndAttributeGraphs' => [ qw/
      commit
      extDbRlsSpec
      logDir
      ontologyExtDbRlsSpec
      / ],
    'ApiCommonData::Load::Plugin::LoadDatasetSpecificEntityGraph' => [ qw/
      commit
      extDbRlsSpec
      / ],
  );



sub run {
  my ($self, $test, $undo) = @_;

  my $plugin = $self->getParamValue("plugin");

  my %params;
  
  foreach my $param (@{$paramSet{$plugin}}){
    given($param){
      when ('commit') {
		  	$params{'commit'} = $test ? 0 : 1;
      }
      when ('dateObfuscationFile') {
		  	$params{'dateObfuscationFile'} = $self->getMetadataPath("dateObfuscation.txt");
      }
      when ('extDbRlsSpec') {
		  	$params{'extDbRlsSpec'} = $self->getParamValue('extDbRlsSpec');
        $params{'extDbRlsSpec'} =~ s/[|]/\\|/g;
      }
      when ('investigationBaseName') {
		  	$params{'investigationBaseName'} = "investigation.xml";
      }
      when ('isSimpleConfiguration') {
		  	$params{'isSimpleConfiguration'} = "1";
      }
      when ('logDir') {
		  	$params{'logDir'} = $self->getStepDir();
      }
      when ('metaDataRoot') {
		  	$params{'metaDataRoot'} = $self->getMetadataPath();
      }
      when ('ontologyExtDbRlsSpec') {
		  	$params{'ontologyExtDbRlsSpec'} = sprintf( "OntologyTerm_%s_RSRC\\|dontcare",$self->getParamValue('webDisplayOntologyName'));
      }
      when ('ontologyMappingFile') {
		  	$params{'ontologyMappingFile'} = sprintf("%s/ontology/release/production/%s.owl", $ENV{GUS_HOME}, $self->getParamValue('webDisplayOntologyName'));
      }
      when ('ontologyMappingOverrideFileBaseName') {
		  	$params{'ontologyMappingOverrideFileBaseName'} = "ontologyMapping.xml";
      }
      when ('valueMappingFile') {
		  	$params{'valueMappingFile'} = $self->getMetadataPath("valueMap.txt");
      }
    }
  }
  
  

  unless($paramSet{$plugin}){ die "Plugin $plugin not supported\n" }

  my $args = join(" ", map { sprintf("--%s %s", $_, $params{$_}) } @{$paramSet{$plugin}} );
  
  $self->runPlugin($test, $undo, $plugin, $args);
}

sub getMetadataPath {
  my ($self, @args) = @_;
  return join("/", $self->getWorkflowDataDir(), $self->getParamValue("dataDir"), @args);
}


1;

