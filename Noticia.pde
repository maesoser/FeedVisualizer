class Noticia{
  String source;
  String section;
  String title;
  String link;
  String description;
  String pubDate;
  String hash;
  Date timedate;
  
  Noticia(String t, String l, String d, String p){
    title = removeAccents(t);
    link = l;
    description = removeAccents(d).replace("&nbsp","");
    pubDate = p;
    timedate = translatetime(pubDate);
    hash = createHash(title);
    if(description.indexOf("<")!=-1) description = description.substring(0,description.indexOf("<"));
  }
  
  void addCSVinfo(String s,String sec){
    source = s;
    section = sec;
  }
  
  Date translatetime(String timeString){
    Date date = null;
    DateFormat format = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.ENGLISH);
    try{
      date = format.parse(timeString);
    }catch(Exception e){
      println("Imposible parsear "+timeString);
    }
    //println(date);
    return date;
  }
  
  Boolean itContains(String t){
    if(titleContains(t)) return true;
    if(descriptionContains(t)) return true;
    
    else return false;
    
  }
  
  Boolean titleContains(String text){
    text = removeAccents(text);
    if(removeAccents(title.toUpperCase()).indexOf(text.toUpperCase())!=-1) return true;
    else return false;   
  }
  
    Boolean descriptionContains(String text){
      text = removeAccents(text);
    if(removeAccents(description.toUpperCase()).indexOf(text.toUpperCase())!=-1) return true;
    else return false; 
  }
  
  String createHash(String text){
    try{
      MessageDigest messageDigest = MessageDigest.getInstance("MD5");
      messageDigest.update(text.getBytes());
      return  new String(messageDigest.digest());
    }catch(Exception e){
      return "NULL";
    }
  }
  
  Boolean isHash(String text){
    return hash.equals(text);
  }
  
  String getFormattedText(){
    DateFormat df = new SimpleDateFormat("dd/M/yyyy HH:mm:ss");
    String reportDate = df.format(timedate);
    return source+","+section+"\t\t\t"+reportDate+"\n\n"+description;
  }
  
  String getDate(){
    DateFormat df = new SimpleDateFormat("dd/M/yyyy");
    String reportDate = df.format(timedate);
    return reportDate;
  }
  
  String getFormattedTitle(){
    return removeAccents(title);  
  } 

String removeAccents(String text) {
    return text == null ? null :
        Normalizer.normalize(text, Form.NFD)
            .replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
}
}