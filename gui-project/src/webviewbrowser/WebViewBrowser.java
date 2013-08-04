/*
 * Copyright (c) 2012 Oracle and/or its affiliates.
 * All rights reserved. Use is subject to license terms.
 *
 * This file is available and licensed under the following license:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the distribution.
 *  - Neither the name of Oracle Corporation nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package webviewbrowser;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javafx.application.Application;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.HPos;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.geometry.VPos;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Control;
import javafx.scene.control.Hyperlink;
import javafx.scene.control.Label;
import javafx.scene.control.RadioButton;
import javafx.scene.control.Separator;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextAreaBuilder;
import javafx.scene.control.TextField;
import javafx.scene.control.ToggleGroup;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.Clipboard;
import javafx.scene.input.ClipboardContent;
import javafx.scene.input.DragEvent;
import javafx.scene.input.Dragboard;
import javafx.scene.input.MouseEvent;
import javafx.scene.input.TransferMode;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.ColumnConstraints;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.Pane;
import javafx.scene.layout.Priority;
import static javafx.scene.layout.Region.USE_COMPUTED_SIZE;
import javafx.scene.layout.RowConstraints;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.scene.web.WebEngine;
import javafx.scene.web.WebView;
import javafx.stage.Stage;
import net.sf.saxon.s9api.SaxonApiException;
 
/**
 * Demonstrates a WebView object accessing a web page.
 *
 * @see javafx.scene.web.WebView
 * @see javafx.scene.web.WebEngine
 */
public class WebViewBrowser extends Application {
 
    @Override public void start(Stage primaryStage) throws Exception {
        Pane root = new WebViewPane();
        Scene scene = new Scene(root, 1280, 900);
           scene.setOnDragOver(new EventHandler<DragEvent>() {
                 @Override
                 public void handle(DragEvent event) {
                     Dragboard db = event.getDragboard();
                     if (db.hasFiles()) {
                         event.acceptTransferModes(TransferMode.COPY);
                     } else {
                         event.consume();
                     }
                 }
             });
           
                        // Dropping over surface
            scene.setOnDragDropped(new EventHandler<DragEvent>() {
                @Override
                public void handle(DragEvent event) {
                    Dragboard db = event.getDragboard();
                    boolean success = false;
                    if (db.hasFiles()) {
                        success = true;
                        String filePath;
                        for (File file:db.getFiles()) {
                            filePath = file.getAbsolutePath();
                            locationField.setText(filePath);
                        }
                    }
                    event.setDropCompleted(success);
                    event.consume();
                }
            });

        primaryStage.setScene(scene);
        primaryStage.getIcons().add(new Image("file:xmlspectrum-icon.png"));
        primaryStage.setTitle("XMLSpectrum-FX");
        primaryStage.show();
    }
    
    /**
     * The main() method is ignored in correctly deployed JavaFX 
     * application. main() serves only as fallback in case the 
     * application can not be launched through deployment artifacts,
     * e.g., in IDEs with limited FX support. NetBeans ignores main().
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        launch(args);
    }
       
    private TextField locationField = null;
    private TextArea statusField = null;
    
    private WebEngine eng = null;
    
    private HTMLRender hr = new HTMLRender();
    
    private AnchorPane textVBox = null;
    
    private RowConstraints row2;
    private RowConstraints row3;
    
    private boolean useTextArea = false;
    private TextArea textArea = null;

    /**
     * Create a resizable WebView pane
     */
    public class WebViewPane extends Pane {

        public WebViewPane() {
            VBox.setVgrow(this, Priority.ALWAYS);
            ((Pane)this).setStyle("-fx-background-color:#daeafa;");

            setMaxWidth(Double.MAX_VALUE);
            setMaxHeight(Double.MAX_VALUE);
            try {
                hr.init();
            } catch (SaxonApiException ex) {
                Logger.getLogger(WebViewBrowser.class.getName()).log(Level.SEVERE, null, ex);
            }

            WebView view = new WebView();
            view.setMinSize(500, 200);
            view.setPrefSize(500, 200);
            String classPath = new java.io.File("").getAbsolutePath();

            String helpURL = "file:///" + classPath + "/docs/readme.html";
            eng = view.getEngine();
            eng.load(helpURL);
            String fontURL = "file:///" + classPath + "/fonts/SourceCodePro-Regular.ttf";
            Font.loadFont(fontURL,  10);
            locationField = new TextField("");
            locationField.setMaxHeight(25);
            locationField.setPromptText("Enter URL or local path or drag and drop files here");
            locationField.setStyle("-fx-background-color:white; -fx-text-fill:black; border-width:1px; margin:2px");
            statusField = new TextArea("");
            statusField.setMaxHeight(36);
            statusField.setText("Status: Ready");
            statusField.setEditable(false);
            statusField.setStyle("-fx-text-fill: #2030a0;"+
                "-fx-background-color: #cadaea;"+
                "-fx-font-family: 'Monospaced';");
            final VBox vBox = addVBox();
            final VBox vBoxRight = addVBoxRight();
            textVBox = addTextVBox();            
            Button goButton = new Button("Run");
            goButton.setPrefWidth(100);
            goButton.setDefaultButton(true);
            EventHandler<ActionEvent> goAction;
            goAction = new EventHandler<ActionEvent>() {
                @Override
                public void handle(ActionEvent event) {
                        String sourceText = (useTextArea)? textArea.getText() : locationField.getText();
                        runRenderingTask(sourceText, !useTextArea);
                }
            };
            goButton.setOnAction(goAction);
            locationField.setOnAction(goAction);
            eng.locationProperty().addListener(new ChangeListener<String>() {
                @Override public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
                    //locationField.setText(newValue);
                }
            });

            Label title1 = new Label("  XMLSpectrum");
            Label title2 = new Label("");
            title1.setFont(Font.font("Arial", FontWeight.BOLD, 16));
            title2.setFont(Font.font("Arial", FontWeight.NORMAL, 16));
            Image image = new Image("file:xmlspectrum-icon.png");
            title1.setMinHeight(30);
            title1.setAlignment(Pos.CENTER);
            title1.setPrefHeight(USE_PREF_SIZE);
            title1.setMinWidth(150);
            title1.setGraphic(new ImageView(image));
            title1.setTextFill(Color.web("#6a9aba"));
            title2.setTextFill(Color.web("#6a9aba"));

            //
            GridPane grid = new GridPane();
            grid.setVgap(5);
            grid.setHgap(5);
            GridPane.setConstraints(title1, 0, 0, 1, 1, HPos.CENTER, VPos.CENTER, Priority.NEVER, Priority.SOMETIMES);            
            GridPane.setConstraints(locationField, 1, 0, 1, 1, HPos.CENTER, VPos.CENTER, Priority.ALWAYS, Priority.SOMETIMES);
            GridPane.setConstraints(goButton, 2, 0, 1, 1, HPos.CENTER, VPos.CENTER, Priority.NEVER, Priority.SOMETIMES);
            GridPane.setConstraints(title2, 3, 0, 1, 1, HPos.CENTER, VPos.CENTER, Priority.NEVER, Priority.SOMETIMES);
            GridPane.setConstraints(textVBox, 1, 1, 2, 1, HPos.CENTER, VPos.CENTER, Priority.ALWAYS, Priority.ALWAYS);
            GridPane.setConstraints(view, 1, 2, 2, 1, HPos.CENTER, VPos.CENTER, Priority.ALWAYS, Priority.SOMETIMES); 
            GridPane.setConstraints(vBox, 0, 1, 1, 2, HPos.CENTER, VPos.CENTER, Priority.ALWAYS, Priority.SOMETIMES);
            GridPane.setConstraints(vBoxRight, 3, 1, 1, 2, HPos.CENTER, VPos.CENTER, Priority.ALWAYS, Priority.SOMETIMES);
            GridPane.setConstraints(statusField, 0, 3, 3, 1, HPos.CENTER, VPos.CENTER, Priority.ALWAYS, Priority.ALWAYS);
            grid.getColumnConstraints().addAll(
                    new ColumnConstraints(200,200,200, Priority.NEVER, HPos.RIGHT, true),
                    new ColumnConstraints(100, 100, Double.MAX_VALUE, Priority.ALWAYS, HPos.CENTER, true),
                    new ColumnConstraints(100,100,100, Priority.NEVER, HPos.RIGHT, true),
                    new ColumnConstraints(200,200,200, Priority.NEVER, HPos.RIGHT, true)
            );
            grid.getChildren().addAll(title1, vBox, locationField, goButton, title2, textVBox, view, vBoxRight, statusField);
            RowConstraints row1 = new RowConstraints();
            row2 = new RowConstraints();
            row3 = new RowConstraints();
            RowConstraints row4 = new RowConstraints();
            row1.setMaxHeight(30);
            row1.setMinHeight(30);
            row1.setVgrow(Priority.ALWAYS);
            vBox.setMinHeight(100);
            textVBox.setMaxHeight(0);
            row2.setMaxHeight(0);
            row3.setPrefHeight(USE_COMPUTED_SIZE);            
            //row3.setFillHeight(true);
            row3.setVgrow(Priority.SOMETIMES);
            row4.setMaxHeight(40);
            row4.setMinHeight(40);
            row4.setFillHeight(true);
            //grid.setGridLinesVisible(true);
            grid.getRowConstraints().addAll(row1,row2,row3, row4);
            getChildren().add(grid);
            
        
        }
        
        private void resetStatusText(){
            statusField.setText("");
        }
        
        private void runRenderingTask(String inputURI, Boolean inputIsURI){
            resetStatusText();
            try {
                Map paramMap = getXslParameters(); 
                hr.run(paramMap, inputURI, inputIsURI, 

                    new FXListener(){
                        @Override
                        public void callback(String outPath){
                                String pfx = outPath.substring(0,1);
                                if (pfx.equals("[")){
                                    statusField.appendText(outPath + "\n");
                                }else {
                                    String fullHTMLString = "";
                                    try {
                                    final Clipboard clipboard = Clipboard.getSystemClipboard();
                                    final ClipboardContent content = new ClipboardContent();
                                    // br fix required because html output-method seems to be affected by xhtml namespace
                                    fullHTMLString = HTMLRender.getFileContent("file:///" + outPath).replace("<br></br>", "<br />");                                    
                                    int start = fullHTMLString.indexOf("style=") + 7;
                                    int end = fullHTMLString.lastIndexOf("</pre>") + 6;
                                    String divString = "<pre style=\"white-space: nowrap; ";
                                    String preString = divString + fullHTMLString.substring(start, end);
                                    content.putString(preString);
                                    clipboard.setContent(content);
                                    } catch (Exception e){}
                                    eng.loadContent(fullHTMLString);
                                    //eng.load("file:///" + outPath);
                                }
                        }
                    }
               );
            } catch (SaxonApiException ex) {
                Logger.getLogger(WebViewBrowser.class.getName()).log(Level.SEVERE, null, ex);
            } catch (IOException ex) {
                Logger.getLogger(WebViewBrowser.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        
        public Map<String, String> getXslParameters(){
            Map<String, String> m = new HashMap<String, String>();
            String useToc = this.getSelectedTOC();
            m.put("indent",        getSelectedIndent());
            m.put("auto-trim",     getSelectedTrim());
            m.put("color-theme",   getSelectedColor());
            m.put("font-name",     getSelectedFont());
            m.put("force-newline", getSelectedNL());
            m.put("format-mixed-content", getSelectedMC());
            if (getSelectedDocType().equals("deltaxml")){
                m.put("document-type-prefix", "deltaxml");
            }
            m.put("css-inline",    ((useToc.equals("yes"))? "no":"yes")); 
            m.put("document-type", getSelectedDocType());
            m.put("link-names",    useToc);
            return m;
        }

        @Override protected void layoutChildren() {
            List<Node> managed = getManagedChildren();
            double width = getWidth();
            double height = getHeight();
            double top = getInsets().getTop();
            double right = getInsets().getRight();
            double left = getInsets().getLeft();
            double bottom = getInsets().getBottom();
            for (int i = 0; i < managed.size(); i++) {
                Node child = managed.get(i);
                layoutInArea(child, left, top,
                               width - left - right, height - top - bottom,
                               0, Insets.EMPTY, true, true, HPos.CENTER, VPos.CENTER);
            }
        }
        
        private ToggleGroup fontGroup = new ToggleGroup();
        private ToggleGroup colorGroup = new ToggleGroup();
        private ToggleGroup trimGroup = new ToggleGroup();
        private ToggleGroup indentGroup = new ToggleGroup();
        private ToggleGroup NLGroup = new ToggleGroup();
        private ToggleGroup MCGroup = new ToggleGroup();
        private ToggleGroup OGroup = new ToggleGroup();
        private ToggleGroup docGroup = new ToggleGroup();
        private ToggleGroup tocGroup = new ToggleGroup();
        
        public String getSelectedFont(){
            return (String) fontGroup.getSelectedToggle().getUserData();
        }
        public String getSelectedColor(){
            return (String) colorGroup.getSelectedToggle().getUserData();
        }        
        public String getSelectedTrim(){
            return (String) trimGroup.getSelectedToggle().getUserData();
        }        
        public String getSelectedIndent(){
            return (String) ((RadioButton)indentGroup.getSelectedToggle()).getUserData();
        }
        public String getSelectedNL(){
            return (String) NLGroup.getSelectedToggle().getUserData();
        }
        public String getSelectedMC(){
            return (String) MCGroup.getSelectedToggle().getUserData();
        }
        public String getSelectedDocType(){
            return (String) docGroup.getSelectedToggle().getUserData();
        }
        public String getSelectedTOC(){
            return (String) tocGroup.getSelectedToggle().getUserData();
        }
        
        private AnchorPane addTextVBox(){
            final TextArea area = TextAreaBuilder.create()
                    .prefWidth(USE_COMPUTED_SIZE)
                    .prefHeight(USE_COMPUTED_SIZE)
                    .wrapText(true)
                    .build();

              area.setStyle("-fx-text-fill: white;"+
                "-fx-text-fill: black;"+
                "-fx-background-color: white;"+
                "-fx-font-family: 'Monospaced';");
              textArea = area;
              //VBox vBox = new VBox();
              AnchorPane vBox = new AnchorPane();
              AnchorPane.setTopAnchor(textArea, 2.0);
              AnchorPane.setLeftAnchor(textArea, 2.0);
              AnchorPane.setRightAnchor(textArea, 2.0);
              AnchorPane.setBottomAnchor(textArea, 2.0);
              vBox.getChildren().add(area);
            return vBox;
        }
        
        private VBox addVBox() {
            VBox vbox = new VBox();
            vbox.setStyle("-fx-background-color:#daeafa;");
            vbox.setPadding(new Insets(10));
            vbox.setSpacing(7);
            
            RadioButton rbUseTextArea = new RadioButton("Text Area");
            rbUseTextArea.setToggleGroup(OGroup);

            RadioButton rbUseFileSource = new RadioButton("File (drag and drop)");
            rbUseFileSource.setSelected(true);
            rbUseFileSource.setToggleGroup(OGroup);
            addBlueTitle(vbox, "Transform Settings");
            addTitle(vbox, "Source");
            vbox.getChildren().add(rbUseTextArea);
            vbox.getChildren().add(rbUseFileSource);
            vbox.getChildren().add(new Separator());
            
               rbUseTextArea.setOnMouseClicked(new EventHandler<MouseEvent>() {
                    @Override
                    public void handle(MouseEvent e) {
                        row2.setMinHeight(60);
                        row2.setMaxHeight(250);
                        textVBox.setMaxHeight(USE_COMPUTED_SIZE);
                        //textVBox.setStyle("-fx-background-color:blue;");
                        row2.setPrefHeight(USE_COMPUTED_SIZE);
                        locationField.setEditable(false);
                        locationField.setStyle("-fx-background-color:#ececec; -fx-text-fill:black; border-width:1");                        
                        textArea.prefHeightProperty().bind(textVBox.prefHeightProperty());
                        useTextArea = true;
                    }
                });
               
                rbUseFileSource.setOnMouseClicked(new EventHandler<MouseEvent>() {
                    @Override
                    public void handle(MouseEvent e) {
                        textVBox.setMaxHeight(0);
                        row2.setMinHeight(0);
                        row2.setMaxHeight(0);
                        locationField.setEditable(true);
                        locationField.setStyle("-fx-background-color:white; -fx-text-fill:black; border-width:1");
                        useTextArea = false;
                    }
                });
            
            addTitle(vbox, "Font");

            RadioButton rb1 = new RadioButton("Monospaced");
            rb1.setUserData("");
            rb1.setToggleGroup(fontGroup);

            RadioButton rb2 = new RadioButton("Source Code Pro");
            rb2.setUserData("scp"); 
            rb2.setSelected(true);
            rb2.setToggleGroup(fontGroup);

            vbox.getChildren().add(rb1);
            vbox.getChildren().add(rb2);
            vbox.getChildren().add(new Separator());
            
            addTitle(vbox, "Color Theme");
            RadioButton crb1 = new RadioButton("Solarized-Dark");
            crb1.setUserData("dark");
            crb1.setToggleGroup(colorGroup);
            crb1.setSelected(true);

            RadioButton crb2 = new RadioButton("Solarized-Light");
            crb2.setUserData("light");
            crb2.setToggleGroup(colorGroup);
            
            RadioButton crb5 = new RadioButton("GitHub (Light)");
            crb5.setUserData("github");
            crb5.setToggleGroup(colorGroup);
            
            RadioButton crb6 = new RadioButton("GitHub (Blue)");
            crb6.setUserData("github-blue");
            crb6.setToggleGroup(colorGroup);

            RadioButton crb3 = new RadioButton("RoboTicket");
            crb3.setUserData("roboticket-grey");
            crb3.setToggleGroup(colorGroup);
            
            RadioButton crb4 = new RadioButton("Tomorrow-Night");
            crb4.setUserData("tomorrow-night");
            crb4.setToggleGroup(colorGroup);
            
            RadioButton crb7 = new RadioButton("PG-Light");
            crb7.setUserData("pg-light");
            crb7.setToggleGroup(colorGroup);
            
            vbox.getChildren().add(crb1);
            vbox.getChildren().add(crb2);
            vbox.getChildren().add(crb5);
            vbox.getChildren().add(crb6);
            vbox.getChildren().add(crb7);
            vbox.getChildren().add(crb3);
            vbox.getChildren().add(crb4);
            vbox.getChildren().add(new Separator());
            
            //
            addTitle(vbox, "Language");
            RadioButton drb1 = new RadioButton("Auto");
            drb1.setUserData("");
            drb1.setToggleGroup(docGroup);
            drb1.setSelected(true);

            RadioButton drb2 = new RadioButton("XSLT");
            drb2.setUserData("xslt");
            drb2.setToggleGroup(docGroup);

            RadioButton drb3 = new RadioButton("XQuery/XPath");
            drb3.setUserData("xquery");
            drb3.setToggleGroup(docGroup);
            
            RadioButton drb4 = new RadioButton("XML Schema");
            drb4.setUserData("xsd");
            drb4.setToggleGroup(docGroup);
            
            RadioButton drb5 = new RadioButton("XProc");
            drb5.setUserData("xproc");
            drb5.setToggleGroup(docGroup);
            
            RadioButton drb6 = new RadioButton("Schematron");
            drb6.setUserData("schematron");
            drb6.setToggleGroup(docGroup);
            
            RadioButton drb7 = new RadioButton("DeltaXML");
            drb7.setUserData("deltaxml");
            drb7.setToggleGroup(docGroup);
            
            vbox.getChildren().add(drb1);
            vbox.getChildren().add(drb2);
            vbox.getChildren().add(drb3);
            vbox.getChildren().add(drb4);
            vbox.getChildren().add(drb5);
            vbox.getChildren().add(drb6);
            vbox.getChildren().add(drb7);
            vbox.getChildren().add(new Separator());
            //
            addTitle(vbox, "XSLT Project");
            RadioButton tocrb1 = new RadioButton("Yes");
            tocrb1.setUserData("yes");
            tocrb1.setToggleGroup(tocGroup);

            RadioButton tocrb2 = new RadioButton("No");
            tocrb2.setUserData("no");
            tocrb2.setToggleGroup(tocGroup);
            tocrb2.setSelected(true);
            vbox.getChildren().add(tocrb1);
            vbox.getChildren().add(tocrb2);
          
            return vbox;
        }
        private VBox addVBoxRight() {
            VBox vbox = new VBox();
            vbox.setStyle("-fx-background-color:#daeafa;");
            vbox.setPadding(new Insets(10));
            vbox.setSpacing(7);            
            
            RadioButton trb1 = new RadioButton("On");
            trb1.setUserData("yes");
            trb1.setToggleGroup(trimGroup);
            trb1.setSelected(true);

            RadioButton trb2 = new RadioButton("Off");
            trb2.setUserData("no");
            trb2.setToggleGroup(trimGroup);
            addBlueTitle(vbox, "XML/XSLT Formatting");
            addTitle(vbox, "XML: Auto-Trim");
            vbox.getChildren().add(trb1);
            vbox.getChildren().add(trb2);
            vbox.getChildren().add(new Separator());
            
            addTitle(vbox, "XML Indent (Chars)");
            RadioButton irb1 = new RadioButton("-1 (No alignment)");
            irb1.setUserData("-1");
            irb1.setToggleGroup(indentGroup);

            RadioButton irb2 = new RadioButton("0");
            irb2.setUserData("0");
            irb2.setToggleGroup(indentGroup);

            RadioButton irb3 = new RadioButton("2");
            irb3.setUserData("2");
            irb3.setSelected(true);            
            irb3.setToggleGroup(indentGroup);
            
            RadioButton irb4 = new RadioButton("3");
            irb4.setUserData("3");
            irb4.setToggleGroup(indentGroup);
            vbox.getChildren().add(irb1);
            vbox.getChildren().add(irb2);
            vbox.getChildren().add(irb3);
            vbox.getChildren().add(irb4);
            vbox.getChildren().add(new Separator());
            
            RadioButton nrb1 = new RadioButton("On");
            nrb1.setUserData("yes");
            nrb1.setToggleGroup(NLGroup);

            RadioButton nrb2 = new RadioButton("Off");
            nrb2.setSelected(true);
            nrb2.setUserData("no");
            nrb2.setToggleGroup(NLGroup);
            
            addTitle(vbox, "XML: Force NewLines");
            vbox.getChildren().add(nrb1);
            vbox.getChildren().add(nrb2);
            vbox.getChildren().add(new Separator());
            
            RadioButton mrb1 = new RadioButton("On");
            mrb1.setUserData("yes");
            mrb1.setToggleGroup(MCGroup);
            
            RadioButton mrb2 = new RadioButton("Off");
            mrb2.setSelected(true);
            mrb2.setUserData("no");
            mrb2.setToggleGroup(MCGroup);
            
            addTitle(vbox, "XML: Indent Mixed-Content");
            vbox.getChildren().add(mrb1);
            vbox.getChildren().add(mrb2);
            vbox.getChildren().add(new Separator());
            
            String classPath = new java.io.File("").getAbsolutePath().replace('\\', '/');
            addBlueTitle(vbox, "Documentation");
            newHyperlink(vbox, "XMLSpectrum Guide", classPath + "/docs/readme.html", true);
            vbox.getChildren().add(new Separator());
            addBlueTitle(vbox, "Samples");
            newHyperlink(vbox, "Sample #1: XQuery", classPath + "/samples/search-ui.xqy", false);
            newHyperlink(vbox, "Sample #2: XSLT", classPath + "/samples/xpathcolorer-x.xsl", false);
            newHyperlink(vbox, "Sample #3: XProc", classPath + "/samples/xproccorb.xpl", false);
            newHyperlink(vbox, "Sample #4: XML Schema", classPath + "/samples/schema-assert.xsd", false);
          
            return vbox;
        }
        
        private Hyperlink newHyperlink(VBox vbox, String label, String path, Boolean isUrl){
            Hyperlink hl1 = new Hyperlink(label);
            hl1.setStyle("-fx-text-fill: #6a9aba;");
            hl1.setUserData("file:///" + path);
            VBox.setMargin(hl1, new Insets(0, 0, 0, 8));
            vbox.getChildren().add(hl1);
            if (isUrl){
            hl1.setOnAction(new EventHandler<ActionEvent>() {
                    @Override
                    public void handle(ActionEvent e) {
                        eng.load(((String)((Control)e.getTarget()).getUserData()));
                    }
                });
            } else {
               hl1.setOnAction(new EventHandler<ActionEvent>() {
                    @Override
                    public void handle(ActionEvent e) {
                        String filePath = ((String)((Control)e.getTarget()).getUserData());
                        System.out.println("newpath: " + filePath);
                        String sourceText = setSourceText(filePath);
                        runRenderingTask(sourceText, !useTextArea);
                    }

                   private String setSourceText(String filePath) {
                       String sourceText;
                       if (useTextArea){
                           sourceText = HTMLRender.getFileContent(filePath);
                           textArea.setText(sourceText);
                           
                       } else {
                           sourceText = filePath;
                           locationField.setText(filePath);
                       }
                       return sourceText;
                   }
                });
            }
            return hl1;
        }
        
        
        public void addTitle(VBox vbox, String titleText) {
            Text title = new Text(titleText);
            title.setFont(Font.font("Arial", FontWeight.BOLD, 14));
            vbox.getChildren().add(title);
        }
        public void addBlueTitle(VBox vbox, String titleText) {
            Label title = new Label(titleText);
            title.setFont(Font.font("Arial", FontWeight.BOLD, 14));
            title.setTextFill(Color.web("#6a9aba"));
            vbox.getChildren().add(title);
        }
                    
    }
}
