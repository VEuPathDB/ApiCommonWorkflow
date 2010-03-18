package org.gusdb.workflow;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;
import org.apache.commons.digester.Digester;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import org.gusdb.workflow.XmlParser;
import org.gusdb.workflow.Name;

public class ResourceXmlValidator extends XmlParser {

    private static final Logger logger = Logger.getLogger(ResourceXmlValidator.class);
    public ResourceXmlValidator() {
        super("lib/rng/resources.rng");
    }

    public validateResourcesXml(String xmlFileName) throws IOException, Exception {
        configure();
        
        // construct urls to model file, prop file, and config file
        URL modelURL = makeURL(gusHome, "lib/xml/datasources/" + xmlFileName);

        if (!validate(modelURL))
            throw new Exception("validation failed.");
    }

    public static void main(String[] args) throws Exception  {
        String cmdName = System.getProperty("cmdName");
 
        // process args
        Options options = declareOptions();
        String cmdlineSyntax = cmdName + " -f resources_xml_file";
        String cmdDescrip = "Validate a resources XML file against the RNG schema.";
        CommandLine cmdLine =
            Utilities.parseOptions(cmdlineSyntax, cmdDescrip, "", options, args);
        String xmlFileName = cmdLine.getOptionValue("f");
        
	ResourceXmlValidator validator = new ResourceXmlValidator();
	validator.validateResourcesXml(xmlFileName);
        System.exit(0);
    }

    private static Options declareOptions() {
        Options options = new Options();

        Utilities.addOption(options, "f", "", true);

        return options;
    }




}
