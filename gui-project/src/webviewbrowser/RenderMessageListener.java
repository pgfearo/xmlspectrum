/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package webviewbrowser;

import javax.xml.transform.SourceLocator;
import net.sf.saxon.s9api.MessageListener;
import net.sf.saxon.s9api.XdmNode;

/**
 *
 * @author Philip
 */
public class RenderMessageListener implements MessageListener  {
    
    private FXListener listener;
    
    public RenderMessageListener(FXListener listener){        
        this.listener = listener;
    }

    public void message(XdmNode xn, boolean bln, SourceLocator sl) {
        String msg = xn.getStringValue();
        listener.callback(msg);
    }
    
}
