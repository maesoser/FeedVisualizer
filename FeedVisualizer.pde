import controlP5.*;
import java.util.*;
import java.text.*;
import java.security.MessageDigest;
import java.util.Map;
import java.text.Normalizer;
import java.text.Normalizer.Form;

String[] titles;

ArrayList <Noticia> noticias ;
ControlP5 cp5;
Table rss_feeds;
PFont font;
PFont font_title;
PFont counter_font;
int n_size;
String url;
int index;
Textarea descriptionText;
Textarea titletext;
Textarea countertext;
Boolean firstlaunch = true;

ScrollableList newslist;
Textfield searchText;
Button searchbutton;
Button refresh;
Button linkbutton;

void setup() {
  
  background(40);
  n_size = 0;
  noticias = new ArrayList();
  url = null;
  size(1000, 700);
  cp5 = new ControlP5(this);

  font_title = loadFont("Calibri-Bold-20.vlw");
  font = loadFont("Calibri-18.vlw");
  counter_font = loadFont("Calibri-Bold-42.vlw");

  titletext = cp5.addTextarea("ttxt")
    .setPosition(6, 475)
    .setSize(895, 45)
    .setFont(font_title)
    .hideScrollbar() 
    .setLineHeight(18)
    .setColor(color(255))
    .setColorBackground(40)
    .setColorForeground(40)
    .setText("");

  newslist = cp5.addScrollableList("News")
    .setPosition(6, 65)
    .setSize(985, 400)
    .setBarHeight(25)
    .setItemHeight(25)
    .setBarVisible(true) 
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;

  descriptionText = cp5.addTextarea("dtxt")
    .setPosition(6, 525)
    .setSize(985, 170)
    .setFont(font)
    .setLineHeight(18)
    .setColor(color(255))
    .setColorBackground(40)
    .setColorForeground(40);
  descriptionText.setText("");


  countertext = cp5.addTextarea("itxt")
    .setPosition(6, 685)
    .setSize(1000, 25)
    .setFont(font)
    .setLineHeight(18)
    .hideScrollbar() 
    .setColor(color(255))
    .setColorBackground(40)
    .setColorForeground(40);
  countertext.setText("");

  searchText = cp5.addTextfield("Search")
    .setPosition(6, 10)
    .setSize(400, 50)
    .setFont(counter_font)
    .setAutoClear(false)
    .setLabelVisible(false)
    .setLabel("") 
    ;

  searchbutton = cp5.addButton("SEARCH")
    .setValue(0)
    .setPosition(425, 10)
    .setSize(200, 50)
    ;

  refresh = cp5.addButton("REFRESH")
    .setValue(0)
    .setPosition(635, 10)
    .setSize(200, 50)
    ;

  linkbutton = cp5.addButton("OPEN")
    .setValue(0)
    .setPosition(900, 475)
    .setSize(90, 50)
    ;
}

void draw() {
  background(40);
}

void News(int n) {
  /* request the selected item based on index n */
  println(titles[n]);
  String this_hash = createHash(titles[n]);
  for (Noticia noticia : noticias) {
    if (noticia.isHash(this_hash)) {
      descriptionText.setText(noticia.getFormattedText());
      titletext.setText(noticia.title);
      url = noticia.link;
      index = n;
    }
  }
  newslist.open();
}

public void REFRESH() {
  for (String item : titles) {
    newslist.removeItem(item);
  }
  newslist.clear();
  newslist.update();
  if (firstlaunch) {
    firstlaunch = false;
  } else {
    updateList();
  }
  println("a button event from REFRESH");
  titles = clearList(titles);
  newslist.addItems(titles);
  newslist.update();
  n_size = titles.length;
  countertext.setText(Integer.toString(titles.length)+" articles from "+rss_feeds.getRowCount()+" sources.");
}

public void OPEN() {
  link(url);
}

public void SEARCH() {

  titles = null;

  ArrayList<String> temp_array = new ArrayList();

  for (Noticia noticia : noticias) {
    temp_array.add(noticia.title);
  }

  titles = temp_array.toArray(new String[temp_array.size()]);

  for (String item : titles) {
    newslist.removeItem(item);
  }

  newslist.clear();
  newslist.update();

  String text = searchText.getText().toUpperCase();
  ArrayList<String> titles_temp = new ArrayList<String>();

  for (Noticia noticia : noticias) {
    if (noticia.itContains(text)) titles_temp.add(noticia.title);
  }

  titles = null;
  titles = titles_temp.toArray(new String[titles_temp.size()]);
  titles = clearList(titles);
  newslist.addItems(titles);
  newslist.update();
  countertext.setText( Integer.toString(titles.length)+" articles of "+n_size+ " from "+rss_feeds.getRowCount()+" sources.");
}

String createHash(String text) {
  try {
    MessageDigest messageDigest = MessageDigest.getInstance("MD5");
    messageDigest.update(text.getBytes());
    return  new String(messageDigest.digest());
  }
  catch(Exception e) {
    return "NULL";
  }
}

void updateList() {

  titles = null;
  rss_feeds = loadTable("rss.csv", "header");

  // Load RSS feed
  for (int x=0; x<rss_feeds.getRowCount(); x++) {


    // Obtenemos la info de clasificiación guardada en el csv
    String source = rss_feeds.getString(x, 0);
    String section = rss_feeds.getString(x, 1);

    if (source.indexOf("#")==-1) {
      println(rss_feeds.getString(x, 2));
      String url = rss_feeds.getString(x, 2);
      try {
        XML rss = loadXML(url);
        // Extrae el titulo, 
        XML[] titleXMLElements = rss.getChildren("channel/item/title");
        XML[] linkXMLElements = rss.getChildren("channel/item/link");
        XML[] descriptionXMLElements = rss.getChildren("channel/item/description");
        XML[] pubDateXMLElements = rss.getChildren("channel/item/pubDate");

        //titles = new String[titleXMLElements.length];
        for (int i = 0; i < titleXMLElements.length; i++) {
          // La fecha es del tipo:     <pubDate><![CDATA[Wed, 18 Nov 2015 15:46:51 +0100]]></pubDate>
          Noticia temp_not = new Noticia(titleXMLElements[i].getContent(), linkXMLElements[i].getContent(), descriptionXMLElements[i].getContent(), pubDateXMLElements[i].getContent());
          temp_not.addCSVinfo(source, section);
          n_size++;
          DateFormat df = new SimpleDateFormat("dd/M/yyyy");
          String datext = df.format(new Date());
          if (temp_not.getDate().equals(datext)) noticias.add(temp_not);
        }
      }
      catch(Exception e) {
        println("Error");
      }
    }
  }

  ArrayList<String> temp_array = new ArrayList();
  for (Noticia noticia : noticias) {
    temp_array.add(noticia.title);
  }
  titles = temp_array.toArray(new String[temp_array.size()]);
}

String[] clearList(String[] list) {
  ArrayList<String> list_temp = new ArrayList<String>(Arrays.asList(list));
  Set<String> hs = new HashSet();
  hs.addAll(list_temp);
  list_temp.clear();
  list_temp.addAll(hs);
  return list_temp.toArray(new String[list_temp.size()]);
}

void keyPressed() {
    if(key == 'O'){
      OPEN();
    }
  if(key == ENTER){
      SEARCH();
    }
  if (key == CODED) {
    if (keyCode == RIGHT) {
      if (index+1<titles.length)       index = index+1;
      /* request the selected item based on index n */
      println(titles[index]);
      String this_hash = createHash(titles[index]);
      for (Noticia noticia : noticias) {
        if (noticia.isHash(this_hash)) {
          descriptionText.setText(noticia.getFormattedText());
          titletext.setText(noticia.title);
          url = noticia.link;
        }
      }
    }
    if (keyCode == LEFT) {
      if (index!=0) index = index-1;

      /* request the selected item based on index n */
      println(titles[index]);
      String this_hash = createHash(titles[index]);
      for (Noticia noticia : noticias) {
        if (noticia.isHash(this_hash)) {
          descriptionText.setText(noticia.getFormattedText());
          titletext.setText(noticia.title);
          url = noticia.link;
        }
      }
    }
    
  }
}