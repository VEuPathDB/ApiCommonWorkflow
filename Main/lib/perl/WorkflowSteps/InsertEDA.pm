package ApiCommonWorkflow::Main::WorkflowSteps::InsertEDA;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use feature "switch";
use File::Basename qw/dirname/;
use Fcntl qw(:flock LOCK_EX LOCK_UN);

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

  # Each of these lists are the list of arguments for each plugin
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
      schema
      / ],
   'ApiCommonData::Load::Plugin::LoadAttributesFromEntityGraph' => [ qw/ 
     commit
     extDbRlsSpec
     logDir
     ontologyExtDbRlsSpec
      schema
      __FLOCK__
      / ],
    'ApiCommonData::Load::Plugin::LoadEntityTypeAndAttributeGraphs' => [ qw/
      commit
      extDbRlsSpec
      logDir
      ontologyExtDbRlsSpec
      schema
      / ],
    'ApiCommonData::Load::Plugin::LoadDatasetSpecificEntityGraph' => [ qw/
      commit
      extDbRlsSpec
      schema
      / ],
    'ApiCommonData::Load::Plugin::MakeEntityDownloadFiles' => [ qw/
      extDbRlsSpec
      ontologyExtDbRlsSpec
      outputDir
      fileBasename
      schema
      / ],
    'ApiCommonData::Load::Plugin::InsertEntityStudy' => [ qw/
      commit
      extDbRlsSpec
      stableId
      schema
      / ],
  );



sub run {
  my ($self, $test, $undo) = @_;

  my $plugin = $self->getParamValue("plugin");

  my %params;

  my $lockfile = '';
  
  foreach my $param (@{$paramSet{$plugin}}){
    given($param){
      when ('__FLOCK__'){
        my ($lfbase) = ( $plugin =~ /ApiCommonData::Load::Plugin::(.*)/ );
        $lockfile = sprintf("%s/%s.lock", dirname($self->getStepDir()),$lfbase);
      }
      when ('commit') {
		  	$params{'commit'} = $test ? 0 : 1;
      }
      when ('dateObfuscationFile') {
		  	$params{'dateObfuscationFile'} = $self->getMetadataPath($self->getParamValue($param));
      }
      when ('extDbRlsSpec') {
		  	$params{'extDbRlsSpec'} = $self->getParamValue('extDbRlsSpec');
        $params{'extDbRlsSpec'} =~ s/[|]/\\|/g;
      }
      when ('investigationBaseName') {
		  	$params{'investigationBaseName'} = $self->getParamValue($param);
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
		  	$params{'ontologyMappingOverrideFileBaseName'} = $self->getParamValue($param);
      }
      when ('valueMappingFile') {
		  	$params{'valueMappingFile'} = $self->getMetadataPath($self->getParamValue($param));
      }
      when ('outputDir') {
		  	$params{'outputDir'} = $self->getMetadataPath($self->getParamValue('outputDir'));
      }
      when ('schema') {
		    $params{'schema'} = $self->getParamValue('schema');
      }
      when ('stableId') {
		    $params{'stableId'} = $self->getParamValue('stableId');
      }
      when ('fileBasename') {
		    $params{'fileBasename'} = $self->getParamValue('fileBasename');
      }
    }
  }
  
  

  unless($paramSet{$plugin}){ die "Plugin $plugin not supported\n" }

  my $args = join(" ", map { sprintf("--%s %s", $_, $params{$_}) } grep { !/__FLOCK__/ } @{$paramSet{$plugin}} );

  if($lockfile){ 
    open(my $fh, ">>$lockfile");
    flock($fh, LOCK_EX);
    printf $fh ("%s\n", $params{'logDir'});
    $self->runPlugin($test, $undo, $plugin, $args);
    flock($fh, LOCK_UN);
    close($fh);
  }
  else {
    $self->runPlugin($test, $undo, $plugin, $args);
  } 
}

sub getMetadataPath {
  my ($self, @args) = @_;
  return join("/", $self->getWorkflowDataDir(), $self->getParamValue("dataDir"), @args);
}


1;

