import java.util.HashMap;
import java.awt.Color;

Float [][] coords;
String [] labels;
PFont arial;
HashMap config;

void setup() {
  
  config = loadConfig("config.yml");
  
  size(Integer.parseInt((String)config.get("width")),Integer.parseInt((String)config.get("height")));
  Color bg_color = Color.decode((String)config.get("background-color"));
  background(bg_color.getRed(),bg_color.getGreen(),bg_color.getBlue());
  arial = loadFont("Arial-BoldMT-72.vlw");
  noLoop();
  
  String [][] csv = loadCSV("input.csv");
  Float [] tops = new Float [csv.length-1];
  Float [] sums = new Float [csv.length-1];
  Float [] mults = new Float [csv.length-1];
  Float multiplier = 0.0;
  
  //create the array multipliers for rows
  for (int i=1; i < csv.length; i++) {
    tops[i-1] = float(csv[i][1]);
    if (tops[i-1] > multiplier) {
      multiplier = tops[i-1];
    }
    sums[i-1] = 0.0;
    for (int j=2; j < csv[1].length; j++) {
      sums[i-1] += float(csv[i][j]);
    }
  }
  multiplier = (height*0.95) / multiplier;
  for (int i=0; i < tops.length; i++) {
    mults[i] = tops[i] * multiplier / sums[i];
  }
  
  //create arrays of coordinates and labels
  coords = new Float [csv.length-1][csv[1].length-2];
  labels = new String [csv[1].length - 1];
  for (int i=1; i < csv.length; i++) {
    for (int j=2; j < csv[i].length; j++) {
      labels[j-2] = csv[0][j];
      coords[i-1][j-2] = (float(csv[i][j]) * mults[i-1]) + (j > 2 ? coords[i-1][j-3] : 0.0);
    }
  }

}

void draw() {
  
  Float xinc = float(width) / float(coords.length-1);
  Integer labelPos;
  Float textPos;
  Color temp_color;
  color colors [] = new color [7];
  for (int i=0; i < 7; i++) {
    temp_color = Color.decode((String)config.get("color-"+Integer.toString(i+1)));
    colors[i] = color(temp_color.getRed(), temp_color.getGreen(), temp_color.getBlue());
  }
  textFont(arial,Integer.parseInt((String)config.get("font-size")));
  textAlign(CENTER);

  for (int i=0; i < coords[0].length; i++) {
    labelPos = 1;
    noStroke();
    fill(colors[i%8]);
    beginShape();
    curveVertex(0, height-coords[0][i]);
    //draw the top boundary of the row
    for (int j=0; j < coords.length; j++) {
      curveVertex(xinc*j, height-coords[j][i]);
      //find the widest gap to place the label there
      if (j > 0 && j < coords.length - 1) {
        if (coords[j][i] - (i > 0 ? coords[j][i-1] : 0) > coords[labelPos][i] - (i > 0 ? coords[labelPos][i-1] : 0)) {
          labelPos = j;
        }
      }
    }
    //draw the sides and bottom boundary
    curveVertex(width, height-coords[coords.length-1][i]);
    if (i > 0) {
      curveVertex(width,height-coords[coords.length-1][i-1]);
      for (int j=coords.length-1; j >= 0; j--) {
        curveVertex(xinc*j, height-coords[j][i-1]);
      }
      curveVertex(0, height-coords[0][i-1]);
    }
    else {
      curveVertex(width, height-coords[coords.length-1][i]);
      vertex(width,height);
      vertex(0,height);
    }
    vertex(0, height-coords[0][i]);
    endShape();
    //draw the label
    fill(#FFFFFF);
    textPos = height - (i > 0 ? coords[labelPos][i-1] : 0) - (coords[labelPos][i] - (i > 0 ? coords[labelPos][i-1] : 0))/2 + 9;
    text(labels[i],xinc*labelPos,textPos);
  }
  
  save("output.png");
  exit();

}

//function to import a csv into an array
String [][] loadCSV (String file) {
   
  //load csv
  String lines[] = loadStrings(file);
  String [][] csv;
  int csvWidth=0;
  
  //calculate max width of csv file
  for (int i=0; i < lines.length; i++) {
    String [] chars=split(lines[i],',');
    if (chars.length>csvWidth){
      csvWidth=chars.length;
    }
  }
  
  //create csv array based on # of rows and columns in csv file
  csv = new String [lines.length][csvWidth];
  
  //parse values into 2d array
  for (int i=0; i < lines.length; i++) {
    String [] temp = new String [lines.length];
    temp= split(lines[i], ',');
    for (int j=0; j < temp.length; j++){
      String field = temp[j];
      if (field.length() > 0 && field.substring(0,1).equals("\"")) {
        field = field.substring(1);
      }
      if (field.length() > 0 && field.substring(field.length()-1).equals("\"")) {
        field = field.substring(0,field.length()-1);
      }
      csv[i][j]=field;
    }
  }
  
  return csv;
  
} 

//loads a 1D config yml file into a hash
HashMap loadConfig (String file) {
  
  HashMap config = new HashMap();
  
  String lines [] = loadStrings(file);
  for (int i=0; i < lines.length; i++) {
    String [] parts = trim(split(lines[i],':'));
    if (parts.length > 1) {
      String field = new String(parts[1]);
      if (field.length() > 0 && field.substring(0,1).equals("\"")) {
        field = field.substring(1);
      }
      if (field.length() > 0 && field.substring(field.length()-1).equals("\"")) {
        field = field.substring(0,field.length()-1);
      }
      config.put(parts[0],field);
    }
  }
  
  return config;
  
}
