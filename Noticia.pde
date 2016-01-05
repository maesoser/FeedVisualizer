class Noticia{
  String source;
  String section;
  String title;
  String link;
  String description;
  String pubDate;
  String hash;
  String similarTitle;
  IntList distances;
  Date timedate;
  
  Noticia(String t, String l, String d, String p){
    title = t;
    link = l;
    description =d;
    pubDate = p;
    timedate = translatetime(pubDate);
    hash = createHash(title);
    distances = new IntList();
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
    if(title.toUpperCase().indexOf(text.toUpperCase())!=-1) return true;
    else return false;   
  }
  
    Boolean descriptionContains(String text){
    if(description.toUpperCase().indexOf(text.toUpperCase())!=-1) return true;
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
    return source+","+section+"\t\t\t"+reportDate+"\n\n"+description+"\nSimilar a :"+similarTitle+"\nMean distance: "+getMeanDistance();
  }
  
  int getDistance(String word){
    return minDistance(this.description,word);
  }
  
  int getMaxDistance(){
    return distances.max();
  }
  int getMinDistance(){
    return distances.min();
  }
  
  int getMeanDistance(){
    int overall = 0;
    for(int distance:distances){
      overall = overall + distance;
    }
    return overall/distances.size();
  }
  
  int getMeanDistanceNormalized(){
    int d = getMeanDistance();
    return (d/255)*10;
  }
  
  int minDistance(String word1, String word2) {
    int len1 = word1.length();
    int len2 = word2.length();
   
    // len1+1, len2+1, because finally return dp[len1][len2]
    int[][] dp = new int[len1 + 1][len2 + 1];
   
    for (int i = 0; i <= len1; i++) {
      dp[i][0] = i;
    }
   
    for (int j = 0; j <= len2; j++) {
      dp[0][j] = j;
    }
   
    //iterate though, and check last char
    for (int i = 0; i < len1; i++) {
      char c1 = word1.charAt(i);
      for (int j = 0; j < len2; j++) {
        char c2 = word2.charAt(j);
   
        //if last two chars equal
        if (c1 == c2) {
          //update dp value for +1 length
          dp[i + 1][j + 1] = dp[i][j];
        } else {
          int replace = dp[i][j] + 1;
          int insert = dp[i][j + 1] + 1;
          int delete = dp[i + 1][j] + 1;
   
          int min = replace > insert ? insert : replace;
          min = delete > min ? min : delete;
          dp[i + 1][j + 1] = min;
        }
      }
    }
   
    return dp[len1][len2];
  }
} 