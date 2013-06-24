/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package webviewbrowser;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javafx.concurrent.Task;
import javax.xml.transform.SourceLocator;
import net.sf.saxon.s9api.MessageListener;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltTransformer;

/**
 *
 * @author Philip
 */
public class RenderingTask extends Task<String> {
    
    final private XsltTransformer trans;
    final private Map<String, String> parameterMap;
    final private Serializer out;
    final private Processor proc;
    final private FXListener listener;
    final private String outPath;
    
    public RenderingTask(Map<String, String> parameterMap, XsltTransformer transformer, Processor proc, FXListener listener, String outPath){
        this.trans = transformer;
        this.proc = proc;
        this.parameterMap = parameterMap;
        this.listener = listener;
        this.outPath = outPath;
        Serializer serializer = null;
        try {
            serializer = getTempDestination();
        } catch (IOException ex) {
            Logger.getLogger(RenderingTask.class.getName()).log(Level.SEVERE, null, ex);
        }
        this.out = serializer;
    }

    @Override
    protected String call() throws Exception {
                trans.setInitialTemplate(new QName("main"));
                for (Map.Entry<String, String> entry : parameterMap.entrySet()) {
                    trans.setParameter(new QName(entry.getKey()), 
                                       new XdmAtomicValue(entry.getValue()));
                }

                
                trans.setMessageListener(
                   new MessageListener(){
                       @Override
                       public void message(XdmNode xn, boolean bln, SourceLocator sl) {
                            String msg = "[XSLT MSG] " + xn.getStringValue();
                            updateMessage(msg);
                       }
                   }     
                );
                trans.setDestination(out);
                trans.transform();
                updateMessage(outPath);
                updateProgress(1,1);
                return "";
    }
    @Override
    public void updateMessage(final String msg) {
        javafx.application.Platform.runLater(new Runnable() {
            public void run() {
                listener.callback(msg);
            }
        });
    }
    
    private Serializer getTempDestination() throws IOException {
        File outFile;
        outFile = File.createTempFile("xms-", ".html");
        Serializer localOut = proc.newSerializer(outFile);
        localOut.setOutputProperty(Serializer.Property.METHOD, "html");
        localOut.setOutputProperty(Serializer.Property.INDENT, "yes");
        return localOut;
    }
    
    
    
}
