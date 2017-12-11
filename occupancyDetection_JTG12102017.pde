/*
INSTITUTION:  Lewis University
COURSE NAME:  CPSC 53000-FA17 Data Visualization
SEMESTER:     Fall
DATE:         12/08/2017
GROUP:        5
STUDENT NAMES: Taylor Boss, John T Giles, Kyle Healy, Eric Schumacher
ASSIGNMENT:   PROJECT 4

Program Requirements (RQ):
    Requirement fulfillment is labelled in the code, for example,
    requirement 1 fulfillment is labelled RQ1.
    
    For this assignment, working in a group.  The same one as for 
    the previous group assignment. Use Processing to sketch  
    visualizations for multiple time series data. 
    More specifically:
    Find an interesting time series datasets online. For example, 
    get historical stock prices for different stocks or population data over 
    time for different regions. 
    The goal is to tell a story about these time series with a Processing 
    sketch visualization.

1.  Using the time series examples from the Ben Fry book, write a Processing 
    sketch which does the following:
    A.  Display the time series
    B.  Display a title describing the type of data being visualized
    C.  Display names of the different time series loaded 
        These could be tabs or a legend-like display on the side of the plot
    D.  Visualizes the time series.  The visualization should include 
        1.  Axis marks
        2.  Labels
        3.  Gridlines
2.  Additional required features:
    A.  Rollovers – upon getting close to a point on the plot, 
                    display the actual data of that point 
                    (like in the book example)
    B.  Ability to turn on/off gridlines by using:
        Button on the screen or by a keyboard button
    C.  Switching to a different time series to be visualized.
        This can be done through a tabbed interface or a legend.
3.  Additional optional features for extra credit (+2 points for each; 
    up to 6 points max):
    A.  Zoom: 
        Allow user to zoom in and out of the graph by changing the axis range. 
        Use of a scroll wheel on a mouse, whenever the mouse is inside the plotting region.
    B.  Visualize multiple time series: 
        Allow the user to select more than one time series to be visualized 
        Use different encodings for each (e.g. color). 
        Series not currently selected should still be plotted, 
        but be less visible (e.g. use lighter colors and lower weights for lines).
    C.  Scrolling: 
        Allow the user to scroll horizontally to see more of a time series.
    D.  Other features: 
        Add other features that can be considered for extra credit, 
        but these should be useful and non-trivial.

4.  Additional Requirements:
    A.  Follow design considerations presented in previous weeks
    B.  Visualize at least 3 different time series
    C.  Well documented code following standard programming guidelines: 
        proper use of whitespaces, appropriate variable names, etc.
    D.  Code should run without errors:
        ANY ERRORS THAT PREVENT EXECUTION WILL RESULTS IN ZERO POINTS!
*/    
OccupancyTable data;

//Use only one of these next 3 lines. changes input file.
//String file="datatest.txt";
//String file="datatest2.txt";
String file="datatraining.txt";

float[] dataMin, dataMax;
Date dateMin, dateMax;
Date[] dates;
float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

PFont plotFont;

//Used to create tabs in the visualization
float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

// REFINE AND INTERACT VARIABLES
int currentColumn = 1;
int columnCount;
int rowCount = 0;

int xInterval = 200000;
float[] yInterval = {0,1,5,250,500,0.001,1};
String[] columnAxisLabels = {"Date","Degrees\nCelsius","Relative\nHumidity %","Light\n(in Lux)","Co2\n(in ppm)","Humidity\nRatio","Occupied (1)\nNot (0)"};
int HUMIDITY=5;

int toggleLine = 0;

//Data Point Descrition variables
//float value;
//float radius;
float closestDist;
String closestText; 
float closestTextX; 
float closestTextY;

Integrator[] interpolators;

void setup(){
   size(1200, 810);
   
  // Corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
   
   data = new OccupancyTable(file);
   columnCount = data.getColumnCount();
   rowCount = data.getRowCount();
   
   // DATES : Load the dates up
   dates = new Date[rowCount];
   for(int i=0; i<rowCount;i++){
     dates[i]=new Date(data.get(i,0));
   }
   //Find max and min dates
   findMinAndMaxDate();
   
   //find max and min for occupancy table
   dataMin = data.getColMins();
   dataMax = data.getColMaxes();
   
   plotFont = createFont("SansSerif", 20);
   textFont(plotFont);
   
   //  INTERPOLATION
   interpolators = new Integrator[rowCount];
   
   for (int row = 0; row < rowCount; row++) {
     float initialTempValue = data.getFloat(row, 1);
     interpolators[row] = new Integrator(initialTempValue);
     interpolators[row].attraction = 0.1; // Set lower than the default
   }
   
   smooth();  
}

void draw(){
  background(224);
  rowCount = data.getRowCount();
  // Show the plot area as a white box. 
  fill(255);

  closestDist = MAX_FLOAT;

  rectMode(CORNERS);
  noStroke( );
  rect(plotX1, plotY1, plotX2, plotY2);
  fill(#5679C1);
  
  strokeWeight(2);
  stroke(#5679C1);
  
  drawAxisLabels();
  
  noFill();
  drawDataPoints(currentColumn);  //RQ1A
  
  drawXLabels();
  drawYLabels(currentColumn);
  
  for (int row = 0; row < rowCount; row++) { 
    interpolators[row].update( );
  }
  
  // Use global variables set in drawpoints( ) 
  // to draw text related to closest circle. 
  if (closestDist != MAX_FLOAT) { 
    fill(0); textAlign(CENTER); 
    text(closestText, closestTextX, closestTextY);
  }
  
  noStroke();
  fill(#5679C1);
//   drawDataBars(currentColumn);
  drawTitleTabs();

  noFill(); 
  strokeWeight(2); 
  drawDataLine(currentColumn); 
  drawDataHighlight(currentColumn);
}

//Processes the dates once.
// Finds the Min and Max Date
void findMinAndMaxDate(){
  //Set the min and max date to the first date
  dateMin=dates[0];
  dateMax=dates[0];
  
  //Loop through all the dates and compare the date to the min and max date. 
  //If it's smaller than dateMin, replace dateMin with the new one
  //If it's bigger than dateMax, replace the dateMax with the new one
  for(int i=1; i<dates.length;i++){
    //Compare minimum
    if(dateMin.isBiggerThan(dates[i])){
      dateMin=dates[i];
    }
    //Compare max
    if(dates[i].isBiggerThan(dateMax)){
      dateMax=dates[i];
    }
  }
  //println("Max date: " + dateMax.getDateTimeAsFloat());
  //println("Min date: " + dateMin.getDateTimeAsFloat());
}


// Draw the data as a series of points.
void drawDataPoints(int col) {
  rowCount = data.getRowCount();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      value = data.getFloat(row, col);
      float x = map(dates[row].getDateTimeAsFloat(), dateMin.getDateTimeAsFloat(), dateMax.getDateTimeAsFloat(), plotX1, plotX2);
      float y = map(value, dataMin[col], dataMax[col], plotY2, plotY1);
      point(x, y);
    }
  }
}

//Draws the labels for a specific column
void drawYLabels(int col){
  fill(0);
  textSize(10);
  textAlign(RIGHT, CENTER);
  for (float v = dataMin[col]; v <= dataMax[col]; v += yInterval[col]) {
    float y = map(v, dataMin[col], dataMax[col], plotY2, plotY1);
    if(col==HUMIDITY){
      text(v, plotX1 - 10, y);
    } else {
      text(floor(v), plotX1 - 10, y);
    }
  }
}

//Draws the X column labels
void drawXLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);

  // Use thin, gray lines to draw the grid.
  stroke(224);
  strokeWeight(1);


  for (int row = 0; row < rowCount; row++) {
    if (dates[row].getDateTimeAsFloat() % xInterval == 0) {
      float x = map(dates[row].getDateTimeAsFloat(), dateMin.getDateTimeAsFloat(), dateMax.getDateTimeAsFloat(), plotX1, plotX2);
      text(dates[row].getDate(), x, plotY2 + 10);
      line(x, plotY1, x, plotY2);
    }
  }
}

//Press the [ and ] keys to rotate through the tabs
void keyPressed() { 
  if (key == '[') {
    currentColumn--;
    if (currentColumn < 1) {
      currentColumn = columnCount - 1;
    }
  } else if (key == ']') {
    currentColumn++;
    if (currentColumn == columnCount) {
      currentColumn = 1;
    }
  }
}


//Adjusts the image based on the location of the mouse click
void mousePressed() {
  if (toggleLine == 0) toggleLine = 1;
  else toggleLine = 0;

  if (mouseY > tabTop && mouseY < tabBottom) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]) {
        setColumn(col);
      }
    }
  }
}


//Updates the visualization based on the column.
// Used for smooth transitions between tabs
void setColumn(int col) {
   if (col != currentColumn) {
     currentColumn = col;
   }
   
  for (int row = 0; row < rowCount; row++) {
      interpolators[row].target(data.getFloat(row, col));
   } 
}

//Draws the axis labels
void drawAxisLabels() { 
  fill(0);
  textSize(13);
  textLeading(15);
  textAlign(CENTER, CENTER);
  // Use \n (aka enter or linefeed) to break the text into separate lines.
  
  text(columnAxisLabels[currentColumn], labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Time", (plotX1+plotX2)/2, labelY);
}

//Draws the title tabs
void drawTitleTabs() { 
  rectMode(CORNERS); 
  noStroke( ); 
  textSize(20); 
  textAlign(LEFT);
  // On first use of this method, allocate space for an array
  // to store the values for the left and right edges of the tabs.
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15; 
  tabBottom = plotY1;
  for (int col = 1; col < columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    // If the current tab, set its background white; otherwise use pale gray.
    fill(col == currentColumn ? 255 : 224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    // If the current tab, use black for the text; otherwise use dark gray.
    fill(col == currentColumn ? 0 : 64);
    text(title, runningX + tabPad, plotY1 - 10);
    runningX = tabRight[col];
  }
}

void drawDataLine(int col) { 
  beginShape(); 
  int rowCount = data.getRowCount(); 
  for (int row = 0; row < rowCount; row ++) { 
    if (data.isValid(row, col)) { 
      float value = data.getFloat(row, col); 
      float x = map(dates[row].getDateTimeAsFloat(), dateMin.getDateTimeAsFloat(), dateMax.getDateTimeAsFloat(), plotX1, plotX2);
      float y = map(value, dataMin[col], dataMax[col], plotY2, plotY1);
      vertex(x, y); 
    } 
  } 
endShape( ); 
}

void drawDataHighlight(int col) { 
  for (int row = 0; row < rowCount; row ++) { 
    if (data.isValid(row, col)) { 
      float value = data.getFloat(row, col); 
      float x = map(dates[row].getDateTimeAsFloat(), dateMin.getDateTimeAsFloat(), dateMax.getDateTimeAsFloat(), plotX1, plotX2);
      float y = map(value, dataMin[col], dataMax[col], plotY2, plotY1);
      if (dist(mouseX, mouseY, x, y) < 3) { 
        strokeWeight(10); point(x, y); 
        fill(0); 
        textSize(18); 
        textAlign(CENTER); 
        text(nf(value, 0, 2) + " (" + dates[row].getDateTimeAsFloat() + ")", x, y-8);
      } 
    } 
  } 
}
