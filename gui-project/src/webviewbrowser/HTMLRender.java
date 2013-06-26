/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package webviewbrowser;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;
import javafx.concurrent.Task;
import javax.xml.transform.stream.StreamSource;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

/**
 *
 * @author Philip
 */
public class HTMLRender {
    
    public void init() throws SaxonApiException{
        
        proc = new Processor(false);
        XsltCompiler comp = proc.newXsltCompiler();
        File file = new File("../app/xsl/highlight-file.xsl");
        if (!file.exists()){
            file = new File("xslt/highlight-file.xsl");
        }
        exp = comp.compile(new StreamSource(file));
        trans = exp.load();
    }
    
    private Processor proc = null;
    private XsltExecutable exp = null;
    private XsltTransformer trans = null;
    
    public static String getFileContent(String path){
        FileInputStream stream;
        try {
            File f = new File(path.substring(8));
            System.out.println("exists: " + f.exists());
            stream = new FileInputStream(f);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(HTMLRender.class.getName()).log(Level.SEVERE, null, ex);
            return "";
        }
        try {
          FileChannel fc = stream.getChannel();
          MappedByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, fc.size());
          /* Instead of using default, pass in a decoder. */
          return Charset.defaultCharset().decode(bb).toString();
        }
        catch (IOException ex) {
            Logger.getLogger(HTMLRender.class.getName()).log(Level.SEVERE, null, ex);
            return "";
        } 
        finally {
            try {
                stream.close();
            } catch (IOException ex) {
                Logger.getLogger(HTMLRender.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
       
    public Task run(Map<String, String> parameterMap, String inputURI, 
                    Boolean inputIsURI, FXListener inListener) 
                       throws SaxonApiException, IOException {
        
        final Map<String, String> taskMap = new HashMap<String, String>();
        for (Map.Entry<String, String> entry : parameterMap.entrySet()) {
            
            taskMap.put(entry.getKey(), entry.getValue());
        }

        // the file to transform
        String sourceFile = getSource(inputIsURI, inputURI);
        Boolean createTOC = taskMap.get("link-names").equals("yes");
        
        String tempPath = System.getProperty("java.io.tmpdir");
        tempPath = (createTOC)? tempPath + "package" + File.separatorChar : tempPath;
        final String outPath = getAbsOutPath(sourceFile, tempPath, createTOC);
        
        taskMap.put("sourcepath", sourceFile);
        taskMap.put("output-path", tempPath);
        
        Task<String> task = new RenderingTask(taskMap, trans, proc, inListener, outPath);
        
        ExecutorService pool = Executors.newCachedThreadPool();
        pool.submit(task);
        // ensure last task is completed before exiting thread pool
        pool.shutdown();

        System.out.println("HTMLRender output written to: " + outPath);
        return task; //outPath;
    }

    private String getSource(Boolean inputIsURI, String inputURI) throws IOException {
        String sourceFile;
        if (inputIsURI) {
            sourceFile = inputURI;
        } else {
            
            File temp;
            temp = File.createTempFile("inx-", ".xms");
            //FileWriter fw = new FileWriter(temp.getName(), false);
            BufferedWriter outBw = new BufferedWriter (new OutputStreamWriter(new FileOutputStream(temp.getAbsolutePath()),"UTF-8"));
            outBw.write(inputURI);
            outBw.close();
            sourceFile = temp.getAbsolutePath();
        }
        return sourceFile;
    }

    private String getAbsOutPath(String sourceFile, String tempPath, Boolean createTOC) {
        int pos1 = sourceFile.lastIndexOf('/');
        int pos2 = sourceFile.lastIndexOf('\\');
        int pos = (pos1 > pos2)? pos1 : pos2;
        String filename = sourceFile.substring(pos + 1);
        String lastChar = tempPath.substring(tempPath.length() - 1);
        String osAdjustedTempPath = (lastChar.equals("/") || lastChar.equals("\\"))? tempPath : tempPath + "/";
        String outPath = (createTOC)? osAdjustedTempPath + "index.html" :osAdjustedTempPath + filename + ".html";
        // check file does not already exist - if it does remove it
        File f = new File(outPath);
        if (f.exists()){ f.delete(); }
        
        return outPath;
    }

    
}
